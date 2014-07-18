param (
    [string]$solution = ".\SQLServerDashboard.sln",
    [string]$zipname = "SQLServerDashboard.zip",
	[string]$compressor = "c:\Program Files\7-Zip\7z.exe",
	[string]$comment = "New version"
 )
 
# Clean up binary folder since we will be generating new binaries
rm ..\Binary\*.* -Force -Recurse

# build new version
msbuild /verbosity:minimal $solution
# Compress bin\debug and move to binary folder
cmd /c $compressor a -tzip $zipname *.* 
cmd /c copy $zipname ..\Binary\ /Y

cd ..
git add -A *.*
git commit -a -m $comment
git push origin master
