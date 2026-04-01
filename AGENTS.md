# PROJECT KNOWLEDGE BASE

Multi-host NixOS configuration using the [unify](https://codeberg.org/quasigod/unify) framework with flake-parts and import-tree. Manages 5 machines (desktop, laptop, server, RPi, mini PC) with shared modules, home-manager, sops-nix secrets, and nix-fast-build CI pushing to a private niks3 cache.

## STRUCTURE

```
./
├── flake.nix              # Entry point — inputs + import-tree of hosts/ and modules/
├── .sops.yaml             # SOPS key hierarchy (PGP master + age per host/user)
├── hosts/                 # Per-machine configs (see hosts/AGENTS.md)
├── modules/               # Reusable feature modules (see modules/AGENTS.md)
├── secrets/               # SOPS-encrypted YAML (per-host + per-user)
└── .github/workflows/     # CI: flake-checks, lock updates, dependabot automerge
```

## BUILD & VERIFICATION COMMANDS

```bash
# Build and activate a single host (run on target machine)
nixos-rebuild switch --flake .#<hostname>

# Dry-run build for a single host (local verification, no activation)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Check all hosts (CI-equivalent — builds every host)
nix flake check --accept-flake-config

# Enter dev shell (provides sops + nix)
nix develop

# Edit a secret
sops secrets/hosts/<host>.yml

# Update all flake inputs
nix flake update

# Update a single flake input
nix flake lock --update-input <input-name>
```

### CI Pipeline (`.github/workflows/flake-checks.yml`)

CI runs on push to `main` and on PRs. It generates a matrix from `hosts/checks.nix`, builds each host with `nix-fast-build --skip-cached --max-jobs 1`, then pushes results to `cache.jadestar.dev` via niks3 with OIDC auth. Path-based skip logic only triggers builds when `hosts/<name>/**`, `modules/**`, `secrets/**`, `flake.nix`, or `flake.lock` change.

**Before submitting changes**: run `nix flake check --accept-flake-config` to verify all hosts evaluate and build without errors.

## CODE STYLE GUIDELINES

### Module Pattern (MANDATORY)

All modules use `unify.*` attributes — NEVER raw NixOS `imports`:

```nix
# NixOS-only module (applies globally)
{ ... }: {
  unify.nixos = { ... };
}

# Home-manager-only module (applies globally)
{ ... }: {
  unify.home = { pkgs, ... }: { ... };
}

# Module group contributor (scoped to pc, dev, gaming, etc.)
{ ... }: {
  unify.modules.pc = {
    nixos = { ... };
    home = { pkgs, ... }: { ... };
  };
}
```

### Host Definition Pattern

```nix
{config, ...}: {
  unify.hosts.nixos.<name> = {
    modules = with config.unify.modules; [ ... ];
    users.jaden.modules = config.unify.hosts.nixos.<name>.modules;
    disk-layout = { disk0 = "/dev/..."; enableSwap = true; swapSize = 4; };
    nixos = { system.stateVersion = "25.11"; ... };
    home = { ... };
  };
}
```

### Nix Formatting

- **2-space indentation** — no tabs
- **Braces on same line**: `{config, ...}:` not `{ config, ... }:` on a new line
- **Attribute grouping**: related attrs grouped visually (networking together, boot together, etc.)
- **Lists on multiple lines** when more than ~3 items; single-line for short lists like `["aarch64-linux"]`
- **`let...in` blocks**: placed at start of function body when needed
- **`inherit`**: used freely (e.g., `inherit (lib) mkOption types;`)
- **`with` expressions**: used for `pkgs` (`with pkgs; [...]`) and module lists (`with config.unify.modules; [...]`)

### Naming Conventions

- **Files**: kebab-case (`btrfs-luks.nix`, `rootless-docker.nix`). Single-word for simple modules (`mpv.nix`, `sudo.nix`)
- **Module groups**: kebab-case (`desktop-plasma`, `disk-btrfs-on-luks-with-raid0`)
- **Hosts**: lowercase, no hyphens (`asrock`, `thinkpadx1`, `dokja`)
- **Options**: camelCase for NixOS options (`enableSwap`, `swapSize`), kebab-case for unify options (`disk-layout`, `primaryUser`)
- **Secrets files**: `secrets/hosts/<host>.yml` or `secrets/users/<user>.yml`

### Accessing Host Context

- Use `hostConfig.primaryUser.username` / `.name` / `.email` for user info — NEVER hardcode
- Use `hostConfig` (passed as first arg to `nixos`/`home` in host definitions) for host-level options
- Home-manager `pkgs` comes from nixpkgs (`useGlobalPkgs = true`) — no separate `nixpkgs` config needed

### Imports and Auto-Discovery

- **`import-tree`** auto-discovers all `.nix` files under `hosts/` and `modules/` — just create a file and it's loaded
- **NEVER** use raw `imports = [...]` in module files — use `unify.nixos.imports` or `unify.home.imports`
- The ONLY exception is `flake.nix` which uses `inputs.import-tree`

## CRITICAL CONSTRAINTS

- **`abort-on-warn = true`** in `flake.nix` — any Nix warning aborts the build. Never introduce deprecation warnings.
- **`pipe-operators`** experimental feature enabled — pipe syntax (`|>`) is used (see `hosts/checks.nix`)
- **`allow-import-from-derivation = false`** — all derivations must evaluate without IFD
- **One module per file** — each `.nix` file contributes to exactly one `unify.modules.*` group (or uses `unify.nixos`/`unify.home` directly)
- **VCS**: This repo uses [jj (jujutsu)](https://github.com/jj-vcs/jj) — `.jj/` directory present. Git history may be a backing repo.

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add a new host | `hosts/<name>/default.nix` | Follow host pattern above. Add to `hosts/checks.nix` list |
| Add a new module | `modules/<category>/<name>.nix` | Auto-discovered by import-tree. Use `unify.modules.*` |
| Add a CLI tool | `modules/cli/` | Contributes to `unify.modules.dev` or `unify.modules.pc` |
| Change disk layout | `modules/meta/disk-layout/` | Options in `nixos.nix`, templates in sibling files |
| Add a secret | `secrets/hosts/<host>.yml` | Must add rule in `.sops.yaml` |
| Fix WireGuard | `hosts/*/wg-*.nix` | Server: `hosts/dokja/wg-server.nix`, clients: `hosts/*/wg-client.nix` |
| Add a container | `hosts/<host>/containers.nix` | See `hosts/aesop/containers.nix` |
| Change hardening | `modules/hardening/` | Kernel params, PAM, USBGuard, SSH, ACL |

## ANTI-PATTERNS (DO NOT DO)

- **Do NOT use raw `imports`** in module files — use `unify.nixos.imports` / `unify.home.imports`
- **Do NOT hardcode user info** — use `hostConfig.primaryUser.*`
- **Do NOT remove the `/var/empty` HACK** in `modules/desktop/xdg.nix` — the XDG options themselves are broken
- **Do NOT use `lib.mkDefault` carelessly** in host configs — it can silently override module settings
- **Do NOT introduce `builtins.fetch*` or IFD patterns** — blocked by flake config

## KNOWN ISSUES / TODOs

- `modules/toplevel/users.nix`: Admin account creation pending. `trusted-users` is commented out.
- `hosts/teemo/default.nix`: NTS (Network Time Security) pending; chrony disabled, timesyncd as fallback.
- Dependabot + automerge configured for flake input updates. PRs from dependabot are auto-approved in CI.
