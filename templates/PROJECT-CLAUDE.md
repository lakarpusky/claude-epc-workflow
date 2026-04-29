# CLAUDE.md

<!-- ============================================================
     PROJECT-SPECIFIC CLAUDE.md TEMPLATE
     ============================================================
     Copy this file to your project root and fill in the sections
     that apply. Delete sections that don't.

     Target: under 150 lines after filling in. Per Anthropic's
     guidance, bloated CLAUDE.md files cause Claude to ignore your
     instructions. Test for every line: "Would removing this cause
     Claude to make mistakes?" If no, cut it.

     This file is project-specific. Personal defaults live in
     ~/.claude/CLAUDE.md and load automatically.
     ============================================================ -->

## Project overview

<!-- 2–3 sentences:
     - What does this project do?
     - Who uses it?
     - How is it deployed (SaaS, self-hosted, mobile, internal tool)?
-->

## Tech stack

<!-- Only the non-obvious choices. If it's a vanilla React + Vite + TypeScript
     project, you don't need to list those — Claude will infer them.
     Mention:
     - Framework + version if non-default (e.g., UmiJS 4, Next.js App Router)
     - State management library if not Redux Toolkit (e.g., DVA, Zustand, Jotai)
     - UI library if it shapes patterns (e.g., Ant Design Pro v4, shadcn/ui)
     - Build tool if non-default
     - HTTP client if it has interceptor logic (e.g., umi-request, custom axios)
     - Testing stack if it constrains test patterns
     - Auth strategy if Claude needs to know it for API work
-->

## Architecture

<!-- ### Entry points
     Main entry files, route configs, layout wrappers.

     ### Directory structure
     A short tree view of src/ with one-line descriptions per directory.

     ### Data flow
     One-line description of how data moves through the app.

     ### State management pattern
     Where models/stores/slices live and how components connect.
-->

## Commands

<!-- Only the commands Claude will need to run. Don't list every script
     in package.json — list the ones that are non-obvious or critical.
```bash
npm run dev       # Start dev server on port XXXX
npm run test      # Run tests (Jest/Vitest/etc.)
npm run lint      # Lint
npm run build     # Production build
```
-->

## Conventions

<!-- Only the conventions Claude can't infer from existing code.
     If your codebase uses Prettier with default config, don't waste
     lines on quote style — Claude will match what it sees.

     Worth documenting:
     - Path aliases (@/, ~/) if used
     - File naming if non-default (e.g., kebab-case for components)
     - Custom HTTP error handling pattern
     - Error boundary placement
     - State management connection pattern (e.g., DVA model shape)
     - Form validation library and pattern
-->

## Critical paths

<!-- 3–5 most important user flows. For each:
     - One-line description
     - Key files involved
     - "Watch out" gotchas

     Examples worth documenting:
     - Authentication flow
     - Core feature (whatever the app's main job is)
     - Payment/checkout flow
     - Admin configuration

     Skip if the project is small enough that everything is critical.
-->

## File risk map

<!-- Categorize files by blast radius. Not all projects need this —
     skip if your project is straightforward.

     ### Critical (don't touch without extreme caution)
     Files where bugs break the entire app.

     ### Important (core features)
     Files powering primary features.

     ### Standard
     Regular feature code.

     ### Safe to refactor
     Utilities, translations, low blast radius.
-->

## Keyword glossary

<!-- Map team vocabulary to actual files/concepts. Skip if your team
     uses standard terminology.

| Term | Means | Located at |
| --- | --- | --- |
| "the form builder" | Dynamic form renderer | `src/components/FormBuilder/` |
| "the dashboard" | Main user landing page | `src/pages/Dashboard/` |
-->

## Known issues / tech debt

<!-- Document known problems so Claude doesn't make them worse and
     doesn't re-fix what's intentionally broken.

| Issue | Location | Risk | Notes |
| --- | --- | --- | --- |
| Search re-renders on every keystroke | `src/components/Search/` | High | Needs debounce |
-->

## Reference docs

<!-- Anthropic's recommendation: prefer pointers to copies. Don't paste
     long architecture docs into CLAUDE.md or @-import them — that loads
     the entire file every session. Reference them so Claude reads them
     on demand.

- API architecture details: `docs/api-architecture.md` (read when adding endpoints)
- Database schema: `docs/db-schema.md` (read when modifying models)
- Deployment process: `docs/deployment.md` (read when changing build config)
-->

---

<!-- ============================================================
     DELETE EVERYTHING BELOW BEFORE COMMITTING
     ============================================================
     Quick reference for what to include vs. exclude.

     INCLUDE:
     - Project-specific facts Claude can't infer from code
     - Commands Claude will actually run
     - Conventions that differ from defaults
     - Critical-path files and gotchas
     - Known issues that look like bugs but are intentional

     EXCLUDE:
     - Generic advice ("write clean code", "use meaningful names")
     - Style rules a linter enforces
     - Long code snippets (they go stale; reference files instead)
     - Repetitions of what's in package.json or README.md
     - Anything Claude already knows by default

     TEST EVERY LINE: "Would removing this cause Claude to make a
     mistake?" If no, cut it.

     References:
     - Anthropic best practices: https://code.claude.com/docs/en/best-practices
     - Practical guide: https://www.humanlayer.dev/blog/writing-a-good-claude-md
     ============================================================ -->
