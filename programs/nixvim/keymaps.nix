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
    ];
  };
}
