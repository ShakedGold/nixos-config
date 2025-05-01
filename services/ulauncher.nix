{
  pkgs,
  ...
} : {
  systemd.user.services.ulauncher = {
    Install = {
      After = ["network.target"];
      WantedBy = ["default.target"];
    };

    Unit = {
      "Description" = "Linux Application Launcher";
      "Documentation" = ["https://ulauncher.io/"];
    };

    Service = let
      pydeps = pkgs.python3.withPackages (pp:
        with pp; [
          # calculate anything
          google
          pytz # https://github.com/tchar/ulauncher-albert-calculate-anything
          pint # https://github.com/tchar/ulauncher-albert-calculate-anything
          simpleeval # https://github.com/tchar/ulauncher-albert-calculate-anything
          requests # https://github.com/tchar/ulauncher-albert-calculate-anything
          parsedatetime # https://github.com/tchar/ulauncher-albert-calculate-anything
          google-api-python-client # https://github.com/Carlosmape/ulauncher-calendar/blob/master/requirements.txt
          google-auth-oauthlib # https://github.com/Carlosmape/ulauncher-calendar/blob/master/requirements.txt
          pydbus
          pygobject3

          # spotify webapi
          spotipy
        ]);
    in
    {
      Type = "simple";
      Restart = "always";
      RestartSec = 1;
      ExecStart = pkgs.writeShellScript "ulauncher-env-wrapper.sh" ''
        export PATH="''${XDG_BIN_HOME}:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        export PYTHONPATH="${pydeps}/${pydeps.sitePackages}"
        exec ${pkgs.ulauncher}/bin/ulauncher --hide-window --verbose
      '';
    };
  };
}
