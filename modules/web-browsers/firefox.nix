{withSystem, ...}: {
  flake.modules.homeManager.desktop-plasma = {pkgs, ...}: {
    programs.firefox.nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];
  };

  flake.modules.homeManager.gui = {pkgs, ...}: {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
    };

    programs.firefox = {
      enable = true;
      languagePacks = ["en_US"];
      policies = {
        SearchSuggestEnabled = false;
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };
        HttpsOnlyMode = "force_enabled";
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
          Exceptions = [];
        };
        SanitizeOnShutdown = {
          Cache = true;
          Cookies = true;
          Sessions = true;
          SiteSettings = true;
          OfflineApps = true;
          Locked = true;
        };
        FirefoxHome = {
          Search = true;
          TopSites = true;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = true;
          Locked = true;
        };
        InstallAddonsPermission = {
          "Allow" = [];
          "Default" = false;
        };
        DisplayBookmarksToolbar = "always";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";
        DisablePocket = true;
        DisableFormHistory = true;
        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = true;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        DisableMasterPasswordCreation = true;
        DisableTelemetry = true;
        PasswordManagerEnabled = false;
        HardwareAcceleration = true;
      };
      profiles.default = {
        isDefault = true;
        settings = {
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
        search = {
          default = "ddg";
          privateDefault = "ddg";
          force = true;
          engines = {
            nix-packages = {
              name = "Nix Packages";
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@np"];
            };
            nix-options = {
              name = "NixOS Options";
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@no"];
            };
            nixos-wiki = {
              name = "NixOS Wiki";
              urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
              iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
              definedAliases = ["@nw"];
            };
            home-manager-options = {
              name = "Home Manager Options";
              urls = [
                {
                  template = "https://home-manager-options.extranix.com/";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                    {
                      name = "release";
                      value = "master";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@hmo"];
            };
          };
        };
        extensions.packages = withSystem pkgs.system ({inputs', ...}:
          with inputs'.nur.legacyPackages.repos.rycee.firefox-addons; [
            plasma-integration
            privacy-redirect
            proton-pass
            ublock-origin
            addy_io
            bitwarden
          ]);
      };
    };
  };
}
