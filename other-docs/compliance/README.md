# Compliance and References

Purpose: Track authoritative links and metadata for compliance standards and regulations. Avoid storing copyrighted full texts. Store official links and local file pointers provided by the user.

## Standards

- ISO 14001:2015 — Environmental Management Systems (EMS)
  - Scope: EMS requirements with guidance for use.
  - Official source: ISO catalog (search "ISO 14001:2015").
    - https://www.iso.org/search.html?q=ISO%2014001%3A2015
  - Local copy: Provide file path if you have a licensed copy.
    - Example: `other-docs/references/ISO_14001_2015_EMS.pdf` (user-provided)

- ISO 14067:2018 — Greenhouse gases — Carbon footprint of products
  - Scope: Quantification and communication of product carbon footprint (PCF).
  - Official source: ISO catalog (search "ISO 14067:2018").
    - https://www.iso.org/search.html?q=ISO%2014067%3A2018
  - Local copy: Provide file path if you have a licensed copy.
    - Example: `other-docs/references/ISO_14067_2018_PCF.pdf` (user-provided)

## Indian Compliance (General)

- GST (India)
  - Central Board of Indirect Taxes & Customs (CBIC): https://www.cbic.gov.in/
  - GST Portal (registration/returns): https://www.gst.gov.in/
  - Notes: Map HSN codes appropriately for chemical products; ensure place-of-supply rules are configured in ERP.

- Karnataka State — Environment & Safety
  - Karnataka State Pollution Control Board (KSPCB): https://kspcb.karnataka.gov.in/english
  - Department of Factories, Boilers, Industrial Safety and Health (Karnataka): official portal (confirm current URL).
    - Search: https://www.google.com/search?q=Karnataka+Factories+Boilers+Industrial+Safety+and+Health
  - Notes: Verify applicable consents (CTE/CTO), hazardous storage norms, and reporting obligations.

## Dolibarr Configuration Considerations

- Treat Indian GST and Karnataka compliance as primary lenses for configuration.
- Use Dolibarr modules and UI for settings unless explicit code changes are required.
- Keep compliance-related procedures in `other-docs/guides/` as runbooks if needed.

## Missing or New Documents

- If a referenced document is not available, request:
  - Document name and edition (e.g., ISO 14001:2015),
  - Source link and license status,
  - Approval to store a local copy (if permitted) under `other-docs/references/`.

## Change Log

- 2025-11-13: Initialized README with ISO 14001:2015 and ISO 14067:2018, plus India/Karnataka links.
