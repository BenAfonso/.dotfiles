## Install

```sh
git clone https://github.com/BenAfonso/.dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## Private files

Sensitive files live outside normal tracked configs in `~/.dotfiles/private/`.

- `private/` is ignored by git via `.gitignore`.
- `scripts/encrypt-privates.sh` archives `~/.dotfiles/private/` and writes encrypted output to `configs/private.tar.gz.age` using `age`.
- `scripts/install-privates.sh` gets the age key from KeePassXC, decrypts `configs/private.tar.gz.age`, extracts it back into `~/.dotfiles/private/`, then links `~/.password-store` to `private/password-store/`.
- Configs that need secrets should symlink into `private/`, e.g. `configs/pi/agent/auth.json -> ../../../private/pi/agent/auth.json`.

### Update encrypted private archive

After changing files under `private/`:

```sh
./scripts/encrypt-privates.sh
```

Then commit the changed encrypted archive, not the plaintext `private/` directory.

### Restore private files

During install this runs automatically via `install.sh`:

```sh
./scripts/install-privates.sh
```

Requires KeePassXC entry `Age key - Pass and config` in `~/.keepass/keepass-noha.kdbx`, with `raw` private key and `public` recipient fields.
