{pkgs, ...}: {
  programs.nixvim = {
    enable = true;

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "confirm-quit.nvim";
        version = "unstable"; # or use "unstable" if it's not tagged
        src = pkgs.fetchFromGitHub {
          owner = "yutkat";
          repo = "confirm-quit.nvim";
          rev = "a1dbd9b553e8d6770cd6a879a3ee8ffad292c70c"; # use latest commit
          sha256 = "sha256-EGwSPxHCZaHWeeN8M+d3UXOor9ME7R6skpkcENVENRw="; # use `nix flake show` or `nix-prefetch`
        };
      })
    ];

    # Optional: configure it in luaPlugins or luaConfig
    extraConfigLua = ''
      require("confirm-quit").setup()
    '';
  };
}
