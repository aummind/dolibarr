# Chart of Accounts Setup Guide - India Manufacturing

**Purpose:** Manual setup of Chart of Accounts (COA) for India-based manufacturing in Dolibarr, with GST compliance.

**Target:** Karnataka-based manufacturing company using Indian GAAP and GST.

---

## Prerequisites

1. **Dolibarr installed and accessible**
2. **Admin user credentials**
3. **Accounting module enabled**
4. **Company details configured** (India country, Karnataka state)

---

## Step 1: Enable Accounting Module

1. Login as administrator
2. Navigate: **Home → Setup → Modules/Applications**
3. Search for "Accounting" or "Accountancy"
4. Click **Activate** if not already enabled
5. Confirm activation message appears

---

## Step 2: Create Chart of Accounts System

### Access Setup
1. Navigate: **Accountancy → Setup → Chart of accounts**
2. Click **"Setup"** tab in accounting admin area

### Create New COA System (if no India COA exists)
1. Go to: **Accountancy → Setup → Accounting system**
2. Click **"New"** or **"Create"**
3. Fill in:
   - **Country:** India (IN)
   - **PCG Version Code:** `IN-GAAP` or `IN-MFG` (your choice)
   - **Label:** "Indian GAAP - Manufacturing"
   - **Active:** Yes
4. Click **"Create"**

### Set as Active COA
1. Navigate: **Home → Setup → Company/Organization**
2. Find **"Accounting/Bookkeeping"** section
3. Select your new COA system: `IN-GAAP` or `IN-MFG`
4. Save

---

## Step 3: Account Structure - Indian GAAP for Manufacturing

### Recommended Account Number Ranges

Based on Schedule III of Companies Act 2013 and GST requirements:

#### **Assets (1000-1999)**
- **1000-1099:** Cash and Bank
  - 1000: Cash on Hand
  - 1010: Petty Cash
  - 1100: Bank Account - [Bank Name]
  - 1110: Bank Account - [Another Bank]

- **1100-1199:** Current Assets
  - 1200: Sundry Debtors (Accounts Receivable)
  - 1210: Advances to Suppliers
  - 1220: Employee Advances
  - 1230: Loans and Advances - Others

- **1300-1499:** Inventory
  - 1300: Raw Materials
  - 1310: Work in Progress (WIP)
  - 1320: Finished Goods
  - 1330: Packing Materials
  - 1340: Stores and Spares

- **1500-1699:** Fixed Assets
  - 1500: Land
  - 1510: Buildings
  - 1520: Plant and Machinery
  - 1530: Furniture and Fixtures
  - 1540: Vehicles
  - 1550: Computers and IT Equipment
  - 1560: Office Equipment

- **1700-1799:** GST Input Tax Credit
  - 1700: GST Input - CGST Receivable
  - 1710: GST Input - SGST Receivable
  - 1720: GST Input - IGST Receivable
  - 1730: GST Input - UTGST Receivable (if applicable)
  - 1740: GST - RCM Input Credit

- **1800-1899:** Other Current Assets
  - 1800: Prepaid Expenses
  - 1810: Deposits (Refundable)
  - 1820: TDS Receivable

#### **Liabilities (2000-2999)**
- **2000-2099:** Current Liabilities
  - 2000: Sundry Creditors (Accounts Payable)
  - 2010: Short-term Loans
  - 2020: Bank Overdraft

- **2100-2199:** GST Payables
  - 2100: GST Output - CGST Payable
  - 2110: GST Output - SGST Payable
  - 2120: GST Output - IGST Payable
  - 2130: GST Output - UTGST Payable (if applicable)
  - 2140: GST - Tax Collected at Source (TCS)

- **2200-2299:** Statutory Liabilities
  - 2200: TDS Payable
  - 2210: PF Payable
  - 2220: ESI Payable
  - 2230: Professional Tax Payable
  - 2240: Income Tax Payable

- **2300-2399:** Employee Payables
  - 2300: Salaries Payable
  - 2310: Wages Payable
  - 2320: Bonus Payable

