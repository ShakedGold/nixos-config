{
  wayland.windowManager.hyprland.settings."$mod" = "CAPS";

  wayland.windowManager.hyprland.settings.bind = [
    "$mod, F, exec, zen"
    "$mod, Q, killactive"

    "$mod, H, movefocus, l"
    "$mod, L, movefocus, r"
    "$mod, J, movefocus, d"
    "$mod, K, movefocus, u"
  ];
}
