{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        gopls = {
          enable = true;
          autostart = true;
        };
        golangci_lint_ls.enable = true;
        lua_ls.enable = true;
      };
    };

    plugins.lsp-format.enable = true;
  };
}
