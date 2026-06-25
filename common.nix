{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  nixpkgs = {
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })

      # Override
      # /run/current-system/sw/share/applications/org.gnome.Terminal.desktop
      # FIXME: not appearing anymore in app menu
      # (final: prev: {
      #   gnome-terminal = prev.gnome-terminal.overrideAttrs (oldAttrs: {
      #     postInstall = (oldAttrs.postInstall or "") + ''
      #       substituteInPlace $out/share/applications/org.gnome.Terminal.desktop \
      #         --replace "Exec=gnome-terminal" "Exec=gnome-terminal --maximize"
      #     '';
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      # Fix "warning: download buffer is full; consider increasing the 'download-buffer-size' setting"
      download-buffer-size = 500000000; # 500 MB
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Use fixed version of the Linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "fr_FR.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };

  # Configure console keymap
  # console.keyMap = "fr";
  # Ergo‑L in vconsole
  console.useXkbConfig = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "ergol";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.bluetooth.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      monaspace # Nerd font with icons
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "MonaspaceNeon" ]; # FIXME: does not work on plasma
      };
    };
  };

  programs = {
    # Install firefox.
    firefox.enable = true;

    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ # https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
          "git"
          "z" # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/z
        ];
        theme = "agnoster"; # "af-magic"; # https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
      };
      autosuggestions.enable = true; # Grey autocomplete suggestion
    };
  };

  # Rootless Docker
  virtualisation.docker = {
    # Disable the system wide Docker daemon
    enable = false;

    rootless = {
      enable = true;
      # Configures the DOCKER_HOST environment variable to point to the rootless Docker instance
      setSocketVariable = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      kdePackages.kate
      kdePackages.kcalc
      haruna
      calibre
      gimp
      keepassxc
      spotify
      # variety # Pretty wallpapers
      dig # For nslookup
      libreoffice
      # ergogen

      # Dev tools
      neovim
      vim
      git
      lazygit
      ripgrep # For neovim search projects
      fd # For neovim search projects
      gnumake # For building neovim plugins
      tree-sitter # For neovim
      docker-compose
      cargo-watch
      dbeaver-bin
      xclip # Fix neovim/lazygit clipboard for X11
      bruno
      watchexec
      kalamine
      hugo # Ergo‑L website
      pandoc # Ergo‑L website
      # freecad
      zip
      nodejs # For neovim Mason to install prettierd with npm

      # Languages
      zig
      cargo # Rust
      rustc # Rust
      rustfmt # Rust
      clippy # Rust
      gcc # Add "cc" for Rust proc-macro2

      # LSP
      lua-language-server # Lua
      rust-analyzer # Rust
      zls # Zig
      # jdt-language-server # Java
      taplo # TOML
      # kotlin-lsp # Not in Nix for now
      # superhtml
      # tailwindcss-language-server

      # Formatter
      # prettierd # Installed via neovim Mason to have the same as openSUSE WSL
      stylua
    ];
  };

  # Variety config
  # systemd.user.services = {
  #   wallpaper-slideshow-random = {
  #     enable = true;
  #     after = [ "network.target" ];
  #     wantedBy = [ "default.target" ];
  #     description = "Sets up the wallpaper slideshow randomly";
  #     serviceConfig = {
  #       Type = "simple";
  #       ExecStart = "variety";
  #     };
  #   };
  # };

  networking = {
    # Enable networking
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      trilowy = {
        # You can set an initial password for your user.
        # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
        # Be sure to change it (using passwd) after rebooting!
        # initialPassword = "correcthorsebatterystaple";
        isNormalUser = true;
        description = "Trilowy";
        # openssh.authorizedKeys.keys = [
        #  # Add your SSH public key(s) here, if you plan on using SSH to connect
        # ];
        extraGroups = [ "networkmanager" "wheel" ];
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  #services.openssh = {
  #  enable = true;
  #  settings = {
  #    # Opinionated: forbid root login through SSH.
  #    PermitRootLogin = "no";
  #    # Opinionated: use keys only.
  #    # Remove if you want to SSH using passwords
  #    PasswordAuthentication = false;
  #  };
  #};

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
