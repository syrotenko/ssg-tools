# Go through all subdirectories in the current directory and run git fetch in each one

# Get the current directory
$currentDir = Get-Location

# Get all subdirectories in the current directory
$subDirs = Get-ChildItem -Directory

# Create a collection to store job information
$jobs = @()

# Loop through each subdirectory and start a job to run git fetch
foreach ($dir in $subDirs) {
    $job = Start-Job -ScriptBlock {
        param($dirPath)
        Write-Output "Fetching in directory: $dirPath"
        Set-Location $dirPath

        # Git fetch outputs to stderr, which PowerShell treats as an error
        # redirect the stderr output of the git fetch command to stdout
        git fetch 2>&1
    } -ArgumentList $dir.FullName
    $jobs += $job
}

# Wait for all jobs to complete
$jobs | ForEach-Object { Receive-Job -Job $_ -Wait }
