# agent-skills

My personal [Agent Skills](https://agentskills.io), in one repo, shared by
every coding agent I use: **Claude Code**, **GitHub Copilot** and **opencode**.
Nothing here is specific to one vendor.

## Setup (once per machine)

```bash
git clone https://github.com/oaklandevans/agent-skills.git ~/.agents/skills
~/.agents/skills/install.sh
```

| Agent | Where it reads skills | How this repo gets there |
|---|---|---|
| GitHub Copilot (CLI, VS Code, JetBrains) | `~/.agents/skills` | the clone itself |
| opencode | `~/.agents/skills` | the clone itself |
| Claude Code | `~/.claude/skills` | one symlink per skill, made by `install.sh` |

If you clone somewhere else, `install.sh` links `~/.agents/skills` to the
clone, as long as that path doesn't already exist.

## Updating

```bash
cd ~/.agents/skills && git pull && ./install.sh
```

Re-running `install.sh` is safe. It links new skills and removes links to
deleted ones.

## Adding a skill

1. Create `<skill-name>/SKILL.md` at the repo root. The folder name must
   equal the `name` in the frontmatter.
2. Run `./install.sh --check` to validate it, then `./install.sh`.
3. Commit and push.

The [`writing-portable-skills`](writing-portable-skills/SKILL.md) skill has
the full rules. Ask any agent to "add a skill to my agent-skills repo" and it
will follow them.

## Keep private info out (this repo is public)

Never commit secrets, personal details, home-directory paths or
client/employer information. [`AGENTS.md`](AGENTS.md) has the full checklist,
and every agent working in this repo reads it before committing. Claude Code
reads it through the `CLAUDE.md` link.

`install.sh` also turns on a pre-commit hook that blocks commits containing
likely secrets, email addresses, home paths, private IPs or files like `.env`
and `*.pem`. Scan the whole repo any time with:

```bash
.githooks/pre-commit --all
```

If it flags a line that is safe, add `privacy-check: allow` to that line.

## Using skills in a single project instead

To pin skills to one repo (for teammates or cloud agents), copy the skill
folder into that project's `.agents/skills/`. Copilot and opencode read that
folder. Claude Code reads `.claude/skills/`, so add a symlink there too.

## Skills

| Skill | What it does |
|---|---|
| [writing-portable-skills](writing-portable-skills/SKILL.md) | Rules for adding skills to this repo so they work in every agent |
