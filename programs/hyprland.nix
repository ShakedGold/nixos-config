{
  pkgs,
  ...
} :
let
  terminal = "ghostty --gtk-single-instance=true --quit-after-last-window-closed=false";
  rofi = builtins.toString ./rofi;
in {
  # HYPRLAND
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      "$mod" = "ALT";
      bind = [
        "$mod, Return, exec, ${terminal}"
        "$mod, q, killactive"
        "$mod, m, exit"
        "$mod, F, fullscreen, 1"
        "SUPER, L, exec, hyprlock"

        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        "$mod CTRL, h, movewindow, l"
        "$mod CTRL, j, movewindow, d"
        "$mod CTRL, k, movewindow, u"
        "$mod CTRL, l, movewindow, r"

        "$mod, Space, exec, pkill rofi || ${rofi}/launcher/launcher.sh"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"

        "$mod CTRL, 1, movetoworkspace, 1"
        "$mod CTRL, 2, movetoworkspace, 2"
        "$mod CTRL, 3, movetoworkspace, 3"
        "$mod CTRL, 4, movetoworkspace, 4"
        "$mod CTRL, 5, movetoworkspace, 5"
        "$mod CTRL, 6, movetoworkspace, 6"
        "$mod CTRL, 7, movetoworkspace, 7"
        "$mod CTRL, 8, movetoworkspace, 8"
      ];

      monitor = [
        "DP-4, 2560x1440@144, 0x0, 1"
        "HDMI-A-2, 1920x1080@60, 2560x0, 1, transform, 3"
      ];

      input = {
        kb_layout = "us,il";
        kb_variant = "";
        kb_model = "";
        kb_options = "grp:alt_shift_toggle";
        kb_rules = "";
        sensitivity = 0;
        force_no_accel = true;
      };

      general = {
        border_size = 2;
        gaps_in = 2;
        gaps_out = 10;

        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
      };

      decoration = {
        rounding = 5;
        rounding_power = 2;

        active_opacity = 1;
        inactive_opacity = 1;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
          ignore_opacity = true;
        };
      };

      env = [
        "XCURSOR_SIZE,24"
      ];

      exec-once = [
        "ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false"
        "hyprctl dispatch workspace 1"
        "waybar"
        "1password --silent"
        "vesktop --start-minimized"
        "steam -silent"
      ];

      windowrulev2 = [
        "stayfocused, class:(rofi)"
      ];

      workspace = [
        "name:1, monitor:DP-4"
      ];
    };
  };
}
