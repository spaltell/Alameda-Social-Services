public with sharing class DraftVisitNarrativeAction {

    @InvocableMethod(
        label='Draft Visit Narrative'
        description='Uses evidence, rankings, hours, and justifications to draft a Visit narrative via the Draft_Visit_Narrative prompt template. Returns the narrative text without persisting it.'
        category='Visit'
    )
    public static List<Result> draftNarrative(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request request : requests) {
            Result result = new Result();

            try {
                Visit visitRecord = queryVisit(request.visitId);
                String context = buildVisitContext(visitRecord);
                String narrative = callPromptTemplate(context);
                result.narrative = narrative;
                result.success = true;
                result.message = 'Narrative drafted.';
            } catch (Exception e) {
                result.success = false;
                result.narrative = '';
                result.message = 'Error drafting narrative: ' + e.getMessage();
            }

            results.add(result);
        }

        return results;
    }

    private static Visit queryVisit(Id visitId) {
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

    private static String buildVisitContext(Visit v) {
        List<String> sections = new List<String>();

        sections.add('## Category Evidence');
        sections.add('Meal Preparation Evidence: ' + nullSafe(v.Meal_Preparation_Evidence__c));
        sections.add('Ambulation Evidence: ' + nullSafe(v.Ambulation_Evidence__c));
        sections.add('Domestic Services Evidence: ' + nullSafe(v.Domestic_Services_Evidence__c));
        sections.add('Orientation Evidence: ' + nullSafe(v.Orientation_Evidence__c));
        sections.add('');
        sections.add('## Proposed Rankings, Hours, and Justifications');
        sections.add('Meal Preparation: ' + nullSafe(v.Meal_Preparation_Proposed_Ranking__c)
            + ' | Hours: ' + decimalToString(v.Meal_Preparation_Proposed_Hours__c)
            + ' | Exception: ' + booleanToString(v.Meal_Preparation_Is_Exception__c));
        sections.add('  Justification: ' + nullSafe(v.Meal_Preparation_Justification__c));
        sections.add('Ambulation: ' + nullSafe(v.Ambulation_Proposed_Ranking__c)
            + ' | Hours: ' + decimalToString(v.Ambulation_Proposed_Hours__c)
            + ' | Exception: ' + booleanToString(v.Ambulation_Is_Exception__c));
        sections.add('  Justification: ' + nullSafe(v.Ambulation_Justification__c));
        sections.add('Domestic Services: ' + nullSafe(v.Domestic_Services_Proposed_Ranking__c)
            + ' | Hours: ' + decimalToString(v.Domestic_Services_Proposed_Hours__c)
            + ' | Exception: ' + booleanToString(v.Domestic_Services_Is_Exception__c));
        sections.add('  Justification: ' + nullSafe(v.Domestic_Services_Justification__c));
        sections.add('Orientation: ' + nullSafe(v.Orientation_Proposed_Ranking__c) + ' (cognitive category — no hours, no justification field)');

        return String.join(sections, '\n');
    }

    private static String callPromptTemplate(String visitContext) {
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
        inputParams.put('Input:visitContext', wrap(visitContext));

        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.inputParams = inputParams;
        input.isPreview = false;
        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response =
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                'Draft_Visit_Narrative',
                input
            );

        if (response != null && response.generations != null && !response.generations.isEmpty()) {
            return response.generations[0].text;
        }

        throw new AuraHandledException('No response received from Draft_Visit_Narrative prompt template.');
    }

    private static ConnectApi.WrappedValue wrap(String value) {
        ConnectApi.WrappedValue w = new ConnectApi.WrappedValue();
        w.value = value;
        return w;
    }

    private static String nullSafe(String value) {
        return String.isBlank(value) ? 'No evidence provided' : value;
    }

    private static String decimalToString(Decimal value) {
        return value == null ? 'N/A' : String.valueOf(value);
    }

    private static String booleanToString(Boolean value) {
        return value == true ? 'true' : 'false';
    }

    public class Request {
        @InvocableVariable(required=true label='Visit Record ID' description='The Visit record to draft a narrative for')
        public Id visitId;
    }

    public class Result {
        @InvocableVariable(label='Success' description='Whether the draft was produced')
        public Boolean success;

        @InvocableVariable(label='Narrative' description='Drafted narrative text')
        public String narrative;

        @InvocableVariable(label='Message' description='Status or error message')
        public String message;
    }
}