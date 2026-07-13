// Update Last_Visit_Date__c on Accounts based on most recent visit
List<Account> accountsToUpdate = new List<Account>();

// Get all person accounts with visits
Map<Id, Date> accountToLastVisitDate = new Map<Id, Date>();

List<Visit> visits = [
    SELECT AccountId, Worker_Approval_Date__c
    FROM Visit
    WHERE AccountId != null
      AND Worker_Approval_Date__c != null
      AND Household_Visit_Status__c = 'Under Review'
    ORDER BY Worker_Approval_Date__c DESC
];

for (Visit v : visits) {
    if (!accountToLastVisitDate.containsKey(v.AccountId)) {
        accountToLastVisitDate.put(v.AccountId, Date.valueOf(v.Worker_Approval_Date__c));
    }
}

for (Id accountId : accountToLastVisitDate.keySet()) {
    Account acc = new Account(
        Id = accountId,
        Last_Visit_Date__c = accountToLastVisitDate.get(accountId)
    );
    accountsToUpdate.add(acc);
}

update accountsToUpdate;

System.debug('Updated ' + accountsToUpdate.size() + ' accounts with Last Visit Date');
