{
  description = "hyper-nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    code-nix = {
      url = "github:fxttr/code-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        extensions.follows = "nix-vscode-extensions";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs =
        import inputs.nixpkgs
          {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };

      code = inputs.code-nix.packages.${system}.default;
    in
    {
      checks = {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
          };
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          nixpkgs-fmt
          (code {
            profiles = {
              nix = {
                enable = true;
              };
            };
          })
        ];
      };
    };
}
