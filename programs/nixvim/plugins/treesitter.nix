{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;

      settings = {
        indent = true;
        highlight.enable = true;
      };

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        lua
        javascript
        nix
      ];
    };
  };
}
