# Alameda County IHSS Demo Build

**Demo Date:** July 14-15, 2026  
**Build Version:** v1.0-demo  
**Repository:** https://github.com/spaltell/Alameda-Social-Services

---

## Overview

Complete Salesforce demo build for Alameda County In-Home Supportive Services (IHSS) case management automation using AI and Agentforce.

## What's Included

### 1. Lightning Web Components (LWC)
- **householdProfileCard** - Comprehensive household profile with risk levels, authorized hours, and visit history
- **myDayComponent** - Daily visit dashboard with status tracking (Scheduled, In Progress, Pending)
- **mobileHandwritingScanner** - Mobile handwritten note transcription using Salesforce Einstein OCR
- **visitNotesInput** - Visit notes input component
- **ovaNoteScanner** - Alternative note scanning component

### 2. Apex Classes
- **MyDayController** - Apex controller for My Day component (retrieves today's scheduled visits)
- **DemoResetVisitAction** - Demo reset functionality for visit records
- **DraftVisitNarrativeAction** - Auto-generate visit narratives from structured data
- **OVAHandwrittenNoteAnalyzer** - Handwritten note analysis and transcription
- **OVANoteScannerController** - Controller for handwritten note scanner
- **TranscribeHandwrittenNoteAction** - Transcription action for handwritten notes

### 3. Flows
- **Generate_Visit_Rankings_Flow** - Automated visit ranking based on observations and need categories
- **Approve_and_Finalize_Visit_Flow** - Screen flow for finalizing visits with risk assessment and highest need capture
- **Create_Visit_from_Account** - Quick visit creation from Account records
- **Generate_Draft_Narrative_Flow** - Generate compliant narrative text for state submission
- **Scan_Handwritten_Visit_Notes** - Mobile flow for scanning handwritten field notes
- **Update_Account_Last_Visit_Date** - Record-triggered flow to stamp last visit date on Account

### 4. Agentforce Agents & Prompt Templates
- **GPS_Get_Relevant_Regulatory_Codes** - Policy lookup for IHSS regulatory thresholds and citations
- **GPS_Get_Similar_Resolved_Public_Complaints** - Find similar resolved cases for reference
- **GPS_Get_Similar_Unresolved_Public_Complaints** - Identify similar pending issues
- **Grantmaking_Summarize_Application** - Summarize grant applications
- **House_Tour_Release_Summary** - Release summary generation
- **OVA_Case_Summary** - Comprehensive case summary generation
- **OVA_Document_Insight** - Document analysis and insights
- **OVA_Document_Summary** - Document summarization

### 5. Custom Fields
- **Account.Last_Visit_Date__c** - Date field tracking most recent completed visit
- Multiple Visit custom fields for IHSS workflow tracking (rankings, hours, observations, risk levels)

### 6. Page Layouts
- **GPS Person Account Layout** - Includes Last_Visit_Date__c field
- **Visit Layout** - Comprehensive visit record layout with all custom fields

### 7. Data Generation Scripts
Located in `/scripts/`:
- **create-demo-visits.apex** - Generates 20 completed visit records with realistic IHSS data
- **populate-visit-fields.apex** - Populates ActualVisitStartTime, Address, and VisitPriority for reporting
- **update-last-visit-dates.apex** - Stamps Last_Visit_Date__c on Account records

### 8. Demo Documentation
Located in `/docs/`:
- **demo-script.html** - Complete step-by-step demo walkthrough for presentation
  - Live at: https://spaltell.github.io/Alameda-Social-Services/demo-script.html
- **presentation.html** - Customer-facing slide deck with pain points and solution overview
  - Live at: https://spaltell.github.io/Alameda-Social-Services/presentation.html
- **scheduling-availability.png** - Unified Scheduling availability-based booking screenshot
- **scheduling-console.png** - Unified Scheduling console screenshot

---

## Demo Flow

### Phase 1: Home Page & Household Profile
1. View My Day component with prioritized visit list
2. Show Household Profile Card with risk levels and visit history

### Phase 2: Mobile Visit Experience
1. Open visit record on mobile
2. Capture visit notes using mobile handwriting scanner
3. Update Path status to "Visit In Progress"

### Phase 3: Desktop Documentation
1. Return to desktop visit record
2. Paste dictation/transcription from sample data
3. Click "Parse Text" to extract structured data
4. Update Path to "Documentation Pending"

### Phase 4: AI-Powered Ranking & Validation
1. Click "Generate Benefits Eligibility"
2. Ask IHSS Agent: "What is the exception threshold for meal preparation hours?"
3. Review and approve suggested rankings

### Phase 5: Narrative Generation
1. Click "Generate Draft Narrative"
2. Review AI-generated narrative with proper formatting
3. Click "Approve and Finalize" screen flow
4. Input overall risk and highest need
5. Update Path to "Under Review"

### Phase 6: Post-Submission Agent Queries
1. Ask IHSS Agent: "Show me my backlog"
2. Ask: "Which visits are missing rankings?"
3. Ask policy questions for compliance verification

### Appendix: Unified Scheduling
1. Show availability-based booking interface
2. Demo scheduling console with Gantt timeline

---

## Key Features Demonstrated

### AI & Automation
- ✅ Voice-to-text dictation paste
- ✅ Handwritten note transcription (mobile)
- ✅ Smart text parsing for structured data extraction
- ✅ Auto-suggested rankings with regulatory citations
- ✅ One-click narrative generation
- ✅ Conversational AI agent for policy questions and workload management

### Data Management
- ✅ Person Account household management
- ✅ Visit status tracking with Path component
- ✅ Automated last visit date stamping
- ✅ Comprehensive visit reporting fields

### User Experience
- ✅ Mobile-first field visit workflow
- ✅ Desktop documentation and approval
- ✅ Visual household profile cards
- ✅ Daily visit dashboard (My Day)

---

## Technical Architecture

- **Platform:** Salesforce (SDO Org)
- **API Version:** v66.0 / v67.0
- **LWC:** Lightning Web Components with @wire services
- **Apex:** Server-side controllers with @AuraEnabled methods
- **Flows:** Record-triggered and Screen flows
- **AI:** Einstein OCR, Prompt Templates, Agentforce

---

## Deployment Instructions

### Prerequisites
- Salesforce CLI (`sf`) installed
- Authenticated to target org
- Admin permissions

### Deploy Metadata
```bash
sf project deploy start --target-org <your-org-alias>
```

### Grant Field-Level Security
After deploying custom fields, grant FLS to System Administrator:
```bash
# Example for Last_Visit_Date__c
# Use FieldPermissions via REST API or assign permission set
```

### Run Data Generation Scripts
```bash
# Generate demo visits
sf apex run --file scripts/create-demo-visits.apex --target-org <your-org>

# Populate visit fields for reporting
sf apex run --file scripts/populate-visit-fields.apex --target-org <your-org>

# Stamp last visit dates
sf apex run --file scripts/update-last-visit-dates.apex --target-org <your-org>
```

### Assign Components to Page Layouts
- Add Household Profile Card to Person Account page
- Add My Day Component to Home page
- Ensure all custom fields visible on Visit layout

---

## Demo Resources

- **Demo Script:** https://spaltell.github.io/Alameda-Social-Services/demo-script.html
- **Presentation Deck:** https://spaltell.github.io/Alameda-Social-Services/presentation.html
- **Sample Dictation:** https://mdevsales.github.io/ihss-agent-demo/

---

## Pain Points Addressed

1. **Time-Consuming Documentation** - 2+ hours per visit reduced via voice-to-text and auto-parsing
2. **Manual Ranking Process** - AI suggests rankings with regulatory citations
3. **Limited Policy Access** - Conversational agent provides instant policy lookups
4. **Backlog Management** - Agent identifies incomplete visits and prioritizes workload

---

## Expected Impact

- **Faster Case Processing** - From 3 cases/day baseline to 5-7 cases/day with automation
- **Reduced Backlog** - 500 case backlog, 400 people waiting → faster compliance
- **Better Outcomes** - More time for in-home visits, less time on paperwork

---

## Support & Questions

For questions about this demo build, contact:
- **Developer:** Claude AI / Skyler Paltell
- **Repository:** https://github.com/spaltell/Alameda-Social-Services
- **Demo Date:** July 14-15, 2026

---

**🎯 This is the complete demo build. All metadata, scripts, and documentation are included.**
