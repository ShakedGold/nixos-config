{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      inlayHints = true;

      servers = {
        gopls = {
          enable = true;
          autostart = true;
        };
        nil_ls = {
          enable = true;
          settings.nix.flake.autoArchive = true;
        };

        pylsp.enable = true;
        pylsp.settings.plugins.pylsp_mypy.enabled = true;
        pylsp.settings.plugins.pylint.enabled = true;

        golangci_lint_ls.enable = true;
        lua_ls.enable = true;
        clangd.enable = true;
        dockerls.enable = true;
      };
    };

    plugins.lsp-format.enable = true;
  };
}
