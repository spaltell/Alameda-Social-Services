/**
 * @description Apex controller for Household Profile Card LWC
 * @author Claude AI
 * @date 2026-07-13
 */
public with sharing class HouseholdProfileController {

    /**
     * @description Get visit history and summary for a household
     * @param accountId The Account ID (Person Account)
     * @return HouseholdProfileData wrapper with visit history and alerts
     */
    @AuraEnabled(cacheable=true)
    public static HouseholdProfileData getVisitHistory(Id accountId) {
        HouseholdProfileData result = new HouseholdProfileData();

        try {
            // Query recent visits for this account
            List<Visit> visits = [
                SELECT Id, Name, Status, Household_Visit_Status__c,
                       CreatedDate, Worker_Approval_Date__c,
                       Overall_Risk_Level__c, Highest_Need_Category__c,
                       Meal_Preparation_Approved_Ranking__c,
                       Ambulation_Approved_Ranking__c,
                       Domestic_Services_Approved_Ranking__c,
                       Orientation_Approved_Ranking__c,
                       Meal_Preparation_Proposed_Hours__c,
                       Ambulation_Proposed_Hours__c,
                       Domestic_Services_Proposed_Hours__c,
                       Meal_Preparation_Is_Exception__c,
                       Ambulation_Is_Exception__c,
                       Domestic_Services_Is_Exception__c
                FROM Visit
                WHERE AccountId = :accountId
                ORDER BY CreatedDate DESC
                LIMIT 10
            ];

            result.recentVisits = new List<VisitSummary>();

            for (Visit v : visits) {
                VisitSummary summary = new VisitSummary();
                summary.id = v.Id;
                summary.name = v.Name;
                summary.householdVisitStatus = v.Household_Visit_Status__c;
                summary.completedDate = v.Worker_Approval_Date__c != null
                    ? v.Worker_Approval_Date__c
                    : v.CreatedDate;
                summary.riskLevel = v.Overall_Risk_Level__c;
                summary.highestNeedCategory = v.Highest_Need_Category__c;

                // Get hours from proposed (if approved not available yet)
                summary.mealPrepHours = v.Meal_Preparation_Proposed_Hours__c;
                summary.ambulationHours = v.Ambulation_Proposed_Hours__c;
                summary.domesticServicesHours = v.Domestic_Services_Proposed_Hours__c;

                result.recentVisits.add(summary);
            }

            // Calculate days since last visit
            if (!visits.isEmpty()) {
                Visit mostRecent = visits[0];
                Date lastVisitDate = mostRecent.Worker_Approval_Date__c != null
                    ? Date.valueOf(mostRecent.Worker_Approval_Date__c)
                    : Date.valueOf(mostRecent.CreatedDate);
                Integer daysSince = Date.today().daysBetween(lastVisitDate);
                result.daysSinceLastVisit = Math.abs(daysSince);
                result.isOverdue = result.daysSinceLastVisit > 90;
            } else {
                result.daysSinceLastVisit = null;
                result.isOverdue = false;
            }

            // Check for pending exceptions
            result.hasPendingExceptions = false;
            for (Visit v : visits) {
                if (v.Household_Visit_Status__c == 'Under Review' &&
                    (v.Meal_Preparation_Is_Exception__c == true ||
                     v.Ambulation_Is_Exception__c == true ||
                     v.Domestic_Services_Is_Exception__c == true)) {
                    result.hasPendingExceptions = true;
                    break;
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving visit history: ' + e.getMessage());
        }

        return result;
    }

    /**
     * Wrapper class for household profile data
     */
    public class HouseholdProfileData {
        @AuraEnabled public List<VisitSummary> recentVisits { get; set; }
        @AuraEnabled public Integer daysSinceLastVisit { get; set; }
        @AuraEnabled public Boolean isOverdue { get; set; }
        @AuraEnabled public Boolean hasPendingExceptions { get; set; }
    }

    /**
     * Wrapper class for visit summary
     */
    public class VisitSummary {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String householdVisitStatus { get; set; }
        @AuraEnabled public DateTime completedDate { get; set; }
        @AuraEnabled public String riskLevel { get; set; }
        @AuraEnabled public String highestNeedCategory { get; set; }
        @AuraEnabled public Decimal mealPrepHours { get; set; }
        @AuraEnabled public Decimal ambulationHours { get; set; }
        @AuraEnabled public Decimal domesticServicesHours { get; set; }
    }
}
