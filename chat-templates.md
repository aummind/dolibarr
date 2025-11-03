# Chat Session Starters for Chemical Manufacturing Project

Note: For any setup/installation/configuration guidance during chats, reference the authoritative docs under `docker-deploy/setup/`:
- 01-installation.md (install and first run)
- 02-configuration.md (clean configuration guide)
- 03-scripts.md (script reference)
- 04-daily-workflow.md (daily start/exit usage)
- 05-backup-system.md (backup/restore)
These files are the primary source for step-by-step operational guidance in Chat Mode.

## Session Start Template
```
Context: Chemical Manufacturing Dolibarr ERP Implementation
Current Phase: [Installation/Configuration/Testing/Deployment]
Last Completed: [specific task]
Current Issue: [if any]
Files Modified: [list key files]
Next Goal: [specific objective]

Key Project Details:
- Industry: Chemical Manufacturing (bulk, specialty, formulations)
- Compliance: Indian GST, ISO 14001/14076, GHS classification
- Users: Multi-department (Production, QC, R&D, EHS, HR)
- Timeline: 6-week phased implementation
```

## Phase-Specific Prompts

### Installation Phase
```
Working on Dolibarr installation wizard for chemical manufacturing.
Database: db/dolibarr/dolibarr/dolibarrpass
Company: Indian chemical manufacturer with GST compliance
Focus: Regulatory compliance and safety protocols
```

### Configuration Phase  
```
Configuring chemical manufacturing modules in Dolibarr.
Products: CAS numbers, GHS classification, safety data
Inventory: Hazardous storage, batch tracking, compliance
Quality: COA, SDS, testing methods, ISO standards
```

### Implementation Phase
```
Implementing chemical manufacturing workflows.
BOMs: Multi-step chemical processes with equipment tracking
Users: Department-based permissions and safety protocols  
Compliance: Environmental tracking and carbon footprint
```

## Emergency Context Recovery
If conversation memory is lost, use this quick context:

```
PROJECT: Chemical Manufacturing Dolibarr ERP
STATUS: [Current phase from session-context.md]
URGENT: Safety and compliance requirements for chemical industry
DOCS: Use docker-deploy/setup/ (01-installation, 02-configuration, 04-daily-workflow, 05-backup-system, 03-scripts)
FILES: Check /workspaces/dolibarr/ for templates and configurations
BACKUP: dolibarr_backup_20251027_161242 available for reference
URL: [Codespaces forwarded 8080 URL]
```