- **2400-2499:** Other Current Liabilities
  - 2400: Advances from Customers
  - 2410: Expenses Payable
  - 2420: Security Deposits (from customers/vendors)

- **2500-2999:** Long-term Liabilities
  - 2500: Term Loans
  - 2510: Mortgage Loans
  - 2520: Unsecured Loans

#### **Equity (3000-3999)**
- 3000: Share Capital / Proprietor's Capital
- 3100: Retained Earnings
- 3200: Reserves and Surplus
- 3300: Current Year Profit/Loss

#### **Revenue / Income (4000-4999)**
- **4000-4099:** Sales - Domestic
  - 4000: Sales - Products (Domestic)
  - 4010: Sales - Services (Domestic)
  - 4020: Sales Returns - Products
  - 4030: Sales Returns - Services

- **4100-4199:** Sales - Interstate
  - 4100: Sales - Products (Interstate IGST)
  - 4110: Sales - Services (Interstate IGST)

- **4200-4299:** Sales - Exports
  - 4200: Sales - Products (Export)
  - 4210: Sales - Services (Export)

- **4300-4399:** Other Income
  - 4300: Interest Income
  - 4310: Discount Received
  - 4320: Miscellaneous Income
  - 4330: Foreign Exchange Gain

#### **Expenses / Cost of Goods Sold (5000-5999)**
- **5000-5099:** Direct Material Costs
  - 5000: Raw Material Purchases - Domestic
  - 5010: Raw Material Purchases - Interstate
  - 5020: Raw Material Purchases - Import
  - 5030: Packing Material Purchases
  - 5040: Purchase Returns

- **5100-5199:** Direct Labor
  - 5100: Direct Wages
  - 5110: Contract Labor - Manufacturing

- **5200-5299:** Manufacturing Expenses
  - 5200: Factory Rent
  - 5210: Power and Fuel
  - 5220: Water Charges - Factory
  - 5230: Factory Maintenance
  - 5240: Consumables and Stores
  - 5250: Job Work Charges

#### **Operating Expenses (6000-6999)**
- **6000-6099:** Employee Costs
  - 6000: Salaries - Admin
  - 6010: Salaries - Sales
  - 6020: Employee Benefits (PF, ESI, Gratuity)
  - 6030: Staff Welfare

- **6100-6199:** Administrative Expenses
  - 6100: Office Rent
  - 6110: Office Maintenance
  - 6120: Electricity - Office
  - 6130: Telephone and Internet
  - 6140: Postage and Courier
  - 6150: Printing and Stationery
  - 6160: Insurance
  - 6170: Legal and Professional Fees
  - 6180: Audit Fees
  - 6190: License and Registration Fees

- **6200-6299:** Selling and Distribution Expenses
  - 6200: Freight Outward
  - 6210: Sales Commission
  - 6220: Advertisement and Marketing
  - 6230: Travel - Sales Team
  - 6240: Vehicle Expenses - Sales

- **6300-6399:** Depreciation and Amortization
  - 6300: Depreciation - Buildings
  - 6310: Depreciation - Plant and Machinery
  - 6320: Depreciation - Furniture
  - 6330: Depreciation - Vehicles
  - 6340: Depreciation - Computers

- **6400-6499:** Financial Costs
  - 6400: Interest on Loans
  - 6410: Bank Charges
  - 6420: Foreign Exchange Loss

- **6500-6599:** Other Expenses
  - 6500: Repairs and Maintenance
  - 6510: Discount Allowed
  - 6520: Bad Debts Written Off
  - 6530: Miscellaneous Expenses

---

## Step 4: Creating Accounts Manually in Dolibarr

### Navigate to Chart of Accounts
1. Go to: **Accountancy → Setup → Chart of accounts**
2. Click **"New Account"** or **"Create"**

### For Each Account, Fill:

**Example: Creating "Cash on Hand" Account**

