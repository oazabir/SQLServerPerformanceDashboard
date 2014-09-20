param (
    [string]$solution = ".\SQLServerDashboard.sln",
    [string]$zipname = "SQLServerDashboard.zip",
	[string]$compressor = "c:\Program Files\7-Zip\7z.exe",
	[string]$folder = "SQLServerDashboard",
	[string]$deployPath = "..\Binary",
	[string]$commitFrom = "..",
	[Parameter(Mandatory=$true)][string]$comment
 )

 # If visual studio has the solution open, close VS, as we can't delete obj folder while it is open
$windowTitle = $solution.Replace(".sln", "")
$vsProcess = get-process | where {$_.mainwindowtitle -match $windowTitle -and $_.ProcessName -eq "devenv"} 
if ($vsProcess.Length -gt 0) {
	Write-Host "Visual Studio has this solution open. Closing..."
	$vsProcess | ForEach-Object { $_.CloseMainWindow(); }
	Sleep 5
	Read-Host "Press ENTER to proceed if Visual Studio is closed"
	$vsProcess = get-process | where {$_.mainwindowtitle -match $windowTitle -and $_.ProcessName -eq "devenv"} 
	if ($vsProcess.Length -gt 0) {
		Write-Host "Visual Studio still has the solution open. Aborting."
		Return
	}
}
 
Push-Location
 

if (Test-Path $zipname) { rm $zipname; }

# Clean up deploy folder 
rm $deployPath\*.* -Force -Recurse

# Build new version
msbuild /verbosity:minimal $solution

# Delete obj
if (Test-Path $folder\obj) { rm $folder\obj -Force -Recurse }

# backup the web.config and remove sensitive entries before pushing to git, eg connectionString
[string]$filename = gi $folder\web.config 
[string]$backup = [System.IO.File]::ReadAllText($filename)
$xml = [xml]$backup
$xml.PreserveWhitespace = $true
foreach($n in $xml.configuration.connectionStrings.add) 
{ 
	$n.connectionString = "" 
}  

# Anonymize any sensitive appSettings entry
foreach($n in $xml.configuration.appSettings.add)
{
  switch($n.key)
  {
	"Password" { $n.value = "Password" }	
  } 
}

# Remove authorization blocks
$xml.configuration.'system.web'.authorization.RemoveAll()

$xml.Save($filename)



# build new version
msbuild /verbosity:minimal $solution
# Compress bin\debug and move to binary folder
cmd /c $compressor a -tzip $zipname $folder -r 
cmd /c copy $zipname ..\Binary\ /Y

cd ..
git pull
git add -A *.*
git commit -a -m $comment
git push origin master
Pop-Location

# Restore web.config
[System.IO.File]::WriteAllText($filename, $backup)