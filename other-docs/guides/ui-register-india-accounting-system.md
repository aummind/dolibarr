# UI Guide: Register India Accounting System in Dolibarr

**Purpose:** Visual step-by-step guide to create IN-GAAP accounting system via Dolibarr web interface.

**Environment:** Dolibarr 23.0.0-alpha | Karnataka Manufacturing | GST Compliance

**Time Required:** 5-10 minutes

---

## Prerequisites Checklist

Before starting:

- [ ] Dolibarr running at http://localhost:8080
- [ ] Logged in as **Administrator**
- [ ] Accounting module **enabled** (green checkmark in Modules/Applications)
- [ ] Company country set to **India**

---

## Part 1: Enable Accounting Module (If Not Already Active)

### Step 1.1: Navigate to Modules

1. **Top Menu Bar** → Click **Home**
2. **Left Sidebar** → Click **Setup**
3. Click **Modules/Applications**

**Visual Cue:** You'll see a list of all Dolibarr modules with ON/OFF toggles

### Step 1.2: Activate Accounting

1. **Search box** (top-right of modules list) → Type: `accounting`
2. Locate row: **"Accountancy (Double entries)"**
3. **Status column** → Should show green **"Active"** badge
   - If showing **"Disabled"** → Click the **"Enable"** button (or toggle switch)
4. Wait for page refresh confirming activation

**Confirmation:** Green success message appears: _"Module enabled"_

---

## Part 2: Access Accounting Systems Setup

### Step 2.1: Navigate to Chart of Accounts

**Method A - Via Accountancy Menu:**
1. **Top Menu Bar** → Click **Accountancy** (or **Accounting**)
2. **Submenu** → Click **Setup**
3. **Setup page** → Click **Chart of accounts**

**Method B - Via Setup:**
1. **Top Menu Bar** → Click **Home** → **Setup**
2. Scroll down to **"Modules"** section
3. Click **Accountancy** module link
4. Click **Chart of accounts**

**Visual Cue:** Page title shows _"Chart of accounts"_ or _"Plan comptable"_

### Step 2.2: Open Accounting Systems List

On the Chart of Accounts page:

1. Look for **tabs** near the top:
   - "Chart of accounts" (active by default)
   - **"Accounting systems"** or **"Chart models"**
2. Click the **"Accounting systems"** tab

**Visual Cue:** You'll see a table listing existing accounting systems (e.g., ENG-BASE, FRA PCG, etc.)

**Table Columns:**
- Country
- PCG Version (Code)
- Label
- Active (Yes/No or checkmark)

---

## Part 3: Create India Accounting System

### Step 3.1: Initiate New System Creation

On the Accounting Systems page:

1. Look for **"New"** or **"Create"** button
   - Usually **top-right corner** of the table
   - Or **bottom of the page** below the systems list
2. Click **"New"** button

**Visual Cue:** Form page opens with title: _"New accounting system"_ or _"Create chart model"_

### Step 3.2: Fill System Registration Form

Complete the form fields **exactly** as shown:

| Field Label | Value to Enter | Critical Notes |
|-------------|----------------|----------------|
| **Country** | `India` | Select from dropdown - scroll to find "India" |
| **Code** or **PCG Version** | `IN-GAAP` | **Case-sensitive**, no spaces, exactly as shown |
| **Label** | `Indian GAAP - Manufacturing` | Descriptive name (can customize) |
| **Description** (optional) | `Chart of Accounts for Indian Manufacturing with GST` | Optional but helpful |
| **Active** | ☑ **Checked** | Ensure checkbox is ticked |

**⚠️ CRITICAL:**
- **Code/PCG Version** must be **`IN-GAAP`** (uppercase, hyphen)
- This MUST match column 2 in your CSV import file
- Typos here will cause import failures

### Step 3.3: Save the System

1. Scroll to **bottom of form**
2. Click **"Create"** or **"Save"** button (usually blue)
3. Wait for page reload

