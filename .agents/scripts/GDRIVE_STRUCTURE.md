# Google Drive Official Structure

**Folder Name:** `FERRAMENTAS-FUZZY-HARNESS` (no Drive)  
**Local Repo:** `FERRAMENTAS--FUZZY---HARNESS-`  
**Status:** Official Remote Storage  
**Purpose:** Central repository for SDD, specs, designs, reports, executables

---

## 📁 Crie Essa Estrutura no Google Drive:

```
FERRAMENTAS-FUZZY-HARNESS/
│
├── 📂 SDD/
│   ├── 2026-10-15_Portfolio_MVP_SDD.md
│   ├── 2026-10-15_Portfolio_MVP_SDD.pdf
│   └── [project_name]_SDD.md (add as projects complete)
│
├── 📂 Specs/
│   ├── Dai_Vibe_Code_Spec.md
│   ├── API_Specification.md
│   └── Database_Schema_Spec.md
│
├── 📂 Designs/
│   ├── C4_Diagrams/
│   │   ├── portfolio_mvc_c4.svg
│   │   └── portfolio_mvc_c4.png
│   ├── Architecture/
│   │   ├── system_architecture.md
│   │   └── component_diagram.svg
│   └── Wireframes/
│       └── (UI mockups as needed)
│
├── 📂 Reports/
│   ├── Audit_Trails/
│   │   ├── 2026-10-15_Dai_Ignition_Test.md
│   │   └── 2026-10-15_Anti_Hallucination_Report.md
│   ├── Project_Status/
│   │   └── 2026-10-15_Portfolio_MVP_Status.md
│   └── Compliance/
│       ├── LGPD_Audit.md
│       └── Security_Review.md
│
├── 📂 Executables/
│   ├── Presentations/
│   │   └── Dai_Vibe_Code_Overview.pdf
│   ├── Handbooks/
│   │   ├── Dai_User_Manual.pdf
│   │   └── Team_Training.pdf
│   └── Templates/
│       ├── Project_Brief_Template.md
│       └── Discovery_Checklist.pdf
│
├── 📂 Archive/
│   ├── v1_Proposals/
│   │   └── Original_Dai_Concept.md
│   └── Old_Versions/
│       └── (deprecated docs)
│
└── 📄 README.md
    └── "This is the official storage for all project documentation.
         Sync with local repo: /docs folder via Google Drive API.
         Last sync: [timestamp]"
```

---

## 🔄 Sincronização Automática

**Local → Google Drive:**
```bash
# Script: .agents/scripts/sync_to_gdrive.py
# Runs: Automático via CI/CD ou manualmente
# Direction: Local /docs → Drive FERRAMENTAS-FUZZY-HARNESS/

python .agents/scripts/sync_to_gdrive.py \
  --folder_id "[YOUR_DRIVE_FOLDER_ID]" \
  --source "./docs" \
  --destination "SDD" \
  --mode "sync_docs_only"
```

**Google Drive → Local (pull):**
```bash
# Para trazer atualizações do Drive pro local
python .agents/scripts/sync_from_gdrive.py \
  --folder_id "[YOUR_DRIVE_FOLDER_ID]" \
  --destination "./docs_pulled"
```

---

## 📝 Manual Steps to Create

Since Claude cannot directly access Google Drive without OAuth, **você precisa fazer isso manualmente:**

### Step 1: Create Main Folder
- ✅ Go to: https://drive.google.com/drive/folders/1VISuH9znTKeqzXT-YtXVCKCJID5o8EdS?usp=drive_link
- ✅ Create folder: `FERRAMENTAS-FUZZY-HARNESS`

### Step 2: Create Subfolders
Inside `FERRAMENTAS-FUZZY-HARNESS`, create:
```
SDD/
Specs/
Designs/ (with C4_Diagrams/, Architecture/, Wireframes/)
Reports/ (with Audit_Trails/, Project_Status/, Compliance/)
Executables/ (with Presentations/, Handbooks/, Templates/)
Archive/
```

### Step 3: Get Folder ID
- ✅ Right-click folder → Share → Get link
- ✅ Copy Folder ID from URL: `https://drive.google.com/drive/folders/[FOLDER_ID_HERE]`
- ✅ Save to: `.agents/config/gdrive_config.json`

### Step 4: Register in Project
Add to `.claude/settings.json`:
```json
{
  "google_drive": {
    "official_folder_name": "FERRAMENTAS-FUZZY-HARNESS",
    "folder_id": "[PASTE_YOUR_FOLDER_ID]",
    "sync_enabled": true,
    "sync_direction": "bidirectional",
    "sync_interval": "on_commit",
    "sync_paths": {
      "local_docs": "./docs",
      "drive_destination": "SDD"
    }
  }
}
```

---

## ✅ Checklist

- [ ] Folder created in Drive: `FERRamentas-FUZZY-HARNESS`
- [ ] Subfolders created (SDD, Specs, Designs, Reports, Executables, Archive)
- [ ] Folder ID obtained and saved to `.agents/config/gdrive_config.json`
- [ ] settings.json updated with folder_id
- [ ] Sync scripts tested
- [ ] CI/CD configured to sync on commits
- [ ] Team notified of new official location

---

**Status:** Waiting for manual folder creation in Drive. Scripts ready to deploy.
