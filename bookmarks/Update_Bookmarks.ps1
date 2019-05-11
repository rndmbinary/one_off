<#
Author:  Tyron Howard
Name: Update_Bookmarks
Last Modified:  28 Mar 2018
Version:  1.0 (Super Lazy Code Edition)
Description: For Bookmark Administrators to copy from their local browswers to an archived file.
SHA256: 827F5E57E180FA6CC5002ABBBD19693DD1515BAA5D37676465759305D9F495B0
#>

function create_backup_bookmarks() {
    New-Item -ItemType Directory "$env:USERPROFILE\Favorites\Links\IE"; 
    New-Item -ItemType Directory "$env:USERPROFILE\AppData\Roaming\Chrome\Data\Default\Chrome"
    Copy-Item -Recurse "$env:USERPROFILE\Favorites\Links\*" "$env:USERPROFILE\Favorites\Links\IE" -Exclude "IE"
    Copy-Item -Recurse "$env:USERPROFILE\AppData\Roaming\Chrome\Data\Default\Bookmarks*" "$env:USERPROFILE\AppData\Roaming\Chrome\Data\Default\Chrome" -Exclude "Chrome"
    
    $bookmark_files = ("$env:USERPROFILE\Favorites\Links\IE", "$env:USERPROFILE\AppData\Roaming\Chrome\Data\Default\Chrome")
    Compress-Archive -Path $bookmark_files[0],$bookmark_files[1] -CompressionLevel NoCompression -DestinationPath "..\bookmarks" -Force

    Remove-Item -Recurse "$env:USERPROFILE\Favorites\Links\IE"; Remove-Item -Recurse "$env:USERPROFILE\AppData\Roaming\Chrome\Data\Default\Chrome"

}

create_backup_bookmarks
PAUSE
