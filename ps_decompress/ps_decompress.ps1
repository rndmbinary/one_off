$base64_data = Read-Host("Paste Base64 String To Be Decompressed")
$convert_data = [System.Convert]::FromBase64String($base64_data)
$mem_stream_data = New-Object System.IO.MemoryStream
$mem_stream_data.Write($convert_data, 0, $convert_data.Length)
$mem_stream_data.Seek(0,0) | Out-Null

$stream_reader_data = New-Object System.IO.StreamReader(New-Object System.IO.Compression.DeflateStream($mem_stream_data, [System.IO.Compression.CompressionMode]::Decompress))

Write-Output $stream_reader_data
PAUSE
