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

### Test image

```
nix run .#vmImage # CTRL-A X to close ;)
ssh 127.0.0.1 -o StrictHostKeyChecking=no -p 2222 -l admin # Password: admin
```
