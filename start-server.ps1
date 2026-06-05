$port = 8369
$dir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$file = Join-Path $dir "OctalBytes-Platform.html"

if (-not (Test-Path $file)) {
    Write-Host "ERROR: OctalBytes-Platform.html not found in $dir" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

try { $listener.Start() }
catch {
    Write-Host "ERROR: Could not start server on port $port — is it already running?" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "  OctalBytes Platform" -ForegroundColor Yellow
Write-Host "  Running at http://localhost:$port/" -ForegroundColor Green
Write-Host "  Opening browser..."
Write-Host ""
Write-Host "  Keep this window open while using the platform." -ForegroundColor Gray
Write-Host "  Close this window (or press Ctrl+C) to stop." -ForegroundColor Gray
Write-Host ""

Start-Process "http://localhost:$port/"

$content = [IO.File]::ReadAllBytes($file)

while ($listener.IsListening) {
    try {
        $ctx  = $listener.GetContext()
        $resp = $ctx.Response
        $resp.ContentType = "text/html; charset=utf-8"
        $resp.ContentLength64 = $content.Length
        $resp.OutputStream.Write($content, 0, $content.Length)
        $resp.OutputStream.Flush()
        $resp.Close()
    } catch { }
}
