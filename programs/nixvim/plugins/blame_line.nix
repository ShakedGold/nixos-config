{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "blame_line";
        version = "unstable"; # or use "unstable" if it's not tagged
        src = pkgs.fetchFromGitHub {
          owner = "braxtons12";
          repo = "blame_line.nvim";
          rev = "9b469d97b6cb50b12e5569ddc9d899513d0671b6"; # use latest commit
          sha256 = "sha256-uTZPmYg24oEbp+0kzp7DepL0EdKLevsT9gO/T+UztUI="; # use `nix flake show` or `nix-prefetch`
        };
      })
    ];

    # Optional: configure it in luaPlugins or luaConfig
    extraConfigLua = ''
      require("blame_line").setup {}
    '';
  };
}
