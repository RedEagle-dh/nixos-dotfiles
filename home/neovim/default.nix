{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      rose-pine
      (nvim-treesitter.withPlugins (p: [
        p.java
        p.lua
        p.nix
        p.bash
        p.json
        p.yaml
        p.toml
        p.xml
        p.groovy
        p.kotlin
        p.properties
        p.markdown
        p.markdown_inline
        p.vim
        p.vimdoc
        p.python
        p.typescript
        p.tsx
        p.javascript
      ]))
      nvim-lspconfig
      blink-cmp
      telescope-nvim
      telescope-fzf-native-nvim
      plenary-nvim
      nvim-tree-lua
      nvim-web-devicons
      lualine-nvim
      gitsigns-nvim
      which-key-nvim
      nvim-autopairs
    ];

    extraPackages = with pkgs; [
      jdt-language-server
      lua-language-server
      nixd
      basedpyright
      ruff
      typescript
      typescript-language-server
      ripgrep
      fd
    ];

    initLua = builtins.readFile ./init.lua;
  };

  programs.java.enable = true;

  home.packages = with pkgs; [
    maven
    gradle
  ];
}
