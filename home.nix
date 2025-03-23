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
  davincivideo = pkgs.writeShellScriptBin "davincivideo" ''
#!/bin/bash

# Put his file in ~/.local/bin to be in the path
# Run it from directory where video file is in
# execute as: davincimp4.sh 'file name.mov'
# Inverted commas required if a space in the filename

# Check if an input file is provided
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <input_mov_file>"
  exit 1
fi

# Get the input file name (without extension)
input_file="$\{1%.*\}"

# Get the output file name (same name as input but with .mp4 extension)
output_file="$\{input_file\}.mp4"

# Option in Video: FFmpeg command with hardware acceleration and encoding parameters
# For a higher bitrate try changing -qp 15 to -qp 10
ffmpeg -hwaccel cuda -hwaccel_device 0 -i "$input_file.mov" -vf yadif -codec:v h264_nvenc -qp 10 -bf 2 -flags +cgop -pix_fmt yuv420p -codec:a aac -strict -2 -b:a 384k -r:a 48000 -movflags faststart "$output_file"

# Another Nvidia option
# ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -i "$input_file.mov" -c:a copy -c:v h264_nvenc -b:v 10M -fps_mode passthrough "$output_file"

# Non Nvidia option
# ffmpeg -i "$input_file.mov" -vf yadif -codec:v libx264 -crf 1 -bf 2 -flags +cgop -pix_fmt yuv420p -codec:a aac -strict -2 -b:a 384k -r:a 48000 -movflags faststart "$output_file"

echo "Conversion completed. Output file: $output_file"
  '';
in let
  onePassPath = "~/.1password/agent.sock";
in {
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
    davincivideo 
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
      ${lib.concatMapStrings (x: "${toString x}\n") (lib.mapAttrsToList(name: value: "export ${name}=${toString value}") config.home.sessionVariables)}
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
