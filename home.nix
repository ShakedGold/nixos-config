{
  pkgs,
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
in {
  imports = [
    ./programs
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
}
