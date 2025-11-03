# Setup Directory Audit (non-official)

Date: 2025-11-03
Scope: docker-deploy/setup/*.md

## Summary
- Overall structure is helpful (01–06). Most content is consistent with the current compose and Dockerfile.
- 02-configuration.md contains formatting issues (duplicated headings, broken code fences, interleaved sample text and code blocks) that may confuse readers.

## Issues Observed
- 02-configuration.md
  - Duplicate titles: "# Configuration Guide# Dolibarr Docker - Configuration Guide"
  - Broken code blocks: e.g., "```Current settings in Dockerfile:" and nested code fences with language specifiers embedded mid-line.
  - Mixed ASCII diagram and code fences not closed properly.
  - Sections duplicated (Overview, Container Configuration) and interleaved text/code.
- Minor: Some versions and images in examples (nginx tag, compose version lines) should align with docker-deploy/docker-compose.yml.

## Recommendations
- Split 02-configuration.md into concise sections:
  1) PHP configuration (Dockerfile snippets)
  2) Nginx configuration (nginx.conf snippet)
  3) Docker Compose services summary
  4) Performance tuning (OPcache, MariaDB knobs)
  5) Security notes (headers, exposure)
- Fix code fences and language hints; avoid nested/inline code fence markers.
- Remove duplicated headings and redundant sections.
- Align example image tags and parameters with the living docker-deploy files.

## Low-Risk Immediate Fixes (optional)
- We can quickly normalize headings, close code fences, and remove obvious duplicates without changing intent.
- Larger reorganizations should be reviewed to keep authorship and meaning intact.

## Next Actions
- If you approve, I can provide a cleaned 02-configuration.md that preserves content but fixes formatting and structure.
