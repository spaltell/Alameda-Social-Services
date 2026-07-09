/**
 * @description Apex Action to generate Visit rankings, hours, and justifications from evidence fields
 * @author Claude AI
 * @date 2026-07-09
 */
public with sharing class GenerateVisitRankingsAction {

    /**
     * @description Invocable method to analyze evidence and generate rankings
     * @param requests List of input parameters containing Visit IDs
     * @return List of result messages
     */
    @InvocableMethod(
        label='Generate Visit Rankings and Justifications'
        description='Analyzes evidence fields and assigns rankings, hours, exceptions, and justifications'
        category='Visit'
    )
    public static List<Result> generateRankings(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request request : requests) {
            Result result = new Result();

            try {
                // Step 1: Query the Visit record
                Visit visitRecord = queryVisitRecord(request.visitId);

                // Step 2: Validate evidence exists
                if (!hasEvidence(visitRecord)) {
                    result.success = false;
                    result.message = 'No evidence fields populated. Please run "Save Notes" first.';
                    results.add(result);
                    continue;
                }

                // Step 3: Call the Prompt Template
                String promptResponse = callPromptTemplate(visitRecord);

                // Step 4: Parse the JSON response
                AssessmentResult assessment = parsePromptResponse(promptResponse);

                // Step 5: Update the Visit record with parsed data
                updateVisitRecord(visitRecord, assessment);

                // Step 6: Apply hard-coded exception safety net
                visitRecord = applyHardCodedExceptionSafetyNet(visitRecord);

                // Step 7: Save to database
                update visitRecord;

                // Step 7: Build success result
                result.success = true;
                result.message = 'Rankings and justifications generated successfully.';
                result.exceptionsDetected = buildExceptionSummary(assessment);

            } catch (Exception e) {
                result.success = false;
                result.message = 'Error: ' + e.getMessage();
                result.exceptionsDetected = '';
            }

            results.add(result);
        }

        return results;
    }

    /**
     * @description Query Visit record with evidence and ranking fields
     * @param visitId The ID of the Visit record
     * @return Visit record with all necessary fields
     */
    private static Visit queryVisitRecord(Id visitId) {
        return [
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
                   Domestic_Services_Justification__c
            FROM Visit
            WHERE Id = :visitId
            LIMIT 1
        ];
    }

    /**
     * @description Check if Visit has any evidence populated
     * @param visitRecord The Visit record
     * @return True if at least one evidence field has content
     */
    private static Boolean hasEvidence(Visit visitRecord) {
        return String.isNotBlank(visitRecord.Meal_Preparation_Evidence__c)
            || String.isNotBlank(visitRecord.Ambulation_Evidence__c)
            || String.isNotBlank(visitRecord.Domestic_Services_Evidence__c)
            || String.isNotBlank(visitRecord.Orientation_Evidence__c);
    }

    /**
     * @description Call the Prompt Template via ConnectApi
     * @param visitRecord The Visit record with evidence fields
     * @return The AI-generated response as JSON string
     */
    private static String callPromptTemplate(Visit visitRecord) {
        // Build input parameter map
        Map<String, ConnectApi.WrappedValue> inputParams =
            new Map<String, ConnectApi.WrappedValue>();

        // Wrap each evidence field
        inputParams.put('Input:mealPrepEvidence', wrapValue(
            String.isNotBlank(visitRecord.Meal_Preparation_Evidence__c)
                ? visitRecord.Meal_Preparation_Evidence__c
                : 'No evidence provided'
        ));
        inputParams.put('Input:ambulationEvidence', wrapValue(
            String.isNotBlank(visitRecord.Ambulation_Evidence__c)
                ? visitRecord.Ambulation_Evidence__c
                : 'No evidence provided'
        ));
        inputParams.put('Input:domesticServicesEvidence', wrapValue(
            String.isNotBlank(visitRecord.Domestic_Services_Evidence__c)
                ? visitRecord.Domestic_Services_Evidence__c
                : 'No evidence provided'
        ));
        inputParams.put('Input:orientationEvidence', wrapValue(
            String.isNotBlank(visitRecord.Orientation_Evidence__c)
                ? visitRecord.Orientation_Evidence__c
                : 'No evidence provided'
        ));
        inputParams.put('Input:visitId', wrapValue(visitRecord.Id));

        // Create input object
        ConnectApi.EinsteinPromptTemplateGenerationsInput input =
            new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.inputParams = inputParams;
        input.isPreview = false;

        // CRITICAL: Required for Prompt Template API access
        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

        // Call the prompt template
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response =
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                'Generate_Visit_Rankings_and_Justifications',
                input
            );

        // Extract the generated text
        if (response != null &&
            response.generations != null &&
            !response.generations.isEmpty()) {
            return response.generations[0].text;
        }

        throw new AuraHandledException('No response received from Prompt Template.');
    }

    /**
     * @description Helper method to wrap a string value for ConnectApi
     * @param value The string value to wrap
     * @return Wrapped value
     */
    private static ConnectApi.WrappedValue wrapValue(String value) {
        ConnectApi.WrappedValue wrapped = new ConnectApi.WrappedValue();
        wrapped.value = value;
        return wrapped;
    }

    /**
     * @description Parse the JSON response from the prompt template
     * @param promptResponse The raw response from the AI
     * @return Parsed assessment result
     */
    private static AssessmentResult parsePromptResponse(String promptResponse) {
        try {
            // Remove any markdown code fences if present
            String cleanedResponse = promptResponse.trim();
            if (cleanedResponse.startsWith('```json')) {
                cleanedResponse = cleanedResponse.substring(7);
            }
            if (cleanedResponse.startsWith('```')) {
                cleanedResponse = cleanedResponse.substring(3);
            }
            if (cleanedResponse.endsWith('```')) {
                cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length() - 3);
            }
            cleanedResponse = cleanedResponse.trim();

            // Deserialize directly into typed wrapper
            AssessmentResult parsedData = (AssessmentResult) JSON.deserialize(
                cleanedResponse,
                AssessmentResult.class
            );
            return parsedData;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to parse AI response: ' + e.getMessage());
        }
    }

    /**
     * @description Apply hard-coded exception safety net to ensure exception flags are set correctly
     * @param visitRecord The Visit record to validate
     * @return Visit record with corrected exception flags
     */
    private static Visit applyHardCodedExceptionSafetyNet(Visit visitRecord) {
        // 1. Meal Preparation Math Check (Weekly)
        if (visitRecord.Meal_Preparation_Proposed_Hours__c != null) {
            Decimal mealHours = visitRecord.Meal_Preparation_Proposed_Hours__c;
            if (mealHours < 3.01 || mealHours > 7.00) {
                visitRecord.Meal_Preparation_Is_Exception__c = true;
            }
        }

        // 2. Ambulation Math Check (Weekly)
        if (visitRecord.Ambulation_Proposed_Hours__c != null) {
            Decimal ambHours = visitRecord.Ambulation_Proposed_Hours__c;
            if (ambHours < 1.00 || ambHours > 2.10) {
                visitRecord.Ambulation_Is_Exception__c = true;
            }
        }

        // 3. Domestic Services Math Check (Monthly)
        if (visitRecord.Domestic_Services_Proposed_Hours__c != null) {
            Decimal domHours = visitRecord.Domestic_Services_Proposed_Hours__c;
            if (domHours > 6.00) {
                visitRecord.Domestic_Services_Is_Exception__c = true;
            }
        }

        return visitRecord;
    }

    /**
     * @description Update Visit record with assessment data
     * @param visitRecord The Visit record to update
     * @param assessment The parsed assessment data
     */
    private static void updateVisitRecord(Visit visitRecord, AssessmentResult assessment) {
        // Rankings
        visitRecord.Meal_Preparation_Proposed_Ranking__c = assessment.Meal_Preparation_Proposed_Ranking;
        visitRecord.Ambulation_Proposed_Ranking__c = assessment.Ambulation_Proposed_Ranking;
        visitRecord.Domestic_Services_Proposed_Ranking__c = assessment.Domestic_Services_Proposed_Ranking;
        visitRecord.Orientation_Proposed_Ranking__c = assessment.Orientation_Proposed_Ranking;

        // Hours (Orientation has no hours field)
        visitRecord.Meal_Preparation_Proposed_Hours__c = assessment.Meal_Preparation_Proposed_Hours;
        visitRecord.Ambulation_Proposed_Hours__c = assessment.Ambulation_Proposed_Hours;
        visitRecord.Domestic_Services_Proposed_Hours__c = assessment.Domestic_Services_Proposed_Hours;

        // Exception flags
        visitRecord.Meal_Preparation_Is_Exception__c = assessment.Meal_Preparation_Is_Exception;
        visitRecord.Ambulation_Is_Exception__c = assessment.Ambulation_Is_Exception;
        visitRecord.Domestic_Services_Is_Exception__c = assessment.Domestic_Services_Is_Exception;

        // Justifications
        visitRecord.Meal_Preparation_Justification__c = assessment.Meal_Preparation_Justification;
        visitRecord.Ambulation_Justification__c = assessment.Ambulation_Justification;
        visitRecord.Domestic_Services_Justification__c = assessment.Domestic_Services_Justification;
    }

    /**
     * @description Build exception summary message
     * @param assessment The parsed assessment data
     * @return Summary of which categories have exceptions
     */
    private static String buildExceptionSummary(AssessmentResult assessment) {
        List<String> exceptions = new List<String>();

        if (assessment.Meal_Preparation_Is_Exception == true) {
            exceptions.add('Meal Preparation');
        }
        if (assessment.Ambulation_Is_Exception == true) {
            exceptions.add('Ambulation');
        }
        if (assessment.Domestic_Services_Is_Exception == true) {
            exceptions.add('Domestic Services');
        }

        if (exceptions.isEmpty()) {
            return 'None';
        } else {
            return String.join(exceptions, ', ');
        }
    }

    /**
     * Wrapper class matching the prompt template's JSON structure
     * Note: Property names must match JSON keys exactly (with double underscores)
     */
    public class AssessmentResult {
        public String Meal_Preparation_Proposed_Ranking { get; set; }
        public Decimal Meal_Preparation_Proposed_Hours { get; set; }
        public Boolean Meal_Preparation_Is_Exception { get; set; }
        public String Meal_Preparation_Justification { get; set; }

        public String Ambulation_Proposed_Ranking { get; set; }
        public Decimal Ambulation_Proposed_Hours { get; set; }
        public Boolean Ambulation_Is_Exception { get; set; }
        public String Ambulation_Justification { get; set; }

        public String Domestic_Services_Proposed_Ranking { get; set; }
        public Decimal Domestic_Services_Proposed_Hours { get; set; }
        public Boolean Domestic_Services_Is_Exception { get; set; }
        public String Domestic_Services_Justification { get; set; }

        public String Orientation_Proposed_Ranking { get; set; }
    }

    /**
     * Inner class for input parameters
     */
    public class Request {
        @InvocableVariable(required=true label='Visit Record ID' description='The ID of the Visit record to analyze')
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

        @InvocableVariable(label='Exceptions Detected' description='Summary of categories with exceptions')
        public String exceptionsDetected;
    }
}
