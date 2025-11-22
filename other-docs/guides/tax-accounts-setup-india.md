# Tax Accounts Configuration Guide (India - IN-GAAP)

**Purpose:** Configure accounting codes for taxes in Dolibarr dictionaries and modules for India/Karnataka with GST, TDS, and Professional Tax compliance.

**Applies to:** Dolibarr 23.0.0-alpha with IN-GAAP accounting system active.

---

## Prerequisites

- IN-GAAP accounting system created and active
- India COA imported with tax accounts (codes 1700-1799, 2100-2299)
- Accounting module enabled

---

## Overview: Tax Accounts in IN-GAAP

Your chart includes these tax account categories:

### GST (Goods and Services Tax)
**Input Tax Credit (ITC) - Assets:**
- `1700` — GST Input Tax Credit (parent/consolidated)
- `1701` — GST Input - CGST Receivable
- `1702` — GST Input - SGST Receivable
- `1703` — GST Input - IGST Receivable
- `1704` — GST Input - UTGST Receivable
- `1710` — GST - RCM Input Credit (Reverse Charge Mechanism)

**Output Tax Payable - Liabilities:**
- `2100` — GST Output Tax Payable (parent/consolidated)
- `2101` — GST Output - CGST Payable
- `2102` — GST Output - SGST Payable
- `2103` — GST Output - IGST Payable
- `2104` — GST Output - UTGST Payable
- `2110` — GST - TCS Payable (Tax Collected at Source)

### TDS (Tax Deducted at Source)
**Receivable (when you pay and deduct TDS):**
- `1720` — TDS Receivable (parent/consolidated)
- `1721` — TDS on Contracts
- `1722` — TDS on Professional Fees

**Payable (when others deduct TDS from your income):**
- `2201` — TDS Payable

### Other Statutory Taxes
- `2202` — TCS Payable (Tax Collected at Source - on sales)
- `2203` — Income Tax Payable
- `2230` — Professional Tax Payable (Karnataka PT on salaries)
- `2240` — Labour Welfare Fund Payable

### Payroll Statutory Liabilities
- `2210` — PF (Provident Fund) Payable
- `2211` — Employee PF Payable
- `2212` — Employer PF Payable
- `2220` — ESI (Employee State Insurance) Payable
- `2221` — Employee ESI Payable
- `2222` — Employer ESI Payable

---

## Part 1: Configure GST in VAT Dictionary

### Step 1.1: Access VAT Rates Dictionary

**Navigate:** Home → Setup → Dictionaries → **VAT rates**

**Direct URL:** `/htdocs/admin/dict.php?id=10&from=accountancy`

### Step 1.2: GST Rate Configuration

Configure three GST rates for Karnataka intra-state (CGST+SGST split):

#### GST 5% (Intra-state Karnataka)

| Field | Value |
|-------|-------|
| Country | India |
| Code | `GST-5-INTRA` |
| Rate (%) | `5` |
| Type | Standard |
| Note/Label | `GST 5% (2.5% CGST + 2.5% SGST) - Karnataka` |
| **Accountancy code (sell)** | `2101` — GST Output - CGST Payable |
| **Accountancy code (buy)** | `1701` — GST Input - CGST Receivable |
| Active | Yes |

**Important:** Dolibarr typically applies one account code per tax line. For CGST+SGST split:
- Create a second tax rate entry with same 5% but account `2102` (SGST sell) / `1702` (SGST buy)
- Or configure via tax calculation rules (advanced)

**Recommended Approach:** Use consolidated accounts `2100`/`1700` for defaults; split manually in journals if required for GST return filing.

#### GST 12% (Intra-state Karnataka)

| Field | Value |
|-------|-------|
| Country | India |
| Code | `GST-12-INTRA` |
| Rate (%) | `12` |
| Note/Label | `GST 12% (6% CGST + 6% SGST) - Karnataka` |
| **Accountancy code (sell)** | `2101` or `2100` |
| **Accountancy code (buy)** | `1701` or `1700` |
| Active | Yes |

#### GST 18% (Intra-state Karnataka)

| Field | Value |
|-------|-------|
| Country | India |
| Code | `GST-18-INTRA` |
| Rate (%) | `18` |
| Note/Label | `GST 18% (9% CGST + 9% SGST) - Karnataka` |
| **Accountancy code (sell)** | `2101` or `2100` |
| **Accountancy code (buy)** | `1701` or `1700` |
| Active | Yes |

#### GST 28% (Intra-state Karnataka)

