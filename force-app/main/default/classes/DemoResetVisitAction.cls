/**
 * @description Apex Action to reset all AI-generated fields on Visit record for demo purposes
 * @author Claude AI
 * @date 2026-07-09
 */
public with sharing class DemoResetVisitAction {

    /**
     * @description Invocable method to clear all evidence, ranking, hours, exception, and justification fields
     * @param requests List of input parameters containing Visit IDs
     * @return List of result messages
     */
    @InvocableMethod(
        label='Demo Reset Visit Fields'
        description='Clears all AI-generated evidence, rankings, hours, exceptions, and justifications for demo reset'
        category='Visit'
    )
    public static List<Result> resetVisitFields(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request request : requests) {
            Result result = new Result();

            try {
                // Query the Visit record with all fields we need to clear (preserving Visit_Notes_Dictation__c)
                Visit visitRecord = [
                    SELECT Id,
                           Meal_Preparation_Evidence__c,
                           Ambulation_Evidence__c,
                           Domestic_Services_Evidence__c,
                           Orientation_Evidence__c,
                           Meal_Preparation_Proposed_Ranking__c,
                           Ambulation_Proposed_Ranking__c,
                           Domestic_Services_Proposed_Ranking__c,
                           Orientation_Proposed_Ranking__c,
                           Meal_Preparation_Proposed_Hours__c,
                           Ambulation_Proposed_Hours__c,
                           Domestic_Services_Proposed_Hours__c,
                           Meal_Preparation_Is_Exception__c,
                           Ambulation_Is_Exception__c,
                           Domestic_Services_Is_Exception__c,
                           Meal_Preparation_Justification__c,
                           Ambulation_Justification__c,
                           Domestic_Services_Justification__c,
                           Meal_Preparation_Approved_Ranking__c,
                           Ambulation_Approved_Ranking__c,
                           Domestic_Services_Approved_Ranking__c,
                           Orientation_Approved_Ranking__c,
                           Draft_Narrative__c,
                           Final_Narrative__c,
                           Household_Visit_Status__c,
                           Narrative_Status__c,
                           Report_Status__c,
                           Overall_Risk_Level__c,
                           Highest_Need_Category__c,
                           Submitted_For_Review_Date__c,
                           Worker_Approval_Date__c
                    FROM Visit
                    WHERE Id = :request.visitId
                    LIMIT 1
                ];

                // Clear all evidence fields
                visitRecord.Meal_Preparation_Evidence__c = null;
                visitRecord.Ambulation_Evidence__c = null;
                visitRecord.Domestic_Services_Evidence__c = null;
                visitRecord.Orientation_Evidence__c = null;

                // Clear all proposed ranking fields
                visitRecord.Meal_Preparation_Proposed_Ranking__c = null;
                visitRecord.Ambulation_Proposed_Ranking__c = null;
                visitRecord.Domestic_Services_Proposed_Ranking__c = null;
                visitRecord.Orientation_Proposed_Ranking__c = null;

                // Clear all approved ranking fields
                visitRecord.Meal_Preparation_Approved_Ranking__c = null;
                visitRecord.Ambulation_Approved_Ranking__c = null;
                visitRecord.Domestic_Services_Approved_Ranking__c = null;
                visitRecord.Orientation_Approved_Ranking__c = null;

                // Clear all hours fields
                visitRecord.Meal_Preparation_Proposed_Hours__c = null;
                visitRecord.Ambulation_Proposed_Hours__c = null;
                visitRecord.Domestic_Services_Proposed_Hours__c = null;

                // Clear all exception flags (checkboxes must be false, not null)
                visitRecord.Meal_Preparation_Is_Exception__c = false;
                visitRecord.Ambulation_Is_Exception__c = false;
                visitRecord.Domestic_Services_Is_Exception__c = false;

                // Clear all justification fields
                visitRecord.Meal_Preparation_Justification__c = null;
                visitRecord.Ambulation_Justification__c = null;
                visitRecord.Domestic_Services_Justification__c = null;

                // Clear narrative fields
                visitRecord.Draft_Narrative__c = null;
                visitRecord.Final_Narrative__c = null;

                // Clear risk and category fields
                visitRecord.Overall_Risk_Level__c = null;
                visitRecord.Highest_Need_Category__c = null;

                // Clear status fields and reset Household Visit Status to Scheduled
                visitRecord.Household_Visit_Status__c = 'Scheduled';
                visitRecord.Narrative_Status__c = null;
                visitRecord.Report_Status__c = null;

                // Clear date stamps
                visitRecord.Submitted_For_Review_Date__c = null;
                visitRecord.Worker_Approval_Date__c = null;

                // Update the record
                update visitRecord;

                result.success = true;
                result.message = 'All AI-generated fields cleared successfully. Visit is ready for demo.';

            } catch (Exception e) {
                result.success = false;
                result.message = 'Error: ' + e.getMessage();
            }

            results.add(result);
        }

        return results;
    }

    /**
     * Inner class for input parameters
     */
    public class Request {
        @InvocableVariable(required=true label='Visit Record ID' description='The ID of the Visit record to reset')
        public Id visitId;
    }

    /**
     * Inner class for output results
     */
    public class Result {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean success;

        @InvocableVariable(label='Message' description='Result message or error details')
        public String message;
    }
}
