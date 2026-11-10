# DANISH ARMY ROOT SUITE

**Root-only Android / Termux package**

A Termux Bash utility for managing files directly inside `/data/local/tmp`.

## Termux install command

Run these commands in Termux:

```bash
pkg update -y && pkg install git curl -y
git clone https://github.com/freefire6872349325-bit/DANISH-ARMY-ROOT-SUITE.git
cd DANISH-ARMY-ROOT-SUITE
bash install.sh
```

Launch:

```bash
danish
```

## Update

From inside the cloned project folder:

```bash
bash update.sh
```

## Uninstall

From inside the cloned project folder:

```bash
bash uninstall.sh
```

This removes only the installed `danish` command. It does not delete `/data/local/tmp/danish.sh` or any other TMP files.

## Repository structure

```text
DANISH-ARMY-ROOT-SUITE/
├── danish-army-manager.sh
├── install.sh
├── update.sh
├── uninstall.sh
├── README.md
├── CHANGELOG.md
├── VERSION
└── LICENSE
```

## GitHub Release package

Upload the ZIP package as an asset under GitHub **Releases**. Keep the source files above in the repository's root (main branch), so the updater can fetch `danish-army-manager.sh`.

Suggested release:
- Tag: `v1.0.0`
- Title: `DANISH ARMY ROOT SUITE v1.0.0`
- Asset: `DANISH-ARMY-ROOT-SUITE-v1.0.0.zip`

## Requirements

- Android phone with working root access (`su`)
- Termux
- `git` for cloning
- `curl` for the panel download feature and updater

## Safety

- Root access is required; non-root devices are not supported.
- Executing a selected shell script runs it with root privileges. Review scripts before running them.
- Permission `777` is broad and risky; use it only when you understand the consequences.
- The WhatsApp channel prompt is self-confirmation and does not verify membership.
- The panel script is downloaded from a separate URL. Inspect and trust its source before executing it.
- This package is assembled from the supplied manager code and has not been tested on the user's device.
