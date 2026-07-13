/**
 * LWC-facing controller for handwritten note scanner. Exposes two AuraEnabled
 * entry points: transcribe a ContentDocument via the vision-capable Flex prompt template,
 * and write the resulting text to the Visit_Notes_Dictation__c field on the Visit record.
 */
public with sharing class OVANoteScannerController {

    @AuraEnabled
    public static String transcribeNote(String contentDocumentId) {
        return OVAHandwrittenNoteAnalyzer.transcribe(contentDocumentId);
    }

    @AuraEnabled
    public static void saveToVisit(Id visitId, String transcription) {
        Visit visitRecord = [
            SELECT Id, Visit_Notes_Dictation__c
            FROM Visit
            WHERE Id = :visitId
            LIMIT 1
        ];

        String existing = visitRecord.Visit_Notes_Dictation__c != null
            ? visitRecord.Visit_Notes_Dictation__c + '\n\n---\n\n'
            : '';
        visitRecord.Visit_Notes_Dictation__c = existing + transcription;
        update visitRecord;
    }
}