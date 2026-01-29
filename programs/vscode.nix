{
  pkgs,
  ...
} : {
  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          formulahendry.auto-rename-tag
          streetsidesoftware.code-spell-checker
          dbaeumer.vscode-eslint
          eamodio.gitlens
          golang.go
          graphql.vscode-graphql
          graphql.vscode-graphql-syntax
          ecmel.vscode-html-css
          lokalise.i18n-ally
          shd101wyy.markdown-preview-enhanced
          bierner.markdown-mermaid
          davidanson.vscode-markdownlint
          pkief.material-icon-theme
          yoavbls.pretty-ts-errors
          ms-vscode-remote.vscode-remote-extensionpack
          timonwong.shellcheck
          bradlc.vscode-tailwindcss
          jgclark.vscode-todo-highlight
          vue.volar
        ];
        userSettings = {
          "editor.smoothScrolling" = true;
          "editor.cursorBlinking" = "smooth";
          "editor.formatOnSave" = true;
          "workbench.colorTheme" = "Vira Carbon";
          "editor.cursorSmoothCaretAnimation" = "on";
          "window.menuBarVisibility" = "visible";
          "window.titleBarStyle" = "custom";
          "editor.mouseWheelZoom" = true;
          "workbench.iconTheme" = "material-icon-theme";
        };
      };
    };
  };
}
