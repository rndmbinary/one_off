uthor:  Tyron Howard
Last Modified:  28 Mar 2018
Version:  2.3
Description:  Deletes current Chrome/IE Bookmarks and replaces with latest bookmarks specified in this folder.
SHA256: FAACF0F3AE14DC538054CA1AC094EEB2917E4D0B98FFB9CFBC1D9550D56C7164
#>
$date = (Get-Date -Format "yyyy-MM-dd-hh-mm")

function folder_checks() {
    $folder_locations = ("User_Backups", "user_backups\$env:USERNAME", "user_backups\$env:USERNAME\$date", "$env:USERPROFILE\AppData\Roaming\Chrome\Data\Default\")

    ForEach($location in $folder_locations){
        if((Test-Path $location) -eq $False){
            New-Item -ItemType Directory $location
            Write-Host $location + "was created"
        }
    }
    if ((Test-Path "$env:APPDATA\bookmarks") -eq $True) {
            Remove-Item -Force "$env:APPDATA\bookmarks"
    }
}

function stop_browsers() {
    Stop-Process -Name Chrome -ErrorAction Ignore
    Stop-Process -Name iexplore -ErrorAction Ignore
}

function create_backup_bookmarks() {
    $bookmark_files = ("$env:USERPROFILE\Favorites\*", "$env:USERPROFILE\AppData\Roaming\Chrome\Data\Default\Bookmarks*")
    Compress-Archive -Path $bookmark_files[0],$bookmark_files[1] -CompressionLevel NoCompression -DestinationPath "user_backups\$env:USERNAME\$date\bookmarks"

}

function replace_favorites() {
    $folder_location = @{
        "$env:APPDATA\bookmarks\IE\*" = "$env:USERPROFILE\Favorites\Links\"
        "$env:APPDATA\bookmarks\Chrome\*" = "$env:USERPROFILE\AppData\Roaming\Chrome\Data\Default\"
    }
    
    Expand-Archive .\bookmarks.zip -DestinationPath "$env:APPDATA\bookmarks"

    ForEach($hashtable in $folder_location.Keys){
        Copy-Item -Recurse $hashtable $folder_location[$hashtable] -Force
    }
}

folder_checks
stop_browsers
create_backup_bookmarks
replace_favorites
folder_checks