**Success Confirmation:**
- Green banner message: _"Accounting system successfully created"_
- Page redirects to Accounting Systems list
- **IN-GAAP** now appears in the table with:
  - Country: **India**
  - PCG Version: **IN-GAAP**
  - Active: **Yes** ✓

---

## Part 4: Activate IN-GAAP for Your Company

### Step 4.1: Navigate to Company Setup

**Path:**
1. **Top Menu Bar** → Click **Home**
2. **Left Sidebar** → Click **Setup**
3. Click **Company/Organization** (or **Company/Foundation**)

**Visual Cue:** Page shows company details form with multiple sections

### Step 4.2: Locate Accounting Configuration

Scroll down the Company/Organization page to find:

**Section Header:** _"Accounting / Bookkeeping"_ or _"Accountancy"_

This section contains:
- Chart of accounts (dropdown)
- Fiscal year start
- Accounting mode settings
- Other accounting preferences

### Step 4.3: Select IN-GAAP

In the **"Chart of accounts"** or **"Accounting system"** field:

1. Click the **dropdown menu**
2. Locate: **`IN-GAAP - Indian GAAP - Manufacturing`**
   - Format: `[Code] - [Label]`
3. Click to select it

**Dropdown Options Should Include:**
- (Empty) - No chart selected
- ENG-BASE - UK Chart
- **IN-GAAP - Indian GAAP - Manufacturing** ← **Select this**
- Other countries...

### Step 4.4: Save Company Settings

1. Scroll to **bottom of page**
2. Click **"Modify"** or **"Save"** button
3. Wait for confirmation

**Success Confirmation:**
- Green message: _"Company information modified"_
- Page reloads with IN-GAAP shown as selected

---

## Part 5: Verification Steps

### Verify System Registration

**Navigate:** Accountancy → Setup → Chart of accounts → **Accounting systems** tab

**Check Table Row for IN-GAAP:**

| Country | PCG Version | Label | Active |
|---------|-------------|-------|--------|
| India | **IN-GAAP** | Indian GAAP - Manufacturing | ✓ Yes |

### Verify Company Assignment

**Navigate:** Home → Setup → Company/Organization

**Under "Accounting / Bookkeeping" section:**
- Chart of accounts: **IN-GAAP - Indian GAAP - Manufacturing**

### Verify Chart of Accounts Page

**Navigate:** Accountancy → Setup → Chart of accounts

