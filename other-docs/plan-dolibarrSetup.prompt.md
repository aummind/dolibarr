## Plan: Complex Dolibarr Multi-Warehouse Setup

This plan establishes a CSV-driven, QR-enabled, document-intensive procurement and multi-warehouse system in Dolibarr. It prioritizes native UI/CSV workflows, defers custom development, and creates templates for future implementation.

### Steps

1. **Enable required modules and configure core settings** via Admin > Setup > Modules: Products & Services, Stock, Warehouses, Supplier Proposals, Supplier Orders, Supplier Invoices, Barcode, ECM, Workstation, Import, Export; set MAIN_FEATURES_LEVEL=2 for development mode

2. **Design and document 9-warehouse structure with custom purposes** using ExtraFields (Admin > Setup > Dictionaries > Extra Fields > Warehouse): add fields for `warehouse_type` (select: ingress/storage/quality/manufacturing/finished), `security_level`, `entry_procedure`; create CSV import template with hierarchy (fk_parent) for warehouses 11→21→31→41/42→51→52→91

3. **Create product/material specification framework** via ExtraFields on Products: add `approval_status` (select), `tds_file_url`, `sds_file_url`, `coa_file_url`, `carbon_data_file_url`, `specification_document`, `approved_by`, `approval_date`, `qc_required` (boolean), `default_qc_warehouse` (link to warehouse 41/42); generate CSV templates for bulk import

4. **Build QR code system** by setting PRODUIT_DEFAULT_BARCODE_TYPE='QRCODE', enabling BARCODE_ON_SHIPPING_PDF, configuring PDF templates to show barcodes; create test product batch with QR codes; document QR content structure (product ref, batch, warehouse, specification links)

5. **Configure supplier quote→PO→reception workflow** by creating Supplier Proposal numbering scheme, defining ExtraFields for quote comparison (`vendor_rating`, `lead_time_days`, `quote_validity`), setting up warehouse routing (ingress 11→storage 21→QC 41→manufacturing 51); build CSV templates for supplier proposals (manual), purchase orders, supplier prices with multi-tier pricing

6. **Allocate workstations to warehouses** via Workstation ExtraField `fk_default_warehouse` linking to manufacturing (51), intermediary (52), QC (42) warehouses; create CSV import template; document workstation-to-warehouse mapping for MRP integration

7. **Create single hooks/triggers template file** documenting trigger action points (PRODUCT_CREATE for QC routing, ORDER_SUPPLIER_VALIDATE for warehouse allocation, STOCK_MOVEMENT for cross-warehouse transfers, warehouse routing automation 11→21→41→51); mark sections "FUTURE IMPLEMENTATION - DO NOT CODE"; include sample trigger structure from [htdocs/core/triggers/interface_50_modAgenda_ActionsAuto.class.php](htdocs/core/triggers/interface_50_modAgenda_ActionsAuto.class.php); prioritize trigger development for warehouse automation workflow

8. **Build master CSV template library** by exporting blank templates from Dolibarr (Home > Tools > Export), configuring show/hide fields per entity type, then uploading with same hooks as originals; consolidate: products (with specifications), warehouses (with hierarchy), supplier prices (with documents), purchase orders, workstations (with warehouse links), stock movements; store in [htdocs/custom/setup_templates/](htdocs/custom/setup_templates/); document field mappings referencing official wiki pages

### Further Considerations

1. **Document association strategy** - Use direct file upload to product documents with multi-supplier filename convention: `{PRODUCT-REF}_{SUPPLIER-NAME}_{DOCTYPE}.pdf` (e.g., `PROD-001_ACME-CHEM_TDS.pdf`, `PROD-001_BETA-SUPPLY_SDS.pdf`); store in `documents/produit/{product_ref}/`; create ExtraFields on Product for document links (`tds_file_url`, `sds_file_url`, `coa_file_url`) pointing to relative paths; consider ECM for version control if document updates are frequent.

2. **Supplier proposal CSV import limitation** - No native template exists; we must manually create proposals via UI then CSV-export for template structure.

3. **Approval workflow implementation** - Purely ExtraField-based (status select dropdown) vs. trigger-enforced validation? Without triggers, approval is manual/visual only. Consider whether QC approval should block stock movements or just flag status.

4. **QR code content specification** - Simple (product ref only) vs. rich (embedded JSON with spec links, batch, expiry)? Simple QR codes work immediately; rich content requires custom PDF template modification.

5. **Warehouse workflow automation** - Stock must automatically route from warehouse 11→21→41→51; prioritize trigger development for automated transfers based on workflow stages (reception at 11 triggers transfer to 21 after document check, 21→41 after quantity verification, 41→51 after QC approval); document manual procedures as fallback during trigger development phase.

6. **Testing sequence** - Test order: (1) Create 2 products with specs/QR codes, (2) Import 2 suppliers, (3) Manual supplier proposal, (4) Convert to PO, (5) Receive at warehouse 11, (6) Transfer 11→21→41, (7) QC approve, (8) Transfer to 51. This validates entire flow before bulk import.
