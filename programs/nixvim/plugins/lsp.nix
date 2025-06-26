{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        gopls = {
          enable = true;
          autostart = true;
        };
        golangci_lint_ls.enable = true;
        lua_ls.enable = true;
        nil_ls = {
          enable = true;
          autoArchive = true;
        };
      };
    };

    plugins.lsp-format.enable = true;
  };
}
