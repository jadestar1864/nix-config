# HOSTS

Per-machine NixOS configurations. Each host directory contains a `default.nix` defining `unify.hosts.nixos.<name>` and optionally auxiliary `.nix` files for host-specific services.

## HOST SUMMARY

| Host | Hardware | Role | Disk Layout | Modules | State Ver |
|------|----------|------|-------------|---------|-----------|
| asrock | Desktop (2x NVMe) | Gaming/workstation | btrfs-luks-with-raid0 | pc, dev, desktop-plasma, gaming | 25.05 |
| thinkpadx1 | ThinkPad X1 Laptop | Laptop/dev | btrfs-on-luks | pc, dev, desktop-plasma, laptop | 25.05 |
| dokja | VPS (cloud) | Public server | gpt-bios-compat | (minimal) | 25.11 |
| teemo | Raspberry Pi 4 | Home server | ext4-simple | (minimal) | 25.11 |
| aesop | Intel N100 mini PC | Media server | ext4-simple | (minimal) | 25.11 |

## STRUCTURE

```
hosts/
├── checks.nix          # Build matrix for CI (pipe-operators syntax)
├── asrock/             # Desktop workstation
│   └── default.nix
├── thinkpadx1/         # Laptop
│   ├── default.nix
│   └── wg-client.nix
├── dokja/              # Public VPS server
│   ├── default.nix
│   ├── wg-server.nix
│   ├── swag.nix
│   ├── swag-configs/   # 13 nginx/proxy .conf files
│   ├── fail2ban.nix
│   ├── prometheus_exporter.nix
│   └── auto-upgrade.nix
├── teemo/              # Raspberry Pi 4
│   ├── default.nix
│   ├── containers.nix
│   ├── monitoring.nix
│   ├── wg-client.nix
│   ├── device-tree.nix # Device tree overlays (custom + upstream RPi)
│   ├── case-argoneonev2.nix
│   ├── actual-storage.nix
│   ├── niks3.nix       # Binary cache service
│   ├── rclone-space.nix
│   └── auto-upgrade.nix
└── aesop/              # Intel N100 mini PC
    ├── default.nix
    ├── containers.nix  # 518 lines — largest file in repo
    ├── wg-client.nix
    ├── prometheus_exporter.nix
    ├── ntfy-sh.nix
    ├── seerr.nix
    ├── external-ssd.nix
    └── auto-upgrade.nix
```

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Add a new host | Create `hosts/<name>/default.nix`, add hostname to `hosts/checks.nix` list |
| Change networking for a host | `hosts/<name>/default.nix` → `nixos.networking` and `systemd.network` |
| Add a container to a host | `hosts/<name>/containers.nix` (aesop, teemo) |
| Configure WireGuard server | `hosts/dokja/wg-server.nix` (hub) |
| Configure WireGuard client | `hosts/<name>/wg-client.nix` (spokes) |
| Add nginx proxy config | `hosts/dokja/swag-configs/<name>.conf` |
| Change reverse proxy | `hosts/dokja/swag.nix` |
| Add monitoring | `hosts/teemo/monitoring.nix` or `hosts/*/prometheus_exporter.nix` |
| Change RPi device tree | `hosts/teemo/device-tree.nix` (uses overlays pattern) |

## HOST PATTERNS

### Desktop hosts (asrock, thinkpadx1)
- Use `unify.modules` profiles: `pc`, `dev`, `desktop-plasma`
- NetworkManager for networking
- Disk encryption (btrfs-on-luks)
- Full home-manager config with desktop apps

### Server hosts (dokja, teemo, aesop)
- Minimal profile (no `pc`/`dev`/`desktop-plasma` modules)
- Static networking via `systemd.network` (no NetworkManager)
- SSH with authorized keys only
- Host-specific services in separate `.nix` files

### Adding a new host
1. Create `hosts/<name>/default.nix` following the pattern:
   ```nix
   {config, ...}: {
     unify.hosts.nixos.<name> = {
       modules = with config.unify.modules; [ ... ];
       users.jaden.modules = config.unify.hosts.nixos.<name>.modules;
       disk-layout = { disk0 = "..."; enableSwap = true; swapSize = 4; };
       nixos = { system.stateVersion = "25.11"; ... };
     };
   }
   ```
2. Generate `facter.json` on the target machine
3. Add hostname to the list in `hosts/checks.nix`
4. Add age key to `.sops.yaml` and create `secrets/hosts/<name>.yml`

## CONVENTIONS

- Auxiliary host files (wg-client, containers, monitoring, etc.) are separate `.nix` files in the host directory — NOT merged into default.nix
- All hosts use `hardware.facter.reportPath = ./facter.json` — hardware facts are committed
- Server hosts disable `networkmanager.enable` and use `systemd.network` with static addresses
- WireGuard: dokja is the hub (`wg-server.nix`), all others are spokes (`wg-client.nix`)
- `auto-upgrade.nix` files enable automatic NixOS upgrades on server hosts
- Shared secrets between hosts use naming like `secrets/hosts/<host1>-<host2>.yml`

## NOTES

- `hosts/aesop/containers.nix` (518 lines) is the largest file — media server containers (Sonarr, Radarr, Plex, etc.)
- `hosts/teemo/device-tree.nix` (121 lines) uses NixOS hardware device tree overlays for RPi
- `hosts/dokja/swag-configs/` contains 13 nginx `.conf` files for reverse proxy
- `hosts/checks.nix` uses pipe-operators syntax (`|>`) — requires `pipe-operators` experimental feature
