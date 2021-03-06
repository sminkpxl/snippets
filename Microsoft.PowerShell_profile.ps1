#
# Note: prereqs: 
#       1. some kind of linux installed (debian, ubuntu, etc.)
#       2. fortune installed in that linux
#       3. script vcal.sh from <location>
#
# some came from here: https://stackoverflow.com/questions/4166370/how-can-i-write-a-powershell-alias-with-arguments-in-the-middle
# some came from here: https://devops-collective-inc.gitbook.io/a-unix-person-s-guide-to-powershell/commands-detail-u
# prompt came from here: https://blogs.msmvps.com/richardsiddaway/2013/07/21/fun-with-prompts/

# follow up on me:
#    https://docs.microsoft.com/en-us/sysinternals/downloads/desktops
#    https://docs.microsoft.com/en-us/sysinternals/downloads/ctrl2cap
#    https://docs.microsoft.com/en-us/sysinternals/downloads/strings
#    https://docs.microsoft.com/en-us/sysinternals/downloads/debugview
#    https://docs.microsoft.com/en-us/sysinternals/downloads/autoruns
#    https://docs.microsoft.com/en-us/sysinternals/downloads/tcpview
#    https://docs.microsoft.com/en-us/sysinternals/downloads/diskmon

# this has to be useful somehow:
#    Invoke-RestMethod -Uri http://numbersapi.com/37 -UseBasicParsing
#    [Environment]::GetFolderPath('Desktop') ref: https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/finding-system-paths
#    get public IP: Invoke-RestMethod -Uri 'ipinfo.io/json'
#    netsh wlan show profile name="*" key=clear | Where-Object { $_ -match "SSID name\s*:\s(.*)$"} | ForEach-Object { $matches[1].Replace('"','') } `
#    ref: https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/understanding-rest-web-services-in-powershell
#    ref: https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/dumping-wi-fi-passwords
#    netstat -an | find `"443`" -> works - escape " with `

# actual windows mvp powershell profile - check it out: https://gist.github.com/potatoqualitee/cf3ee4146991da80a8e38feeadb47473

# this to: Get-Alias a* will show all aliases starting with an 'a'
# kill is already aliased to stop-process

# remove "bad" aliases - only force it when needed
remove-item -path alias:ls
remove-item -path alias:pwd
remove-item -path alias:gl -Force

# create some vars
$myprofversion = '1.20'
$myCurrentDirectory = $HOME
$env:myXargs = $true

# update system vars
$MaximumHistoryCount = 1000

# Get rid of the ps7 promotion - open powershell with -nologo for cleanest experience
Clear-Host
bash -c "fortune"

# git related
function gs { git status $args }
function gd { git diff $args }
function gsm { git ls-files -m . }
function gcp { git cherry-pick $args }
function gco { git checkout $args }
function gs { git status $args }
function gsu { git status -uno $args }
function glf { git log --name-status --oneline $args }
function gsi { echo 'git submodule init'; git submodule init }
function gup { echo 'git fetch --all'; git fetch --all; echo 'git pull'; git pull }
function gsur { echo 'git submodule update --recursive'; git submodule update --recursive }
function dirty { git describe --tag --long --dirty --always }
function app { git commit -m "update submodule application" application }
function lib { git commit -m "update submodule library" library }
function swi { git commit -m "update submodule swi" swi }
function gl { git config --list }
function gss { git submodule status }
function modck { git log -1; git log -1 origin/main } # nice to be able to overide what the remote looks like e.g. if a param is provided, use it otherwise use origin/main
function gbr { git branch --show-current }
function lc { python.exe C:\_me\scripts\list-commits.py $args }

# Compute file hashes - useful for checking successful downloads 
function md5    { Get-FileHash -Algorithm MD5 $args }
function sha1   { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }
function xon { $env:myXargs = $true }  # TODO: figure out why these aren't working
function xoff { $env:myXargs = $false }
function env { dir env: }

# Simple function to start a new elevated process. If arguments are supplied then 
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin
{
    if ($args.Count -gt 0)
    {   
       $argList = "& '" + $args + "'"
       Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList
    }
    else
    {
       Start-Process "$psHome\powershell.exe" -Verb runAs
    }
}
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin
Set-Alias -Name g -Value findstr # think of a better way of doing this

