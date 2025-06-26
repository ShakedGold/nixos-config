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
      ExecStart = pkgs.writeShellScript "albert-env-wrapper.sh" ''
        # export PATH="''${XDG_BIN_HOME}:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        albert
      '';
    };
  };
}
