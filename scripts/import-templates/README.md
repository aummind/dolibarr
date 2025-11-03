Import templates for Dolibarr (Products with Categories, Suppliers/Trade Names, and Variants)

This folder contains CSV templates to help you build the hierarchy you described:

Category > Sub-category > Product code >> Technical name (IUPAC) >> Trade name(s) (multiple vendors) >> Variants

Overview
- Categories are hierarchical product categories.
- Product code maps to product ref (unique).
- Technical name (IUPAC) is stored on the product (recommended as the main label) or an extra field named iupac_name.
- Trade names per vendor are modeled with Supplier Prices (one per vendor), using vendor-specific label and reference.
- Variants use the Product Variants module (attributes + combinations) to create child products.

Files
- categories.csv: Optional seed of category tree (label and parent). You can also create categories manually.
- products.csv: Core products. Use the IUPAC name as label. Keep ref as your product code.
- product_category_links.csv: Links each product to its category (or path). Import after categories and products exist.
- suppliers.csv: Optional supplier directory if you want to import suppliers.
- supplier_prices.csv: Vendor-specific trade names and prices per product.
- product_attributes.csv: Variant attributes (e.g., Purity, Concentration, Packaging).
- product_attribute_values.csv: Allowed values for each attribute.
- variants.csv: Variant combinations (child products) for each parent product.

Suggested import order
1) Enable modules: Categories, Products & Services, Product Variants, Suppliers, Import tool.
2) Create (or import) Categories first.
3) Import Products (use ref for Product code, label for IUPAC).
4) Link Products to Categories (product_category_links.csv).
5) Create Suppliers (or ensure they exist).
6) Import Supplier Prices (trade names) for each Product.
7) Create Variant Attributes and Values.
8) Import Variant combinations.

Notes
- Extra field: If you prefer to keep the product label for a market name, add an extra field iupac_name (type: Varchar(255)) to products under Setup > Dictionaries > Extra fields > Product.
- Category linking: If your importer requires IDs instead of labels/paths, import categories first, export to get IDs, then VLOOKUP to add a parent_id column before import.
- Taxes/currency: Adjust tva_tx and currency to your locale (India GST or others). If you use the India-GST module, keep tax fields consistent with your configuration.
- CSVs are UTF-8 without BOM. Keep headers as-is and map to Dolibarr fields in the Import tool.
