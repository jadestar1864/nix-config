# MODULES

Reusable feature modules auto-discovered by `import-tree` from `flake.nix`. Each module contributes to `unify.modules.*`, `unify.nixos`, `unify.home`, or `unify.options.*`.

## STRUCTURE

```
modules/
├── boot/default.nix           # systemd-boot, EFI defaults
├── home-manager.nix           # Home-manager integration via unify
├── sops-nix.nix               # Secrets management via unify
├── disko.nix                  # Disko module import
├── unfree-packages.nix        # Whitelist-based unfree package handling
├── sudo.nix                   # Sudo configuration
├── tlp.nix                    # Laptop power management
├── libreoffice.nix            # LibreOffice (pc module)
├── messaging-apps.nix         # Signal, Discord, etc. (pc module)
├── systems.nix                # Supported systems: x86_64-linux, aarch64-linux
├── toplevel/users.nix         # User account creation
├── meta/
│   ├── user.nix               # primaryUser option (name, username, email)
│   └── disk-layout/           # Disk layout options + templates
│       ├── nixos.nix          # Option definitions (disk0, disk1, swap, discards)
│       ├── btrfs-luks.nix
│       ├── btrfs-luks-with-raid0.nix
│       ├── ext4-simple.nix
│       └── gpt-bios-compat.nix
├── cli/                       # CLI tools (15 files)
│   ├── default.nix            # Base CLI: bash, starship, fzf, eza, atuin, carapace
│   ├── zsh.nix, ssh.nix, tmux.nix, direnv.nix, zoxide.nix
│   ├── helix.nix, helix-dev.nix
│   ├── jujutsu-vcs.nix, git.nix
│   ├── syntax-highlighting.nix, autosuggestion.nix
│   ├── notify-after-long-running-command.nix
│   ├── gpg.nix, yazi.nix
│   └── ...
├── hardening/                 # Security hardening (9 files)
│   ├── boot.nix               # Kernel params (slab_nomerge, init_on_alloc, pti, etc.)
│   ├── openssh.nix, pam.nix, usbguard.nix, acl.nix
│   ├── blacklist_modules.nix, entropy.nix, machine-id.nix, zram.nix
├── desktop/                   # Desktop environment
│   ├── dconf.nix, terminal.nix, xdg.nix
├── plasma/                    # KDE Plasma
│   ├── kde.nix, plasma-manager.nix
├── audio/                     # Audio
│   ├── pipewire.nix, easyeffects.nix
├── networking/                # Networking
│   ├── networkmanager.nix, mullvad-vpn.nix, mac-address.nix
├── auth/                      # Authentication
│   ├── bitwarden.nix, proton-pass.nix, yubikey.nix
├── media/                     # Media apps
│   ├── mpv.nix, entertainment.nix, freetube.nix, pcloud.nix
├── gaming/                    # Gaming
│   ├── steam.nix, gamemode.nix, apps.nix
├── development/               # Dev tools
│   ├── rootless-docker.nix, nix-output-monitor.nix, nix-trusted-user.nix
├── infrastructure/            # Flake infra
│   ├── flake-parts.nix, devshell.nix, github-actions.nix, time.nix
├── nix/                       # Nix settings
│   ├── settings.nix, package.nix
├── web-browsers/
│   └── firefox.nix
├── hardware/
│   └── facter.nix
└── assets/                    # Theme TOML files
    ├── gruvbox-rainbow.toml
    └── base16_default_dark.toml
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add a desktop app | `modules/<category>/` | Contribute to `unify.modules.pc.home` or `.nixos` |
| Add a dev tool | `modules/cli/` or `modules/development/` | Contribute to `unify.modules.dev.home` |
| Change shell config | `modules/cli/zsh.nix` | zsh + plugins |
| Change editor config | `modules/cli/helix.nix` or `helix-dev.nix` | Base editor vs dev extras |
| Change Nix daemon config | `modules/nix/settings.nix` | Registry, experimental features, substituters |
| Change Nix version | `modules/nix/package.nix` | Uses `nixVersions` from nixpkgs |
| Add security hardening | `modules/hardening/` | Each file is a focused hardening area |
| Change firewall | `modules/hardening/openssh.nix` | SSH + network hardening |
| Add VPN support | `modules/networking/mullvad-vpn.nix` | Mullvad VPN client |
| Add auth device | `modules/auth/yubikey.nix` | YubiKey, or bitwarden.nix, proton-pass.nix |
| Add a disk layout template | `modules/meta/disk-layout/` | Add file, reference from host |

## MODULE CONTRIBUTION PATTERN

Every module file uses `unify.*` attributes to declare its contribution. The pattern is:

```nix
{config, ...}: {
  unify.modules.<group>.nixos = { ... };  # NixOS-level config
  # OR
  unify.modules.<group>.home = { pkgs, ... }: { ... };  # Home-manager config
  # OR both in one file:
  unify.modules.<group> = {
    nixos = { ... };
    home = { ... };
  };
}
```

### Module groups and their contributors

| Group | Contributors | Used by hosts |
|-------|-------------|---------------|
| `pc` | cli/default.nix, audio/*, desktop/*, media/*, auth/*, networking/networkmanager, messaging-apps, libreoffice | asrock, thinkpadx1 |
| `dev` | cli/{helix-dev,ssh,zsh,tmux,direnv,zoxide,jj,syntax-highlighting,autosuggestion,notify}, development/* | asrock, thinkpadx1 |
| `desktop-plasma` | plasma/*, desktop/terminal.nix | asrock, thinkpadx1 |
| `gaming` | gaming/* | asrock |
| `laptop` | tlp.nix | thinkpadx1 |
| `disk-btrfs-on-luks` | meta/disk-layout/btrfs-luks.nix | thinkpadx1 |
| `disk-btrfs-on-luks-with-raid0` | meta/disk-layout/btrfs-luks-with-raid0.nix | asrock |
| `disk-ext4-simple` | meta/disk-layout/ext4-simple.nix | teemo, aesop |
| `disk-gpt-bios-compat` | meta/disk-layout/gpt-bios-compat.nix | dokja |

## CONVENTIONS

- **One module per file** — each `.nix` file contributes to exactly one `unify.modules.*` group
- **No raw `imports`** — use `unify.nixos.imports` or `unify.home.imports`. Only `flake.nix` uses `inputs.import-tree`
- **Use `hostConfig`** to access host-level options (name, primaryUser, disk-layout) inside module bodies
- **kebab-case filenames** — multi-word: `btrfs-luks.nix`, `rootless-docker.nix`. Single-word: `mpv.nix`, `sudo.nix`
- **Theme assets** go in `modules/assets/` as TOML, referenced via `builtins.fromTOML (builtins.readFile ../assets/<file>)`

## ANTI-PATTERNS (THIS MODULES DIRECTORY)

- **Do NOT add `imports = [ ... ]` at NixOS level** — the unify framework handles module composition
- **Do NOT reference `pkgs` without checking** — home-manager uses `useGlobalPkgs = true`, so pkgs come from nixpkgs
- **`modules/desktop/xdg.nix` HACK** — uses `/var/empty` workaround for broken XDG options. Do not remove without testing
- **`modules/toplevel/users.nix` TODO** — admin account creation pending, `trusted-users` commented out

## NOTES

- `modules/cli/default.nix` serves double duty: base CLI tools AND the `unify.modules.pc.home` profile
- `modules/unfree-packages.nix` defines a reusable inner module for both NixOS and home-manager
- `modules/infrastructure/github-actions.nix` generates the CI matrix via `nix-github-actions`
- `modules/infrastructure/devshell.nix` provides `nix develop` with sops + nix
- All modules are auto-discovered — just create the file and it's picked up by import-tree
