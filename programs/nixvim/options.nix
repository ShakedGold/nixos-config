{
  programs.nixvim = {
    enable = true;

    opts = {
      expandtab = true;
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
      tabstop = 2;
      softtabstop = 2;

      shiftwidth = 2; # Tab width should be 2
      confirm = true;
      cmdheight = 0;

      undodir = "/tmp/.nvim-undo-dir";
      undofile = true;

      colorcolumn = "120";
    };

    clipboard.register = "unnamedplus";

    globals.mapleader = " ";
  };
}
