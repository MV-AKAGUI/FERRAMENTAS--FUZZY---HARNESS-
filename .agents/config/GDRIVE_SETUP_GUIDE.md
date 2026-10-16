# Google Drive Setup Guide

**Objective:** Configure official Google Drive folder as central storage for FERRAMENTAS-FUZZY-HARNESS project

**Status:** Ready for activation

---

## 📋 Step-by-Step Setup

### **Step 1: Create Folder Structure in Google Drive**

Go to: https://drive.google.com/drive/folders/1VISuH9znTKeqzXT-YtXVCKCJID5o8EdS?usp=drive_link

Create this folder structure:

```
FERRAMENTAS-FUZZY-HARNESS/
├── SDD/
├── Specs/
├── Designs/
│   ├── C4_Diagrams/
│   ├── Architecture/
│   └── Wireframes/
├── Reports/
│   ├── Audit_Trails/
│   ├── Project_Status/
│   └── Compliance/
├── Executables/
│   ├── Presentations/
│   ├── Handbooks/
│   └── Templates/
└── Archive/
```

### **Step 2: Get Google Drive Folder ID**

1. Open the main folder `FERRAMENTAS-FUZZY-HARNESS`
2. Copy the URL: `https://drive.google.com/drive/folders/[FOLDER_ID_HERE]`
3. Extract the `[FOLDER_ID_HERE]` part
4. Save it to environment variable:

```bash
# Windows PowerShell
$env:GOOGLE_DRIVE_FOLDER_ID = "YOUR_FOLDER_ID_HERE"

# Or add to .env file:
GOOGLE_DRIVE_FOLDER_ID=YOUR_FOLDER_ID_HERE
```

### **Step 3: Setup Google Drive API Credentials**

1. Go to: https://console.cloud.google.com/apis/dashboard
2. Create a new project: `DAISUGI-FERRAMENTAS`
3. Enable APIs:
   - ✅ Google Drive API
   - ✅ Google Sheets API (optional)
4. Create OAuth 2.0 credentials (Desktop app)
5. Download the credentials JSON file
6. Save to: `.agents/credentials/google_credentials.json`

### **Step 4: Test Authentication**

```bash
# Test sync script
python .agents/scripts/sync_to_gdrive.py \
  --folder_id "$env:GOOGLE_DRIVE_FOLDER_ID" \
  --source "./docs" \
  --mode "sync_docs_only"
```

First run will open browser for OAuth login. Approve and it will save token.

### **Step 5: Configure CI/CD (Optional)**

Add to GitHub Actions workflow:

```yaml
- name: Sync Docs to Google Drive
  env:
    GOOGLE_DRIVE_FOLDER_ID: ${{ secrets.GOOGLE_DRIVE_FOLDER_ID }}
  run: |
    python .agents/scripts/sync_to_gdrive.py \
      --folder_id $GOOGLE_DRIVE_FOLDER_ID \
      --source "./docs"
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

---

## 🔄 Synchronization Modes

### **Mode 1: Manual Sync (Anytime)**

```bash
# Sync local /docs to Drive
python .agents/scripts/sync_to_gdrive.py \
  --folder_id "$env:GOOGLE_DRIVE_FOLDER_ID" \
  --source "./docs" \
  --destination "SDD"
```

### **Mode 2: Auto-Sync on Commit**

Add to `.git/hooks/post-commit`:

```bash
#!/bin/bash
python .agents/scripts/sync_to_gdrive.py \
  --folder_id "$(grep GOOGLE_DRIVE_FOLDER_ID .env | cut -d= -f2)" \
  --source "./docs"
```

### **Mode 3: Scheduled Sync (Cron)**

Linux/Mac:
```bash
# Sync every hour
0 * * * * cd /path/to/repo && python .agents/scripts/sync_to_gdrive.py --folder_id "$GOOGLE_DRIVE_FOLDER_ID" --source "./docs"
```

Windows (Task Scheduler):
```
Program: python
Arguments: .agents/scripts/sync_to_gdrive.py --folder_id %GOOGLE_DRIVE_FOLDER_ID% --source ./docs
Trigger: Hourly or On Demand
```

---

## 📁 Local Folder Structure (Maps to Drive)

```
/docs/
├── /sdd/                          → Drive: SDD/
│   ├── portfolio_mvc_sdd.md
│   └── portfolio_mvc_sdd.pdf
├── /specs/                        → Drive: Specs/
│   ├── api_specification.md
│   └── database_schema.md
├── /designs/                      → Drive: Designs/
│   ├── c4_diagrams/
│   ├── architecture.md
│   └── wireframes/
├── /reports/                      → Drive: Reports/
│   ├── audit_trails/
│   ├── project_status.md
│   └── compliance/
└── /executables/                  → Drive: Executables/
    ├── presentations/
    └── handbooks/
```

---

## ✅ Final Checklist

- [ ] Folder created in Google Drive: `FERRAMENTAS-FUZZY-HARNESS`
- [ ] Subfolders created (SDD, Specs, Designs, Reports, Executables, Archive)
- [ ] Google Drive Folder ID obtained
- [ ] `GOOGLE_DRIVE_FOLDER_ID` environment variable set
- [ ] Google credentials JSON downloaded and saved
- [ ] Sync script tested successfully
- [ ] First sync executed (check Google Drive for files)
- [ ] CI/CD configured (if using GitHub Actions)
- [ ] Team notified of official location

---

## 📞 Support

If sync fails:
1. Check `GOOGLE_DRIVE_FOLDER_ID` is correct
2. Verify credentials file exists: `.agents/credentials/google_credentials.json`
3. Check sync logs: `.agents/logs/gdrive_sync.json`
4. Reauthorize: Delete `token.json` and run sync again

---

**Status:** Setup guide ready. Waiting for manual folder creation in Google Drive.

Once you complete Steps 1-2, I can automate the rest via Python sync scripts.
