{pkgs, ...}: {
  programs.anyrun = {
    enable = true;
    config = {
      hidePluginInfo = true;
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
      ];
    };
  };
}
