{
  wayland.windowManager.hyprland.settings."$mod" = "SUPER";

  wayland.windowManager.hyprland.settings.bind = [
    "$mod, F, exec, zen"
    "$mod, Q, killactive"

    "$mod, H, movefocus, l"
    "$mod, L, movefocus, r"
    "$mod, J, movefocus, u"
    "$mod, K, movefocus, d"
  ];
}
