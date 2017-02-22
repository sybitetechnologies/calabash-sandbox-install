1. Comment out the lines in `install-windows.ps1` which download and unzip the ruby and gem zips.
- Run `install-windows.ps1`, ignoring the error about `calabash-android` not being recognised.  This creates the sandbox folders and sets the PATH environment variable.
- Install the 32bit version of [Ruby 2.3.1](http://rubyinstaller.org/downloads/) with the default options.
- Create the folder `%USERPROFILE%\.calabash\sandbox\Rubies\ruby-2.3.1` and copy the contents of `C:\Ruby23` into it.
- Install the latest version of [Devkit](http://rubyinstaller.org/downloads/) that is for use with 32bit Ruby 2.0 and above into `c:\DevKit`.
- Start a new Command Prompt
- Run `calabash-sandbox`
- `cd` into `c:\DevKit`
- Run `ruby dk.rb init`
- Edit `c:\DevKit\config.yml` replacing `C:/Ruby23` with the folder that Ruby was copied into - something like `C:\Users\<your user>\.calabash\sandbox\Rubies\ruby-2.3.1`.
- Run `ruby dk.rb install`
- Download the latest rubygems from https://rubygems.org/pages/download
- Update rubygems following the instructions at http://guides.rubygems.org/ssl-certificate-update/#installing-using-update-packages
- Run `gem install bundler`
- Create a file named `Gemfile` in `%USERPROFILE%\.calabash\sandbox` with the contents:

        source 'https://rubygems.org'
        gem 'calabash-android', '>= 0.8.2', '< 1.0'
        gem 'xamarin-test-cloud', '>= 2.0.2', '< 3.0'
- `cd` into `%USERPROFILE%\.calabash\sandbox` and Run `bundle install`
- Edit `%USERPROFILE%\.calabash\sandbox\Gems\bin\*.bat` replacing `C:\Users\<your user>\.calabash\sandbox\Rubies\ruby-2.3.1\bin\ruby.exe` with `ruby.exe`.
- Zip `%USERPROFILE%\.calabash\sandbox\Rubies\ruby-2.3.1` into `ruby-2.3.1-win32.zip`
- Zip `%USERPROFILE%\.calabash\sandbox\Gems` into `CalabashGems-win32.zip`
- Upload both zip files to `https://s3-eu-west-1.amazonaws.com/calabash-files/calabash-sandbox/windows/` ensuring that you select `Make everything public`

 
