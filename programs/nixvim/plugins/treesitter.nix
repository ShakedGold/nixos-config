{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.treesitter.enable = true;

    plugins.treesitter.settings = {
      indent.enable = true;
      highlight.enable = true;
    };

    plugins.treesitter.grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      lua
      javascript
      nix
    ];
  };
}
