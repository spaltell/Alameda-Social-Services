// Create 20 completed visits with realistic data
List<Visit> visits = new List<Visit>();

// Person Account IDs
List<Id> accountIds = new List<Id>{
    '001Ka00004fKRy7IAG', // Paul Marshall
    '001Ka00004fKRyAIAW', // Larry Baxter
    '001Ka00004fKRyBIAW', // Alex Carter
    '001Ka00004fKRyEIAW', // Margaret Chen
    '001Ka00004fKRyGIAW', // Johnny Marshall
    '001Ka00004fKRyHIAW', // Mary Adams
    '001Ka00004fKRyIIAW', // Henry Miller
    '001Ka00004fKRyJIAW', // Maria Anderson
    '001Ka00004fKRyKIAW', // Bobby Marshall
    '001Ka00004fKRz1IAG'  // Robert Janzen
};

Id visitorId = '005Ka000004vsw5IAA';
Id placeId = '131Ka000000m71cIAA';

// Risk levels and categories
List<String> riskLevels = new List<String>{'Low', 'Medium', 'High'};
List<String> needCategories = new List<String>{'Meal Preparation', 'Ambulation', 'Domestic Services', 'Orientation'};

// Create visits spread over past 120 days
for (Integer i = 0; i < 20; i++) {
    Visit v = new Visit();
    v.AccountId = accountIds[Math.mod(i, accountIds.size())];
    v.VisitorId = visitorId;
    v.PlaceId = placeId;
    v.Status = 'Completed';
    v.Household_Visit_Status__c = 'Under Review';

    // Spread visits over past 120 days
    Integer daysAgo = 120 - (i * 6);
    DateTime approvalDate = DateTime.now().addDays(-daysAgo);
    v.Worker_Approval_Date__c = approvalDate;
    v.PlannedVisitStartTime = approvalDate.addHours(-2);

    // Realistic risk assessment
    Integer riskIndex = Math.mod(i, 3);
    v.Overall_Risk_Level__c = riskLevels[riskIndex];
    v.Highest_Need_Category__c = needCategories[Math.mod(i, 4)];

    // Proposed hours (realistic IHSS ranges)
    v.Meal_Preparation_Proposed_Hours__c = 8 + Math.mod(i, 5);
    v.Ambulation_Proposed_Hours__c = 1.5 + (Math.mod(i, 3) * 0.5);
    v.Domestic_Services_Proposed_Hours__c = 15 + Math.mod(i, 8);

    // Approved rankings (Rank 1-5)
    v.Meal_Preparation_Approved_Ranking__c = 'Rank ' + String.valueOf(1 + Math.mod(i, 5));
    v.Ambulation_Approved_Ranking__c = 'Rank ' + String.valueOf(1 + Math.mod(i + 1, 5));
    v.Domestic_Services_Approved_Ranking__c = 'Rank ' + String.valueOf(1 + Math.mod(i + 2, 5));
    v.Orientation_Approved_Ranking__c = 'Rank ' + String.valueOf(1 + Math.mod(i + 3, 5));

    // Exception flags (some visits have exceptions)
    if (Math.mod(i, 7) == 0) {
        v.Meal_Preparation_Is_Exception__c = true;
    }
    if (Math.mod(i, 11) == 0) {
        v.Ambulation_Is_Exception__c = true;
    }

    // Narrative (realistic worker documentation)
    v.Draft_Narrative__c = '<p>Visit conducted on ' + approvalDate.format('MMMM dd, yyyy') +
        '. Client demonstrated ' + riskLevels[riskIndex].toLowerCase() +
        ' risk level with primary need in ' + v.Highest_Need_Category__c +
        '. Home environment is safe and clean. Client is cooperative and engaged in care planning.</p>';

    v.Final_Narrative__c = v.Draft_Narrative__c;

    v.Narrative_Status__c = 'Submitted';
    v.Report_Status__c = 'Submitted';
    v.Submitted_For_Review_Date__c = approvalDate.addHours(-1);

    visits.add(v);
}

insert visits;

System.debug('Created ' + visits.size() + ' completed visits');
System.debug('Visit IDs: ' + visits);
