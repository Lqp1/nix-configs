# My Nix Flake

## Flake format
```
nix fmt .
```

## Lock update

```
nix flake update --commit-lock-file
```

## Upgrade systems

### MacOS

```
nix run nix-darwin -- switch --flake .
sudo darwin-rebuild --flake . switch
```

### Linux

```
sudo nixos-rebuild --flake . switch
```
