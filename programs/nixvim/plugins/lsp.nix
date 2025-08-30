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

        rust_analyzer = {
          enable = true;
          installRustc = false;
          installCargo = false;
        };

        pylsp.enable = true;
        pylsp.settings.plugins.pylsp_mypy.enabled = true;
        pylsp.settings.plugins.pylint.enabled = true;

        golangci_lint_ls.enable = true;
        lua_ls.enable = true;
        clangd.enable = true;
        dockerls.enable = true;
        cmake.enable = true;
      };

      keymaps = {
        silent = true;
        lspBuf = {
          gd = {
            action = "definition";
            desc = "Goto Definition";
          };
          gr = {
            action = "references";
            desc = "Goto References";
          };
          gD = {
            action = "declaration";
            desc = "Goto Declaration";
          };
          gI = {
            action = "implementation";
            desc = "Goto Implementation";
          };
          gT = {
            action = "type_definition";
            desc = "Type Definition";
          };
          K = {
            action = "hover";
            desc = "Hover";
          };
          "<leader>cw" = {
            action = "workspace_symbol";
            desc = "Workspace Symbol";
          };
          "<leader>cr" = {
            action = "rename";
            desc = "Rename";
          };
        };
        diagnostic = {
          "<leader>cd" = {
            action = "open_float";
            desc = "Line Diagnostics";
          };
          "[d" = {
            action = "goto_next";
            desc = "Next Diagnostic";
          };
          "]d" = {
            action = "goto_prev";
            desc = "Previous Diagnostic";
          };
        };
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

      vim.diagnostic.config {
        float={border=_border}
      };

      require('lspconfig.ui.windows').default_options = {
        border = _border
      }

      vim.diagnostic.enable = true
      -- vim.diagnostic.config({
      --   virtual_lines = true,
      -- })
    '';
  };
}
