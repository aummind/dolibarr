# Materials taxonomy and secure product configuration

This guide sets up your materials hierarchy, product codes, secure technical names, and supplier trade-name mapping in Dolibarr (v23+), following your manufacturing/MRO/safety model.

## Overview

- Categories: Root families MANUFACTURING, MAINTENANCE, SAFETY with defined sub-categories
- Product code policy: every material identified by a stable code in Ref (can also be encoded as QR barcode)
- Product naming: product Label = sub-category name for quick visual grouping; detailed names held in secure fields
- Secure technical data: technical/IUPAC/CAS stored in restricted extrafields (managers/admins only)
- Supplier mapping: same material linked to multiple vendors (trade names, vendor SKU/price)

---

## Policy contract (what we enforce)

1) Exclusive code-based identity
- Every material has a unique, stable code. Store it in Ref and (optionally) mirror it into the Barcode field. If the Barcode module is enabled, set barcode = Ref (QR recommended) so scans resolve to the same source of truth.

2) Visual grouping by sub-category
- Product Label intentionally matches the sub-category concept (for manufacturing: “solvent”, “chemical”, “resin”, …). This keeps lists/documents scannable; the specific technical identity lives in secure fields.

3) Multiple technical names supported
- Maintain multiple name fields: Technical name(s), IUPAC name(s), and CAS number.

4) Access-controlled confidentiality
- Technical fields are restricted to permitted users only (Managers/Admins). Use extrafield visibility (if available in your version) or “Internal only” plus group permissions.

5) Vendor trade-name linkage
- The same internal material (Ref) can be supplied by multiple vendors under different trade names. Link them on the product’s Suppliers prices tab (Vendor SKU = trade name), keeping internal technical names separate and secure.

---

## 1) Create/verify root categories

UI path: Products/Services > Dictionaries > Categories > Product/Service categories

Create these root categories if not already present:
- MANUFACTURING (type=Product/Service)
- MAINTENANCE (type=Product/Service)
- SAFETY (type=Product/Service)

Tip: Categories > New category. Keep parent empty (root).

---

## 2) Create sub-categories

Create the following sub-categories under their parent. Use type = Product/Service (Type=0).

Parent: MANUFACTURING
- SOLVENT — Solvents - Organic and inorganic volatile compounds, water
- CHEMICAL — Chemicals - Pure and/or compounded
- RESIN — Resins - Thermoplastic thermosetting functional bio-sourced oils etc
- POLYMERS — Polymers - Synthetic natural modified polymers
- FORMULATED — Formulated Products - Ready-to-use solutions custom blends
- OTHERS — Other materials - Gases desiccants etc
- PIGMENTS — Pigments and Dyes - Organic/inorganic pigments dyes
- FILLER — Fillers - Mineral organic reinforcing fillers others
- ADDITIVE — Additives - Processing aids performance enhancers property modifiers dispersing agents wetting agents defoamers surface tension modifiers deaerators
- FUNCTIONAL — Functional Fillers - Electrical flame retardant thermal optical
- PAINTS — Paints and Coatings - Paints protective coatings
- LUBRICANTS — Chemical Lubricants - Lubricants greases
- SAMPLE — Chemical Samples - Test samples reference standards

Parent: MAINTENANCE
- CLEANING — Cleaning Compounds - Rust convertor passivator degreaser solvent detergent cleaners
- COATINGS — Maintenance Coatings - Paints protective coatings touch-ups
- OILS AND LUBRICANTS — Oils and lubricants - Equipment oils bearing greases
- SPARES — Spare Parts - Mechanical electrical instrumentation parts
- TOOLS — Tools - Mechanical tool machining kits speciality
- CONSUMABLES — Maintenance Consumables - Filters gaskets seals grinding media

Parent: SAFETY
- EQUIPMENT — Safety Equipment - Fire systems emergency showers ventilation
- CONSUMABLES-S — Safety Consumables - First aid spill kits absorbents
- PROTECTIVE — Protective Gear - PPE respiratory protection eye protection
- CHEMICALS-S — Safety Chemicals - Neutralizers emergency response chemicals

Optional import template: docker-deploy/debug_info/categories_import_earth.csv

---

## 2.1) Earthy colors for categories

We ship an earthy palette so root categories have deeper tones and sub-categories lighter shades. You can set colors in two ways:

