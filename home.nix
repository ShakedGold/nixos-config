{
  config,
  pkgs,
  ...
}: let
  nixos-build = pkgs.writeShellScriptBin "nixos-build" ''
    pushd $HOME/.config/home-manager
    $EDITOR configuration.nix
    alejandra . &>/dev/null
    git --no-pager diff -U0 main
    read -p "Do you want to nixos-rebuild [Y/n]: " -n 1 -r
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo
        echo "!!! Canceled by user."
        exit 1
    fi
    echo "Cleaning NixOS Cache..."
    rm -rf $HOME/.cache/nix/
    echo "NixOS Rebuilding..."
    sudo nixos-rebuild switch &> ~/nixos-rebuild.log

    # If errors were found in the rebuild log, exit before committing
    if grep -Eq "^error" ~/nixos-rebuild.log; then
        grep --color "error" ~/nixos-rebuild.log
        exit 1
    fi

    echo "Committing..."
    git add -A
    git commit -am "$(nixos-rebuild list-generations | grep current) - $(date)"
    git push
    popd
  '';
in let
  # onePassPath = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  onePassPath = "~/.1password/agent.sock";
in {
  imports = [<plasma-manager/modules>];
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.clipman = {
    enable = true;
  };

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

    environment = let
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
    in {
      PYTHONPATH = "${pydeps}/${pydeps.sitePackages}";
    };
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 1;
      ExecStart = pkgs.writeShellScript "ulauncher-env-wrapper.sh" ''
        export PATH="''${XDG_BIN_HOME}:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
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
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };

    initExtra = ''
      [[ "$TERM" == "xterm-kitty" ]] && export TERM=xterm-256color
    '';

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "thefuck"];
      theme = "robbyrussell";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ${onePassPath}
      Host shaked-mac
          User shakedgold
          HostName 192.168.1.148
          IdentityAgent ${onePassPath}
          LocalForward localhost:3380 localhost:3380
          LocalForward localhost:3381 localhost:3381
          LocalForward localhost:5173 localhost:5173
          LocalForward localhost:5174 localhost:5174
          LocalForward localhost:33443 localhost:33443
    '';
  };

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
      equinusocio.vsc-material-theme
      equinusocio.vsc-material-theme-icons
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

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
    };
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
        numlockOnStartup = true;
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
                  "preferred://browser"
                  "applications:kitty.desktop"
                  "applications:vesktop.desktop"
                  "applications:code.desktop"
                  "applications:com.github.eneshecan.WhatsAppForLinux.desktop"
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
