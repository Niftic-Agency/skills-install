# skills-install

Public bootstrap for **[Niftic-Agency/niftic-skills](https://github.com/Niftic-Agency/niftic-skills)** (private).

Teammates run:

```bash
curl -fsSL https://raw.githubusercontent.com/Niftic-Agency/skills-install/main/install.sh | bash
```

The script installs [GitHub CLI](https://cli.github.com/) and Node.js 20+ via Homebrew if they are missing, opens a browser so you can sign in to GitHub, then clones `niftic-skills` into `~/.niftic/skills` and links every skill into each AI tool it finds. A `niftic-skills` command lands in `~/.local/bin`.

macOS is the supported target. On Linux you'll need `gh` and Node 20+ installed already; the script tells you where to get them.

After the first install, use `niftic-skills sync` to pick up new skills. See the main repo for the rest of the commands.
