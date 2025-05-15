# Go through all subdirectories in the current directory and run git fetch in each one

# Get the current directory
$currentDir = Get-Location

# Get all subdirectories in the current directory
$subDirs = Get-ChildItem -Directory

# Count the number of subdirectories
$totalDirs = $subDirs.Count
$currentDirIndex = 0

# Create a collection to store job information
$jobs = @()

# Loop through each subdirectory and start a job to run git fetch
foreach ($dir in $subDirs) {
    $currentDirIndex++
    $job = Start-Job -ScriptBlock {
        param($dirPath, $currentDirIndex, $totalDirs)
        $percentage = [math]::Round(($currentDirIndex / $totalDirs) * 100, 0)
        Write-Output "($percentage%) Fetching in directory $dirPath"
        Set-Location $dirPath

        # Git fetch outputs to stderr, which PowerShell treats as an error
        # redirect the stderr output of the git fetch command to stdout
        # Even when the output is redirected, PowerShell may still log those messages as errors
        try {
            $output = git fetch 2>&1
            # Write-Output $output
        } catch {
            # suppress for now
            # Write-Output "Error fetching in directory $dirPath: $_"
        }
    } -ArgumentList $dir.FullName, $currentDirIndex, $totalDirs
    $jobs += $job
}

# Wait for all jobs to complete
$jobs | ForEach-Object { Receive-Job -Job $_ -Wait }
