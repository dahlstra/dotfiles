# Dotfiles (chezmoi)

Personal dotfiles managed by [chezmoi](https://www.chezmoi.io/). Cross-platform-friendly layout; currently Windows-only.

## Layout

| Source path | Deploys to | Notes |
| --- | --- | --- |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | `email` templated per machine. |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Verbatim. |
| `dot_config/powershell/profile.ps1.tmpl` | `~/.config/powershell/profile.ps1` | Real pwsh 7 `$PROFILE` is a one-line dot-source stub written by the bootstrap script. Edit this file for profile changes. |
| `AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json.tmpl` | Same under `~/AppData/...` | `backgroundImage` templated to `$HOME/Pictures/totoro.jpg`. |
| `Pictures/totoro.jpg` | `~/Pictures/totoro.jpg` | Windows Terminal (and future WezTerm) background image. |
| `dot_copilot/instructions/*` | `~/.copilot/instructions/*` | Copilot instruction files. |
| `dot_copilot/agents/*` | `~/.copilot/agents/*` | Copilot agent definitions. |
| `dot_copilot/symlink_skills.tmpl` | `~/.copilot/skills` (symlink) | Points at `~/.agents/skills`. |
| `dot_agents/skills/**` | `~/.agents/skills/**` | Master copy of skill dirs. |
| `run_once_bootstrap-pwsh-profile.ps1.tmpl` | (runs once) | Overwrites real pwsh 7 `$PROFILE` with a dot-source stub pointing at the chezmoi-managed profile. |
| `run_onchange_install-winget.ps1.tmpl` | (runs on change) | `winget import` of `.chezmoidata/winget_packages.json`. Re-runs when the package list changes. |
| `run_onchange_setup-adb-path.ps1.tmpl` | (runs on change) | Ensures `%LOCALAPPDATA%\Android\Sdk\platform-tools` is on the User PATH. Work machines only. |
| `run_onchange_install-fonts.ps1.tmpl` | (runs on change) | Installs "Hack Nerd Font Mono" (Regular/Bold/Italic/BoldItalic) per-user from `fonts/Hack.zip`. Re-runs when the zip changes. |
| `.chezmoidata/winget_packages.json` | (data) | Package list consumed by the winget script. |
| `fonts/Hack.zip` | (not deployed) | Font bundle consumed by the font script. Ignored via `.chezmoiignore`. |

## Install on a new machine

**Prerequisite (Windows):** enable Developer Mode so chezmoi can create the `~/.copilot/skills` symlink without elevation. Go to *Settings → System → For developers → Developer Mode → On*. Otherwise `chezmoi apply` must be run from an elevated shell.

```powershell
winget install twpayne.chezmoi
chezmoi init --apply <source>
```

Where `<source>` is one of:
- **OneDrive git bundle** (current backup mechanism — no remote yet): copy `dotfiles.bundle` from `<user OneDrive>/dotfiles-backup/`, then `chezmoi init --apply <path-to-bundle>`.
- **Git remote URL** (once one is set up): `chezmoi init --apply <url>`.

`chezmoi init` prompts for machine-specific values (`email`, `is_work`, `repos_dir`) via `.chezmoi.toml.tmpl` and writes them to `~/.config/chezmoi/chezmoi.toml`.

After `chezmoi apply`:
1. Open a new pwsh 7 shell — the profile should load automatically.
2. Open Windows Terminal — it should pick up the managed `settings.json` and use Hack Nerd Font Mono.

## Daily workflow

| Task | Command |
| --- | --- |
| Edit a managed file | `chezmoi edit <destination-path>` (e.g., `chezmoi edit ~/.gitconfig`) |
| Preview pending changes | `chezmoi diff` |
| Apply changes | `chezmoi apply` |
| Import a new file from the live location | `chezmoi add <path>` |
| Re-import a file that was edited in place | `chezmoi re-add <path>` |
| Jump to the source dir | `chezmoi cd` |
| Pull + apply upstream changes | `chezmoi update` |

## Backup

The source dir is a local git repo. A snapshot bundle is kept in OneDrive:

```powershell
chezmoi cd
git bundle create "$HOME/OneDrive - Lake Shore Cryotronics/dotfiles-backup/dotfiles.bundle" --all
```

To restore, see `RESTORE.md` next to the bundle.

## Escape hatch (if chezmoi ever gets in the way)

- `chezmoi archive --format tar` produces a fully-rendered tarball of every managed file — trivially convertible to plain dotfiles at their final paths.
- The source dir itself is a normal git repo of plain files with a small naming convention (`dot_` -> `.`, `symlink_` -> symlink, `run_once_` / `run_onchange_` -> scripts, `.tmpl` -> template). Convertible to a bare-repo-in-`$HOME` setup or plain copies with a short script.
