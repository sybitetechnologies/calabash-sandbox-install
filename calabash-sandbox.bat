@echo off

setlocal EnableDelayedExpansion

set SCRIPT_VERSION=0.1.2

if "%1" == "version" (
  echo.
  echo Calabash sandbox version: %SCRIPT_VERSION%
  GOTO:EOF
)
set powershellCommand=null
set powershellUpdateCommand=null
for /f "delims=" %%i in ('echo %CMDCMDLINE% ^| findstr "calabash-sandbox.bat"') do set powershellCommand=%%i
for /f "delims=" %%i in ('echo %CMDCMDLINE% ^| findstr " update"') do set powershellUpdateCommand=%%i
set powershellCommand=%powershellCommand:~0,4%
set powershellUpdateCommand=%powershellUpdateCommand:~0,4%

set CALABASH_SANDBOX=%USERPROFILE%\.calabash\sandbox
set CALABASH_RUBY_VERSION=ruby-2.3.1
set CALABASH_RUBY_PATH=%CALABASH_SANDBOX%\Rubies\%CALABASH_RUBY_VERSION%\bin
set CALABASH_GEM_HOME=%CALABASH_SANDBOX%\Gems

set GEM_HOME=%CALABASH_GEM_HOME%
set GEM_PATH=%CALABASH_GEM_HOME%

for %%a in ("%PATH:;=" "%") do (
  set directory=%%a
  set replacedDirectory=!directory:\ruby=!
  if !replacedDirectory!==!directory! (
    if [!CALABASH_SANDBOX_PATH!] == [] (
       set CALABASH_SANDBOX_PATH=%%~a
    ) else (
      set CALABASH_SANDBOX_PATH=!CALABASH_SANDBOX_PATH!;%%~a
    )
  )
)

if "%1" == "update" (
  echo.
  echo Updating gems...
    
  set CurrentDirectory=%cd%
  cd "%CALABASH_SANDBOX%" > nul
  
  set GemfileExists=0
  if exist Gemfile (
    set GemfileExists=1
    for /f "delims=" %%i in ('"forfiles /m Gemfile /c "cmd /c echo @fdate @ftime" "') do set OriginalGemfileDate=%%i	
  )
  
  bitsadmin.exe /transfer DownloadingGemfile https://raw.githubusercontent.com/calabash/install/master/Gemfile.Windows "!CALABASH_SANDBOX!\Gemfile" > nul
    
  if !GemfileExists!==0 (
    if not exist Gemfile (
      echo.
      echo Unable to download newest Gemfile, please try again.
      cd "%CurrentDirectory%" > nul
      GOTO:EOF
    )
  ) else (
    for /f "delims=" %%i in ('"forfiles /m Gemfile /c "cmd /c echo @fdate @ftime" "') do set CurrentGemfileDate=%%i	
    if "!OriginalGemfileDate!" == "!CurrentGemfileDate!" (
      echo Unable to download newest Gemfile, please try again.
	  cd "%CurrentDirectory%" > nul
      GOTO:EOF
    )
  )
  
  cmd /C "calabash-sandbox > nul && bundle update > nul 2>&1"
  for /f "delims=" %%i in ('cmd /C "calabash-sandbox > nul && calabash-android version 2>&1" ') do set AndroidVersion=%%i
  for /f "delims=" %%i in ('cmd /C "calabash-sandbox > nul && test-cloud version 2>&1" ') do set TestCloudVersion=%%i
  
  echo.
  echo Done^^! Now the sandbox contains:
  
  echo calabash-android:   !AndroidVersion!
  echo xamarin-test-cloud: !TestCloudVersion! 
  echo.
  
  cd "%CurrentDirectory%" > nul
  GOTO:EOF
)

title Calabash Sandbox
if "%powershellCommand%"=="null" (
  color 0b
)
cls

echo.
echo Calabash sandbox version: %SCRIPT_VERSION%
echo.

endlocal & (
  set "PATH=%CALABASH_RUBY_PATH%;%GEM_HOME%\bin;%CALABASH_SANDBOX_PATH%"
  set GEM_HOME=%GEM_HOME%
  set GEM_PATH=%GEM_PATH%
    
  set PROMPT=[calabash] $p$g
  
  if not "%powershellCommand%"=="null" (
    if "%powershellUpdateCommand%"=="null" (
      cmd /k echo type 'exit' to return to powershell when done	
	)
  )
)



