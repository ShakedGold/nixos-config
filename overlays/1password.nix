final: prev: {
  _1password-gui = prev._1password-gui.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      substituteInPlace /run/current-system/sw/share/applications/1password.desktop \
        --replace "Exec=1password" "Exec=1password --ozone-platform=x11"
    '';
  });
}