1. **Account Number:** `1000`
2. **Label:** `Cash on Hand`
3. **Short Label:** `Cash`
4. **Account Parent:** Leave blank (this is a top-level account) or select parent category
5. **PCG Type:** Select appropriate type:
   - `CAPIT` - Equity/Capital
   - `IMMO` - Fixed Assets
   - `STOCK` - Inventory
   - `THIRDPARTY` - Receivables/Payables
   - `FINAN` - Financial (Bank/Cash)
   - `EXPENSE` - Expenses
   - `INCOME` - Revenue
   - `PROD` - Products (for inventory valuation)
6. **Accounting Category:** Optional - used for grouping/reporting
7. **Reconcilable:** Check if this account needs bank reconciliation (e.g., bank accounts)
8. **Active:** Yes
9. Click **"Create"**

### Bulk Creation Tips
- Start with top-level categories (parent accounts)
- Then create child accounts
- Use consistent numbering (e.g., all bank accounts 1100-1199)
- Keep labels clear and consistent

### Example Account Creation Sequence

**Step 1: Create Parent Categories**
1. `1000` - Current Assets (parent)
2. `2000` - Current Liabilities (parent)
3. `3000` - Equity (parent)
4. `4000` - Revenue (parent)
5. `5000` - Direct Costs (parent)
6. `6000` - Operating Expenses (parent)

**Step 2: Create Child Accounts**
Under `1000 - Current Assets`:
- `1000` - Cash on Hand
- `1100` - Bank Account
- `1200` - Sundry Debtors
- `1700` - GST Input CGST
- etc.

---

## Step 5: GST-Specific Account Setup

### Critical GST Accounts

**Input Tax Credit (Assets - 1700-1799)**
1. Create: `1700 - GST Input CGST Receivable`
2. Create: `1710 - GST Input SGST Receivable`
3. Create: `1720 - GST Input IGST Receivable`

**Output Tax (Liabilities - 2100-2199)**
1. Create: `2100 - GST Output CGST Payable`
2. Create: `2110 - GST Output SGST Payable`
3. Create: `2120 - GST Output IGST Payable`

### GST Configuration Notes
- **Intra-state (within Karnataka):** CGST + SGST
- **Inter-state (outside Karnataka):** IGST only
- **Reverse Charge Mechanism (RCM):** Create separate accounts if needed

---

## Step 6: Configure Default Accounts

After creating accounts, map them to Dolibarr operations:

1. Navigate: **Accountancy → Setup → Default accounts**
2. Map the following:

### Customer/Supplier Accounts
- **Customer Account (Default):** `1200` (Sundry Debtors)
- **Supplier Account (Default):** `2000` (Sundry Creditors)

### Product Accounts (Domestic Sales)
- **Product Sold Account:** `4000` (Sales - Products Domestic)
- **Product Purchase Account:** `5000` (Raw Material Purchases)

### Product Accounts (Interstate Sales)
- **Product Sold Interstate:** `4100` (Sales - Products Interstate)

### Product Accounts (Export)
- **Product Sold Export:** `4200` (Sales - Products Export)

### Service Accounts
- **Service Sold Account:** `4010` (Sales - Services Domestic)
- **Service Purchase Account:** `5100` (Service Purchases)

### GST Accounts
- **VAT Sold Account (Output Tax):** `2100` (GST Output CGST) or create separate
- **VAT Buy Account (Input Tax):** `1700` (GST Input CGST)
- **VAT Payment Account:** (Where you pay GST to government)

### Other Key Accounts
- **Bank/Cash Transfer Account:** `1100` (Bank Account - for transfers)
- **Suspense Account:** `1800` (Suspense/Temporary)

---

## Step 7: Karnataka-Specific Considerations

### State Code
- Karnataka State Code: **29**
- Ensure this is set in Company → Organization setup

### SGST Rate
- Karnataka uses standard SGST rates
- Configure tax rates: **Home → Setup → Dictionaries → Taxes (VAT/GST)**

### Tax Dictionary Setup
1. Go to: **Home → Setup → Dictionaries → Taxes (VAT/GST)**
2. Create tax entries for common rates:

