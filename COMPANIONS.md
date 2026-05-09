# Companions

Optional personal-setup files that pair with the agents + `/epc` core system but are independent of it. The agents work without these. These work in any Claude Code setup without the agents.

```
~/.claude/
├── CLAUDE.md                                     ← personal defaults (~30 lines)
├── templates/
│   └── PROJECT-CLAUDE.md                         ← copy to projects, fill in
└── skills/
    └── karpathy-guidelines/                      ← on-demand coding behavior
        ├── SKILL.md
        └── EXAMPLES.md
```

| File | Purpose | Loads when |
|---|---|---|
| `CLAUDE.md` | Personal defaults: direct-mode rules, debugging discipline, bash hygiene | Every session |
| `templates/PROJECT-CLAUDE.md` | Per-project template: tech stack, critical paths, conventions | When copied to a project root |
| `skills/karpathy-guidelines/` | Four principles preventing common LLM coding mistakes | On code-writing tasks (description match) |

## Install

```bash
mkdir -p ~/.claude/templates ~/.claude/skills/karpathy-guidelines

cp /tmp/claude-epc/CLAUDE.md ~/.claude/CLAUDE.md
cp /tmp/claude-epc/templates/PROJECT-CLAUDE.md ~/.claude/templates/
cp /tmp/claude-epc/skills/karpathy-guidelines/* ~/.claude/skills/karpathy-guidelines/
```

For new projects, copy the template into the repo root:

```bash
cd ~/code/my-project
cp ~/.claude/templates/PROJECT-CLAUDE.md ./CLAUDE.md
$EDITOR ./CLAUDE.md
```

## Global CLAUDE.md

A 30-line personal defaults file: direct-mode rules, debugging discipline, bash hygiene. Every line answers Anthropic's [official test](https://code.claude.com/docs/en/best-practices): *"Would removing this cause Claude to make mistakes?"*

Per [Anthropic's guidance](https://code.claude.com/docs/en/best-practices): bloated CLAUDE.md files cause Claude to ignore instructions. The official recommendation is under 200 lines.

## Project template

`PROJECT-CLAUDE.md` is copied to each project's root and filled in. ~80% comments and prompts that guide what to include (tech stack, architecture, critical paths, file risk map, known issues) and reminders to cut anything generic.

## karpathy-guidelines skill

A third-party skill derived from [Forrest Chang's andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (MIT licensed), which distilled four principles from [Andrej Karpathy's observations on LLM coding pitfalls](https://x.com/karpathy/status/2015883857489522876):

1. **Think Before Coding** — surface assumptions, present interpretations, push back when warranted
2. **Simplicity First** — minimum code that solves the problem, no speculative abstractions
3. **Surgical Changes** — touch only what the request requires, match existing style
4. **Goal-Driven Execution** — define verifiable success criteria, write tests that reproduce bugs first

The skill loads on-demand for code-writing tasks (via description match), so it doesn't burn context on idle sessions.

### Adaptations from the upstream

This is a derivative work. Two changes from Forrest Chang's original:

- **Tightened skill description** for more reliable activation — explicit `MUST ACTIVATE` directive plus trigger verbs (implement, fix, refactor, build, etc.) that match how requests are phrased.
- **EXAMPLES.md ported to JavaScript/TypeScript and React** — the upstream uses Python. All examples were rewritten in JS/TS for stack alignment, plus three React-specific examples added (don't refactor unrelated hooks while memoizing, don't reach for Context unprompted, don't optimize without Profiler data).

The four principles themselves are unchanged from the upstream. Credit for the principles goes to Karpathy and Forrest Chang.

## License

The `karpathy-guidelines` skill is a derivative of MIT-licensed work; modifications retain the same license. Global CLAUDE.md and project template are MIT, original to this repo.
