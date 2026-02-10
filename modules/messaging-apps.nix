{inputs, ...}: {
  unify.modules.pc = {
    home = {pkgs, ...}: {
      home.packages = with pkgs; [
        element-desktop
        protonmail-desktop
        signal-desktop
        tutanota-desktop
        # Discord Krisp doesn't work because of patched binary
        # https://github.com/NixOS/nixpkgs/issues/195512
        # https://github.com/NixOS/nixpkgs/pull/424232
        #discord
      ];

      # Use discord from flatpak as workaround
      imports = [
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
      ];

      services.flatpak = {
        enable = true;
        update.auto.enable = true;
        uninstallUnmanaged = true;
        packages = [
          "com.discordapp.Discord"
        ];
      };
      systemd.user.tmpfiles.rules = [
        # For flatpak discord RPC
        # https://github.com/flathub/com.discordapp.Discord/wiki/Rich-Precense-%28discord-rpc%29
        "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0"
      ];

      services.arrpc.enable = true;
    };
    nixos = {
      # Need system-level flatpak for home-manager level flatpak
      services.flatpak.enable = true;
    };
  };
}
