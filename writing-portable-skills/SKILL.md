---
name: writing-portable-skills
description: Create or edit an agent skill in the personal agent-skills repo so it works the same in Claude Code, GitHub Copilot and opencode. Use when the user asks to add, write, fix or review a skill (a SKILL.md file).
---

# Writing portable skills

Skills in this repo must work in every agent that supports the open Agent
Skills format. Follow these rules so nothing is tied to one vendor.

## Layout

Each skill is one folder at the repo root:

```
<skill-name>/
├── SKILL.md          required
├── scripts/          optional helper scripts
└── references/       optional longer docs, templates, examples
```

## Frontmatter

Start `SKILL.md` with YAML frontmatter containing only these fields:

- `name` (required): lowercase letters, digits and single hyphens, at most
  64 characters, and exactly the same as the folder name.
- `description` (required, at most 1024 characters): say what the skill does
  **and** when to use it. Agents decide whether to load the skill from this
  line alone, so include the words a user would actually say.
- `license`, `compatibility`, `metadata` (optional).

Do not add vendor-specific fields such as `allowed-tools`, `model` or
`disable-model-invocation`. Some agents ignore them and others don't, so the
skill would behave differently depending on where it runs.

## Body

- Write instructions in plain language. Describe actions ("search the
  codebase for…", "run the tests") instead of naming a specific agent's tools.
- Keep `SKILL.md` short (under ~500 lines). Move long reference material
  into `references/` and say when to read it.
- Refer to bundled files by paths relative to the skill folder, for example
  `scripts/check.sh`.
- Scripts should need only common tools (bash, python3, git) and print clear
  errors when something is missing.

## Keep it public-safe

The repo is public. Never put secrets, personal details, absolute home paths
or client/employer information in a skill. Use placeholders such as
`<api-key>` or `name@example.com`, and have skills read secrets from
environment variables at run time. Follow the full checklist in the repo's
`AGENTS.md` before committing.

## After adding or renaming a skill

1. Run `./install.sh --check` from the repo root to validate every skill and
   scan the repo for private info.
2. Run `./install.sh` so Claude Code picks up the new skill.
3. Commit on a branch, push it and open a pull request against `main`
   (never commit to `main` directly; see the repo's `AGENTS.md`).
4. After the PR is merged, on each machine: `git switch main && git pull`,
   then `./install.sh`.
