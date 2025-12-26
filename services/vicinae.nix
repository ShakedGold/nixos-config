{pkgs, ...}: {
  systemd.user.services.albert = {
    Install = {
      WantedBy = ["default.target"];
    };

    Unit = {
      "Description" = "Vicinae Application Launcher";
      "Documentation" = [];
      After = ["network.target"];
    };

    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 1;
      ExecStart = pkgs.writeShellScript "vicinae-server.sh" "vicinae server --replace";
    };
  };
}
