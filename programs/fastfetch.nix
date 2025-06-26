{pkgs, ...}
: {
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos";
        padding = {
          right = 1;
        };
      };
      display = {
        separator = "";
        color = {
          keys = "blue";
          title = "red";
        };
        key = {
          width = 20;
          type = "string";
        };
        bar = {
          width = 10;
          charElapsed = "■";
          charTotal = "-";
        };
        percent = {
          type = 9;
          color = {
            green = "green";
            yellow = "light_yellow";
            red = "light_red";
          };
        };
      };
      modules = [
        "title"
        "separator"
        {
          type = "os";
          key = "OS";
          keyColor = "blue";
          format = "{name} {version}";
        }
        {
          type = "kernel";
          key = "Kernel";
        }
        "wm"
        "break"
        {
          type = "memory";
          key = "Memory";
          percent = {
            type = 3;
            green = 30;
            yellow = 70;
          };
        }
        "disk"
        "break"
        "gpu"
        "uptime"
        "colors"
      ];
    };
  };
}
