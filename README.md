# Nix Configurations

Declarative system and user configurations for Linux (NixOS) and macOS (nix-darwin) using Nix Flakes and Home Manager.

---

## 1. Architecture

Configuration layers import their dependencies hierarchically:

```
Workstation (i3 / Desktop) -> Linux Base (Headless/CLI) -> Base (Common)
VM (Headless Test VM)      -> Linux Base               -> Base
macOS (nix-darwin)         -> Darwin Base              -> Base
```

* **`base.nix`**: Common cross-platform system defaults and core CLI tools.
* **`os/linux-base.nix`**: Headless Linux defaults, storage, security, and networking.
* **`os/linux-workstation.nix`**: Graphical desktop environment (i3), applications, and hardware policies.
* **`os/darwin.nix`**: macOS system defaults, Homebrew integration, and Cocoa keybindings.
* **`home-manager/`**: User-space environment (shell, dev tools, desktop session configs).
* **`hosts/`**: Host-specific hardware definitions, filesystems, and machine overrides.

---

## 2. Daily Usage

### Apply Changes

* **NixOS**:
  ```bash
  run0 nixos-rebuild switch --flake .
  ```
* **macOS (nix-darwin)**:
  ```bash
  darwin-rebuild switch --flake .
  ```

### Maintenance

* **Standard lock update**:
  ```bash
  nix flake update --commit-lock-file
  ```
* **Update with upstream diff review**:
  ```bash
  scripts/lock-review update --commit-lock-file
  ```
* **Format codebase**:
  ```bash
  nix fmt .
  ```

---

## 3. Specialisations & Profiles

Laptop configurations include a declarative **`Powersave`** specialisation for maximum battery runtime and silent operation (disables CPU turbo boost, tunes power policies, and enables diagnostic `debugfs`):

* **Switch live (no reboot)**:
  ```bash
  run0 /run/current-system/specialisation/Powersave/bin/switch-to-configuration test
  ```
* **Switch back to default live**:
  ```bash
  run0 /run/current-system/bin/switch-to-configuration test
  ```
* **Boot directly into Powersave**:
  Press <kbd>Space</kbd> or <kbd>Esc</kbd> at the `systemd-boot` menu and select `NixOS (Powersave)`.

---

## 4. Bootstrapping

### NixOS

1. Partition and format disks according to your desired layout:
   * [NixOS Installation Guide](https://nixos.org/manual/nixos/stable/#sec-installation)
   * [LUKS Partitioning Guide](https://nixos.org/manual/nixos/stable/#sec-luks-file-systems)
   * [LVM Guide](https://nixos.wiki/wiki/LVM)
2. Mount partitions (e.g. `/mnt`) and generate hardware configuration:
   ```bash
   nixos-generate-config --root /mnt
   ```
3. Copy/merge the hardware configuration into `hosts/<hostname>.nix`, register the host in `flake.nix`, install without setting a root password, and initialize your user password:
   ```bash
   nixos-install --flake .#<hostname> --no-root-passwd
   nixos-enter --root /mnt -c "passwd <username>"
   ```

### macOS (nix-darwin)

1. Install Nix.
2. Clone repository and run the installer switch:
   ```bash
   nix run nix-darwin -- switch --flake .#<hostname>
   ```

---

## 5. VM Testing

To build and launch a headless test VM in QEMU:
```bash
nix run .#vmImage
```

Connect to the running VM via SSH (password: `admin`):
```bash
ssh localhost -o StrictHostKeyChecking=no -p 2222 -l admin
```
