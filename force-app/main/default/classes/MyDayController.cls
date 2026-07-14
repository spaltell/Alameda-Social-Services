/**
 * @description Apex controller for My Day Component LWC
 * @author Claude AI
 * @date 2026-07-13
 */
public with sharing class MyDayController {

    /**
     * @description Get today's scheduled visits for the current user
     * @param userId The current user's ID
     * @return List of VisitSummary records for today
     */
    @AuraEnabled(cacheable=true)
    public static List<VisitSummary> getTodaysVisits(Id userId) {
        List<VisitSummary> result = new List<VisitSummary>();

        try {
            // Query visits assigned to the current user that are scheduled for today
            List<Visit> visits = [
                SELECT Id, Name, Status, Household_Visit_Status__c,
                       AccountId, Account.Name, Account.BillingStreet,
                       Account.BillingCity, Account.BillingState,
                       Account.BillingPostalCode,
                       PlannedVisitStartTime, CreatedDate
                FROM Visit
                WHERE VisitorId = :userId
                  AND Status = 'Planned'
                  AND Household_Visit_Status__c IN ('Scheduled', 'Visit In Progress', 'Documentation Pending')
                  AND DAY_ONLY(PlannedVisitStartTime) = TODAY
                ORDER BY PlannedVisitStartTime ASC NULLS LAST, CreatedDate ASC
            ];

            for (Visit v : visits) {
                VisitSummary summary = new VisitSummary();
                summary.id = v.Id;
                summary.visitName = v.Name;
                summary.householdName = v.Account.Name;
                summary.accountId = v.AccountId;
                summary.householdVisitStatus = v.Household_Visit_Status__c;

                // Build address from Account billing address
                summary.address = buildAddress(
                    v.Account.BillingStreet,
                    v.Account.BillingCity,
                    v.Account.BillingState,
                    v.Account.BillingPostalCode
                );

                summary.scheduledDate = v.PlannedVisitStartTime;

                result.add(summary);
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving today\'s visits: ' + e.getMessage());
        }

        return result;
    }

    /**
     * @description Helper method to build formatted address string
     * @param street Street address
     * @param city City
     * @param state State
     * @param postalCode Postal code
     * @return Formatted address string or null if all fields are blank
     */
    private static String buildAddress(String street, String city, String state, String postalCode) {
        List<String> parts = new List<String>();

        if (String.isNotBlank(street)) {
            parts.add(street);
        }

        List<String> cityStateParts = new List<String>();
        if (String.isNotBlank(city)) {
            cityStateParts.add(city);
        }
        if (String.isNotBlank(state)) {
            cityStateParts.add(state);
        }

        if (!cityStateParts.isEmpty()) {
            parts.add(String.join(cityStateParts, ', '));
        }

        if (String.isNotBlank(postalCode)) {
            parts.add(postalCode);
        }

        return parts.isEmpty() ? null : String.join(parts, ' ');
    }

    /**
     * Wrapper class for visit summary
     */
    public class VisitSummary {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String visitName { get; set; }
        @AuraEnabled public String householdName { get; set; }
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String householdVisitStatus { get; set; }
        @AuraEnabled public String address { get; set; }
        @AuraEnabled public DateTime scheduledDate { get; set; }
    }
}
