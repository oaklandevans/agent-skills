# Instructions for agents working in this repo

This repo holds personal agent skills shared by Claude Code, GitHub Copilot
and opencode. **The repo is public on GitHub.** Anything committed here can be
read, copied and indexed by anyone, and stays in git history even after it is
deleted.

## Branches and pull requests

Never commit or push directly to `main`. For every change:

1. Create a branch from an up-to-date `main`, named for the change
   (for example `add-release-notes-skill` or `fix/install-links`).
2. Commit there, after the privacy check below.
3. Push the branch and open a pull request against `main` with a short
   summary of what changed and why.
4. Leave merging to the user unless they explicitly ask you to merge.

Note that `~/.agents/skills` is the live copy every agent reads skills from.
While a branch is checked out there, agents see that branch's skills, so
switch back to `main` (`git switch main && git pull`) once the PR is merged.

## Before every commit: privacy check

Before you stage or commit anything, review the full diff (`git diff --cached`)
and confirm none of the following is in it. If you find any, stop, remove or
generalize it, and tell the user what you changed.

**Secrets and credentials**
- API keys, access tokens, passwords, session cookies, private keys, `.env`
  files, certificates, or connection strings with credentials in them.

**Personal information**
- Real names (other than the repo owner's GitHub username), email addresses,
  phone numbers, street addresses, account or customer IDs.
- Absolute paths that include a username, such as `/Users/<name>/...`.
  Use `~/...` or a relative path instead.

**Work and client details**
- Employer, client or project names, internal hostnames and URLs, private IP
  addresses, Slack channels, ticket numbers, or anything copied from internal
  docs, wikis or code.
- Proprietary code, prompts or data that belongs to someone else.

**How to generalize instead**
- Replace real values with placeholders such as `<api-key>`,
  `name@example.com`, `https://example.com` or `~/projects/my-app`.
- If a skill needs a secret at run time, have it read an environment variable
  (for example `$MY_SERVICE_TOKEN`) and say so in `SKILL.md`. Never store the
  value in the repo.
- If a skill only makes sense with private details, it belongs in a separate
  private repo, not this one. Tell the user.

## Automated check

`install.sh` turns on a pre-commit hook (`.githooks/pre-commit`) that scans
staged files for common secrets, email addresses, home-directory paths,
private IP addresses and risky file types such as `.env` or `*.pem`.

- Run it on the whole repo at any time: `.githooks/pre-commit --all`
  (also run by `./install.sh --check`).
- The hook catches common patterns only. It does **not** replace the manual
  review above: it can't recognize client names, internal URLs or private
  context.
- If it flags something that is genuinely safe (for example a placeholder),
  add `privacy-check: allow` to that line. Don't use `git commit --no-verify`
  unless the user explicitly asks you to.

## Adding or editing skills

Follow the [`writing-portable-skills`](writing-portable-skills/SKILL.md)
skill: plain `SKILL.md` folders at the repo root, only standard frontmatter,
no vendor-specific fields. Run `./install.sh --check` before committing.
