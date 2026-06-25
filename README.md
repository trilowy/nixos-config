# NixOS

## Installation

Pour l’installer sur un système existant :

```sh
cd /etc
sudo mv nixos nixos_backup
cd ~
git clone git@github.com:trilowy/nixos-config.git
sudo mv nixos /etc/nixos
sudo cp nixos_backup/hardware-configuration.nix /etc/nixos
```

Ou depuis le liveUSB :
- Avec GParted :
  - Créer une partition de 1024 Mo nommée `EFI` en fat32
  - Créer une partition du restant nommée `root` avec le label `root` en ext4
  - Valider
  - Ajouter sur la partition `EFI` les flags `boot` et `esp`
- Dans un terminal :
  - Monter la partition `root` sur `/mnt` :
    ```sh
    sudo mount /dev/nvme0n1p2 /mnt
    ```
  - Monter la partition `EFI` sur `/mnt/boot` :
    ```sh
    sudo mount --mkdir /dev/nvme0n1p1 /mnt/boot
    ```
  - Reprendre leurs ID et les changer dans la conf `valora-hardware-configuration.nix` :
    ```sh
    lsblk -f
    ```
  - Installer :
    ```sh
    sudo nixos-install --flake github:trilowy/nixos-config#valora
    ```

## Autres

Pour mettre à jour :

```sh
sudo nixos-rebuild switch --flake .#valora
```

Pour mettre à jour sans tout casser (changement de Desktop Environment par exemple) :

```sh
sudo nixos-rebuild boot --flake .#valora
```
Et reboot.

Pour update les packages :

```sh
nix flake update
```

Pour réinstaller le bootloader :

```sh
sudo nixos-rebuild switch --flake .#valora --install-bootloader
```

Pour savoir quelle version de NixOS :

```sh
nixos-version
nix --version
```

Si on change de DE ça peut être important de reset les conf (attention ça vire le clavier Ergo‑L) :

```sh
dconf reset -f /
```

Retour arrière sur ancienne version :

```sh
nixos-rebuild switch --rollback
```

Liste des générations NixOS disponibles :

```sh
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
```

Clean pour faire de la place sur le disque :

```sh
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 1
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3
nix-collect-garbage
```

Lancer juste un programme en version unstable :

```sh
nix run github:NixOS/nixpkgs/nixpkgs-unstable#neovim
```
