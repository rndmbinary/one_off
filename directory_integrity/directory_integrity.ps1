<#
FILE NAME: directory_integrity.ps1
DESC: The puprose of this script is to create a list of all the files in the share and store the information in a UTF8 format under the CSV extention.
AUTHOR: Tyron Howard
REQURES: Powershell 5.1 or greater, Windows 10 V.1607, Outlook 2013 API
VERION: 0.8.2
HASH: E8484DE56BD372AD5B6D9E1BEBF32139F254E38948B86228BC241D44D9F9E67A
#>
<# 
.FUTURE FUNCTIONS:
    check_magic 
    create_magic
    compress_magic
.NOTES:

#>
$Error.clear()
$timestamp = Get-Date -Format s | foreach {$_ -replace ":","-"}
$output_results = ".\"+ $timestamp + "-di-journal.csv"
$output_errors = ".\" + $timestamp + "-di-errors.csv"
$outputLongFileNames = ".\" + $timestamp  + "-di-filenames.csv"
$output_agedFiles = ".\" + $timestamp + "-di-agedfiles.csv"
$output_size = ".\" + $timestamp + "-di-size.txt"
$output_location = "\\network_share\journal"
$directory_current = "\\network_share\"
$directory_list = Get-ChildItem $directory_current -Recurse -ErrorVariable +e -ErrorAction SilentlyContinue `
                  | Select Name,Length,Mode,CreationTime,LastWriteTime,LastAccessTime,FullName,@{N="PSParentPath";E={$_.PSParentPath -replace '.+\:\:',''}}



function error_handling() {
    If($Error) {
        For($c=0;$c -le $Error.Count;$c++) {
            ([regex]::Matches($Error,'(?i)\.\s([A-Z].+?\w:.+?\w\.)').value).replace('\.\s','') | Out-File $output_errors -Append
        }
        Write-Host "An error has occured. This may have happened due to the permissions with the account, error with the code or files do not exsist. 'n" `
                   "Please review the" + $output_errors + "file for additional information."
    }
}

function delete_magic() {
    $directory_list = Get-ChildItem $output_location -Include $output_errors, $output_results
    ForEach ($directory_item in $directory_list) {
        $d = @{
            '$directory_item.CreationTime' = $directory_item.Name
        }
        If ((New-Timespan $directory_item.CreationTime).TotalSeconds -le (New-Timespan $directory_item.CreationTime).TotalSeconds - 1296000) {
            Remove-Item $output_location +"\"+ [string]($d['$directory_item.CreationTime']) -ErrorVariable +e
        }
    }
}


function process_magic() { 
    "Indexed Time|Name|Length|Mode|CreationTime|LastWriteTime|LastAccessTime|FullName|Owner|Hash (SHA256)" `
    | Out-File $output_results -ErrorVariable +e -ErrorAction SilentlyContinue

    ForEach($directory_item in $directory_list) {
        $directory_item_timestamp = Get-Date -Format o
        $directory_item_owner = (Get-Acl $directory_item.FullName -ErrorVariable +e -ErrorAction SilentlyContinue).Owner
        $directory_item_hash = (Get-FileHash $directory_item.FullName -ErrorVariable +e -ErrorAction SilentlyContinue).Hash
        $array_directory = $directory_item_timestamp + "|" + $directory_item.Name + "|" + $directory_item.Length + "|" + $directory_item.Mode + "|" + $directory_item.CreationTime `
        + "|" + $directory_item.LastWriteTime + "|" + $directory_item.LastAccessTime + "|" + $directory_item.FullName + "|" + $directory_item_owner + "|" + $directory_item_hash
        $array_directory | Out-File $output_results -Append -ErrorVariable +e -ErrorAction SilentlyContinue
    }
}


 function long_filenames() {
    $d = @{}

    ForEach($directory_item in $directory_list) {
        $actualDirItemLength = [int](($directory_item.FullName -replace '(?i)(\w)\:\\.+\\AA\s-\sSPRING\sCLEANING\\','.\').Length)
        If($actualDirItemLength -ge 255) {
            If(!([System.IO.File]::Exists($outputLongFileNames))) {
                "Actual File Length|File Length (NTFS)|Full File Path" | Out-File $outputLongFileNames
            }
            [string]($actualDirItemLength) + "|" + [string]($directory_item.FullName.Length) + "|" + [string]($directory_item.FullName) | Out-File $outputLongFileNames -Append
#           $d[$directory_item.Name] = ($directory_item.FullName.Length, $actualDirItemLength)
        }
    }
#   $directory_item_lfn = ($d.GetEnumerator() | Format-Table Name,@{L='Length, Actual';E={$_.Value}})
#   $directory_item_lfn | Out-File $outputLongFileNames
}


function files_accessed() {
    $d = @{}

    ForEach($directory_item in $directory_list) {
        If((New-Timespan $directory_item.LastAccessTime).TotalSeconds -le (New-Timespan $directory_item.LastAccessTime).TotalSeconds - 63115200) {
            $d[$directory_item.FullName] = $directory_item.LastAccessTime
        }
    }
    $directory_item_sorted = ($d.GetEnumerator() | Sort-Object -Property Value)
    $directory_item_sorted | Out-File $output_agedFiles

    return $directory_item_sorted
}

function directory_size() {
        $d = @{}
        $array_directory = $directory_list | Where-Object {$_.Mode -eq 'd-----' -and $_.PSParentPath -eq $directory_current}
        
        ForEach($directory_name in $array_directory) {
            $directory_size = [int]((Get-ChildItem $directory_name.FullName -Recurse -Force -ErrorVariable +e -ErrorAction SilentlyContinue `
            | Measure-Object -Property Length -Sum -ErrorVariable +e -ErrorAction SilentlyContinue).Sum/1MB)
            $d[$directory_name.Name] = $directory_size
        }
        $directory_results_sorted = ($d.GetEnumerator() | Sort -Property Name | Format-Table @{L='Directory';E={$_.Name}},@{L='Size (MB)';E={$_.Value}})
        $directory_results_sorted | Out-File $output_size
        return $directory_results_sorted
 }

function create_magic_message() {
    $ol = New-Object -comObject Outlook.Application
    $ns = $ol.GetNameSpace("MAPI")
 
    $mail = $ol.CreateItem(0)
    $mail.Importance = 2

#    $mail.Attachments.Add("$output_results")
    
    $mail.Subject = "Network Share Information $timestamp"  
    $mail.Body = directory_size
                 
#    $mail.Save()
    $mail.Display()

}


delete_magic
long_filenames
files_accessed
directory_size
process_magic
error_handling
#create_magic_message<Paste>
