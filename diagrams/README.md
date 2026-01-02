# Mermaid Diagram Sources

This directory contains the source `.mmd` (Mermaid) files for the technical diagrams in the book.

## Regenerating Diagrams

To regenerate PNG images after editing a `.mmd` file:

```bash
# From the unix_doc root directory:
PUPPETEER_EXECUTABLE_PATH=/home/user/.cache/puppeteer/chrome-headless-shell/linux-143.0.7499.169/chrome-headless-shell-linux64/chrome-headless-shell \
  mmdc -i diagrams/FILENAME.mmd -o src/FILENAME.png -b transparent -p .puppeteerrc.json
```

Replace `FILENAME` with the appropriate diagram name (e.g., `1.4-syscall-flow`).

### Batch Regeneration

To regenerate all diagrams:

```bash
for mmd in diagrams/*.mmd; do
  filename=$(basename "$mmd" .mmd)
  PUPPETEER_EXECUTABLE_PATH=/home/user/.cache/puppeteer/chrome-headless-shell/linux-143.0.7499.169/chrome-headless-shell-linux64/chrome-headless-shell \
    mmdc -i "$mmd" -o "src/${filename}.png" -b transparent -p .puppeteerrc.json
  echo "Regenerated ${filename}.png"
done
```

## Prerequisites

- `mmdc` (Mermaid CLI): Install with `npm install -g @mermaid-js/mermaid-cli`
- Chrome headless shell: Install with `npx puppeteer browsers install chrome-headless-shell`

## Diagram Naming Convention

Diagrams follow the pattern: `[chapter].[section]-[description].mmd`

Examples:
- `1.1-fork-creation.mmd` → Process lifecycle, fork diagram
- `1.4-syscall-flow.mmd` → System call flow diagram
- `2.2-hat-layer.mmd` → HAT layer diagram
