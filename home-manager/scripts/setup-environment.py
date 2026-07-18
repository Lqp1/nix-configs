#!/usr/bin/env python3
import argparse
import os
import subprocess
import shutil
import sys
import xml.etree.ElementTree as ET

def log(module, msg):
    print(f"[{module}] {msg}", file=sys.stderr)

def main():
    parser = argparse.ArgumentParser(description="Bootstrap user environment")
    parser.add_argument("--git-bin", default="git", help="Path to the git binary")
    args = parser.parse_args()

    git_bin = args.git_bin
    home = os.path.expanduser("~")

    print("\n=== Commencing Environment Setup ===", file=sys.stderr)

    # 1. Create smount directories
    shares = ["shares/home", "shares/share", "shares/vault"]
    for share in shares:
        path = os.path.join(home, share)
        if not os.path.exists(path):
            os.makedirs(path)
            log("smount", f"Created directory: {path}")
        else:
            log("smount", f"Directory already exists: {path}")

    # 2. Ensure Repo directory exists
    repo_dir = os.path.join(home, "Documents/Repo")
    if not os.path.exists(repo_dir):
        os.makedirs(repo_dir)
        log("repos", f"Created Repo root directory: {repo_dir}")
    else:
        log("repos", f"Repo root directory already exists: {repo_dir}")

    # 3. Clone repositories
    repos = [
        ("spectre-meltdown-checker", "https://github.com/speed47/spectre-meltdown-checker"),
        ("kconfig-hardened-check", "https://github.com/a13xp0p0v/kconfig-hardened-check"),
        ("lazyvim-config", "git@github.com:Lqp1/lazyvim-config.git")
    ]

    for name, url in repos:
        dest = os.path.join(repo_dir, name)
        if not os.path.exists(dest):
            log("repos", f"Cloning {name} from {url}...")
            try:
                subprocess.run([git_bin, "clone", url, dest], check=True)
                log("repos", f"Successfully cloned {name}")
            except subprocess.CalledProcessError as e:
                log("repos", f"Failed to clone {name}: {e}")
        else:
            log("repos", f"Repository {name} already exists at {dest}")

    # 4. Neovim symlink
    nvim_config = os.path.join(home, ".config/nvim")
    lazyvim_target = os.path.join(repo_dir, "lazyvim-config")
    
    if os.path.exists(nvim_config) or os.path.islink(nvim_config):
        # Check where it points if it's a symlink
        if os.path.islink(nvim_config):
            target = os.readlink(nvim_config)
            log("neovim", f"Symlink already exists pointing to {target}")
        else:
            log("neovim", f"Directory or file already exists at {nvim_config} (skipping symlink creation)")
    else:
        os.makedirs(os.path.dirname(nvim_config), exist_ok=True)
        os.symlink(lazyvim_target, nvim_config)
        log("neovim", f"Created symlink: {nvim_config} -> {lazyvim_target}")

    # 5. Patch VeraCrypt Configuration
    vc_file = os.path.join(home, ".config/VeraCrypt/Configuration.xml")
    if os.path.exists(vc_file) and os.path.getsize(vc_file) > 0:
        log("veracrypt", f"VeraCrypt configuration found at {vc_file}. Patching options...")
        try:
            tree = ET.parse(vc_file)
            root = tree.getroot()
            conf = root.find("configuration")
            if conf is None:
                conf = ET.SubElement(root, "configuration")

            modified = False

            def set_key(key, val):
                nonlocal modified
                for c in conf.findall("config"):
                    if c.get("key") == key:
                        if c.text != val:
                            c.text = val
                            modified = True
                            log("veracrypt", f"- Updated {key} to {val}")
                        return
                new_c = ET.SubElement(conf, "config", key=key)
                new_c.text = val
                modified = True
                log("veracrypt", f"- Set new key {key} to {val}")

            set_key("MountVolumesReadOnly", "1")
            set_key("FilesystemOptions", "iocharset=utf8")

            if modified:
                if hasattr(ET, "indent"):
                    ET.indent(tree, space="\t", level=0)
                tree.write(vc_file, encoding="utf-8", xml_declaration=True)
                log("veracrypt", "VeraCrypt configuration successfully updated.")
            else:
                log("veracrypt", "VeraCrypt configuration is already up-to-date.")
        except Exception as e:
            log("veracrypt", f"Failed to patch VeraCrypt configuration: {e}")
    else:
        log("veracrypt", "VeraCrypt configuration not found (skipping).")

    print("=== Environment Setup Complete ===\n", file=sys.stderr)

if __name__ == "__main__":
    main()
