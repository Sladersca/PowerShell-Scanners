[CmdletBinding()]
param (
    # Number of System Stability Indexes to return (generated hourly)
    [Int]$Count = (24 * 7 * 4) #-Four week rolling window
)

# Gather $Count worth of ReliabilityStabilityMetrics
$StabilityMetrcs = Get-CimInstance -ClassName Win32_ReliabilityStabilityMetrics | Select-Object -First $Count

# Generate Min/Max/Average stability for our collected window.
$StabilityStats = $StabilityMetrcs | Measure-Object -Average -Maximum  -Minimum -Property systemStabilityIndex

# Get the most recent stability and when it was generated
$LastStabitiyMetric = $StabilityMetrcs | Select-Object -First 1 -Property systemStabilityIndex, TimeGenerated

# Output the collected data
[PSCustomObject]@{
    Minimum = [math]::Round($StabilityStats.Minimum)
    Average = [math]::Round($StabilityStats.Average, 2) #round to two decimal places for sanity
    Maximum = [math]::Round($StabilityStats.Maximum)
    Last = $LastStabitiyMetric.systemStabilityIndex
    LastDate = [DateTime]$LastStabitiyMetric.TimeGenerated
}