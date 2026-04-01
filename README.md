# nix-config

> > Immortal cultivation is repentant enlightenment.
> >
> > Like tiny grains of salt gathering to form the sea,
> >
> > Build mountains through repentant enlightenment.
> >
> > Building a mountain of salt is perhaps the fastest way to reach the heavens.
>
> As your gaze pierces through the heavens, a \[double cone separated by a colorless wall\] enters your field of vision, endlessly exuding an endless sense of despair. Strangely, the longer you linger on that feeling, your mind finds increasing clarity. Such is the nature you felt: \[something\] that brings anguish on the surface but is a source of comfort after contemplation. Regardless of your will, a certain \[name\] is engraved into your mind: 
>
> Leisure Extinguishing Mantra.
>
> ☯

The path of a NixOS practitioner is unforgiving; the world has settled and manifesting one's will to action is no small feat. This scripture was written for my own cultivation, but if you are a fellow traveler on the Nix path, perhaps even the babbling of this mere mortal can illuminate the next step. A technique to borrow. A pattern to adapt. A reminder that declarative configuration is, at its core, the pursuit of immutability — and what is immortality if not the absence of change? And what is the absence of change in the face of a heart that covers Heaven and Earth? Boiled...I think eating boiled potatoes could reveal more clues.

```bash
$ nix flake check --accept-flake-config
Understanding the system before breakthrough...
Fortune accumulated. Ryeong lowers the six-sided club!
```

The only way out is through.

---

## Hosts

Middle realms, composed of the corpses of previous iterations. After all, isn't that how all systems are formed? Each host is a practice arena — carved for its purpose, declared in scripture, and rebuilt with a single command.

| Host | Form | Purpose | Disk Formation |
|------|------|---------|----------------|
| **asrock** | Desktop — Ryzen, dual NVMe | Gaming & workstation | btrfs-luks-with-raid0 |
| **thinkpadx1** | ThinkPad X1 Carbon | Portable cultivation station | btrfs-on-luks |
| **dokja** | VPS in the cloud | Public-facing gateway — WireGuard hub | gpt-bios-compat |
| **teemo** | Raspberry Pi 4 | Home server, containers, monitoring | ext4-simple |
| **aesop** | Intel N100 mini PC | Media server | ext4-simple |

New hosts are added the same way every time: a `default.nix` under `hosts/`, a name in `checks.nix`, a vault in `secrets/`. The mantra does not care how many grounds you tend — only that each is declared fully.

---

*May your closures evaluate swiftly, your store stay garbage-free, and your tribulations compile on the first attempt.*

[Return to top](#nix-config)