| Field | Value |
|-------|-------|
| Country | India |
| Code | `GST-28-INTRA` |
| Rate (%) | `28` |
| Note/Label | `GST 28% (14% CGST + 14% SGST) - Karnataka` |
| **Accountancy code (sell)** | `2101` or `2100` |
| **Accountancy code (buy)** | `1701` or `1700` |
| Active | Yes |

### Step 1.3: IGST for Inter-state Transactions

For sales/purchases outside Karnataka:

#### GST 5% (Inter-state IGST)

| Field | Value |
|-------|-------|
| Country | India |
| Code | `GST-5-INTER` |
| Rate (%) | `5` |
| Note/Label | `GST 5% IGST - Inter-state` |
| **Accountancy code (sell)** | `2103` — GST Output - IGST Payable |
| **Accountancy code (buy)** | `1703` — GST Input - IGST Receivable |
| Active | Yes |

Repeat for 12%, 18%, 28% with codes `GST-12-INTER`, `GST-18-INTER`, `GST-28-INTER`.

### Step 1.4: Zero-rated GST (Exports with LUT)

| Field | Value |
|-------|-------|
| Country | India |
| Code | `GST-0-EXPORT` |
| Rate (%) | `0` |
| Note/Label | `GST 0% Export (LUT)` |
| **Accountancy code (sell)** | Leave empty or use `2103` |
| **Accountancy code (buy)** | Leave empty |
| Active | Yes |

---

## Part 2: Configure TDS in Dolibarr

### Current TDS Support in Dolibarr

**Note:** Dolibarr core does not have native TDS module as of 23.0.0-alpha. TDS must be handled via:
1. Manual journal entries
2. Custom module (if available)
3. Supplier invoice line-level deductions (workaround)

### Step 2.1: TDS Setup (Workaround Method)

#### Option A: Manual Journal Entries

When paying supplier invoices with TDS deduction:

**Example:** ₹10,000 invoice with 10% TDS (Section 194C - Contracts)

1. Supplier invoice posts: Debit `5001` (Expense) ₹10,000 | Credit `2000` (Payable) ₹10,000
2. When paying, create manual journal entry:
   - Debit `2000` (Payable) ₹10,000
   - Credit `1100` (Bank) ₹9,000
   - Credit `1721` (TDS on Contracts) ₹1,000

**TDS Deposit Entry** (when depositing to govt):
- Debit `2201` (TDS Payable) ₹1,000
- Credit `1100` (Bank) ₹1,000

**TDS Receivable → Payable Transfer** (at month-end):
- Debit `2201` (TDS Payable) ₹1,000
- Credit `1721` (TDS on Contracts) ₹1,000

#### Option B: Configure as "Other Tax" in Dolibarr

If your Dolibarr version supports "Local Tax" fields:

1. Navigate: Home → Setup → Dictionaries → **Taxes (TDS/TCS)**
2. Create entries for common TDS sections:
   - Section 194C (Contracts) - 1% or 2%
   - Section 194J (Professional Fees) - 10%
3. Set accountancy code (buy): `1721` or `1722`

**Limitation:** May not split TDS amount from payment automatically.

### Step 2.2: TDS Account Mapping Reference

Use these accounts when creating manual TDS entries:

**When you deduct TDS (paying suppliers):**
- Debit: Supplier payable `2000` (reduce liability)
- Credit: TDS Receivable `1721` (Contracts) or `1722` (Professional Fees)

**When TDS is deducted from your income (customer payments):**
- Debit: TDS Payable `2201` (customer owes you less)
- Credit: Customer receivable `1200` (reduce asset)

**When depositing TDS to government:**
- Debit: TDS Payable `2201`
- Credit: Bank `1100`

---

## Part 3: Configure Professional Tax (Karnataka)

### Step 3.1: Professional Tax Setup

**Professional Tax in Karnataka:** Monthly tax on salaries/wages (ranges from ₹0 to ₹200/month based on salary slab).

**Account Code:** `2230` — Professional Tax Payable

### Step 3.2: Configure in Payroll/Salary Module

If using Dolibarr HR/Payroll module:

1. Navigate: Home → Setup → Dictionaries → **Salary deductions**
2. Add entry:
   - Code: `PT-KA`
   - Label: `Professional Tax - Karnataka`
   - Type: Statutory deduction
   - **Accountancy code:** `2230`
3. When processing salaries, Professional Tax deduction posts to `2230`

### Step 3.3: Manual Entry Method

If not using HR module, record PT monthly:

**Salary payment with PT deduction:**
- Debit: `6001` (Salaries - Administrative) ₹50,000
- Credit: `1100` (Bank) ₹49,800
- Credit: `2230` (Professional Tax Payable) ₹200

