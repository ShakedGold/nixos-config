{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  nixos-build = pkgs.writeShellScriptBin "nixos-build" ''
    pushd $HOME/.config/home-manager
    $EDITOR configuration.nix
    alejandra . &>/dev/false
    git --no-pager diff -U0 main
    read -p "Do you want to nixos-rebuild [Y/n]: " -n 1 -r
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo
        echo "!!! Canceled by user."
        exit 1
    fi
    echo "NixOS Rebuilding..."
    sudo nixos-rebuild switch

    # If errors were found in the rebuild log, exit before committing
    # if grep -Eq "^error" ~/nixos-rebuild.log; then
    #     grep --color "error" ~/nixos-rebuild.log
    #     exit 1
    # fi

    echo "Committing..."
    git add -A
    git commit -am "$(nixos-rebuild list-generations | grep current) - $(date)"
    git push
    popd
  '';
  onePassPath = "~/.1password/agent.sock";
in {
  imports = [
    ./hyprland.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "shaked";
  home.homeDirectory = "/home/shaked";
  home.enableNixpkgsReleaseCheck = false;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    nixos-build
    hyprland
    papirus-icon-theme
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # KDE ulauncher sys extension
    ".config/ulauncher-system/entries/kde.json".text = ''
      {
        "lock": {
            "command": "dbus-send --dest=org.freedesktop.ScreenSaver --type=method_call /ScreenSaver org.freedesktop.ScreenSaver.Lock"
        },
        "log-out": {
            "command": "qdbus org.kde.Shutdown /Shutdown  org.kde.Shutdown.logout"
        },
        "restart": {
            "command": "qdbus org.kde.Shutdown /Shutdown  org.kde.Shutdown.logoutAndReboot"
        },
        "shutdown": {
            "command": "qdbus org.kde.Shutdown /Shutdown  org.kde.Shutdown.logoutAndShutdown"
        }
      }
    '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/shaked/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  
  xdg.desktopEntries = {
    "1password" = {
      name = "1Password";
      exec = "1password --ozone-platform=x11 %U";
      type = "Application";
      icon = "1password";
      comment = "Password manager and secure wallet";
      mimeType = [ "x-scheme-handler/onepassword" ];
      categories = [ "Office" ];
      terminal = false;
    };
    "davinci-resolve-studio" = {
      categories = ["AudioVideo" "AudioVideoEditing" "Video" "Graphics"];
      comment = "Professional video editing, color, effects and audio post-processing";
      exec = ''"qdbus org.kde.kded6 /kded org.kde.kded6.unloadModule "appmenu" && davinci-resolve-studio %u && qdbus org.kde.kded6 /kded org.kde.kded6.loadModule "appmenu""'';
      icon = "davinci-resolve-studio";
      name = "Davinci Resolve Studio";
      type = "Application";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.clipman = {
    enable = true;
  };

  programs.obs-studio.package = inputs.nixpkgs-obs-nvenc.legacyPackages.${pkgs.system}.obs-studio.override {
    cudaSupport = true;
  };
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-pipewire-audio-capture
  ];
  # environment for ulauncher
  systemd.user.services.ulauncher = {
    Install = {
      After = ["network.target"];
      WantedBy = ["default.target"];
    };

    Unit = {
      "Description" = "Linux Application Launcher";
      "Documentation" = ["https://ulauncher.io/"];
    };

    Service = let
      pydeps = pkgs.python3.withPackages (pp:
        with pp; [
          # calculate anything
          google
          pytz # https://github.com/tchar/ulauncher-albert-calculate-anything
          pint # https://github.com/tchar/ulauncher-albert-calculate-anything
          simpleeval # https://github.com/tchar/ulauncher-albert-calculate-anything
          requests # https://github.com/tchar/ulauncher-albert-calculate-anything
          parsedatetime # https://github.com/tchar/ulauncher-albert-calculate-anything
          google-api-python-client # https://github.com/Carlosmape/ulauncher-calendar/blob/master/requirements.txt
          google-auth-oauthlib # https://github.com/Carlosmape/ulauncher-calendar/blob/master/requirements.txt
          pydbus
          pygobject3

          # spotify webapi
          spotipy
        ]);
    in
    {
      Type = "simple";
      Restart = "always";
      RestartSec = 1;
      ExecStart = pkgs.writeShellScript "ulauncher-env-wrapper.sh" ''
        export PATH="''${XDG_BIN_HOME}:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        export PYTHONPATH="${pydeps}/${pydeps.sitePackages}"
        exec ${pkgs.ulauncher}/bin/ulauncher --hide-window --verbose
      '';
    };
  };

  # Programs
  programs.git = {
    enable = true;
    userName = "Shaked Gold";
    userEmail = "shakedgold2005@gmail.com";
    extraConfig.init.defaultBranch = "main";
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono NL Nerd Font";
      size = 10;
    };
    settings = {
      confirm_os_window_close = 0;
      tab_bar_style = "powerline";
    };
    shellIntegration.enableZshIntegration = true;
    keybindings = {
      "ctrl+j" = "send_text all \\x1b\\x5b\\x42";
      "ctrl+k" = "send_text all \\x1b\\x5b\\x41";
      "ctrl+h" = "send_text all \\x1b\\x5b\\x44";
      "ctrl+l" = "send_text all \\x1b\\x5b\\x43";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      cat = "bat";
      ls = "eza --icons=always";
      pcat = "bat --style plain";
    };

    initExtra = ''
      [[ "$TERM" == "xterm-kitty" ]] && export TERM=xterm-256color
      ${lib.concatMapStrings (x: "${toString x}\n") (lib.mapAttrsToList(name: value: "export ${name}=${toString value}") config.home.sessionVariables)}
      source ${config.home.homeDirectory}/.config/home-manager/custom-zsh-theme.zsh-theme
    '';

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "thefuck"];
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

programs.ssh = {
  enable = true;
  # Disable default options by setting them to false
  matchBlocks = {
    "*" = {
      extraOptions = {
        "IdentityAgent" = onePassPath;
      };
    };
    "shaked-mac" = {
      hostname = "192.168.1.148";
      user = "shakedgold";
      extraOptions = {
        "IdentityAgent" = onePassPath;
      };
      localForwards = [
        {
          host.address = "localhost";
          bind.address = "localhost";
          host.port = 3380;
          bind.port = 3380;
        }
        {
          host.address = "localhost";
          bind.address = "localhost";
          host.port = 3381;
          bind.port = 3381;
        }
        {
          host.address = "localhost";
          bind.address = "localhost";
          host.port = 5173;
          bind.port = 5173;
        }
        {
          host.address = "localhost";
          bind.address = "localhost";
          host.port = 5174;
          bind.port = 5174;
        }
        {
          host.address = "localhost";
          bind.address = "localhost";
          host.port = 33443;
          bind.port = 33443;
        }
      ];
    };
  };
};
  # programs.ssh = {
  #   enable = true;
  #   extraConfig = ''
  #     Host *
  #         IdentityAgent ${onePassPath}
  #   '';
  # };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      formulahendry.auto-rename-tag
      streetsidesoftware.code-spell-checker
      dbaeumer.vscode-eslint
      eamodio.gitlens
      golang.go
      graphql.vscode-graphql
      graphql.vscode-graphql-syntax
      ecmel.vscode-html-css
      lokalise.i18n-ally
      shd101wyy.markdown-preview-enhanced
      bierner.markdown-mermaid
      davidanson.vscode-markdownlint
      pkief.material-icon-theme
      yoavbls.pretty-ts-errors
      ms-vscode-remote.vscode-remote-extensionpack
      timonwong.shellcheck
      bradlc.vscode-tailwindcss
      jgclark.vscode-todo-highlight
      vue.volar
    ];
    userSettings = {
      "editor.smoothScrolling" = true;
      "editor.cursorBlinking" = "smooth";
      "editor.formatOnSave" = true;
      "workbench.colorTheme" = "Material Theme Ocean High Contrast";
      "workbench.iconTheme" = "material-icon-theme";
      "editor.cursorSmoothCaretAnimation" = "on";
      "window.menuBarVisibility" = "visible";
      "window.titleBarStyle" = "custom";
    };
  };

  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark";
  };

  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-alphablack";
      clickItemTo = "select";
      lookAndFeel = "com.github.vinceliuice.Colloid-dark-nord";
      cursor.theme = "macOS";
      iconTheme = "Papirus-Dark";
      colorScheme = "BreezeDark";
      wallpaper = "${config.home.homeDirectory}/.config/home-manager/wallpaper.png";
      enableMiddleClickPaste = false;
    };

    session = {
      sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
    };

    kwin = {
      edgeBarrier = 0;
    };

    kscreenlocker = {
      autoLock = false;
      lockOnStartup = true;
      timeout = 0;
    };

    window-rules = [
      {
        description = "ULauncher";
        match = {
          window-class = {
            value = "ulauncher";
            type = "substring";
          };
          window-types = ["normal"];
        };
        apply = {
          noborder = true;
          above = true;
        };
      }
    ];

    hotkeys.commands."launch-kitty" = {
      name = "Launch Konsole";
      key = "Meta+Return";
      command = "kitty";
    };
    hotkeys.commands."lock" = {
      name = "Lock Screen";
      key = "Meta+L";
      command = "dbus-send --dest=org.freedesktop.ScreenSaver --type=method_call /ScreenSaver org.freedesktop.ScreenSaver.Lock";
    };
    hotkeys.commands."ulauncher-toggle" = {
      name = "Ulauncher Toggle";
      key = "Alt+Space";
      command = "ulauncher-toggle";
    };

    input = {
      mice = [
        {
          enable = true;
          name = "SteelSeries SteelSeries Aerox 3 Wireless";
          acceleration = 0;
          accelerationProfile = "none";
          scrollSpeed = 1;
          vendorId = "1038";
          productId = "183a";
        }
        {
          enable = true;
          name = "Aerox 3";
          acceleration = 0;
          accelerationProfile = "none";
          scrollSpeed = 1;
          vendorId = "0111";
          productId = "183a";
        }
      ];
      keyboard = {
        numlockOnStartup = "on";
        layouts = [
          {
            layout = "us";
          }
          {
            layout = "il";
          }
        ];
      };
    };

    panels = [
      {
        location = "top";
        height = 34;
        screen = "all";
        widgets = [
          {
            kickerdash = {
              icon = "kde-symbolic";
            };
          }
          "org.kde.plasma.appmenu"
          "org.kde.plasma.panelspacer"
          {
            systemTray = {
              items = {
                showAll = false;
                shown = [
                  "org.kde.plasma.keyboardlayout"
                ];
                hidden = [
                  "CopyQ_copyq"
                  "ulauncher"
                  "Xwayland Video Bridge_pipewireToXProxy"
                  "com.github.eneshecan.WhatsAppForLinux.Tray"
                  "com.github.zren.alphablackcontrol"
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.brightness"
                  "org.kde.plasma.networkmanagement"
                  "org.remmina.Remmina"
                  "plasmashell_microphone"
                  "steam"
                  "applications:vesktop.desktop"
                ];
              };
            };
          }
          "org.kde.plasma.digitalclock"
        ];
        hiding = "normalpanel";
      }
      {
        location = "bottom";
        height = 60;
        floating = true;
        hiding = "dodgewindows";
        lengthMode = "fit";
        screen = "all";
        widgets = [
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                launchers = [
                  "applications:systemsettings.desktop"
                  "preferred://filemanager"
                  "applications:zen.desktop"
                  "applications:kitty.desktop"
                  "applications:vesktop.desktop"
                  "applications:code.desktop"
                  "applications:spotify.desktop"
                  "applications:steam.desktop"
                ];
              };
            };
          }
        ];
      }
    ];

    shortcuts = {
      kwin = {
        "Kill Window" = "Meta+Q";
      };
      "KDE Keyboard Layout Switcher" = {
        "Switch to Next Keyboard Layout" = "Alt+Shift";
      };
    };
  };
}
