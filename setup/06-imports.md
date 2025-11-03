# Imports: Products hierarchy with IUPAC, trade names, and variants

This guide shows how to build the hierarchy you requested using Dolibarr's standard modules and CSV importer.

Target hierarchy
- Category > Sub-category
- Product code (ref)
- Technical name (IUPAC)
- Trade name(s) per vendor
- Variants (attributes/values)

## Enable modules
- Categories (Product/Service categories)
- Products & Services
- Suppliers
- Product Variants
- Import (Tools > Import)

## Recommended product fields
- ref: Your product code (unique)
- label: Use the IUPAC technical name as the main label
- description: Any additional notes
- Optional extra fields under Setup > Dictionaries > Extra fields > Product:
  - iupac_name (Varchar(255)) — if you prefer to keep label for a market name
  - cas_number (Varchar(32)) — optional but often useful for chemicals
  - hs_code (Varchar(32)) — customs code if needed

## Data modeling choices
- Categories: Build a hierarchical tree (e.g., Chemicals > Solvents > Alcohols). Products can belong to multiple categories.
- Trade names (multiple vendors): Use Supplier prices linked to the product. For each supplier, set a vendor-specific label (trade name) and supplier reference.
- Variants: Define attributes (e.g., Purity, Concentration, Packaging). Variants are child products generated from attribute combinations.

## Import order
1) Categories (optional to import; small trees are quick to create manually)
2) Products (ref + label)
3) Link Products to Categories
4) Suppliers (if not already present)
5) Supplier Prices (trade names per vendor)
6) Variant Attributes
7) Variant Attribute Values
8) Variants (combinations)

CSV templates are under scripts/import-templates/

- categories.csv — label,parent_label,description
- products.csv — ref,label,type,status,barcode,description
- product_category_links.csv — product_ref,category_path,category_label
- suppliers.csv — supplier_name,alias,status,country,phone,email
- supplier_prices.csv — product_ref,supplier_name,supplier_product_ref,trade_name,price,qty_min,currency,tva_tx,lead_time_days
- product_attributes.csv — attribute_name,label,type,position
- product_attribute_values.csv — attribute_name,value,position
- variants.csv — parent_ref,variant_ref,variant_label,attribute_values,status

## Import steps (UI)
1) Categories
   - If importing: Tools > Import > New Import > Dataset: Categories. Map label and (optionally) parent using IDs. If your file uses parent_label, create the first level first or convert labels to IDs via export/VLOOKUP.
2) Products
   - Tools > Import > Dataset: Products. Map ref (Product code), label (IUPAC), type=0 (product), status=1 (enabled). You can ignore unused columns.
3) Link Products to Categories
   - Tools > Import > Dataset: Categories (links). Map product by ref and category by label or ID depending on your Dolibarr version. If only IDs are supported, export categories to get IDs first.
4) Suppliers
   - Tools > Import > Dataset: Third parties. Map supplier_name to Name. Set Type=Supplier.
5) Supplier Prices (Trade names)
   - Tools > Import > Dataset: Supplier prices. Map product by ref, supplier by name, supplier_product_ref, and trade_name to label. Add price, qty_min, currency, tva_tx.
6) Variant Attributes
   - Tools > Import > Dataset: Product attributes. Map attribute_name and label.
7) Variant Attribute Values
   - Tools > Import > Dataset: Product attribute values. Map attribute_name and value.
8) Variants
   - Tools > Import > Dataset: Product variants. Map parent_ref, variant_ref, variant_label, and attribute_values in the form "Attribute=Value;Attribute2=Value2".

## Tips and validations
- After imports, run the report script to validate mappings:
  - scripts/reporting/products_categories_map.sh (generates TXT and CSV under docker-deploy/reports/)
- If you created the iupac_name extra field, the report will include it when available.
- For India GST, keep tva_tx aligned to your configured rates or use your GST module settings.

## Troubleshooting
- Category links require existing categories and products. Import in the suggested order.
- Supplier matching: If matching by name is inconsistent, switch to matching by Supplier ID by exporting suppliers first.
- Variants: Ensure all attributes and values exist before importing combinations.