# functions
function runcmd { cmd /c $args }
function runbash { bash -c $args }
function fortune { bash -c fortune }
function vcal { bash -c "/home/smink/.bin/vcal.sh $args" }
Set-Alias -Name vc -Value vcal
# TODO: something is up when these 3 are on the right side of a pipe as opposed to either the beginning or without a pipe
#function v { gvim.exe $args }
#function vi { gvim.exe $args }
#function gvim { gvim.exe $args }
function gvimdiff { gvim.exe -d $args } 
function . { echo 'I really want to get IP/GPS information here' } # this does not work
function .. { cd .. }
function ls { $a = $args -replace '\\','/'; bash -c "ls $a" } #function ls { bash -c "ls $args" }
function wc { bash -c "wc $args" }
function wcl { $input | Measure-Object -line | select-object -ExpandProperty Lines }
function version { echo $myprofversion; get-wmiobject -class win32_operatingsystem | select caption } 
function psversion { echo(Get-Host).Version } 
function calc { bash -c "echo $args" }
# all of these need to support a position dependent argument '-d' to force omitting things that contain 'Debug/'
function fh { bash -c "find * -type f | xargs -d '\n' grep -HI $args" }
function fhi { bash -c "find * -type f | xargs -d '\n' grep -HIi $args" }
function fhl 
{ 
    # TODO: probably can do this inline instead of using a temp var
    $myxargs = (Get-item -path env:myXargs).value
    if ($myxargs -eq 'True')
    {
        bash -c "find * -type f | xargs -d '\n' grep -HIl $args | xargs" 
    }
    else
    {
        bash -c "find * -type f | xargs -d '\n' grep -HIl $args" 
    }
}  
function fhil 
{
    $myxargs = (Get-item -path env:myXargs).value
    if ($myxargs -eq 'True')
    {
        bash -c "find * -type f | xargs -d '\n' grep -HIil $args | xargs" 
    }
    else
    {
        bash -c "find * -type f | xargs -d '\n' grep -HIil $args" 
    }
}
function findf
{
    if ($args.Count -gt 0)
    {
        bash -c "find * -type f | grep $args"
    }
    else
    {
        bash -c "find * -type f"
    }
}
Set-Alias -Name ff -Value findf
function findfi
{
    $myxargs = (Get-item -path env:myXargs).value
    if ($args.Count -eq 0)
    {
        bash -c "find * -type f"
    }
    elseif ($myxargs -eq 'True')
    {
        bash -c "find * -type f | grep -i $args | xargs"
    }
    else
    {
        bash -c "find * -type f | grep -i $args"
    }
}
Set-Alias -Name ffi -Value findfi
function findd
{
    $myxargs = (Get-item -path env:myXargs).value
    if ($args.Count -eq 0)
    {
        bash -c "find * -type d"
    }
    elseif ($myxargs -eq 'True')
    {
        bash -c "find * -type d | grep $args | xargs"
    }
    else
    {
        bash -c "find * -type d | grep $args"
    }
}
Set-Alias -Name fd -Value findd
function finddi
{
    if ($args.Count -gt 0)
    {
        bash -c "find * -type d | grep -i $args"
    }
    else
    {
        bash -c "find * -type d"
    }
}
Set-Alias -Name fdi -Value finddi
function dfhl { Get-WMIObject Win32_LogicalDisk -filter "DriveType=3" | ft }
function pwd { (Get-Location | select-string -notmatch '----') -replace "`n",'' }
function datetime { (date | select-string ':') -replace "`n",'' }
Set-Alias -Name pdw -Value pwd # I don't know why, but I do this way too often
function info { get-childitem Env: | ft }  # TODO: filter things out of this
function gtd { gvim.exe 'G:\My Drive\notes\*cal*' 'G:\My Drive\notes\*gtd*' } 
function prompt { "$ "; $host.ui.RawUI.WindowTitle = $(get-location) }
function touch
{
    # TODO: what about more than one? currently only supporting a single argument
    If (Test-Path -Path $args[0]) 
    {
        set-itemproperty -Path $args[0] -Name LastWriteTime -Value $(get-date)
    }
    Else
    {
        set-content -Path $args[0] -Value $null
    }
}
function lsusb { gwmi Win32_USBControllerDevice }
function psm 
{
    if ($args.Count -lt 1)
    {
        get-process | select id, ProcessName
    }
    else
    {
        # TODO: this does not work
        get-process | select id, ProcessName | where {$_.processname -like $args[0]}
    }
}
function mank { get-help $args[0] | select name, category, synopsis | ft -a }
function file { bash -c "file ${args}" }
#alias gsmr='for m in $(git ls-files -m); do test -z "$(git diff -w $m)" || echo $m;done'
#alias reposrc='[[ -f .git/config ]] && grep url .git/config | cut -d= -f2 | xargs || echo not a valid git repository'
#alias runflake='flake8 --max-complexity 12 --ignore E303,W391'
#alias whatbranch='git status . 2>&1 | sed -n -e "s/.*On branch //p"'
#alias fhpc='git  status | grep "^#.*modified:" | sed -n -e "s/.*modified://p" | xargs grep --color -HI -e'

