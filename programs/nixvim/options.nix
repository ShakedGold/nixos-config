{
  programs.nixvim = {
    enable = true;

    opts = {
      expandtab = true;
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers

      smartindent = false;

      confirm = true;
      cmdheight = 0;

      undodir = "/tmp/.nvim-undo-dir";
      undofile = true;
    };

    clipboard.register = "unnamedplus";

    globals.mapleader = " ";
  };
}
