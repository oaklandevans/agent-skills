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
3. Commit on a branch and open a pull request. Changes go through PRs,
   not straight to `main` (see [`AGENTS.md`](AGENTS.md)).

The [`writing-portable-skills`](writing-portable-skills/SKILL.md) skill has
the full rules. Ask any agent to "add a skill to my agent-skills repo" and it
will follow them.

## Skills from other repos

Some skills are copied from other public repos instead of written here. They
are listed in [`upstream.txt`](upstream.txt), and each copied folder has the
original `LICENSE` and an `UPSTREAM.md` that links to the exact source commit.

To pull in their latest versions, run this on a branch, review the diff and
open a pull request:

```bash
./sync-upstream.sh
```

Don't edit those folders by hand: the next sync overwrites them. To add
another skill, add a line to `upstream.txt` (only for licenses that allow
copying, such as MIT or Apache 2.0) and run the script.

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
| [angular-developer](angular-developer/SKILL.md) | Modern Angular code and architecture: signals, forms, DI, routing, SSR, testing (from [angular/skills](https://github.com/angular/skills)) |
| [angular-new-app](angular-new-app/SKILL.md) | Create a new Angular app with the Angular CLI (from [angular/skills](https://github.com/angular/skills)) |
| [brainstorming](brainstorming/SKILL.md) | Pin down requirements and design through questions before building a feature, then write a spec (from [obra/superpowers](https://github.com/obra/superpowers)) |
| [executing-plans](executing-plans/SKILL.md) | Work through an implementation plan task by task in the current session (from [obra/superpowers](https://github.com/obra/superpowers)) |
| [finishing-a-development-branch](finishing-a-development-branch/SKILL.md) | Check tests pass, then choose whether to merge, open a PR, keep or discard a finished branch (from [obra/superpowers](https://github.com/obra/superpowers)) |
| [receiving-code-review](receiving-code-review/SKILL.md) | Check review feedback is technically right before acting on it (from [obra/superpowers](https://github.com/obra/superpowers)) |
| [requesting-code-review](requesting-code-review/SKILL.md) | Get finished work reviewed against its plan before merging (from [obra/superpowers](https://github.com/obra/superpowers)) |
| [systematic-debugging](systematic-debugging/SKILL.md) | Find the root cause of a bug, test failure or unexpected behavior before proposing a fix (from [obra/superpowers](https://github.com/obra/superpowers)) |
| [test-driven-development](test-driven-development/SKILL.md) | Write a failing test first, then the code to make it pass, for any feature or bugfix (from [obra/superpowers](https://github.com/obra/superpowers)) |
| [verification-before-completion](verification-before-completion/SKILL.md) | Run the checks and read their output before claiming work is done, fixed or passing (from [obra/superpowers](https://github.com/obra/superpowers)) |
| [writing-plans](writing-plans/SKILL.md) | Turn a spec into a step-by-step implementation plan before touching code (from [obra/superpowers](https://github.com/obra/superpowers)) |
| [writing-portable-skills](writing-portable-skills/SKILL.md) | Rules for adding skills to this repo so they work in every agent |
