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
      Restart = "on-failure";
      RestartSec = 30;
      ExecStart = pkgs.writeShellScript "noisetorch.sh" '''';
    };
  };
}
