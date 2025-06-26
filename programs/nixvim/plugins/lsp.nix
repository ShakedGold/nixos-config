{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        gopls = {
          enable = true;
          autostart = true;
        };
        nil_ls = {
          enable = true;
          settings.nix.flake.autoArchive = true;
        };

        golangci_lint_ls.enable = true;
        lua_ls.enable = true;
      };
    };

    plugins.lsp-format.enable = true;
  };
}
