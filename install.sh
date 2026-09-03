#!/usr/bin/env bash
# Niftic skills installer — public bootstrap for the private niftic-skills repo.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Niftic-Agency/skills-install/main/install.sh | bash
#
# What it does:
#   1. Installs GitHub CLI (gh) and Node.js 20+ via Homebrew on macOS if missing.
#   2. Signs you in to GitHub in a browser if you are not already authenticated.
#   3. Clones Niftic-Agency/niftic-skills into ~/.niftic/skills.
#   4. Runs `niftic-skills init` to link every skill into each AI tool it finds.

set -euo pipefail

REPO="Niftic-Agency/niftic-skills"
CHECKOUT="$HOME/.niftic/skills"

# Route interactive prompts (gh auth login) to the terminal when piped from curl.
if [ ! -t 0 ] && [ -e /dev/tty ]; then
  exec < /dev/tty
fi

log() { printf '\033[1;34m»\033[0m %s\n' "$*"; }
ok()  { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

need_brew() {
  command -v brew >/dev/null 2>&1 || die \
    "Homebrew is required on macOS. Install it from https://brew.sh, then re-run this installer."
}

ensure_gh() {
  if command -v gh >/dev/null 2>&1; then ok "gh already installed"; return; fi
  case "$(uname -s)" in
    Darwin) need_brew; log "installing gh via Homebrew…"; brew install gh >/dev/null ;;
    *)      die "Install the GitHub CLI first: https://cli.github.com/" ;;
  esac
  ok "gh installed"
}

ensure_node() {
  local major
  if command -v node >/dev/null 2>&1; then
    major=$(node -p 'process.versions.node.split(".")[0]')
    if [ "$major" -ge 20 ]; then ok "node $(node -v)"; return; fi
    log "node $(node -v) is too old; installing Node 20+…"
  else
    log "installing Node.js…"
  fi
  case "$(uname -s)" in
    Darwin) need_brew; brew install node >/dev/null ;;
    *)      die "Node.js 20+ required. Install from https://nodejs.org/ and re-run." ;;
  esac
  ok "node $(node -v)"
}

ensure_gh_auth() {
  if gh auth status --hostname github.com >/dev/null 2>&1; then
    ok "gh authenticated as $(gh api user -q .login)"
    return
  fi
  log "opening a browser to sign you in to GitHub…"
  gh auth login --hostname github.com --git-protocol https --web
  ok "gh authenticated as $(gh api user -q .login)"
}

ensure_checkout() {
  if [ -d "$CHECKOUT/.git" ]; then ok "checkout exists at $CHECKOUT"; return; fi
  if [ -e "$CHECKOUT" ]; then
    die "$CHECKOUT exists but isn't a git checkout. Move it aside and re-run."
  fi
  log "cloning $REPO → $CHECKOUT…"
  mkdir -p "$(dirname "$CHECKOUT")"
  gh repo clone "$REPO" "$CHECKOUT" -- --quiet
  ok "cloned"
}

run_init() {
  log "running niftic-skills init…"
  node "$CHECKOUT/bin/niftic-skills.js" init
}

ensure_gh
ensure_node
ensure_gh_auth
ensure_checkout
run_init

echo
ok "Done. Skills appear in the next new session of each AI tool."
