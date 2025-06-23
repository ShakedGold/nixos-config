{
  pkgs,
  ...
}
:
{
  systemd.user.services.noisetorch = {
    Install = {
      WantedBy = ["default.target"];
    };

    Unit = {
      "Description" = "Voice reduction software";
      After = ["network.target"];
    };

    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 1;
      ExecStart = pkgs.writeShellScript "noisetorch.sh" ''
      noisetorch -u
      noisetorch -i -s alsa_output.usb-SteelSeries_SteelSeries_GameDAC_000000000000-00.stereo-chat.monitor
      '';
    };
  };
}
