Search `flake.lock` recursively, and check for nodes that are locked to `path:` references. If there is such a node (which effectively breaks reproducibility on other machines), it exits with non-zero.

## Usage

```sh
nix run github:akirak/flake-no-path
```
