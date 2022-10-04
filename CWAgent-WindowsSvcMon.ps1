Param
(
    [string]$Namespace = 'service-monitor',
    [array]$svclist = @("<ServiceName1>", "<ServiceName2>") # Replace with actual service names
)
Import-Module -Name AWSPowerShell
# Use the EC2 metadata service to get the host EC2 instance's ID
$instanceId = (New-Object System.Net.WebClient).DownloadString("http://169.254.169.254/latest/meta-data/instance-id")
# Associate current EC2 instance with your custom CloudWatch metric
$instanceDimension = New-Object -TypeName Amazon.CloudWatch.Model.Dimension;
$instanceDimension.Name = "instanceid";
$instanceDimension.Value = $instanceId;
$metrics = @();
$runningServices = Get-Service $svclist
# For each running service, add a metric to metrics collection that adds a data point to a CloudWatch Metric named 'Status' with dimensions: instanceid, servicename
$runningServices | % { 
    $dimensions = @();
    $serviceDimension = New-Object -TypeName Amazon.CloudWatch.Model.Dimension;
    $serviceDimension.Name = "service"
    $serviceDimension.Value = $_.Name;
    $dimensions += $instanceDimension;
    $dimensions += $serviceDimension;
    $metric = New-Object -TypeName Amazon.CloudWatch.Model.MetricDatum;
    $metric.Timestamp = [DateTime]::UtcNow;
    $metric.MetricName = 'Status';
    if ($_.Status -eq "Running") { $metric.Value = 1 } else { $metric.Value = 0}
    $metric.Dimensions = $dimensions;
    $metrics += $metric;
}
# Write all of the metrics for this run of the job at once, to save on costs for calling the CloudWatch API.
# This will fail if there are too many services in metrics collection; if this happens, just reduce the amount of
# services monitored
Write-CWMetricData -Namespace $Namespace -MetricData $metrics
