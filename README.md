# chocolatey-packages

[![GitHub Actions Status](https://github.com/mu88/chocolatey-packages/actions/workflows/pack_push.yml/badge.svg)](https://github.com/mu88/chocolatey-packages/actions/workflows/pack_push.yml)
![License](https://img.shields.io/badge/license-DNHML-blue)

A collection of Chocolatey packages for various tools and applications, maintained with automated version updates.

## Motivation

This repository was created to manage my personal collection of Chocolatey packages, including both manually maintained and automatically updated packages using Renovate.

## Packages

### Automatically Updated (`_auto`)

Packages in the `_auto` folder utilize Renovate to automatically check for updates and create pull requests when new versions are available.

| Package | Version | Description |
|---------|---------|-------------|
| **foldersync-desktop** | [![Chocolatey Version](https://img.shields.io/badge/Chocolatey-2.8.5-green)](https://chocolatey.org/packages/foldersync-desktop) | Desktop file synchronization tool |
| **github-copilot-cli** | [![Chocolatey Version](https://img.shields.io/badge/Chocolatey-1.0.32-green)](https://chocolatey.org/packages/github-copilot-cli) | GitHub Copilot command-line interface |
| **px-proxy** | [![Chocolatey Version](https://img.shields.io/badge/Chocolatey-0.10.3-green)](https://chocolatey.org/packages/px-proxy) | Proxy tool for Windows environments |
| **token2-companion** | [![Chocolatey Version](https://img.shields.io/badge/Chocolatey-2.0.2.6-green)](https://chocolatey.org/packages/token2-companion) | Companion application for Token2 |

Each package contains:
- `.nuspec` – Package metadata and manifest
- `update.ps1` – Renovation/update script
- `tools/` – Application installation and uninstallation scripts

## Local Development

### Prerequisites

- [Chocolatey](https://chocolatey.org/install) installed on your system
- PowerShell knowledge for script maintenance

### Directory Structure

```
.
├── renovate.json5            # Renovate configuration
└── _auto/                    # Automatically updated packages
    ├── <package-name>/
    │   ├── <package>.nuspec
    │   ├── update.ps1
    │   └── tools/
    │       ├── chocolateyInstall.ps1
    │       └── chocolateyUninstall.ps1
```

### Working with Packages

1. **Creating a new package:** Add a new folder in `_auto` with the package name
2. **Package metadata:** Define in the `.nuspec` file (version, dependencies, metadata)
3. **Installation:** Implement in `tools/chocolateyInstall.ps1`
4. **Uninstallation:** Implement in `tools/chocolateyUninstall.ps1`
5. **Updates:** Add an `update.ps1` script for Renovate to detect new versions

### Testing Locally

```powershell
# Test installation
choco install -s . <package-name>

# Test uninstallation
choco uninstall <package-name>
```

## Deployment

Packages can be published to:

- **Private/Local feeds:** Host packages for internal use
- **Chocolatey Community Feed:** Public distribution (requires approval)
- **Custom repository:** Self-hosted NuGet server

Refer to the [Chocolatey documentation](https://docs.chocolatey.org/en-us/create/create-packages) for publishing details.

## Renovate Configuration

This repository uses [Renovate](https://www.whitesourcesoftware.com/free-developer-tools/renovate/) to automate dependency updates. Configuration is defined in `renovate.json5`.

Renovate will:
- Monitor package versions
- Create pull requests for updates
- Support custom update rules per package

## License

Do No Harm License (DNHML)

---

For questions or contributions, please open an issue or pull request.
