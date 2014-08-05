$source = 'SQLServerDashboard\'
$dest = '\\RDW09026APP01\SQLServerDashboard\'
$exclude = @('*.pdb','obj','web.config')
Get-ChildItem $source -Recurse -Exclude $exclude | Copy-Item -Destination {Join-Path $dest $_.FullName.Substring($source.length)}