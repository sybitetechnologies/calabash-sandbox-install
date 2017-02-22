Add-Type -AssemblyName System.IO.Compression.FileSystem

function Rewrite-Path($path, $folders)
{
    $pathParts = New-Object System.Collections.Generic.List[string]
    $pathParts.AddRange($path.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries))

    # Remove any ruby bin folders from the path
    Foreach ($dir in $pathParts.ToArray())
    {
        if (Test-Path "$dir\ruby.exe")
        {
            $pathParts.Remove($dir) | Out-Null
        }
    }

    # Ensure each folder in $folders is part of the path
    Foreach ($folder in $folders)
    {
        if (!($pathParts.Contains($folder)))
        {
            $pathParts.Add($folder)
        }
    }
    
    return [string]::Join(";", $pathParts)
}

$ErrorActionPreference = "Stop"

$sandbox="${env:USERPROFILE}\.calabash\sandbox"
$calabashRubiesHome="${sandbox}\Rubies"
$calabashRubyVersion="ruby-2.3.1"
$calabashRubyPath="${calabashRubiesHome}\${calabashRubyVersion}\bin"
$calabashSandboxBin="${sandbox}\bin"
$calabashSandboxBat="${calabashSandboxBin}\calabash-sandbox.bat"

$env:GEM_HOME="${sandbox}\Gems"
$env:GEM_PATH="${env:GEM_HOME}"

#Don't auto-overwrite the sandbox if it already exists
if (Test-Path $sandbox)
{
    $title = "Overwrite Sandbox"
    $message = "Sandbox already exists! Do you want to overwrite? (any gems you've installed will be removed)"
	
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Replaces the $sandbox folder"

    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Exists this script."

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 1) 

    switch ($result)
    {
        1 {
            Write-Host ""            
            Write-Host "Not overwriting ${sandbox}, exiting..."
            exit 0 
        }
    }
}

if (Test-Path $env:GEM_HOME)
{
    Remove-Item $env:GEM_HOME -Force -Recurse 
}
New-Item $env:GEM_HOME -type directory | Out-Null

if (Test-Path $calabashRubiesHome)
{
    Remove-Item $calabashRubiesHome -Force -Recurse     
}
New-Item $calabashRubiesHome -type directory | Out-Null

if (!(Test-Path $calabashSandboxBin))
{
    New-Item $calabashSandboxBin -type directory | Out-Null
}

#Download Ruby
Write-Host "Preparing Ruby ${calabashRubyVersion}..."
$currentDirectory = (Resolve-Path .\).Path
$rubyDownloadFile = "$currentDirectory\${calabashRubyVersion}-win32.zip"
wget https://s3-eu-west-1.amazonaws.com/calabash-files/calabash-sandbox/windows/${calabashRubyVersion}-win32.zip -OutFile $rubyDownloadFile
[System.IO.Compression.ZipFile]::ExtractToDirectory($rubyDownloadFile, $calabashRubiesHome)
Remove-Item $rubyDownloadFile

#Download the gems and their dependencies
Write-Host "Installing gems, this may take a little while..."
$gemsDownloadFile = "$currentDirectory\CalabashGems-win32.zip"
wget https://s3-eu-west-1.amazonaws.com/calabash-files/calabash-sandbox/windows/CalabashGems-win32.zip -OutFile $gemsDownloadFile
[System.IO.Compression.ZipFile]::ExtractToDirectory($gemsDownloadFile, $sandbox)
Remove-Item $gemsDownloadFile

#Download the Sandbox Script
Write-Host "Preparing sandbox..."
wget https://raw.githubusercontent.com/calabash/install/master/calabash-sandbox.bat -OutFile $calabashSandboxBat

$folders = New-Object System.Collections.Generic.List[string]
$folders.Add($calabashSandboxBin)

$userPath = [Environment]::GetEnvironmentVariable("Path", "user");
if (!$userPath)
{
    $userPath = ""
}

$newUserPath = Rewrite-Path $userPath $folders
[Environment]::SetEnvironmentVariable("Path", $newUserPath, "user")

$folders = New-Object System.Collections.Generic.List[string]
$folders.Add($calabashRubyPath)
$folders.Add("${env:GEM_HOME}\bin")
$folders.Add($calabashSandboxBin)

$newProcessPath = Rewrite-Path $env:Path $folders
[Environment]::SetEnvironmentVariable("Path", $newProcessPath, "process")

$droidVersion = (calabash-android version) | Out-String
$testCloudVersion = (test-cloud version) | Out-String

Write-Host ""
Write-Host "Done! Installed:"
Write-Host "calabash-android:   $droidVersion"
Write-Host "xamarin-test-cloud: $testCloudVersion"
Write-host "Execute 'calabash-sandbox update' to check for gem updates."
Write-host "Execute 'calabash-sandbox' to get started!"
Write-Host ""
