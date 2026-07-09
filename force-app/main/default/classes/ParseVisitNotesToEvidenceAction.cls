/**
 * @description Apex Action to parse Visit Notes Dictation into Evidence fields
 * @author Claude AI
 * @date 2026-07-06
 */
public with sharing class ParseVisitNotesToEvidenceAction {

    /**
     * @description Invocable method to process Visit notes and update evidence fields
     * @param requests List of input parameters containing Visit IDs
     * @return List of result messages
     */
    @InvocableMethod(
        label='Parse Visit Notes to Evidence'
        description='Extracts IHSS evidence from Visit Notes Dictation using AI and updates evidence fields'
        category='Visit'
    )
    public static List<Result> parseVisitNotes(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request request : requests) {
            Result result = new Result();

            try {
                // Step 1: Query the Visit record
                Visit visitRecord = queryVisitRecord(request.visitId);

                if (String.isBlank(visitRecord.Visit_Notes_Dictation__c)) {
                    result.success = false;
                    result.message = 'Visit Notes Dictation field is empty.';
                    results.add(result);
                    continue;
                }

                // Step 2: Call the Flex Prompt Template
                String promptResponse = callPromptTemplate(visitRecord.Visit_Notes_Dictation__c);

                // Step 3: Parse the JSON response
                Map<String, String> extractedEvidence = parsePromptResponse(promptResponse);

                // Step 4: Append new evidence to existing fields with timestamp
                updateEvidenceFields(visitRecord, extractedEvidence);

                // Step 5: Update the Visit record
                update visitRecord;

                result.success = true;
                result.message = 'Evidence fields updated successfully.';

            } catch (Exception e) {
                result.success = false;
                result.message = 'Error: ' + e.getMessage();
            }

            results.add(result);
        }

        return results;
    }

    /**
     * @description Query Visit record with all necessary fields
     * @param visitId The ID of the Visit record
     * @return Visit record with evidence fields
     */
    private static Visit queryVisitRecord(Id visitId) {
        return [
            SELECT Id,
                   Visit_Notes_Dictation__c,
                   Meal_Preparation_Evidence__c,
                   Ambulation_Evidence__c,
                   Domestic_Services_Evidence__c,
                   Orientation_Evidence__c
            FROM Visit
            WHERE Id = :visitId
            LIMIT 1
        ];
    }

    /**
     * @description Call the Flex Prompt Template via ConnectApi
     * @param dictationText The text from Visit_Notes_Dictation__c
     * @return The AI-generated response as JSON string
     */
    private static String callPromptTemplate(String dictationText) {
        // Wrap the input parameter
        ConnectApi.WrappedValue wrappedInput = new ConnectApi.WrappedValue();
        wrappedInput.value = dictationText;

        // Build input parameter map
        // Note: Key format is 'Input:parameterName' matching Prompt Builder configuration
        Map<String, ConnectApi.WrappedValue> inputParams =
            new Map<String, ConnectApi.WrappedValue>();
        inputParams.put('Input:dictationText', wrappedInput);

        // Create input object
        ConnectApi.EinsteinPromptTemplateGenerationsInput input =
            new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.inputParams = inputParams;
        input.isPreview = false;

        // REQUIRED: additionalConfig with specific applicationName
        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

        // Call the prompt template
        // Note: Template DeveloperName is passed as the FIRST parameter, not as a field
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response =
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                'Parse_Visit_Notes_to_Evidence',  // DeveloperName from Prompt Builder
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
     * @description Parse the JSON response from the prompt template
     * @param promptResponse The raw response from the AI
     * @return Map of field API names to extracted evidence text
     */
    private static Map<String, String> parsePromptResponse(String promptResponse) {
        Map<String, String> evidenceMap = new Map<String, String>();

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

            // Parse JSON
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(cleanedResponse);

            // Extract each evidence field
            evidenceMap.put('Meal_Preparation_Evidence__c',
                (String) parsedJson.get('Meal_Preparation_Evidence__c'));
            evidenceMap.put('Ambulation_Evidence__c',
                (String) parsedJson.get('Ambulation_Evidence__c'));
            evidenceMap.put('Domestic_Services_Evidence__c',
                (String) parsedJson.get('Domestic_Services_Evidence__c'));
            evidenceMap.put('Orientation_Evidence__c',
                (String) parsedJson.get('Orientation_Evidence__c'));

        } catch (Exception e) {
            throw new AuraHandledException('Failed to parse AI response: ' + e.getMessage());
        }

        return evidenceMap;
    }

    /**
     * @description Update evidence fields by appending new evidence with timestamp
     * @param visitRecord The Visit record to update
     * @param extractedEvidence Map of field names to new evidence text
     */
    private static void updateEvidenceFields(Visit visitRecord, Map<String, String> extractedEvidence) {
        String timestamp = '\n\n[Added ' + Date.today().format() + ']: ';

        // Update Meal Preparation Evidence
        if (String.isNotBlank(extractedEvidence.get('Meal_Preparation_Evidence__c'))) {
            visitRecord.Meal_Preparation_Evidence__c = appendEvidence(
                visitRecord.Meal_Preparation_Evidence__c,
                extractedEvidence.get('Meal_Preparation_Evidence__c'),
                timestamp
            );
        }

        // Update Ambulation Evidence
        if (String.isNotBlank(extractedEvidence.get('Ambulation_Evidence__c'))) {
            visitRecord.Ambulation_Evidence__c = appendEvidence(
                visitRecord.Ambulation_Evidence__c,
                extractedEvidence.get('Ambulation_Evidence__c'),
                timestamp
            );
        }

        // Update Domestic Services Evidence
        if (String.isNotBlank(extractedEvidence.get('Domestic_Services_Evidence__c'))) {
            visitRecord.Domestic_Services_Evidence__c = appendEvidence(
                visitRecord.Domestic_Services_Evidence__c,
                extractedEvidence.get('Domestic_Services_Evidence__c'),
                timestamp
            );
        }

        // Update Orientation Evidence
        if (String.isNotBlank(extractedEvidence.get('Orientation_Evidence__c'))) {
            visitRecord.Orientation_Evidence__c = appendEvidence(
                visitRecord.Orientation_Evidence__c,
                extractedEvidence.get('Orientation_Evidence__c'),
                timestamp
            );
        }
    }

    /**
     * @description Helper method to append new evidence to existing evidence
     * @param existingEvidence Current evidence in the field
     * @param newEvidence New evidence to append
     * @param timestamp Timestamp separator
     * @return Combined evidence text
     */
    private static String appendEvidence(String existingEvidence, String newEvidence, String timestamp) {
        if (String.isBlank(existingEvidence)) {
            return timestamp + newEvidence;
        } else {
            return existingEvidence + timestamp + newEvidence;
        }
    }

    /**
     * Inner class for input parameters
     */
    public class Request {
        @InvocableVariable(required=true label='Visit Record ID' description='The ID of the Visit record to process')
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
