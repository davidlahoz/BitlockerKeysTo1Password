# Bitlocker Recovery Keys to 1Password

This repository contains two PowerShell scripts to fetch Bitlocker recovery keys from Microsoft Graph and import them into 1Password. The scripts are designed for both **Windows** and **macOS**.

## Important note
The script has been tested on a device using the desktop client and is not intended to be executed unattended. To simplify login to 1Password, enable the 1Password CLI integration.
Thereof make sure you have 1Password CLI integration enabled
![1Password settings](Readme-Files/1PasswordCLIInt.png)


However it migth work if you login via Terminal beforehand, but it has not been tested.
```sh
 op account add --address <yourcompany>.1password.eu/com --email <your.email@domain.com> \
  --secret-key <xxxxxxxxxxx> --signin
  ```



## Scripts
- **WIN_BitlockerTo1Password.ps1** → Windows version
- **OSX_BitlockerTo1Password.ps1** → macOS version

## Requirements
### Windows
- **PowerShell 7+** (Required for compatibility with modern modules)
- **Microsoft Graph PowerShell Module**
  ```powershell
  Install-Module -Name Microsoft.Graph -Force -Scope CurrentUser
  ```
- **1Password CLI (op)**
  - Download and install: [1Password CLI](https://developer.1password.com/docs/cli/get-started/)
- **Bitlocker Recovery Key Permissions**
  - The script requires `Device.Read.All` and `InformationProtectionPolicy.Read` permissions in Microsoft Graph.

### macOS
- **PowerShell (pwsh) 7+**
  - Install via Homebrew:
    ```sh
    brew install --cask powershell
    ```
- **Microsoft Graph PowerShell Module**
  ```powershell
  Install-Module -Name Microsoft.Graph -Force -Scope CurrentUser
  ```
- **1Password CLI (op)**
  - Download and install: [1Password CLI](https://developer.1password.com/docs/cli/get-started/)
- **Bitlocker Recovery Key Permissions**
  - The script requires `Device.Read.All` and `InformationProtectionPolicy.Read` permissions in Microsoft Graph.

## Usage
### Windows
1. Open PowerShell as Administrator.
2. Run the script:
   ```powershell
   ./WIN_BitlockerTo1Password.ps1
   ```

### macOS
1. Open a terminal and launch PowerShell:
   ```sh
   pwsh
   ```
2. Navigate to the script directory.
3. Run the script:
   ```powershell
   ./OSX_BitlockerTo1Password.ps1
   ```

## What the Script Does
1. **Authenticates to Microsoft Graph** to fetch Bitlocker recovery keys.
2. **Exports keys to a CSV file**.
3. **Converts the CSV to JSON** format.
4. **Imports the keys into 1Password** under a specified vault.
5. **Removes the temporary files** (CSV and JSON) for security reasons.

## Troubleshooting
- **Authentication Issues:** Ensure you have the correct Microsoft Graph permissions assigned.
- **1Password CLI Errors:** Verify that `op` is installed and correctly configured.
- **Permission Denied Errors:** Run the script with appropriate privileges (`Administrator` on Windows, correct permissions on macOS).

Technically, if you use the CLI command to log in, it should work, but this has not been tested.

## Security Notice
The script handles sensitive data (Bitlocker keys). Ensure that:
- You **run the script in a secure environment**.
- The temporary files (`bitlockerkeys.csv` and `bitlockerkeys.json`) are **not manually stored** after execution.

## License
This script is provided under the [MIT License](LICENSE). Use at your own risk.