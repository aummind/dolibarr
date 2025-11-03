# GST E-invoicing and QR (India)

Non-official checklist – validate with current GST/NIC guidance and statutory advisors before implementation.

## Scope
- E-invoicing for B2B, and QR code for B2C invoices above applicable thresholds.
- Maintain fields for IRN, Acknowledgement No/Date, Signed QR payload, Invoice Reference.

## Data to capture
- Supplier: Legal name, address, GSTIN, place of supply, state code.
- Customer: Legal name, address, GSTIN (if registered), place of supply.
- Invoice: Document type, number, date, HSN/SAC, taxable value, CGST/SGST/IGST, discounts, freight, round-off.
- E-invoice: IRN, Ack No, Ack Date, Signed QR, QR string, EWB details (if any).

## System behavior
- Generate JSON payload conforming to current schema (versioned). Store the signed response.
- Print QR in invoice PDF; include IRN and Ack details when available.
- Handle cancellations/credit notes as per schema; keep audit trail.

## Integration notes
- Decide on integration method (direct NIC or via GSP). Handle credentials securely.
- Rate limits, retries, error handling, and offline fallbacks per legal allowances.
- Time sync and signing requirements.

## Dolibarr integration
- Custom fields on invoices for IRN/Ack/QR payload.
- Hook into invoice validation event to trigger e-invoice generation (when enabled).
- PDF templates updated to render QR and fields.

## Open items
- Confirm schema version and endpoints.
- Confirm QR content and size within template.
- Confirm B2C QR rules for current period.
