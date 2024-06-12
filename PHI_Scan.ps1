# Define network drives to search
$networkDrives = @("\\networkDrive1\path", "\\networkDrive2\path")

# Define file types to scan
$fileTypes = @("*.txt", "*.docx", "*.xlsx", "*.csv")

# Define PHI patterns (e.g., SSN, email, phone number)
$patterns = @(
    "\b\d{3}-\d{2}-\d{4}\b", # SSN
    "\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b", # Email
    "\b\d{3}-\d{3}-\d{4}\b" # Phone number
)

# Define the log file to store results
$logFile = "PHI_ScanResults.log"

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
