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

    extraConfigLua = ''
      local _border = "rounded"

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = _border
        }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = _border
        }
      )

      vim.diagnostic.config{
        float={border=_border}
      };

      require('lspconfig.ui.windows').default_options = {
        border = _border
      }
    '';
  };
}
