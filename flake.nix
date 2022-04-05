{
  description = "Detect local paths in flake.lock";

  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.pre-commit-hooks = {
    url = "github:cachix/pre-commit-hooks.nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit-hooks
    }:
    {
      overlay = _final: prev: {
        flake-no-path = prev.callPackage ./release.nix { };
      };
    } //
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in
      {
        packages = flake-utils.lib.flattenTree {
          inherit (pkgs) flake-no-path;
        };
        defaultPackage = pkgs.flake-no-path;

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true;
              statix.enable = true;
              deno-fmt = {
                enable = true;
                name = "Reformat deno code";
                entry = "${pkgs.deno}/bin/deno fmt";
                files = "\\.(t|j)sx?$";
                pass_filenames = true;
              };
              deno-lint = {
                enable = true;
                name = "Lint deno code";
                entry = "${pkgs.deno}/bin/deno lint";
                files = "\\.(t|j)sx?$";
                pass_filenames = true;
              };
              flake-no-path = {
                enable = true;
                name = "Ensure that flake.lock does not contain a local path";
                entry = "${pkgs.flake-no-path}/bin/flake-no-path";
                files = "flake\.lock$";
                pass_filenames = true;
              };
            };
          };
        };
        devShell = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      });
}
