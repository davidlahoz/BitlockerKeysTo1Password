# Define log folder and file
$logFolder = Join-Path -Path (Get-Location) -ChildPath "logs"
if (-Not (Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder
}
$logFile = Join-Path -Path $logFolder -ChildPath "$(Get-Date -Format 'ddMMyyyy').log"

# Function to log messages
function Log-Message {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $logEntry = "$timestamp [$Type] - $Message"
    Add-Content -Path $logFile -Value $logEntry
}

# Start logging
Log-Message "Script started."

# Invoke 1Password CLI login
$env:OP_SESSION = op signin --raw

# Ensure Microsoft Graph module is installed
if (-Not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Installing Microsoft Graph module..."
    Log-Message "Installing Microsoft Graph module..."
    Install-Module -Name Microsoft.Graph -Force -Scope CurrentUser
}

# Authenticate to Microsoft Graph
Write-Host "Connecting to MsGraph..."
Log-Message "Connecting to MsGraph..."
Connect-MgGraph -Scopes "Device.Read.All", "InformationProtectionPolicy.Read" -UseDeviceAuthentication -NoWelcome

# Function to get the Bitlocker recovery key
function Get-BitlockerRecoveryKey {
    param (
        [string]$RecoveryKeyId
    )
    try {
        $key = (Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId $RecoveryKeyId -Property key).key
        return $key
    }
    catch {
        Write-Host "Error fetching recovery key for ID $RecoveryKeyId" -ForegroundColor Red
        Log-Message "Error fetching recovery key for ID $RecoveryKeyId" "ERROR"
        return $null
    }
}

# Fetch and export Bitlocker recovery keys with selected properties
Write-Host "Fetching Bitlocker keys. Please wait..." -ForegroundColor Yellow
Log-Message "Fetching Bitlocker keys."
$bitlockerKeys = Get-MgInformationProtectionBitlockerRecoveryKey -All | Select-Object Id, @{
    Name       = "Key"
    Expression = { Get-BitlockerRecoveryKey -RecoveryKeyId $_.Id }
}

# Ensure there are keys to export
if ($bitlockerKeys -eq $null -or $bitlockerKeys.Count -eq 0) {
    Write-Host "No Bitlocker keys found. Exiting script." -ForegroundColor Red
    Log-Message "No Bitlocker keys found. Exiting script." "ERROR"
    exit
}

Clear-Host  # macOS compatible version of Clear

# Export to CSV
$csvPath = "bitlockerkeys.csv"
$bitlockerKeys | Export-Csv -NoTypeInformation -Path $csvPath

# Check if CSV file is created and not empty
if (-Not (Test-Path $csvPath) -or (Get-Item $csvPath).Length -eq 0) {
    Write-Host "CSV file creation failed or file is empty. Exiting script." -ForegroundColor Red
    Log-Message "CSV file creation failed or file is empty. Exiting script." "ERROR"
    exit
}

# Convert CSV to JSON with renamed properties
$jsonOutput = Import-Csv $csvPath | ForEach-Object {
    [PSCustomObject]@{
        title    = $_.Id
        password = $_.Key
    }
} | ConvertTo-Json

# Write JSON output to file
$jsonPath = "bitlockerkeys.json"
$jsonOutput | Set-Content -Path $jsonPath

# Check if JSON file is created and not empty
if (-Not (Test-Path $jsonPath) -or (Get-Item $jsonPath).Length -eq 0) {
    Write-Host "JSON file creation failed or file is empty. Exiting script." -ForegroundColor Red
    Log-Message "JSON file creation failed or file is empty. Exiting script." "ERROR"
    exit
}

# Remove CSV file
Remove-Item $csvPath

Write-Host "Bitlocker Keys fetched. Import to 1Password starting..." -ForegroundColor Yellow
Log-Message "Bitlocker Keys fetched. Import to 1Password starting..."

# Load the JSON data from the file
$jsonData = Get-Content -Path $jsonPath | ConvertFrom-Json

# Get the total number of items
$totalItems = $jsonData.Count
$currentIndex = 0

# Iterate over each item in the JSON array
foreach ($item in $jsonData) {
    $currentIndex++
    $title = $item.title
    $password = $item.password

    # Update progress bar
    Write-Progress -Activity "Processing Bitlocker Keys" -Status "Item $currentIndex of $totalItems. Please wait..." -PercentComplete (($currentIndex / $totalItems) * 100)

    # Construct the command with the current title and password
    $command = "op item get `"#BitlockerSample`" --format json | op item create --vault BitlockerKeys --title `"$title`" - 'password=$password'"

    # Run the command and redirect the output to $null
    try {
        Invoke-Expression $command | Out-Null
    }
    catch {
        Write-Host "Error processing item $title" -ForegroundColor Red
        Log-Message "Error processing item $title" "ERROR"
        Remove-Item $jsonPath
        Write-Host "Bitlocker keys imported were deleted for security reasons" -ForegroundColor Red
        Log-Message "Bitlocker keys imported were deleted for security reasons" "ERROR"
        Pause
    }
}

# Clear the progress bar when done
Write-Progress -Activity "Processing items" -Status "Complete" -Completed

# Inform user of success and cleanup task
Clear-Host
Write-Host "$totalItems Bitlocker keys imported successfully." -ForegroundColor Green
Log-Message "$totalItems Bitlocker keys imported successfully."
Write-Host "Deleting JSON file for security reasons." -ForegroundColor Red
Log-Message "Deleting JSON file for security reasons."

# Remove JSON file
Remove-Item $jsonPath
Write-Host "JSON file deleted. The script has finished." -ForegroundColor Green
Log-Message "JSON file deleted. The script has finished."
