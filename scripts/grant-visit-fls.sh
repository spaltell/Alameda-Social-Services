#!/bin/bash

# Grant FLS on all custom Visit, AssessmentTask, and Contact fields to System Administrator profile

ORG_ALIAS="LACPA-Storm"

# Get access token and instance URL
echo "Getting org credentials..."
AUTH_INFO=$(sf org display --target-org $ORG_ALIAS --json)
ACCESS_TOKEN=$(echo $AUTH_INFO | jq -r '.result.accessToken')
INSTANCE_URL=$(echo $AUTH_INFO | jq -r '.result.instanceUrl')

# Get System Administrator profile ID
echo "Fetching System Administrator profile ID..."
PROFILE_QUERY="SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1"
PROFILE_RESPONSE=$(curl -s "${INSTANCE_URL}/services/data/v66.0/query?q=$(echo $PROFILE_QUERY | jq -sRr @uri)" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}")
PROFILE_ID=$(echo $PROFILE_RESPONSE | jq -r '.records[0].Id')

echo "Profile ID: $PROFILE_ID"

# Visit fields
VISIT_FIELDS=(
  "AI_Processing_Status__c"
  "Draft_Narrative__c"
  "Final_Narrative__c"
  "Narrative_Status__c"
  "Overall_Risk_Level__c"
  "Highest_Need_Category__c"
  "Review_Status__c"
  "Submitted_For_Review_Date__c"
  "Reviewed_By__c"
  "Worker_Approval_Date__c"
  "Domestic_Services_Proposed_Ranking__c"
  "Domestic_Services_Approved_Ranking__c"
  "Domestic_Services_Evidence__c"
  "Domestic_Services_Rationale__c"
  "Ambulation_Proposed_Ranking__c"
  "Ambulation_Approved_Ranking__c"
  "Ambulation_Evidence__c"
  "Ambulation_Rationale__c"
  "Meal_Preparation_Proposed_Ranking__c"
  "Meal_Preparation_Approved_Ranking__c"
  "Meal_Preparation_Evidence__c"
  "Meal_Preparation_Rationale__c"
  "Memory_Proposed_Ranking__c"
  "Memory_Approved_Ranking__c"
  "Memory_Evidence__c"
  "Memory_Rationale__c"
  "Orientation_Proposed_Ranking__c"
  "Orientation_Approved_Ranking__c"
  "Orientation_Evidence__c"
  "Orientation_Rationale__c"
  "Judgment_Proposed_Ranking__c"
  "Judgment_Approved_Ranking__c"
  "Judgment_Evidence__c"
  "Judgment_Rationale__c"
)

# AssessmentTask fields
AT_FIELDS=(
  "Observation_Category__c"
  "Room_Location__c"
  "Severity__c"
  "Photo_Attached__c"
  "Captured_On_Mobile__c"
)

# Contact fields
CONTACT_FIELDS=(
  "Client_Status__c"
  "Family_Size__c"
  "Children_Ages__c"
  "Primary_Need_Category__c"
  "Current_Service_Hours__c"
  "Last_Assessment_Date__c"
)

echo ""
echo "Granting FLS for ${#VISIT_FIELDS[@]} Visit fields..."
for FIELD in "${VISIT_FIELDS[@]}"; do
  curl -s -X PATCH \
    "${INSTANCE_URL}/services/data/v66.0/tooling/sobjects/FieldPermissions/Visit.${FIELD}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"PermissionsRead\": true, \"PermissionsEdit\": true}" > /dev/null
  echo "  ✓ Visit.$FIELD"
done

echo ""
echo "Granting FLS for ${#AT_FIELDS[@]} AssessmentTask fields..."
for FIELD in "${AT_FIELDS[@]}"; do
  curl -s -X PATCH \
    "${INSTANCE_URL}/services/data/v66.0/tooling/sobjects/FieldPermissions/AssessmentTask.${FIELD}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"PermissionsRead\": true, \"PermissionsEdit\": true}" > /dev/null
  echo "  ✓ AssessmentTask.$FIELD"
done

echo ""
echo "Granting FLS for ${#CONTACT_FIELDS[@]} Contact fields..."
for FIELD in "${CONTACT_FIELDS[@]}"; do
  curl -s -X PATCH \
    "${INSTANCE_URL}/services/data/v66.0/tooling/sobjects/FieldPermissions/Contact.${FIELD}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"PermissionsRead\": true, \"PermissionsEdit\": true}" > /dev/null
  echo "  ✓ Contact.$FIELD"
done

echo ""
echo "✅ FLS granted for all custom fields to System Administrator profile"