**Example: 18% GST (Intra-state Karnataka)**
- **Code:** `GST18_KA`
- **Label:** `GST 18% (9% CGST + 9% SGST)`
- **Type:** `GST`
- **Rate (%):** `18`
- **Localtax1 (CGST):** `9` (type: `1`)
- **Localtax2 (SGST):** `9` (type: `1`)
- **Country:** India
- **Active:** Yes

**Example: 18% GST (Inter-state IGST)**
- **Code:** `IGST18`
- **Label:** `IGST 18%`
- **Type:** `GST`
- **Rate (%):** `18`
- **Localtax1:** `0`
- **Localtax2:** `0`
- **Country:** India
- **Active:** Yes

Repeat for other rates: 5%, 12%, 28%, and 0% (exempted)

---

## Step 8: Testing and Verification

### Create Test Transactions
1. **Test Invoice (Intra-state):** Verify CGST + SGST split correctly
2. **Test Invoice (Inter-state):** Verify IGST applies
3. **Test Purchase:** Verify input tax credit accounts
4. **Test Payment:** Verify bank account entries

### Check Accounting Entries
1. Navigate: **Accountancy → Journals**
2. Select journal type (Sales, Purchase, Bank)
3. Verify account numbers appear correctly
4. Check debit/credit balance

### Validate GST Reports
- Generate trial balance
- Verify GST input vs output balances
- Check if ready for GSTR-1 / GSTR-3B reconciliation

---

## Step 9: Backup After Setup

Once COA is configured and tested:

```bash
cd /workspaces/dolibarr/docker-deploy
./mark_blank_backup.sh
```

This creates a protected baseline backup with clean COA.

---

## Step 10: Maintenance and Updates

### Regular Reviews
- **Monthly:** Review account usage and add missing accounts
- **Quarterly:** Align with GST return periods
- **Annually:** Review for regulatory changes

### Adding New Accounts
- Follow same numbering scheme
- Document in this guide or workspace notes
- Test with small transactions first

### Exporting COA
1. Navigate: **Accountancy → Setup → Chart of accounts**
2. Use **Export** function to save as CSV/Excel
3. Store in `other-docs/compliance/` or backup location

---

## Troubleshooting

### Issue: "No chart of accounts set"
**Solution:** Go to Setup → Company/Organization → Select COA system

### Issue: "Account not found" when creating invoice
**Solution:** Check Default Accounts mapping (Step 6)

### Issue: GST not splitting into CGST+SGST
**Solution:** 
1. Verify tax dictionary has localtax1 (CGST) and localtax2 (SGST)
2. Check product tax rate assignment
3. Verify customer state matches company state (Karnataka)

### Issue: Wrong GST type applied (IGST instead of CGST+SGST)
**Solution:**
- Check customer address state
- For intra-state (within Karnataka): Should use CGST+SGST
- For inter-state (outside Karnataka): Should use IGST

---

## Resources

### Internal Documentation
- Compliance Index: `/workspaces/dolibarr/other-docs/compliance/README.md`
- Session Context: `/workspaces/dolibarr/session-context.md`
- Docker Setup: `/workspaces/dolibarr/docker-deploy/setup/README.md`

### External References
- **Indian GAAP:** Schedule III, Companies Act 2013
- **GST Portal:** https://www.gst.gov.in/
- **Karnataka VAT/CST:** https://ctax.karnataka.gov.in/
- **Dolibarr Accounting Docs:** https://wiki.dolibarr.org/index.php/Module_Accounting

### Search Terms for India COA
If searching online for pre-built India COA for Dolibarr:
- "Dolibarr India chart of accounts"
- "Dolibarr Indian GAAP COA"
- "Dolibarr GST accounting setup India"
- "Dolibarr Karnataka manufacturing accounts"

---

## Notes

- **No legal advice:** This guide provides technical setup only; consult a chartered accountant for compliance
- **Customize:** Adjust account numbers and structure to your business needs
- **Document changes:** Keep this guide updated as you modify the COA
- **Version control:** Track COA changes in session notes or compliance docs

---

**Last Updated:** 2025-11-18  
**Phase:** Installation & Base Configuration  
**Prepared for:** Karnataka-based chemical manufacturing implementation
