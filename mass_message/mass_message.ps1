$outlook_object = New-Object -comObject Outlook.Application
$namespace = $outlook_object.GetNameSpace("MAPI")

$c = 0
ForEach ($name in (Get-Content .\name_list.txt)) {
    $mail = $outlook_object.CreateItem(0)
    $mail.Importance = 2
    $mail.To = ""
    $mail.CC = ""
    $mail.Subject = ""  
    $mail.Body = @"INSERT CONTENT OF MESSAGE HERE"@
                
                $mail.Save()
                $mail.Display()
                $c++
                Write-Host $c,$name
}
