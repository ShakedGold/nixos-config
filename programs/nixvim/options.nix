{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    opts = {
      expandtab = true;
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers
      tabstop = 4;
      softtabstop = 4;

      shiftwidth = 4;        # Tab width should be 2
    };
  };
}
