# UI Guide: Configure Default Accounts (India - IN-GAAP)

Purpose: Map Dolibarr default accounts to your Indian GAAP chart (GST-ready) so invoices, purchases, stock moves, and payments post to the right ledgers automatically.

Applies to: Dolibarr 23.0.0-alpha, Accounting module enabled, `IN-GAAP` accounting system active.

---

## Prerequisites

- IN-GAAP accounting system created and selected for the company
- India COA imported (e.g., `/workspaces/dolibarr/other-docs/session/import_accounting_in_gaap_with_india_codes.csv`)
- GST tax rates created (5%, 12%, 18%, 28%) in Dictionaries

---

## Open Default Accounts Page

- Path: Accountancy → Setup → Default accounts
- Direct URL: `/htdocs/accountancy/admin/defaultaccounts.php?mainmenu=accountancy&leftmenu=accountancy_admin`

Tip: Use the search box on the page to quickly find each field below.

---

## Recommended Mappings (India COA)

Note: Use the exact account codes from your imported COA. All codes below exist in `import_accounting_in_gaap_with_india_codes.csv`.

### Core Third-Party
- Customer account: `1200` — Trade Receivables (Debtors)
- Supplier account: `2000` — Trade Payables (Creditors)

### Revenue
- Product sold account: `4000` — Revenue from Operations - Domestic
- Service sold account: `4030` — Service Income - Domestic
- Export sales account (if field exists): `4101` — Export Sales - Products

Guidance:
- If only one "Product sold" field exists, use `4001` and override at product card for interstate/export (use `4002` or `4101`).

### Purchases / COGS
- Product bought account: `5001` — Raw Material Purchases - Domestic
- Service bought account: `5206` — Job Work Charges Paid (general services for manufacturing)

Guidance:
- For admin services (consulting/legal), set account on the supplier invoice line or service card (e.g., `6112` Consultancy, `6113` Legal).

### GST / VAT
These defaults act as fallbacks. Prefer setting account codes on each tax rate in Dictionaries (Sell/Buy account) for CGST/SGST/IGST precision.

- VAT collected (sales): `2100` — GST Output Tax Payable (consolidated)
- VAT paid (purchases): `1700` — GST Input Tax Credit (consolidated)
- VAT to pay/rounding account (if only one): `2101` or use tax-rate specific mapping

Optional (set via Tax Dictionary ideally):
- Per-rate (preferred): Output `2101` (CGST), `2102` (SGST), `2103` (IGST); Input `1701` (CGST), `1702` (SGST), `1703` (IGST)

Path to set per-rate accounts: Home → Setup → Dictionaries → VAT rates → Edit each rate → set "Accountancy code (sell/buy)".

### Banking / Cash
- Cash account: `1001` — Cash on Hand
- Bank account (generic): `1100` — Bank Accounts (or select specific `1101`/`1102`/`1103` on bank journals)

Guidance:
- In Bank/Cash module, ensure each bank journal has its own ledger (e.g., `1101` HDFC, `1102` ICICI, `1103` SBI).

### Stock / Inventory
- Stock asset account: `1300` — Inventories
- Stock variation (increase): `5040` — Changes in Inventory
- Stock variation (decrease): `5040` — Changes in Inventory
- WIP (Work in Progress): `1330` — Work in Progress (WIP)

Guidance:
- If you prefer separate increase/decrease accounts, create them and update here later.

### Fixed Assets / Depreciation
- Accumulated depreciation: `1680` — Accumulated Depreciation
- Depreciation expense: `6300` — Depreciation and Amortization

### Rounding / Write-off / Suspense
- Rounding differences (small diffs): `1801` — Suspense Account
- Bad debts write-off (if field exists): `6502` — Bad Debts Written Off

---

## Step-by-Step

1. Open: Accountancy → Setup → Default accounts
2. For each field above, type the code and select the matching label from autocomplete
3. Click Save at bottom of the page
4. Repeat for any additional tabs/sections on the page (Sales, Purchases, Stock, Bank), depending on your Dolibarr version

---

## Verify Configuration

- Create a test product and service (set specific sell accounts only if needed)
- Create an intra-state customer invoice (Karnataka → Karnataka)
  - Lines post to `4001` (product) / `4030` (service)
  - Taxes post to `2101` and `2102` (if tax dictionary mapped)
- Create a supplier invoice
  - Lines post to `5001` (materials) or chosen service expense
  - Taxes post to `1701` and `1702` (if tax dictionary mapped)
- Review: Accountancy → Journals, and General Ledger for correct postings

---

## Tips for India GST