# simplified versions
function head { gc $args | select-object -first 10 }
function tail { gc $args | select-object -last 10 }
function grep { select-string -Path $args[1] -Pattern $args[0] -AllMatches | select-object -ExpandProperty Line }
function grepv { select-string -notmatch -Path $args[1] -Pattern $args[0] -AllMatches | select-object -ExpandProperty Line }
function which { if ($args.Count -lt 1) { echo 'what are you looking for?'; return } Get-Command $args[0] | Select-Object Source | g $args[0] }

# location based things
function xd
{
# this is a work in progress - want it to support 'cd -'
    $localdir = $(get-location) | select-object -ExpandProperty Path
    echo $localdir
    if ($args.Count -lt 1)
    {
        Set-Location $home
    }
    elseif ($args[0] -eq '-')
    {
        Set-Location "$myCurrentDirectory"
    }
    else
    {
        Set-Location $args[0]
    }
    $myCurrentDirectory = $localdir
}
function me { Set-Location c:\_me; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }
function home { Set-Location $home; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }
function documents { Set-Location $home/Documents; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }
function desktop { Set-Location $home/Desktop; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }
function downloads { Set-Location $home/Downloads; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }
function music { Set-Location $home/Music; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }
function videos { Set-Location $home/Videos; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }
function workspace { Set-Location c:\_me\workspace; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }
function 3p { Set-Location c:\_me\3p; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }
function pot { Set-Location c:\_me\pot-swdev; $myCurrentDirectory = $(get-location) | select-object -ExpandProperty Path }

# let windows/powershell figure out where things are
Set-Alias -Name v -Value gvim.exe
Set-Alias -Name vi -Value gvim.exe
Set-Alias -Name gvim -Value gvim.exe
Set-Alias -Name np -Value C:\Windows\notepad.exe
Set-Alias -Name npp -Value "C:\Program Files\Notepad++\notepad++.exe"
Set-Alias -Name make -Value C:\Qt\Qt5.12.11\Tools\mingw730_32\bin\mingw32-make.exe
Set-Alias -Name qmake -Value C:\Qt\Qt5.12.11\5.12.11\mingw73_32\bin\qmake.exe

# handy things to run
Set-Alias -Name paint -Value C:\Windows\System32\mspaint.exe
Set-Alias -Name gimp -Value "C:\Users\Steve Mink\AppData\Local\Programs\GIMP 2\bin\gimp-2.10.exe"
Set-Alias -Name microir -Value "C:\Program Files (x86)\BAE Systems\MicroIR GUI\MicroIR_GUI.exe"
Set-Alias -Name overlay -Value "C:\Program Files (x86)\BAE Systems\MicroIR GUI\OverlayEditor.exe"
Set-Alias -Name vlc -Value "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
# "control" automatically runs control panel
Set-Alias -Name chrome -Value "C:\Program Files\Google\Chrome\Application\chrome.exe"
# "putty" is automatic
Set-Alias -Name wireshark -Value "C:\Program Files\Wireshark\Wireshark.exe"
Set-Alias -Name qt -Value C:\Qt\Qt5.12.11\Tools\QtCreator\bin\qtcreator.exe
Set-Alias -Name ide -Value C:\ST\STM32CubeIDE_1.6.1\STM32CubeIDE\stm32cubeide.exe
Set-Alias -Name studio -Value "C:\Program Files\Android\Android Studio\bin\studio64.exe"
Set-Alias -Name uniflash -Value C:\ti\uniflash_6.1.0\node-webkit\nw.exe
# TODO: vivado does not work; likely need to make it a function
Set-Alias -Name vivado -Value "C:\Xilinx\Vivado\2020.2\bin\unwrapped\win64.o\vvgl.exe"
Set-Alias -Name mx -Value "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeMX\STM32CubeMX.exe"
Set-Alias -Name fox -Value "C:\Program Files\Mozilla Firefox\firefox.exe"
Set-Alias -Name decomp -Value "C:\_me\3p\java-decompiler\jd-gui-windows-1.6.6\jd-gui.exe"

