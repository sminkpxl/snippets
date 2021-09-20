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

# remove "bad" aliases
remove-item -path alias:ls
remove-item -path alias:pwd

# create some vars
$myprofversion = '1.5'

# update system vars
$MaximumHistoryCount = 1000

# Get rid of the ps7 promotion - open powershell with -nologo for cleanest experience
Clear-Host
Write-Host "Windows PowerShell"
Write-Host

# git related
function gs { git status $args }
function gd { git diff $args }
function gsm { git ls-files -m . }
function gcp { git cherry-pick $args }
function gs { git status $args }
function gsi { echo 'git submodule init'; git submodule init }
function gsur { echo 'git submodule update --recursive'; git submodule update --recursive }
function dirty { git describe --tag --long --dirty }

# Compute file hashes - useful for checking successful downloads 
function md5    { Get-FileHash -Algorithm MD5 $args }
function sha1   { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

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

# functions
function runcmd { cmd /c $args }
function runbash { bash -c $args }
function fortune { bash -c fortune }
function vcal { bash -c "/home/smink/.bin/vcal.sh $args" }
# TODO: something is up when these 3 are on the right side of a pipe as opposed to either the beginning or without a pipe
#function v { gvim.exe $args }
#function vi { gvim.exe $args }
#function gvim { gvim.exe $args }
Set-Alias -Name v -Value gvim.exe
Set-Alias -Name vi -Value gvim.exe
Set-Alias -Name gvim -Value gvim.exe
function gvimdiff { gvim.exe -d $args } 
function .. { cd .. }
function ls { bash -c "ls $args" }
function version { echo $myprofversion; get-wmiobject -class win32_operatingsystem | select caption } 
function psversion { echo(Get-Host).Version } 
function calc { bash -c "echo $args" }
function fh { bash -c "find * -type f | xargs grep -HI $args" }
function fhi { bash -c "find * -type f | xargs grep -HIi $args" }
function fhl { bash -c "find * -type f | xargs grep -HIl $args" }
function fhil { bash -c "find * -type f | xargs grep -HIil $args" }
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
function findd
{
    if ($args.Count -gt 0)
    {
        bash -c "find * -type d | grep $args"
    }
    else
    {
        bash -c "find * -type d"
    }
}
function dfhl { Get-WMIObject Win32_LogicalDisk -filter "DriveType=3" | ft }
function pwd { (Get-Location | select-string -notmatch '----') -replace "`n",'' }
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
#alias gsl='git stash list'
#alias gb='git blame'
#alias gdescr='git describe --tag --long --dirty'
#alias gl='git log'

# simplified versions
function head { gc $args | select-object -first 10 }
function tail { gc $args | select-object -last 10 }
function grep { select-string -Path $args[1] -Pattern $args[0] -AllMatches | select-object -ExpandProperty Line }
function grepv { select-string -notmatch -Path $args[1] -Pattern $args[0] -AllMatches | select-object -ExpandProperty Line }

# location based things
function me { Set-Location c:\_me }
function home { Set-Location $home }
function documents { Set-Location $home/Documents }
function desktop { Set-Location $home/Desktop }
function downloads { Set-Location $home/Downloads }
function music { Set-Location $home/Music }
function videos { Set-Location $home/Videos }
function workspace { Set-Location c:\_me\workspace }
function 3p { Set-Location c:\_me\3p }
function pot { Set-Location c:\_me\pot-swdev }

Set-Alias -Name np -Value C:\Windows\notepad.exe
Set-Alias -Name npp -Value "C:\Program Files\Notepad++\notepad++.exe"

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
