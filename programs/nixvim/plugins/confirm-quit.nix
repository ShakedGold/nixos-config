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
          rev = "9f70766a2a6eeafe7744b1a8a2e06a894d43ee7a"; # use latest commit
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # use `nix flake show` or `nix-prefetch`
        };
      })
    ];

    # Optional: configure it in luaPlugins or luaConfig
    extraConfigLua = ''
      require("confirm-quit").setup()
    '';
  };
}