Set-Alias -Name d -Value datetime
Set-Alias -Name t -Value datetime

# note: for pipenv, do this: path + 'C:\Users\Steve Mink\AppData\Local\Programs\Python\Python39\Scripts'
function path([string] $operation, [string] $dir)
{
    # check if empty
    if ($operation)
    {
        if ($operation -eq '+')
        {
            $env:Path += "; $dir"
        }
        elseif ($operation -eq '-')
        {
            $env:Path = "$dir; " + $env:Path
        }
        else
        {
            echo "usage: path [+/- dir]"
        }
    }
    else
    {
        echo $env:Path
    }
}

function reposrc
{
    if (Test-Path .git\config)
    {
        grep url .git\config | ForEach-object { $_ -replace "(.*)= git","git" }
    }
    else
    {
        echo "Not a valid git repository"
    }
}

function newtab { wt --window 0 -p "Windows Powershell" -d "$pwd" powershell -noExit "Get-Location | select-object -Expandproperty Path" }
function fortune { bash -c "fortune" }
#function cmds { grep Set-Alias $profile | ForEach-object { $_.SubString(16) } | ForEach-object { $_.Replace("-Value ","") } } 
function cmds { grep "^Set-Alias" $profile | ForEach-object { $_.SubString(16) } | ForEach-object { $_ -replace " (.*)","" } | sort } 
function ports { Get-ItemProperty -Path HKLM:\HARDWARE\DEVICEMAP\SERIALCOMM | findstr Device | sort } 

# ref: https://www.reddit.com/r/bashonubuntuonwindows/comments/t5d6l0/get_list_of_all_wsl_distributions_their_locations/?utm_medium=android_app&utm_source=share
function sizes
{
    Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss" -Recurse |
    ForEach-Object {
    $distro_name = ($_ | Get-ItemProperty -Name DistributionName).DistributionName
    $distro_dir =  ($_ | Get-ItemProperty -Name BasePath).BasePath

    $distro_dir = Switch ($PSVersionTable.PSEdition) {
    "Core" { $distro_dir -replace '^\\\\\?\\','' }
    "Desktop" {
            if ($distro_dir.StartsWith('\\?\')) 
            {
                $distro_dir
            } 
            else 
            {
                '\\?\' + $distro_dir
            }
        }
    }
    Write-Output "------------------------------"
    Write-Output "Distribution: $distro_name"
    Write-Output "Directory: $($distro_dir -replace '\\\\\?\\','')"
    $distro_size = "{0:N0} MB" -f ((Get-ChildItem -Recurse -LiteralPath "$distro_dir" | Measure-Object -Property Length -sum).sum / 1Mb)
    Write-Output "Size: $distro_size"
    }
}

# function needs: single required argument to construct a command like the following: tasklist.exe /m /fi "imagename eq vfsze.exe"
# above could also be aliased to depends

# something with this: runcmd "powercfg/energy" - monitors battery health for 60s - must be run as admin

# if you get an execution error, run this from an admin powershell:
#     Set-ExecutionPolicy -ExecutionPolicy Unrestricted
# if you get an error on that as well, then run this:
#     Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
#
# hints:
#     1. dump the current profile: cat $profile
#     2. reload the current profile: & $profile
#     3. Get version of various things: $PSVersionTable
#     4. Get Powershell version only: Get-Host | Select-Object Version

#New-Alias -name locate -value C:\Users\Steve Mink\AppData\Local\locate\Invoke-Locate.ps1 -scope Global -force
#New-Alias -name updatedb -value C:\Users\Steve Mink\AppData\Local\locate\Update-LocateDB.ps1 -scope Global -force
#New-Alias -name locate -value C:\Users\Steve Mink\AppData\Local\locate\Invoke-Locate.ps1 -scope Global -force
#New-Alias -name updatedb -value C:\Users\Steve Mink\AppData\Local\locate\Update-LocateDB.ps1 -scope Global -force
#New-Alias -name locate -value C:\Users\Steve Mink\AppData\Local\locate\Invoke-Locate.ps1 -scope Global -force
#New-Alias -name updatedb -value C:\Users\Steve Mink\AppData\Local\locate\Update-LocateDB.ps1 -scope Global -force
