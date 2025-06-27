{
  programs.nixvim = {
    plugins.blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        appearance = {
          nerd_font_variant = "normal";
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
          cmdline = [];
          providers = {
            buffer = {
              score_offset = -7;
            };
            lsp = {
              fallbacks = [];
            };
          };
        };
      };
    };
  };
}