- Always map tax-rate accounts in Dictionaries for CGST/SGST/IGST specificity; defaults are only fallbacks
- For inter-state sales/purchases, ensure IGST rates use `2103`/`1703`
- For exports with LUT/Zero-rated, map to `4101`/`4102` revenue with zero tax

---

## Quick Reference (Codes)

- Receivable: `1200` | Payable: `2000`
- Sales (domestic default): `4000` | Sales (interstate): `4002` | Export: `4101`
- Service income: `4030`
- Purchases (materials): `5001` | Job work: `5206`
- GST Output default: `2100` | Per-tax: `2101` (CGST), `2102` (SGST), `2103` (IGST)
- GST Input default: `1700` | Per-tax: `1701` (CGST), `1702` (SGST), `1703` (IGST)
- Cash: `1001` | Bank: `1100` (or specific)
- Stock asset: `1300` | Stock change: `5040` | WIP: `1330`
- Accum. Depreciation: `1680` | Depreciation expense: `6300`
- Rounding/Suspense: `1801` | Bad debts: `6502`

---

## Troubleshooting

- Missing a field? Your Dolibarr build may group defaults by section; check all tabs.
- Code not found in autocomplete? Ensure the account exists and is Active in your COA.
- Taxes still posting to wrong account? Edit VAT rate in Dictionaries and set correct sell/buy account codes.
- Stock postings missing? Enable Stock module and set stock movement options under Products/Stock setup.

---

## Field-by-Field Mapping (Dolibarr Default Accounts)

Use the following for the page Accountancy → Setup → Default accounts. All codes exist in `import_accounting_in_gaap_with_india_codes.csv`.

### Third parties | Users
- Customer third parties: `1200` — Trade Receivables (Debtors)
- Vendor third parties: `2000` — Trade Payables (Creditors)
- Users on salaries (default): `2301` — Salaries Payable
- Users on expense reports (default): `2300` — Employee Payables

### Product
- Sold products (default): `4000` — Revenue from Operations - Domestic
- Products sold and exported: `4101` — Export Sales - Products
- Products purchased within same country: `5001` — Raw Material Purchases - Domestic
- Products purchased and imported: `5003` — Raw Material Purchases - Import

### Service
- Sold services (default): `4030` — Service Income - Domestic
- Services sold and exported: `4102` — Export Sales - Services
- Services purchased within same country: `5206` — Job Work Charges Paid
- Services purchased and imported: `5206` — Job Work Charges Paid (use RCM fields below if applicable)

### Others
- VAT on sales (default): `2100` — GST Output Tax Payable (consolidated)
- VAT on purchases (default): `1700` — GST Input Tax Credit (consolidated)
- Paying VAT: `2100` — GST Output Tax Payable (clearing on payment)
- Local tax 1 on sales: Leave empty (not used in India)
- Local tax 1 on purchases: Leave empty (not used in India)
- Paying local tax 1: Leave empty (not used in India)
- Local tax 2 on sales: Leave empty (not used in India)
- Local tax 2 on purchases: Leave empty (not used in India)
- Paying local tax 2: Leave empty (not used in India)
- VAT on purchases for reverse charges (Credit): `2100` — GST Output Tax Payable
- VAT on purchases for reverse charges (Debit): `1710` — GST - RCM Input Credit
- Local tax 1 on purchases for reverse charges (Credit): Leave empty
- Local tax 1 on purchases for reverse charges (Debit): Leave empty
- Local tax 2 on purchases for reverse charges (Credit): Leave empty
- Local tax 2 on purchases for reverse charges (Debit): Leave empty
- Transitional bank transfers: `1801` — Suspense Account (use temporarily; create a dedicated transit account later if desired)
- Donations (Donation module): `4406` — Miscellaneous Income (Donation module records receipts)
- Membership subscriptions (Membership module, no invoice): `6520` — Miscellaneous Expenses (note: expense classification)
- Capital (Loan module): `2500` — Long-term Borrowings
- Interest (Loan module): `6401` — Interest on Term Loans
- Insurance (Loan module): `6130` — Insurance - General
- Unallocated funds in waiting: `1801` — Suspense Account

### Discounts
- Accounting discounts granted: `4203` — Discounts and Rebates Allowed
- Accounting discounts received: `4406` — Miscellaneous Income

### Down payments
- Customer deposit (advance received): `2010` — Advances from Customers
- Supplier deposit (advance paid): `1220` — Advances to Suppliers

Notes:
- For GST precision, set accounts on each VAT rate (CGST/SGST/IGST) in Dictionaries; defaults above act only as fallbacks.
- If you prefer dedicated accounts for “bank transfer in transit” or “imported services”, create them later and update this page accordingly.