**Top of page should display:**
- _"Chart of accounts: **IN-GAAP**"_
- _"No accounts found"_ or _"0 accounts"_ (normal - you'll import next)

---

## Part 6: Post-Registration Next Steps

### ✅ Registration Complete

You have successfully:
- Created IN-GAAP accounting system
- Linked it to your company
- Ready for account import

### 🔄 Continue to Import Process

**Next Action:** Import chart of accounts from CSV

**Steps:**
1. Navigate: **Home → Tools → Import**
2. Module: **Accounting**
3. Dataset: **Chart of accounts**
4. File: `/workspaces/dolibarr/other-docs/session/import_accounting_in_gaap_with_india_codes.csv`
5. Follow field mapping guide (see separate import guide)

**Import Guide Reference:** See `chart-of-accounts-setup.md` Step 5

---

## Troubleshooting

### Issue: "Accounting systems" tab not visible

**Possible Causes:**
- Accounting module not enabled
- Insufficient permissions
- Dolibarr version too old

**Solutions:**
1. Verify module active: Setup → Modules → Accountancy (should be green)
2. Log in as **admin** user (not regular user)
3. Try accessing via direct URL: `http://localhost:8080/htdocs/accountancy/admin/accountmodel.php`

### Issue: Country "India" not in dropdown

**Solution:**
1. Navigate: **Home → Setup → Dictionaries → Countries**
2. Search for: **India**
3. Should show: Code = **IN** or **102**, Active = **Yes**
4. If missing or inactive, activate it
5. Return to accounting system creation

### Issue: Cannot create - "PCG version already exists"

**Meaning:** IN-GAAP already registered

**Solution:**
1. Go to: Accountancy → Setup → Chart of accounts → Accounting systems
2. Find **IN-GAAP** row in table
3. If **Active = No**: Click the row → Change Active to **Yes** → Save
4. If **Active = Yes**: Skip to Part 4 (activate for company)

### Issue: Form has different field names

**Dolibarr versions vary slightly**

**Field Name Variations:**

| What You See | What to Enter |
|--------------|---------------|
| "Code" | `IN-GAAP` |
| "PCG Version" | `IN-GAAP` |
| "Accounting model code" | `IN-GAAP` |
| "Chart code" | `IN-GAAP` |

**All variations** → Enter: **`IN-GAAP`**

### Issue: Import fails - "Accounting system not found"

**Cause:** Mismatch between system code and CSV

**Solution:**
1. Verify system: Accountancy → Setup → Accounting systems
2. Confirm **exact code**: `IN-GAAP` (case-sensitive)
3. Open CSV file: `import_accounting_in_gaap_with_india_codes.csv`
4. Check column 2 - all values must be exactly `IN-GAAP`
5. Re-save CSV if needed (UTF-8 encoding)

### Issue: "Save" button grayed out or disabled

**Solution:**
1. Check all **required fields** are filled (usually marked with red asterisk *)
2. Ensure **Code/PCG Version** contains no spaces or special characters
3. Try different browser (Chrome/Firefox) if issue persists
4. Check browser console for JavaScript errors (F12 → Console tab)

---

## Screenshots Location Guide

**When taking screenshots for reference:**

1. **Modules Page:** Showing "Accountancy (Double entries)" module active
2. **Chart of Accounts:** Tabs showing "Chart of accounts" and "Accounting systems"
3. **New System Form:** Empty form before filling
4. **Filled Form:** Complete with IN-GAAP values
5. **Systems List:** Table showing IN-GAAP registered
6. **Company Setup:** Accounting section with IN-GAAP selected
7. **Verification:** Chart of accounts page showing "Chart: IN-GAAP"

**Screenshot Storage:** `/workspaces/dolibarr/other-docs/guides/screenshots/`

---

## Quick Reference Card

### Registration Summary

```
1. Enable Module:     Setup → Modules → Accountancy → Enable
2. Open Systems:      Accountancy → Setup → Chart of accounts → Accounting systems
3. Create New:        Click "New" button
4. Fill Form:         Country=India, Code=IN-GAAP, Label=Indian GAAP, Active=Yes
5. Save:              Click "Create"
6. Activate Company:  Setup → Company → Chart of accounts → Select IN-GAAP
7. Verify:            Accountancy → Chart of accounts → Should show "IN-GAAP"
```

### Critical Values

| Field | Exact Value |
|-------|-------------|
| Country | India (from dropdown) |
| Code | `IN-GAAP` (case-sensitive, no spaces) |
| Active | Yes / Checked |

### Import File Requirement

CSV Column 2 must contain: `IN-GAAP` (matches system code)

---

## Related Documentation

- **System Creation (this doc):** `/workspaces/dolibarr/other-docs/guides/ui-register-india-accounting-system.md`
- **COA Setup Guide:** `/workspaces/dolibarr/other-docs/guides/chart-of-accounts-setup.md`
- **CSV Import File:** `/workspaces/dolibarr/other-docs/session/import_accounting_in_gaap_with_india_codes.csv`
- **Alternative Registration:** `/workspaces/dolibarr/other-docs/guides/create-india-accounting-system.md` (includes SQL method)

---

**Document Version:** 1.0  
**Created:** 2025-11-18  
**Dolibarr Version:** 23.0.0-alpha  
**Target:** India/Karnataka Manufacturing with GST
