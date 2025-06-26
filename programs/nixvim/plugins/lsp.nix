{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      lsp-format.enable = true;
      servers = {
        nixd.enable = true;
        gopls = {
          enable = true;
          filetypes = [ "go" "gomod" "gowork" "gotmpl" ];
        };
      };
  };
}
