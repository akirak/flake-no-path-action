# flake-no-path for Nix

This script checks `path:` references in `flake.lock` files. If there is any node that is locked to an absolute path, it will cause a non-zero exit.

`flake.lock` can be either given as arguments or searched recursively from the working directory.

## Usage

```sh
nix run github:akirak/flake-no-path -- [FILE...]
```
