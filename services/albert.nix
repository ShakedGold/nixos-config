{pkgs, ...}: {
  systemd.user.services.albert = {
    Install = {
      WantedBy = ["default.target"];
    };

    Unit = {
      "Description" = "Linux Application Launcher";
      "Documentation" = ["https://albertlauncher.github.io/"];
      After = ["network.target"];
    };

    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 1;
      ExecStart = pkgs.albert;
    };
  };
}
