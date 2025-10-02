{pkgs, ...}: {
  programs.anyrun = {
    enable = true;
    config = {
      hidePluginInfo = true;
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/librink.so"
        "${pkgs.anyrun}/lib/libkidex.so"
        "${pkgs.anyrun}/lib/libwebsearch.so"
      ];
    };
  };
}
