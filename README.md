# NixOS

## Initialisation

Pour ne pas devoir `sudo` à chaque modification :

```sh
cd /etc/nixos/
sudo mv configuration.nix configuration.nix.backup
sudo ln /home/trilowy/workspace/nixos-config/configuration.nix .
```
