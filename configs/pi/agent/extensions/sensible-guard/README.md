# sensible-guard

Pi extension that gates agent access to likely secret files.

## What it protects

Prompts for user consent before agent tool calls that read or update likely secret targets:

- `.env`, `.env.*`
- files/dirs containing `secret`, `credential`, or `token`
- `.npmrc`, `.pypirc`, `.netrc`, Docker config
- SSH keys and private-key material (`id_rsa`, `*.pem`, `*.key`, `*.p12`, `*.pfx`)
- `secrets/`, `credentials/`

Covered tools:

- `read`
- `write`
- `edit`
- `bash` commands with secret-looking path/text hints

## Commands

- `/sensible-guard` — status
- `/sensible-guard clear` — clear session approvals

Approvals are per session and per operation/target. Non-UI mode blocks protected access by default.

Reload Pi with `/reload` after install/update.
