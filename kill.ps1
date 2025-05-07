# Run the taskkill command with the provided PID

param (
    [int]$args[0]
)

taskkill /pid $args[0] /f
 