{ pkgs, ... }
{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;

      settings = {
        indent = true;
        highlight = true;
      };

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        lua
        javascript
        nix
      ];
    };
  };
}
