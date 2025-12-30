{ config, ... }:
let
  hyperkey = ''Shift+Ctrl+Alt+Meta'';
in
{
  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-alphablack";
      clickItemTo = "select";
      lookAndFeel = "com.github.vinceliuice.Colloid-dark-nord";
      cursor.theme = "macOS";
      iconTheme = "Papirus-Dark";
      colorScheme = "BreezeDark";
      wallpaper = "${config.home.homeDirectory}/.config/nixos/wallpaper.png";
      enableMiddleClickPaste = false;

      windowDecorations = {
        library = "org.kde.klassy";
        theme = "Klassy";
      };
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
          window-types = [ "normal" ];
        };
        apply = {
          noborder = true;
          above = true;
        };
      }
    ];

    input = {
      mice = [
        {
          enable = true;
          name = "SteelSeries SteelSeries Aerox 3 Wireless";
          acceleration = -0.20;
          accelerationProfile = "none";
          scrollSpeed = 1;
          vendorId = "1038";
          productId = "183a";
        }
        {
          enable = true;
          name = "Aerox 3";
          acceleration = -0.20;
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
                  "vesktop"
                  "albert"
                  "applications:albert"
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
                  "applications:org.gnome.Nautilus.desktop"
                  "applications:zen-beta.desktop"
                  "applications:com.mitchellh.ghostty.desktop"
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

    hotkeys.commands = {
      "launch-terminal" = {
        name = "Launch Terminal";
        key = "${hyperkey}+T";
        command = "${config.home.sessionVariables.TERMINAL}";
      };
      "lock" = {
        name = "Lock Screen";
        key = "Meta+L";
        command = "dbus-send --dest=org.freedesktop.ScreenSaver --type=method_call /ScreenSaver org.freedesktop.ScreenSaver.Lock";
      };
      # "albert-toggle" = {
      #   name = "Albert Toggle";
      #   key = "Alt+Space";
      #   command = "albert toggle";
      # };
      # "anyrun" = {
      #   name = "Anyrun";
      #   key = "Alt+Space";
      #   command = "anyrun";
      # };
      "vicinae" = {
        name = "Vicinae";
        key = "Alt+Space";
        command = "vicinae toggle";
      };
    };

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
