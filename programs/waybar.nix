{
  programs.waybar = {
    enable = true;
    
    systemd = {
      enable = true;
      target = "network.target";
    };

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        output = [
          "DP-4"
          "HDMI-A-2"
        ];

        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "hyprland/language"
          "clock"
        ];
      };
    };
  };
}
