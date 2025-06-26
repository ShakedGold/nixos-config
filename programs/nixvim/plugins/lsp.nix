{
  programs.nixvim = {
    plugins.lsp.enable = true;

    plugins.lsp.autoLoad = true;
    plugins.lsp.servers = {
      nixd.enable = true;
    };
  };
}
