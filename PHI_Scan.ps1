# Define network drives to search
$networkDrives = @("\\hneit\homes\kmoker")

# Define file types to scan
$fileTypes = @("*.txt", "*.docx", "*.xlsx", "*.csv")

# Define PHI patterns (e.g., SSN, email, phone number)
$patterns = @(
    "\b\d{3}-\d{2}-\d{4}\b", # SSN
    "\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b", # Email
    "\b\d{3}-\d{3}-\d{4}\b" # Phone number
)

# Define the log file to store results with a specific path
$logFile = "C:\Temp\PHI_ScanResults.log"

# Ensure the log file directory exists
if (-not (Test-Path -Path (Split-Path -Path $logFile -Parent))) {
    New-Item -Path (Split-Path -Path $logFile -Parent) -ItemType Directory -Force
}

# Function to search for PHI in files
function Search-PHI {
    param (
        [string]$filePath,
        [array]$patterns
    )

    # Read file content
    $content = Get-Content -Path $filePath -ErrorAction SilentlyContinue -Raw
    if ($content) {
        foreach ($pattern in $patterns) {
            if ($content -match $pattern) {
                # Log the file path and matched pattern
                $matches = [regex]::Matches($content, $pattern)
                foreach ($match in $matches) {
                    Add-Content -Path $logFile -Value "$filePath - Matched Pattern: $pattern - Value: $($match.Value)"
                }
            }
        }
    }
}

# Scan network drives for PHI
foreach ($drive in $networkDrives) {
    foreach ($fileType in $fileTypes) {
        $files = Get-ChildItem -Path $drive -Filter $fileType -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            Search-PHI -filePath $file.FullName -patterns $patterns
        }
    }
}

# Ensure proper string termination
Write-Host "PHI scan completed. Results are logged in $logFile"

# Verify if the log file is created
if (Test-Path -Path $logFile) {
    Write-Host "Log file created successfully at $logFile"
} else {
    Write-Host "Failed to create log file at $logFile"
}

