// Populate ActualVisitStartTime, Address__Street__s, and VisitPriority for ALL visits with blank fields

List<Visit> visitsToUpdate = [
    SELECT Id, AccountId, PlannedVisitStartTime, Account.BillingStreet,
           ActualVisitStartTime, Address__Street__s, VisitPriority
    FROM Visit
    WHERE Household_Visit_Status__c IN ('Under Review', 'Complete', 'Documentation Pending')
      AND (ActualVisitStartTime = null OR Address__Street__s = null OR VisitPriority = null)
    ORDER BY CreatedDate DESC
];

List<String> priorities = new List<String>{'High', 'Medium', 'Low'};

for (Integer i = 0; i < visitsToUpdate.size(); i++) {
    Visit v = visitsToUpdate[i];

    // Set ActualVisitStartTime to 15 minutes after planned time (only if blank)
    if (v.ActualVisitStartTime == null && v.PlannedVisitStartTime != null) {
        v.ActualVisitStartTime = v.PlannedVisitStartTime.addMinutes(15);
    }

    // Set Address__Street__s from Account BillingStreet (only if blank)
    if (v.Address__Street__s == null) {
        if (String.isNotBlank(v.Account.BillingStreet)) {
            v.Address__Street__s = v.Account.BillingStreet;
        } else {
            v.Address__Street__s = '123 Main Street';
        }
    }

    // Set VisitPriority (rotating High, Medium, Low) (only if blank)
    if (v.VisitPriority == null) {
        v.VisitPriority = priorities[Math.mod(i, 3)];
    }
}

update visitsToUpdate;

System.debug('Updated ' + visitsToUpdate.size() + ' visits with ActualVisitStartTime, Address__Street__s, and VisitPriority');
