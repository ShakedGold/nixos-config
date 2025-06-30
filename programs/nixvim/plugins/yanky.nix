{
  programs.nixvim = {
    plugins.yanky = {
      enable = true;
      enableTelescope = true;
      settings = {
        highlight = {
          timer = 200;
        };
      };
    };
  };
}
