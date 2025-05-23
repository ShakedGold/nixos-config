{
  config,
  ...
} :
let wallpaper = "${config.home.homeDirectory}/.config/home-manager/wallpaper.png"; in {
  services.hyprpaper = {
    enable = true;

    settings = {
      preload = [ wallpaper ];
      wallpaper = [
        "DP-4,${wallpaper}"
        "HDMI-A-2,${wallpaper}"
      ];
    };
  };
}
