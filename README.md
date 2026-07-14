# Alameda County IHSS - AI-Powered Case Management

Salesforce demo build for In-Home Supportive Services (IHSS) case management automation using AI and Agentforce.

**🎯 Demo Build Version:** [v1.0-demo](https://github.com/spaltell/Alameda-Social-Services/releases/tag/v1.0-demo)  
**📅 Demo Date:** July 14-15, 2026

---

## Quick Links

- 📖 [Complete Demo Documentation](./DEMO-BUILD.md)
- 🎬 [Demo Walkthrough Script](https://spaltell.github.io/Alameda-Social-Services/demo-script.html)
- 📊 [Customer Presentation Deck](https://spaltell.github.io/Alameda-Social-Services/presentation.html)

---

## Problem Statement

Alameda County IHSS faces a critical backlog:
- **500 cases** in backlog
- **400 people** waiting for services
- **3 cases/day** current throughput
- **Out of compliance** with state requirements

### Root Cause
Creating compliant narratives with proper rankings and regulatory citations is the bottleneck. Each visit requires 2+ hours of documentation.

---

## Solution Overview

AI-powered automation to accelerate case completion while maintaining compliance:

### Core Features
1. **Voice-to-Text Integration** - Paste dictation directly into visit records
2. **Handwritten Note Scanner** - Mobile OCR transcription of field notes
3. **Smart Text Parsing** - AI extracts rankings, hours, and observations from unstructured text
4. **Auto Rankings with Citations** - AI suggests rankings based on IHSS policy with regulatory evidence
5. **One-Click Narratives** - Generate compliant narrative text for state submission
6. **IHSS Agent** - Conversational AI for policy questions, backlog management, and workload prioritization

### User Experience
- **Mobile-first** field visit workflow
- **Desktop** documentation and approval
- **Visual** household profile cards with risk levels
- **Daily dashboard** for visit prioritization

---

## What’s Included

- ✅ **5 Lightning Web Components** (householdProfileCard, myDayComponent, handwriting scanners)
- ✅ **6 Apex Classes** (controllers, actions, analyzers)
- ✅ **8 Flows** (rankings, finalization, note scanning, automation)
- ✅ **8 Agentforce Prompt Templates** (policy lookup, case summaries, document insights)
- ✅ **Custom Fields & Layouts** (Last_Visit_Date__c, visit tracking fields)
- ✅ **Data Generation Scripts** (20 demo visits with realistic IHSS data)
- ✅ **Demo Documentation** (walkthrough script, presentation deck, screenshots)

See [DEMO-BUILD.md](./DEMO-BUILD.md) for complete component list and technical details.

---

## Demo Flow

1. **Home Page** → View prioritized visit list and household profiles
2. **Mobile Visit** → Capture handwritten notes in the field
3. **Desktop Documentation** → Paste dictation, parse structured data
4. **AI Validation** → Generate rankings, ask agent about policy thresholds
5. **Finalization** → Review narrative, approve rankings, complete workflow
6. **Agent Queries** → "Show me my backlog", "Which visits are missing rankings?"

**Full walkthrough:** https://spaltell.github.io/Alameda-Social-Services/demo-script.html

---

## Expected Impact

| Metric | Before | After |
|--------|--------|-------|
| Cases per day | 3 | 5-7 |
| Time per visit | 2+ hours | ~48 minutes |
| Backlog reduction | Slow | 2-3x faster |

**Goal:** Faster compliance, better outcomes for households in need.

---

## Repository Structure

```
alameda-county-social-services/
├── force-app/main/default/
│   ├── classes/                  # Apex classes (controllers, actions)
│   ├── flows/                    # Screen flows & record-triggered flows
│   ├── genAiPromptTemplates/     # Agentforce prompt templates
│   ├── layouts/                  # Page layouts (Account, Visit)
│   ├── lwc/                      # Lightning Web Components
│   └── objects/                  # Custom fields
├── scripts/                      # Data generation scripts
├── docs/                         # Demo documentation & presentation
├── DEMO-BUILD.md                 # Complete component inventory
└── README.md                     # This file
```

---

## Deployment

### Prerequisites
- Salesforce CLI (`sf`) installed
- Authenticated to target org (SDO recommended)
- Admin permissions

### Deploy
```bash
# Deploy all metadata
sf project deploy start --target-org <your-org-alias>

# Grant field-level security for custom fields
# (See DEMO-BUILD.md for FLS instructions)

# Generate demo data
sf apex run --file scripts/create-demo-visits.apex --target-org <your-org>
sf apex run --file scripts/populate-visit-fields.apex --target-org <your-org>
```

---

## Demo Resources

- **Demo Script (Detailed):** https://spaltell.github.io/Alameda-Social-Services/demo-script.html
- **Presentation Deck:** https://spaltell.github.io/Alameda-Social-Services/presentation.html
- **Sample Dictation Data:** https://mdevsales.github.io/ihss-agent-demo/

---

## Technical Stack

- **Platform:** Salesforce
- **LWC:** Lightning Web Components with @wire services
- **Apex:** Server-side controllers with @AuraEnabled methods
- **Flows:** Record-triggered & Screen flows
- **AI:** Einstein OCR, Prompt Templates, Agentforce
- **API Version:** v66.0 / v67.0

---

## Support

- **Developer:** Claude AI / Skyler Paltell
- **Repository:** https://github.com/spaltell/Alameda-Social-Services
- **Issues:** https://github.com/spaltell/Alameda-Social-Services/issues

---

## License

This is a demo build for Salesforce demonstration purposes.

---

**🚀 Ready to demo? Start here:** [Demo Script](https://spaltell.github.io/Alameda-Social-Services/demo-script.html)
