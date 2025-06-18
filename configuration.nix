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
  hardware.graphics.enable32Bit = true;
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = ["nodev"];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = lib.mkAfter [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=0" "nvidia.NVreg_EnableGpuFirmware=0" ];

  security.sudo.configFile = ''
    Defaults  !sudoedit_checkdir
  '';

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

  nix.settings.experimental-features = ["nix-command" "flakes"];
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
  networking.networkmanager.enable = true;

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
  
  # Enable the hyprland Desktop Environment
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE="wayland";
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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
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
    extraGroups = ["networkmanager" "wheel" "geoclue"];
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
    nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
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

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  # Desktop Portals
  xdg.portal = {
    enable = true;

    config = {
      kde.default = [ "kde" "gtk" "gnome" ];
      kde."org.freedesktop.portal.FileChooser" = [ "kde" ];
      kde."org.freedesktop.portal.OpenURI" = [ "kde" ];

      hyprland.default = [ "hyprland" "gtk" "termfilechooser" ];
      hyprland."org.freedesktop.portal.FileChooser" = [ "termfilechooser" ];
      hyprland."org.freedesktop.portal.OpenURI" = [ "termfilechooser" ];
    };

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-termfilechooser

      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
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
    neovim
    kitty
    zsh
    pay-respects
    ripgrep
    gcc
    nodejs
    protonup-qt
    steam-run
    (steam.override {
      extraPkgs = pkgs: with pkgs; [gtk3 mono libgdiplus zlib];
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
    ulauncher
    wmctrl
    wl-clipboard
    rustup
    tlp
    fzf
    copyq
    fd
    alejandra
    neofetch
    waylock
    xdg-desktop-portal-gtk
    man-pages
    killall
    btop
    tldr
    bat
    vlc
    insomnia
    chromium
    zerotierone
    kdePackages.bluedevil
    unityhub
    busybox
    rpcs3
    zoom-us
    prismlauncher
    inputs.zen-browser.packages."${system}".default
    obs-studio
    nv-codec-headers-12
    wireplumber
    (pkgs.callPackage ./davinci-resolve-paid.nix  {})
    r2modman
    waybar
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
    rofi
    eza
    ghostty
    hyprlock
    pamixer
    hyprpaper
    wails
    docker
    nsis
    upx
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
      ];
    })
    asdf-vm
    superTuxKart
    (discord.override {
      withVencord = true;
    })
    tmux
    gnumake
    fd
    ncdu
    lazygit
    nettools
    python3
    clang-tools
    gitflow
  ];

  programs.noisetorch.enable = true;

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
  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        config = builtins.readFile ./services/kanata/kanata.kbd;
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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  security.pam.loginLimits = [
    { domain = "*"; item = "memlock"; type = "-"; value = "unlimited"; }
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
