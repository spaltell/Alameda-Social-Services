#!/bin/bash
# Grant FLS (Read + Edit) to Admin profile for new Visit fields

ORG_ALIAS="trailsignup.c1d834dc47feb3@salesforce.com"

echo "Granting FLS for Visit fields to System Administrator profile..."

# Get the System Administrator profile ID
PROFILE_ID=$(sf data query --query "SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1" --target-org "$ORG_ALIAS" --json | jq -r '.result.records[0].Id')

echo "System Administrator Profile ID: $PROFILE_ID"

# Field names
FIELDS=(
    "Meal_Preparation_Proposed_Hours__c"
    "Ambulation_Proposed_Hours__c"
    "Domestic_Services_Proposed_Hours__c"
    "Domestic_Services_Is_Exception__c"
    "Ambulation_Is_Exception__c"
    "Meal_Preparation_Is_Exception__c"
    "Meal_Preparation_Justification__c"
    "Ambulation_Justification__c"
    "Domestic_Services_Justification__c"
)

# Grant FLS for each field
for FIELD in "${FIELDS[@]}"; do
    echo "Granting FLS for Visit.$FIELD..."

    # Check if FieldPermissions record exists
    EXISTING=$(sf data query --query "SELECT Id FROM FieldPermissions WHERE ParentId='$PROFILE_ID' AND SobjectType='Visit' AND Field='Visit.$FIELD' LIMIT 1" --target-org "$ORG_ALIAS" --json | jq -r '.result.records[0].Id // empty')

    if [ -z "$EXISTING" ]; then
        # Create new FieldPermissions record
        sf data create record --sobject FieldPermissions \
            --values "ParentId='$PROFILE_ID' SobjectType='Visit' Field='Visit.$FIELD' PermissionsRead=true PermissionsEdit=true" \
            --target-org "$ORG_ALIAS"
    else
        # Update existing record
        sf data update record --sobject FieldPermissions \
            --record-id "$EXISTING" \
            --values "PermissionsRead=true PermissionsEdit=true" \
            --target-org "$ORG_ALIAS"
    fi
done

echo "FLS granted successfully!"
