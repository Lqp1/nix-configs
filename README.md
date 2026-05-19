# My Nix Flake

## Module inheritance

Each module imports its parent, so a host only references the leaf profile.
Arrows (`->`) read as "imports":

```
linux-workstation -> os/linux-workstation -> os/linux-base -> base
                                          -> workstation
test-vm           -> os/linux-base        -> base
darwin            -> os/darwin            -> base
                  -> workstation
```

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
