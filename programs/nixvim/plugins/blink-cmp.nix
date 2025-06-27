{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      blink-ripgrep-nvim
    ];

    plugins.blink-cmp-dictionary.enable = true;
    plugins.blink-cmp-git.enable = true;
    plugins.blink-cmp-spell.enable = true;
    plugins.blink-copilot.enable = true;
    plugins.blink-emoji.enable = true;
    plugins.blink-ripgrep.enable = true;

    plugins.blink-cmp = {
      enable = true;
      setupLspCapabilities = true;

      settings = {
        appearance = {
          nerd_font_variant = "mono";
          use_nvim_cmp_as_default = true;
        };
        completion = {
          accept = {
            auto_brackets = {
              enabled = true;
              semantic_token_resolution = {
                enabled = false;
              };
            };
          };
          documentation = {
            auto_show = true;
            window = {
              border = "single";
            };
          };
          menu = {
            border = "none";
            draw = {
              gap = 1;
              treesitter = ["lsp"];
              columns = [
                {
                  __unkeyed-1 = "label";
                }
                {
                  __unkeyed-1 = "kind_icon";
                  __unkeyed-2 = "kind";
                  gap = 1;
                }
                {__unkeyed-1 = "source_name";}
              ];
            };
          };
        };
        keymap = {
          preset = "default";
          "<C-j>" = [
            "select_next"
            "fallback"
          ];
          "<C-k>" = [
            "select_prev"
            "fallback"
          ];
          "<Return>" = [
            "accept"
            "fallback"
          ];
          "<Tab>" = [
            "accept"
            "fallback"
          ];
        };
        signature = {
          enabled = true;
        };
        sources = {
          default = [
            "buffer"
            "lsp"
            "path"
            "snippets"
            # Community
            "copilot"
            "dictionary"
            "emoji"
            "git"
            "spell"
            "ripgrep"
          ];

          cmdline = [];
          providers = {
            ripgrep = {
              name = "Ripgrep";
              module = "blink-ripgrep";
              score_offset = 1;
            };
            dictionary = {
              name = "Dict";
              module = "blink-cmp-dictionary";
              min_keyword_length = 3;
            };
            emoji = {
              name = "Emoji";
              module = "blink-emoji";
              score_offset = 1;
            };
            copilot = {
              name = "copilot";
              module = "blink-copilot";
              async = true;
              score_offset = 100;
            };
            lsp.score_offset = 4;
            spell = {
              name = "Spell";
              module = "blink-cmp-spell";
              score_offset = 1;
            };
            git = {
              name = "Git";
              module = "blink-cmp-git";
              enabled = true;
              score_offset = 100;
              should_show_items.__raw = ''
                function()
                  return vim.o.filetype == 'gitcommit' or vim.o.filetype == 'markdown'
                end
              '';
              opts = {
                git_centers = {
                  github = {
                    issue = {
                      on_error.__raw = "function(_,_) return true end";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
