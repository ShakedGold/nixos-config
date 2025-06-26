{
  programs.nixvim = {
    plugins.blink-cmp.enable = true;
    plugins.blink-cmp.setupLspCapabilities = true;
  };
}
