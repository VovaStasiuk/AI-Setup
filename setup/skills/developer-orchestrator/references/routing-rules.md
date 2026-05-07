# Routing Rules

## Availability

- If only Claude is available: use Claude, Superpowers if installed, and custom skills. Do not assume Codex/Gemini review.
- If only Codex is available: use Codex and custom skills. Do not assume Superpowers.
- If Claude + Codex are available: prefer Claude/Superpowers for large planning and Codex for review/rescue.
- If Gemini is available: use it for long-context, whole-repo, media, and large PDF tasks.
- If imagegen is available: use it for generated raster assets, mockups, and image edits.
- If Pencil MCP or `.pen` files are available: use `human-ui-designer` for design direction, then `pencil-design` for Pencil-specific workflow.

## Image route detail

`imagegen` is not expected to be a shell command. Do not use `command -v imagegen` as the only availability check.

In Claude:

1. Check whether Codex is available.
2. Check whether Codex has an `imagegen` skill/tool route, for example via installed global Codex skills or the active tool list when visible.
3. If available, ask the user whether to hand off to Codex imagegen.
4. If unavailable, offer fallback routes: SVG/HTML asset, Pencil/Figma export, or external image-generation prompt.

In Codex:

Use the `imagegen` skill/tool directly when the task asks for a raster image or image edit.

## Pencil route detail

Do not treat Pencil as the default design source. Project design files, screenshots, tokens, and `DESIGN.md` remain authoritative.

Use `pencil-design` when the task explicitly involves Pencil, `.pen` files, Pencil MCP tools, editable mockups, or design-to-code from Pencil. If Pencil is unavailable, explain that and offer Figma, HTML/CSS/React prototype, SVG, imagegen, or an external handoff.

## User control

- Ask before major routes unless explicitly requested or forced.
- Forced routes should announce one concise line when not explicitly requested.
- If a route is unavailable, provide the best local fallback instead of blocking.

## Output handling

- For multi-agent handoffs, save or present a compact handoff: goal, context, files, constraints, commands, risks, and exact ask.
- For reviews, preserve raw findings when possible and summarize the decision separately.