- Import path: the seed file includes the Color column (hex, no #):
  - docker-deploy/debug_info/categories_import_earth.csv
- Update existing categories: run the helper when the stack is running:

  ```bash
  chmod +x docker-deploy/tools/apply_category_colors.sh
  docker-deploy/tools/apply_category_colors.sh
  ```

Roots (suggested):
- MANUFACTURING: 8B5E3C
- MAINTENANCE: 6B8E23
- SAFETY: B38F1D

Notes
- Colors are hex without the leading # (Dolibarr accepts either; we standardize without # in TSV/SQL).
- You can tweak any shade later from the category edit page.

---

## 3) Product code and barcode policy

UI path: Setup > Modules > Products/Services > Setup

- Reference (Ref) policy:
  - Choose manual or numbering mask that supports your SKU style (e.g., CHM-SOL-TOL-20L-R00)
  - Keep Ref short, stable, machine-friendly (A–Z 0–9 - _)

UI path: Setup > Modules > Barcode

- Enable Barcode module
- Default encoding: QR Code (or your preferred symbology)
- Configure generation: either auto-generate on product create, or set barcode value = Ref (keeps one source of truth)
  - Recommended: set “Barcode value equals Ref” so barcode and code always match.

Result: every material has a stable Ref code; barcode (QR) can mirror Ref on the product card and PDFs/labels.

---

## 4) Secure technical data via extrafields

UI path: Setup > Dictionaries > Extra fields > Products (product)

Create these extrafields:

- tech_name
  - Type: Text (long)
  - Label: Technical name(s)
  - Visibility: Internal only; if your version supports group-restricted visibility, select only Managers/Admins
  - Help: One per line; do not include trade names

- iupac_name
  - Type: Text (long)
  - Label: IUPAC name(s)
  - Visibility: Internal only; restrict to Managers/Admins if available

- cas_number
  - Type: Varchar(64)
  - Label: CAS No.
  - Visibility: Internal only; restrict to Managers/Admins if available
  - Validation: optional regex e.g. ^\d{2,7}-\d{2}-\d$

Notes
- Field-level group visibility depends on your Dolibarr version; if not present, start with “Internal” visibility and limit access to product cards to internal roles only. We can implement a tiny module/hook to enforce group-level visibility later if needed.
- Keep public-facing product Label non-sensitive (see section 5).

---

## 5) Product naming convention

- Ref (code): your SKU/code (e.g., CHM-SOL-TOL-20L-R00) — stable, used for lookups/barcode
- Label: should match the sub-category concept for quick scanning, e.g. “SOLVENT”, “CHEMICAL”, “RESIN”, or a human-friendly concise variant (e.g., “Toluene 20 L Drum”) depending on how you want it on documents
- Description (short/long): customer-facing descriptions (non-sensitive); technical details remain in extrafields
- Category assignment: on product > Categories tab, attach to the precise sub-category (e.g., MANUFACTURING → SOLVENT)

Tip: If you choose a generic Label (e.g., SOLVENT), add differentiators (pack size/grade) as Variants or in Ref.

---

## 6) Vendor trade name mapping

UI path: Products/Services > Product card > Suppliers prices

- Add supplier linkage(s) for the same product:
  - Vendor: select supplier
  - Vendor SKU: trade name / supplier reference
  - Min qty, price, currency, lead time as provided

This links multiple supplier trade names to the same internal material code (Ref). Use the “Best price” tools for purchasing.

Optional: add an extrafield on product for common synonyms (non-trade) if helpful (Type: Text long, internal only).

---

## 7) Permissions checklist

UI path: Setup > Security > Users & Groups

- Create a group “Formulation Managers”
- Add managers/admins who can view sensitive fields

UI path: Setup > Modules > Products/Services > Permissions (and Advanced permissions)

- Ensure read/write access to products is granted to necessary staff, limit price/stock where needed

UI path: Setup > Dictionaries > Extra fields > Products (product)

- If your version supports group-restricted extrafield visibility, select only the “Formulation Managers” group for tech_name / iupac_name / cas_number
- Otherwise set to “Internal only” and limit product-card access to internal users; we can add a small hook later for per-group masking without changing core

---

## 8) Import/export workflows

- To seed categories at once: create your sub-categories via UI (low volume) or use the CSV template in docker-deploy/debug_info/categories_import_earth.csv
- For products: start with a small pilot set via UI; export to verify columns; then scale with CSV import (Ref, Label, Type, for sale/purchase, category links via the ‘Products categories’ dataset)
  - A ready-to-import CSV template is provided here: docker-deploy/debug_info/products_import_template.csv
  - Mapping in Imports → Products: Ref, Label, Type (0 product / 1 service), ToSell, ToBuy, Barcode (optional, leave blank if using Ref=barcode rule), Unit, PriceHT, VATRate, Duration (for services), Description, NotePublic

- Sensitive fields: import tech_name/iupac_name/cas_number via Products extrafields import (ensure visibility set first)

---

## 9) Validation checklist

- Categories tree shows parent/child as defined
- A sample product has:
  - Ref (code) assigned; barcode present (QR) if enabled
  - Label aligned to your chosen scheme (generic vs specific)
  - Categories tab linked to the correct sub-category
  - Extrafields populated (tech/IUPAC/CAS) and hidden for non-authorized users
  - Supplier prices added for at least one vendor (trade name in Vendor SKU)

---

## 10) Next steps (optional)

- Define SKU mask and variant attributes (e.g., pack size, grade) if you want variants instead of separate SKUs
- Add unit mappings (weight/length/volume units) carefully; confirm unit codes from llx_c_units before bulk import
- Implement per-group field masking if your version lacks extrafield group visibility (we can deliver a tiny hook/module)
- Add export/import templates for Products categories links to batch-attach products to categories

---

Questions or tweaks? Tell me your preferred SKU pattern (segments) and I’ll provide a mask and validation examples.
