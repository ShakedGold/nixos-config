{
  config,
  ...
} :
let wallpaper = "${config.home.homeDirectory}/.config/home-manager/wallpaper.png"; in {
  programs.hyprpaper = {
    enable = true;

    settings = {
      preload = [ wallpaper ];
      wallpaper = [
        "DP-4,${wallpaper}"
        "HDMI-2-A,${wallpaper}"
      ];
    };
  };
}
