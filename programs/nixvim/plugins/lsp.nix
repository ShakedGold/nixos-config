{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        gopls = {
          enable = true;
          filetypes = [ "go" "gomod" "gowork" "gotmpl" ];
        };
      };
    };

    plugins.lsp-format.enable = true;
  };
}
