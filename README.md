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

## First install

Format disks according to:
-
-
-
-

Then generate config, merge it into flake, and install:
```
nixos-generate-config --root /mnt
git clone https://github.com/lqp1/nix-configs
nixos-install --flake .#thomas-xxx --no-root-passwd
# Backup the edited repo to push later on when ssh keys, vault, rclone config etc... are setup
nixos-enter --root /mnt -c "passwd thomas"
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
