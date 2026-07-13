# Nix OS & Home Manager Configurations

Declarative system and user-space configurations for Linux (NixOS) and macOS (nix-darwin) managed via Nix Flakes.

---

## 1. Architecture & Module Inheritance

Each module imports its parent, so host definitions only reference the leaf profiles.
Arrows (`->`) read as "imports":

```
linux-workstation -> os/linux-workstation -> os/linux-base -> base
test-vm           -> os/linux-base        -> base
darwin            -> os/darwin            -> base
```

### 📂 Directory Structure & Scopes

*   **[`base.nix`](file:///home/thomas/Documents/Repo/nix-configs/base.nix) (System Base - Cross-platform)**:
    *   Bare-minimum bootstrap config. Contains essential tools (`git`, `vim`, `htop`, `curl`, `coreutils`, `less`) available system-wide for rescue operations and fallback/headless users.
*   **[`os/linux-base.nix`](file:///home/thomas/Documents/Repo/nix-configs/os/linux-base.nix) (Linux Base)**:
    *   Low-level hardware diagnostics, storage tools, and drivers (`powertop`, `hdparm`, `samba`, `pciutils`).
*   **[`os/linux-workstation.nix`](file:///home/thomas/Documents/Repo/nix-configs/os/linux-workstation.nix) (Workstation Base - Linux)**:
    *   Graphical display manager config (i3 window manager, X11 utilities, udev rules).
    *   **Family/Machine Scope**: Graphical desktop applications shared by all accounts on the host (`firefox`, `vlc`, `libreoffice`, `gimp`, `audacity`, `naps2`, `pavucontrol`).
*   **[`os/darwin.nix`](file:///home/thomas/Documents/Repo/nix-configs/os/darwin.nix) (macOS Base)**:
    *   nix-darwin module configuration, homebrew casks (`stats`), shell defaults, and cocoa-keybindings.
*   **[`home-manager/`](file:///home/thomas/Documents/Repo/nix-configs/home-manager)**:
    *   Portable user workspace environment.
    *   `modules/cli.nix`: Development packages (Go, Nil lsp, custom Python/Ruby wrappers), interactive shell prompts (Zsh theme with command timers, autoenv, syntax-highlighting), and the wrapped Neovim package (pre-packaged with runtime requirements like `gcc` and `nodejs`).
    *   `modules/desktop.nix`: User-specific GUI programs (`keepassxc`, `rofimoji`), X11 cursor themes (`pointerCursor`), and declarative setups for Dunst, Picom, Kitty, Rofi, Redshift, and Polybar.
    *   `modules/user.nix`: Static home directory configs (ssh widgets, mime associations, desktop shortcuts, and custom `smount` mounting profiles).

---

## 2. Bootstrapping a New Install

### 🐧 NixOS

1.  Format the disks according to standard specifications:
    *   [NixOS Disk Installation Guide](https://nixos.org/manual/nixos/stable/#sec-installation)
    *   [LVM Configuration Wiki](https://nixos.wiki/wiki/LVM)
    *   [LUKS Encryption Guide](https://nixos.org/manual/nixos/stable/#sec-luks-file-systems)
2.  Mount the partitions (e.g. `/mnt`), then generate the configuration:
    ```bash
    nixos-generate-config --root /mnt
    ```
3.  Clone the repository, merge the generated hardware configuration to `hosts/`, and run:
    ```bash
    git clone https://github.com/lqp1/nix-configs
    nixos-install --flake .#thomas-x1gen9 --no-root-passwd
    nixos-enter --root /mnt -c "passwd thomas"
    ```

### 🍏 macOS (nix-darwin)

1.  Install Nix in single-user or multi-user mode.
2.  Clone this repository and run the darwin installer switch:
    ```bash
    nix run nix-darwin -- switch --flake .#darwin
    ```

---

## 3. Maintenance & Upgrades

### 🔄 Apply Changes

*   **Linux (NixOS)**:
    ```bash
    sudo nixos-rebuild switch --flake .
    ```
*   **macOS (nix-darwin)**:
    ```bash
    darwin-rebuild switch --flake .
    ```

### 🛡️ First-time Activation Backups
To prevent overwriting local personal data, Home Manager is configured to automatically rename conflicting pre-existing config files in your home directory (e.g., `.bashrc`, `.profile`) by appending a `.backup` extension.

### 🧪 Testing inside a VM (QEMU)
To compile the NixOS configuration and test the environment inside a graphical-free virtual machine:
```bash
nix run .#vmImage
```
To connect to the running VM via SSH (password: `admin`):
```bash
ssh 127.0.0.1 -o StrictHostKeyChecking=no -p 2222 -l admin
```

### 📦 Flake Maintenance
*   Format codebase:
    ```bash
    nix fmt .
    ```
*   Standard lock update:
    ```bash
    nix flake update --commit-lock-file
    ```
*   Update inputs with upstream diff review:
    ```bash
    scripts/lock-review update --commit-lock-file
    # Or update a single input:
    scripts/lock-review lock --update-input <input-name> --commit-lock-file
    ```
