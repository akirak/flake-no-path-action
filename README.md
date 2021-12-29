# flake-no-path for Nix

This script checks `path:` references in `flake.lock` files. If there is any node that is locked to an absolute path, it will cause a non-zero exit.

`flake.lock` can be either given as arguments or searched recursively from the working directory.

## Usage

```sh
nix run github:akirak/flake-no-path -- [FILE...]
```

You can combine it with [pre-commit-hooks.nix](https://github.com/cachix/pre-commit-hooks.nix/).

[Example](https://github.com/akirak/flake-no-path/blob/master/flake.nix):

```nix
   pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
              nix-linter.enable = true;
              flake-no-path = {
                enable = true;
                name = "Ensure that flake.lock does not contain a local path";
                entry = "${flake-no-path}/bin/flake-no-path";
                files = "flake\.lock$";
                pass_filenames = true;
              };
            };
          };
```
