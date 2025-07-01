{pkgs, ...}: let
  nixos-build = pkgs.writeShellScriptBin "nixos-build" ''
    pushd $HOME/.config/home-manager
    $EDITOR configuration.nix
    alejandra . &>/dev/false
    git --no-pager diff -U0 main

    read -p "Do you want to commit [Y/n]: " -n 1 -r
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo
        echo "!!! Canceled by user."
        exit 1
    fi

    echo "Committing..."
    git add -A
    git commit -am "$(nixos-rebuild list-generations | grep current) - $(date)"

    read -p "Do you want to nixos-rebuild [Y/n]: " -n 1 -r
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo
        echo "!!! Canceled by user."
        exit 1
    fi

    echo "NixOS Rebuilding..."
    sudo nixos-rebuild switch --upgrade --impure

    git push
    popd
  '';

  run-or-raise = pkgs.writeShellScriptBin "run-or-raise" ''
    #!/usr/bin/env bash
    # Usage: ww -f "window class filter" -c "run if not found"
    # Usage: ww -fa "window title filter" -c "run if not found"

    ## Find and contribute to a more updated version https://github.com/academo/ww-run-raise

    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
      key="$1"

      case $key in
      -c | --command)
        COMMAND="$2"
        shift # past argument
        shift # past value
        ;;
      -f | --filter)
        FILTERBY="$2"
        shift # past argument
        shift # past value
        ;;
      -fa | --filter-alternative)
        FILTERALT="$2"
        shift # past argument
        shift # past value
        ;;
      *)                   # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift              # past argument
        ;;
      esac
    done

    set -- "''${POSITIONAL[@]}" # restore positional parameters

    SCRIPT_CLASS_NAME=$(
      cat <<EOF
    function kwinactivateclient(targetApp) {
      var clients = workspace.windowList();
      for (var i=0; i<clients.length; i++) {
        client = clients[i];
        if (client.resourceClass == targetApp){
          workspace.activeWindow = client;
          break;
        }
      }
    }
    kwinactivateclient('REPLACE_ME');
    EOF
    )

    SCRIPT_CAPTION=$(
      cat <<EOF
    function kwinactivateclient(targetApp) {
      var clients = workspace.windowList();
      for (var i=0; i<clients.length; i++) {
        client = clients[i];
        if (client.caption == targetApp){
          workspace.activeWindow = client;
          break;
        }
      }
    }
    kwinactivateclient('REPLACE_ME');
    EOF
    )

    CURRENT_SCRIPT_NAME=$(basename $0)

    # ensure the script file exists
    function ensure_script {
      if [ ! -f SCRIPT_PATH ]; then
        if [ ! -d "$SCRIPT_FOLDER" ]; then
          mkdir -p "$SCRIPT_FOLDER"
        fi
        if [ "$1" == "class" ]; then
          SCRIPT_CONTENT=''${SCRIPT_CLASS_NAME/REPLACE_ME/$2}
        else
          SCRIPT_CONTENT=''${SCRIPT_CAPTION/REPLACE_ME/$2}
        fi
        echo "$SCRIPT_CONTENT" >"$SCRIPT_PATH"
      fi
    }

    if [ -z "$FILTERBY" ] && [ -z "$FILTERALT" ]; then
      echo You need to specify a window filter. Either by class -f or by title -fa
      exit 1
    fi

    IS_RUNNING=$(pgrep -o -a -f "$COMMAND" | grep -v "$CURRENT_SCRIPT_NAME")

    if [ -n "$IS_RUNNING" ] || [ -n "$FILTERALT" ]; then
      echo "PROGRAM $COMMAND IS RUNNING"

      SCRIPT_FOLDER="$HOME/.wwscripts/"
      SCRIPT_NAME=$(echo "$FILTERBY$FILTERALT" | md5sum | head -c 32)
      SCRIPT_PATH="$SCRIPT_FOLDER$SCRIPT_NAME"
      if [ -n "$FILTERBY" ]; then
        ensure_script class $FILTERBY
      else
        ensure_script caption $FILTERALT
      fi
      SCRIPT_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
      # run it
      echo "LOADING SCRIPT: $SCRIPT_PATH"

      qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$SCRIPT_PATH" "$SCRIPT_NAME" > /dev/null

      echo "RUNNING SCRIPT: $SCRIPT_PATH"
      qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.start > /dev/null

      # uninstall it
      echo "UNINSTALLING SCRIPT: $SCRIPT_NAME"
      qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript $SCRIPT_NAME > /dev/null

      # remove it
      rm -rf $HOME/.wwscripts
    elif [ -n "$COMMAND" ]; then
      echo "PROGRAM $COMMAND IS NOT RUNNING"

      $COMMAND &
    fi
  '';
in {
  imports = [
    ./programs
    ./services
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
    run-or-raise
    hyprland
    papirus-icon-theme
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-hyprland
    ];
    xdgOpenUsePortal = true;
  };

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
    BROWSER = "zen-beta";
    TERMINAL = "ghostty";
  };

  xdg.desktopEntries = {
    "1password" = {
      name = "1Password";
      exec = "1password --ozone-platform=x11 %U";
      type = "Application";
      icon = "1password";
      comment = "Password manager and secure wallet";
      mimeType = ["x-scheme-handler/onepassword"];
      categories = ["Office"];
      terminal = false;
    };
    "davinci-resolve-studio" = {
      categories = [
        "AudioVideo"
        "AudioVideoEditing"
        "Video"
        "Graphics"
      ];
      comment = "Professional video editing, color, effects and audio post-processing";
      exec = ''"qdbus org.kde.kded6 /kded org.kde.kded6.unloadModule "appmenu" && davinci-resolve-studio %u && qdbus org.kde.kded6 /kded org.kde.kded6.loadModule "appmenu""'';
      icon = "davinci-resolve-studio";
      name = "Davinci Resolve Studio";
      type = "Application";
    };

    whatsie = {
      name = "Whatsie";
      comment = "WhatsApp messaging client for linux";
      genericName = "Whatsapp";
      exec = "QT_QPA_PLATFORM=xcb whatsie";
      icon = "whatsapp";
      categories = [
        "Network"
      ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.file.".clangd".text = ''
    CompileFlags:
      Add:
        - -I${pkgs.glibc.dev}/include
        - -Iinclude
        - -Wall
        - -Wextra
        - -std=c99
        - -pedantic
        - -Werror
      Index:
        Background: Skip
  '';
}
