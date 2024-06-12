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

# Debugging: Print the value of $logFile
Write-Host "Log file path: $logFile"

# Ensure the log file directory exists
$logFileDirectory = Split-Path -Path $logFile -Parent

# Debugging: Print the value of $logFileDirectory
Write-Host "Log file directory: $logFileDirectory"

if (-not (Test-Path -Path $logFileDirectory)) {
    try {
        New-Item -Path $logFileDirectory -ItemType Directory -Force -ErrorAction Stop
        Write-Host "Created directory for log file: $logFileDirectory"
    } catch {
        Write-Host "Failed to create directory for log file: ${_}"
        exit
    }
}

# Create the log file
try {
    Add-Content -Path $logFile -Value "PHI Scan Log File Initialization" -ErrorAction Stop
    Write-Host "Log file created successfully at $logFile"
} catch {
    Write-Host "Failed to create log file at $logFile: ${_}"
    exit
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
