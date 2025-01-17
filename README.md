# My Nix Flake

## Lock update

```
nix flake update --commit-lock-file
```

## Upgrade systems

### MacOS

```
nix run nix-darwin -- switch --flake .
darwin-rebuild --flake . switch
```

### Linux

```
sudo nixos-rebuild --flake . switch
```
