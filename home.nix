{
  pkgs,
  ...
}: let
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
    sudo nixos-rebuild switch

    git push
    popd
  '';
  json-to-nix = pkgs.writeShellScriptBin "json-to-nix" ''

# Original script: https://gist.githubusercontent.com/Scoder12/0538252ed4b82d65e59115075369d34d/raw/e86d1d64d1373a497118beb1259dab149cea951d/json2nix.py
"""Converts JSON objects into nix (hackishly)."""
#!/usr/bin/env python

import sys
import json


INDENT = " " * 2


def strip_comments(t):
    # fixme: doesn't work if JSON strings contain //
    return "\n".join(l.partition("//")[0] for l in t.split("\n"))


def indent(s):
    return "\n".join(INDENT + i for i in s.split("\n"))


def nix_stringify(s):
    # fixme: this doesn't handle string interpolation and possibly has more bugs
    return json.dumps(s)


def sanitize_key(s):
    if s and s.isalnum() and not s[0].isdigit():
        return s
    return nix_stringify(s)


def flatten_obj_item(k, v):
    keys = [k]
    val = v
    while isinstance(val, dict) and len(val) == 1:
        k = next(iter(val.keys()))
        keys.append(k)
        val = val[k]
    return keys, val


def fmt_object(obj, flatten):
    fields = []
    for k, v in obj.items():
        if flatten:
            keys, val = flatten_obj_item(k, v)
            formatted_key = ".".join(sanitize_key(i) for i in keys)
        else:
            formatted_key = sanitize_key(k)
            val = v
        fields.append(f"{formatted_key} = {fmt_any(val, flatten)};")

    return "{\n" + indent("\n".join(fields)) + "\n}"


def fmt_array(o, flatten):
    body = indent("\n".join(fmt_any(i, flatten) for i in o))
    return f"[\n{body}\n]"


def fmt_any(o, flatten):
    if isinstance(o, str) or isinstance(o, bool) or isinstance(o, int):
        return json.dumps(o)
    if isinstance(o, list):
        return fmt_array(o, flatten)
    if isinstance(o, dict):
        return fmt_object(o, flatten)
    raise TypeError(f"Unknown type {type(o)!r}")


def main():
    flatten = "--flatten" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]

    if len(args) < 1:
        print(f"Usage: {sys.argv[0]} [--flatten] <file.json>", file=sys.stderr)
        sys.exit(1)

    with open(args[0], "r") as f:
        contents = f.read().strip()
        if contents[-1] == ",":
            contents = contents[:-1]
        if contents[0] != "{":
            contents = "{" + contents + "}"
        data = json.loads(strip_comments(contents))

    outputs = fmt_any(data, flatten=flatten)
    print(outputs[1:-1])


if __name__ == "__main__":
    main()

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

  home.file.".clangd".text = ''
  CompileFlags:
    Add:
      - -I${pkgs.glibc.dev}/include
      - -I${pkgs.libcxx.dev}/include/c++/v1
      - -Wall
      - -Wextra
      - -std=c99
      - -pedantic
      - -Werror
    Index:
      Background: Skip
'';
}
