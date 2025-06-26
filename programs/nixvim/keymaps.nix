{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        options.silent = true;
        action = "<cmd>Telescope find_files<CR>";
      }
      {
        mode = "n";
        key = "<leader>fg";
        options.silent = true;
        action = "<cmd>Telescope live_grep<CR>";
      }
      {
        mode = "n";
        key = "<leader>e";
        options.silent = true;
        action = "<cmd>Neotree filesystem toggle<CR>";
      }
      {
        mode = "n";
        key = "<leader>w";
        options.silent = true;
        action = "<cmd>w<CR>";
      }
      {
        mode = "n";
        key = "<leader>q";
        options.silent = true;
        action = "<cmd>q<CR>";
      }
      {
        key = "f";
        action.__raw = ''
          function()
            local hop = require('hop')
            hop.hint_words()
          end
        '';
        options.remap = true;
      }
      {
        mode = "n";
        key = "<leader>bb";
        options.silent = true;
        action = "<cmd>BufferPick<CR>";
      }
    ];
  };
}
