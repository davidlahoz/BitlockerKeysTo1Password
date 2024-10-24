# BitLocker Key Export and Import Script

This PowerShell script automates the process of exporting BitLocker recovery keys from Microsoft Graph API, formatting them into JSON, and importing them into 1Password. The script also logs the execution process and ensures the security of data by cleaning up files after completion.

## Features
- Logs all script operations in a daily log file.
- Installs `winget` if not already installed.
- Ensures the Microsoft Graph PowerShell module is installed and authenticates using `Connect-MgGraph`.
- Fetches BitLocker recovery keys from Microsoft Graph.
- Exports recovery keys to both CSV and JSON formats.
- Imports the recovery keys into a 1Password vault.
- Cleans up sensitive files after the process is complete.

## Prerequisites
- [1Password CLI (`op`)](https://developer.1password.com/docs/cli/get-started/) must be installed and configured.
- Access to Microsoft Graph API with `Device.Read.All` and `InformationProtectionPolicy.Read` permissions.
- Microsoft Graph PowerShell module.
- `winget` (automatically installed if missing).
- Proper API permissions to fetch BitLocker keys.

- **1Password Item and Vault**:
   - The script requires a pre-existing item in 1Password with the name `#BitlockerSample`. This item is used as a template for creating new entries. Ensure this item exists before running the script.
   - The BitLocker keys will be imported into a vault named `BitlockerKeys` in 1Password. This vault will be automatically created.


## How It Works

1. **Logging**: 
   - A log folder is created (if it doesn't exist) and all log entries are written to a daily log file.

2. **Environment Setup**:
   - The script checks if `winget` is installed and installs it if missing.
   - It ensures the Microsoft Graph module is installed and authenticated with the necessary permissions.

3. **Fetching BitLocker Recovery Keys**:
   - The script retrieves BitLocker keys from Microsoft Graph API and exports them to a CSV file.
   - The CSV is converted into a JSON format with properties renamed for import into 1Password.

4. **Importing into 1Password**:
   - Each BitLocker key is imported into a 1Password vault, with a progress bar showing the import status.

5. **Cleanup**:
   - After successful import, the CSV and JSON files are deleted for security reasons.

## Script Execution

1. Clone this repository and open the PowerShell script.
2. Run the script:
   ```powershell
   .\BitlockerTo1Password.ps1
