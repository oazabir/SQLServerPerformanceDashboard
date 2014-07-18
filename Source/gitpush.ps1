param (
    [string]$solution = ".\SQLServerDashboard.sln",
    [string]$zipname = "SQLServerDashboard.zip",
	[string]$compressor = "c:\Program Files\7-Zip\7z.exe",
	[string]$comment = "New version"
 )
 
# Clean up binary folder since we will be generating new binaries
rm ..\Binary\*.* -Force -Recurse
if (Test-Path "bin" ) { rm -Force bin }
if (Test-Path "obj" ) { rm -Force obj }

# build new version
msbuild /verbosity:minimal $solution
# Compress bin\debug and move to binary folder
cd bin\debug
del *vshost*
cmd /c $compressor a -tzip $zipname *.* 
cd ../..
cmd /c copy bin\debug\$zipname ..\Binary\ /Y

# remove bin and obj before comitting to git
rm -Force bin
rm -Force obj

cd ..
git add -A *.*
git commit -a -m $comment
git push origin master
