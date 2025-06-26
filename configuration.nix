# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  options,
  lib,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = ["nodev"];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = lib.mkAfter [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=0"
    "nvidia.NVreg_EnableGpuFirmware=0"
  ];

  # security.sudo.configFile = ''
  #   Defaults  !sudoedit_checkdir
  # '';
  security.sudo.enable = lib.mkForce true;

  system.autoUpgrade = {
    enable = true;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "10:00";
    randomizedDelaySec = "45min";
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 10d";
  nix.settings.auto-optimise-store = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
  };

  services.resolved.enable = true;
  networking.resolvconf.useLocalResolver = true;

  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  # Set your time zone.
  time.timeZone = "Asia/Jerusalem";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IL";

  i18n.extraLocaleSettings = {
    LANG = "en_IL";
    LC_ADDRESS = "en_IL";
    LC_IDENTIFICATION = "en_IL";
    LC_MEASUREMENT = "en_IL";
    LC_MONETARY = "en_IL";
    LC_NAME = "en_IL";
    LC_NUMERIC = "en_IL";
    LC_PAPER = "en_IL";
    LC_TELEPHONE = "en_IL";
    LC_TIME = "en_IL";
    LC_ALL = "en_IL";
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "shaked";
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    xwaylandvideobridge
    plasma-browser-integration
  ];
  programs.dconf.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    nur =
      import
      (builtins.fetchTarball {
        # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/main
        url = "https://github.com/nix-community/NUR/archive/33df6fc789f71aa6e203ee8053260ddc61d09174.tar.gz";
        # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
        sha256 = "02kzwkf914my1sshwzhg12hvqahp3x00ggfj0p166lqdajjg57bh";
      })
      {
        inherit pkgs;
      };
  };

  # Enable the hyprland Desktop Environment
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
  };

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        .zen-wrapped
        .zen
        zen
      '';
      mode = "0755";
    };
  };
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  # services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shaked = {
    uid = 1000;
    isNormalUser = true;
    description = "Shaked Gold";
    shell = pkgs.zsh;
    useDefaultShell = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "geoclue"
      "input"
      "kvm"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [pkgs.firefoxpwa];
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = ["shaked"];
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  # Desktop Portals
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  xdg.mime.defaultApplications = {
    "text/html" = "/run/current-system/sw/share/applications/zen.desktop";
    "x-scheme-handler/http" = "/run/current-system/sw/share/applications/zen.desktop";
    "x-scheme-handler/https" = "/run/current-system/sw/share/applications/zen.desktop";
    "x-scheme-handler/about" = "/run/current-system/sw/share/applications/zen.desktop";
    "x-scheme-handler/unknown" = "/run/current-system/sw/share/applications/zen.desktop";
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "233ccaac27ac343e"
    ];
  };

  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  # nix-ld
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries =
    options.programs.nix-ld.libraries.default
    ++ (with pkgs; [
      glib
      nss
      nspr
      dbus
      at-spi2-atk
      cups
      libdrm
      gtk3
      pango
      cairo
      nx-libs
      expat
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
      libxkbcommon
      alsa-lib
      mesa
    ]);

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nix-search-cli
    wget
    colloid-kde
    colloid-gtk-theme
    home-manager
    kitty
    zsh
    ripgrep
    gcc
    nodejs
    protonup-qt
    steam-run
    (steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          gtk3
          mono
          libgdiplus
          zlib
        ];
    })
    spotify
    vscode
    go
    gopls
    postman
    ludusavi
    rclone
    linux-wallpaperengine
    lutris
    wine
    qbittorrent
    anydesk
    firefoxpwa
    stremio
    util-linux
    gparted
    wmctrl
    wl-clipboard
    rustup
    tlp
    fzf
    copyq
    fd
    alejandra
    waylock
    man-pages
    killall
    btop
    bat
    vlc
    chromium
    kdePackages.bluedevil
    busybox
    # rpcs3
    zoom-us
    prismlauncher
    inputs.zen-browser.packages."${system}".default
    obs-studio
    nv-codec-headers-12
    wireplumber
    (pkgs.callPackage ./davinci-resolve-paid.nix {})
    r2modman
    waybar
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    }))
    rofi
    eza
    ghostty
    hyprlock
    pamixer
    hyprpaper
    docker
    upx
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
      ];
    })
    superTuxKart
    vesktop
    tmux
    gnumake
    fd
    ncdu
    lazygit
    nettools
    python3
    clang-tools
    gitflow
    inputs.kwin-effects-forceblur.packages.${pkgs.system}.default
    kdePackages.xdg-desktop-portal-kde
    slurp
    jq
    openssl
    nasm
    albert
    nur.repos.shadowrz.klassy-qt6
    superTuxKart
    insomnia
    gef
    kdotool
    neovim
  ];

  programs.noisetorch.enable = true;
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["shaked"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd.qemu.vhostUserPackages = [pkgs.virtiofsd];

  # add directx -> vulcan
  nixpkgs.overlays = [
    (self: super: {
      steam = super.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            vkd3d
            dxvk
          ];
      };
    })
  ];

  programs.kdeconnect.enable = true;

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        extraDefCfg = ''
          process-unmapped-keys yes
          danger-enable-cmd yes
        '';
        config = builtins.readFile ./services/kanata/kanata.kbd;
      };
    };
    package = pkgs.kanata-with-cmd;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];

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
  system.stateVersion = "24.11"; # Did you read the comment?
}