**PT deposit to Karnataka govt:**
- Debit: `2230` (Professional Tax Payable) ₹200
- Credit: `1100` (Bank) ₹200

---

## Part 4: Payroll Statutory Accounts (PF/ESI)

### Step 4.1: Provident Fund (PF) Configuration

**Accounts:**
- `2211` — Employee PF Payable (deducted from salary)
- `2212` — Employer PF Payable (company contribution)
- `2210` — PF Payable (consolidated, if using one account)

**Typical Entry (Salary ₹50,000, 12% PF each for employee & employer):**
- Debit: `6001` (Salaries) ₹50,000
- Debit: `6010` (Employer PF Contribution) ₹6,000
- Credit: `2211` (Employee PF) ₹6,000 (deducted from employee)
- Credit: `2212` (Employer PF) ₹6,000 (company pays)
- Credit: `1100` (Bank) ₹44,000 (net pay to employee)

**PF Deposit to EPFO:**
- Debit: `2211` + `2212` = ₹12,000
- Credit: `1100` (Bank) ₹12,000

### Step 4.2: ESI Configuration

**Accounts:**
- `2221` — Employee ESI Payable (1.75% of salary)
- `2222` — Employer ESI Payable (4.75% of salary)
- `2220` — ESI Payable (consolidated)

Configure similarly to PF in Payroll dictionaries.

---

## Part 5: Verification and Testing

### Test GST Posting

1. Create a test customer invoice (intra-state):
   - Line: Product ₹10,000
   - Tax: GST 18% (select GST-18-INTRA)
2. Validate invoice
3. Check: Accountancy → Journals → Sales journal
4. Verify postings:
   - Debit: `1200` (Receivable) ₹11,800
   - Credit: `4000` (Sales) ₹10,000
   - Credit: `2101` or `2100` (GST Output) ₹1,800

### Test TDS (Manual Entry)

1. Create supplier invoice: ₹10,000 + GST 18% = ₹11,800
2. Validate
3. Payment: ₹11,800 less 1% TDS = ₹11,682 paid
4. Manual journal entry for TDS ₹118 to account `1721`

### Test Professional Tax

1. Process salary with PT deduction
2. Verify `2230` credited for deduction amount
3. Record PT payment to government, debit `2230`

---

## Quick Reference: Tax Account Codes

### GST
- Input (ITC): `1700` (consolidated) or `1701`/`1702`/`1703` (CGST/SGST/IGST)
- Output (Payable): `2100` (consolidated) or `2101`/`2102`/`2103` (CGST/SGST/IGST)
- RCM: `1710` (Input), `2101` or `2100` (Output)

### TDS
- Receivable (you deduct): `1721` (Contracts), `1722` (Professional Fees), `1720` (consolidated)
- Payable (deducted from you): `2201`

### Professional Tax (Karnataka)
- Payable: `2230`

### TCS
- Payable: `2202`

### Income Tax
- Payable: `2203`

### Payroll Statutory
- PF: `2211` (Employee), `2212` (Employer), `2210` (consolidated)
- ESI: `2221` (Employee), `2222` (Employer), `2220` (consolidated)
- Labour Welfare Fund: `2240`

---

## Troubleshooting

### GST not posting to correct accounts
- Check VAT rate dictionary: Accountancy code (sell/buy) fields must be populated
- If using consolidated `2100`/`1700`, split will not happen automatically
- For CGST+SGST split, consider custom tax calculation rules or manual journal adjustments

### TDS not supported in UI
- Use manual journal entries (see Part 2)
- Check for TDS module in Dolibarr marketplace
- Consider custom development for automated TDS calculation

### Professional Tax deduction not showing
- Verify HR/Payroll module enabled
- Check Salary deductions dictionary configuration
- Use manual journal entry method if module unavailable

### Tax account not appearing in autocomplete
- Ensure account exists in COA (Home → Accountancy → Chart of accounts)
- Check account status is Active
- Refresh browser cache

---

## Related Documentation

- **COA Setup:** `/workspaces/dolibarr/other-docs/guides/chart-of-accounts-setup.md`
- **Default Accounts:** `/workspaces/dolibarr/other-docs/guides/default-accounts-setup-india.md`
- **CSV Import:** `/workspaces/dolibarr/other-docs/session/import_accounting_in_gaap_with_india_codes.csv`

---

**Document Version:** 1.0  
**Created:** 2025-11-19  
**Dolibarr Version:** 23.0.0-alpha  
**Target:** India/Karnataka Manufacturing with GST, TDS, Professional Tax compliance
