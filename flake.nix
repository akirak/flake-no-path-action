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
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; };

        flake-no-path = pkgs.writeShellApplication {
          name = "flake-no-path";
          runtimeInputs = [
            pkgs.deno
            pkgs.fd
          ];
          text = ''
            if [[ $# -eq 0 ]]
            then
              fd --one-file-system flake.lock \
               | xargs deno run --allow-env --allow-read ${./main.ts}
            else
              exec deno run --allow-env --allow-read ${./main.ts} "$@"
            fi
          '';
        };
      in
      rec {
        packages = flake-utils.lib.flattenTree {
          inherit flake-no-path;
        };
        defaultPackage = flake-no-path;
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              nix-linter.enable = true;
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
                entry = "${flake-no-path}/bin/flake-no-path";
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
