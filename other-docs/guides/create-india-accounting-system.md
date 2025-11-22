# Creating India Accounting System in Dolibarr

**Purpose:** Step-by-step guide to create and register an India (IN-GAAP) accounting system in Dolibarr before importing chart of accounts.

**Target:** First-time setup for India-based manufacturing with GST compliance.

---

## Prerequisites

1. **Dolibarr installed** and accessible (http://localhost:8080)
2. **Admin login** credentials
3. **Accounting module enabled**
4. **Company configured** with Country = India

---

## Step 1: Access Accounting System Setup

### Navigate to Accounting Systems
1. Login as administrator
2. Go to: **Home → Setup → Modules/Applications**
3. Ensure **Accounting** module is **Active** (green checkmark)
4. Navigate: **Accountancy → Setup → Chart of accounts**
5. Click on **"Accounting systems"** tab or link

---

## Step 2: Create New Accounting System for India

### Add New System Entry

1. Click **"New"** or **"Create"** button (usually top-right or at bottom)
2. Fill in the form:

| Field | Value | Notes |
|-------|-------|-------|
| **Country** | India | Select from dropdown (country code: 102) |
| **PCG Version** | `IN-GAAP` | Exactly as shown - case sensitive |
| **Label** | `Indian GAAP - Manufacturing` | Descriptive name for your COA |
| **Active** | ☑ Yes | Check the box to activate |

### Important Notes

- **PCG Version** must be **exactly** `IN-GAAP` (no spaces, case-sensitive)
- This code must **match** the "Chart of accounts" column in your import CSV
- Label can be anything descriptive, but keep it clear
- Active = Yes makes it available for selection

3. Click **"Create"** or **"Save"**
4. Confirm success message appears
5. Verify `IN-GAAP` appears in the accounting systems list

---

## Step 3: Set India COA as Active for Company

### Select COA System

1. Navigate: **Home → Setup → Company/Organization**
2. Scroll to **"Accounting/Bookkeeping"** section
3. Find field: **"Chart of accounts"** or **"Accounting system"**
4. Select: **`IN-GAAP - Indian GAAP - Manufacturing`** from dropdown
5. Click **"Modify"** or **"Save"** at bottom of page
6. Confirm save message appears

### Verification

- Return to: **Accountancy → Setup → Chart of accounts**
- You should see: "Chart of accounts: IN-GAAP" displayed
- If not, repeat Step 3

---

## Step 4: Verify System Before Import

### Check System Registration

1. Navigate: **Accountancy → Setup → Accounting systems**
2. Confirm you see:
   - Country: **India**
   - PCG Version: **IN-GAAP**
   - Label: **Indian GAAP - Manufacturing**
   - Active: **Yes** (or green checkmark)

### Check Company Assignment

1. Navigate: **Home → Setup → Company/Organization**
2. Under "Accounting/Bookkeeping" section
3. Verify selected: **IN-GAAP**

Note: If this section is not visible in your build, skip this verification and proceed directly to the import (Step 5). You can assign IN-GAAP to the company later once the system and/or accounts are in place.

---

## Step 5: Ready for Import

Once the accounting system is created and activated:

✅ You can now import chart of accounts using `import_accounting_in_gaap.csv`

### Next Steps

1. **Import Chart of Accounts**
   - Path: Home → Tools → Import
   - Module: Accounting
   - Dataset: Chart of accounts
   - File: `/workspaces/dolibarr/other-docs/session/import_accounting_in_gaap.csv`

2. **Follow Import Guide** (separate document)

---

## Troubleshooting

### Error: "PCG Version already exists"
**Solution:** 
- The system may already exist
- Go to Accounting systems list and verify
- If inactive, activate it and skip to Step 3

### Error: "Country not found"
**Solution:**
- Ensure India is in the country dictionary
- Path: Home → Setup → Dictionaries → Countries
- India should have code 102

### Cannot select IN-GAAP in Company setup
**Solution:**
1. Verify IN-GAAP exists: Accountancy → Setup → Accounting systems
2. Ensure Active = Yes
3. Clear browser cache and retry
4. Log out and log back in

### Import fails with "PCG version not found"
**Solution:**
- Check spelling in CSV: must be exactly `IN-GAAP`
- Column 2 "Chart of accounts" must have `IN-GAAP` in every row
- Verify system exists and is active (Step 4)

---

## Alternative: SQL Direct Insert (Advanced)

**⚠️ Only if UI method fails**

If the UI doesn't allow creating accounting systems, you can insert directly via database:

```sql
-- Connect to database
docker compose exec -T db mysql -u root -p dolibarr

-- Insert India accounting system
INSERT INTO llx_accounting_system (fk_country, pcg_version, label, active) 
VALUES (102, 'IN-GAAP', 'Indian GAAP - Manufacturing', 1);

-- Verify
SELECT * FROM llx_accounting_system WHERE pcg_version = 'IN-GAAP';

-- Exit
exit;
```

**Note:** Replace `102` with India's country ID if different. Find it with:
```sql
SELECT rowid, code, label FROM llx_c_country WHERE code = 'IN';
```

---

## Summary Checklist

Before importing chart of accounts:

- [ ] Accounting module enabled
- [ ] Accounting system `IN-GAAP` created
- [ ] Country set to India (102)
- [ ] Label: "Indian GAAP - Manufacturing"
- [ ] Active: Yes
- [ ] Company COA set to IN-GAAP
- [ ] Verification complete (Step 4)
- [ ] Ready to import CSV

---

**Created:** 2025-11-18  
**For:** Karnataka manufacturing - Dolibarr 23.0.0-alpha  
**Related:** `chart-of-accounts-setup.md`, `import_accounting_in_gaap.csv`
