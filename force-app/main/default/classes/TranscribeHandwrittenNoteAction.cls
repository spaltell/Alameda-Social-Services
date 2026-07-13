public with sharing class TranscribeHandwrittenNoteAction {

    @InvocableMethod(
        label='Transcribe Handwritten Note'
        description='Takes a ContentDocumentId and returns transcribed text using Einstein Vision'
        category='Visit'
    )
    public static List<Result> transcribe(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result res = new Result();

            try {
                // Convert ContentVersionId to ContentDocumentId
                ContentVersion cv = [
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :req.contentVersionId
                    LIMIT 1
                ];

                // Call the existing transcription logic
                String transcription = OVAHandwrittenNoteAnalyzer.transcribe(cv.ContentDocumentId);

                res.success = true;
                res.transcription = transcription;
                res.message = 'Successfully transcribed handwritten note.';

            } catch (Exception e) {
                res.success = false;
                res.message = 'Error: ' + e.getMessage();
                res.transcription = '';
            }

            results.add(res);
        }

        return results;
    }

    public class Request {
        @InvocableVariable(required=true label='Content Version ID')
        public String contentVersionId;
    }

    public class Result {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Transcription')
        public String transcription;

        @InvocableVariable(label='Message')
        public String message;
    }
}
