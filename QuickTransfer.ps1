# ============================================================
#                  QUICK TRANSFER
#          LAPTOP TO LAPTOP FILE TRANSFER
# ============================================================

$ErrorActionPreference = "Continue"

$Port = 8080

# ------------------------------------------------------------
# COLORS / HEADER
# ------------------------------------------------------------

function Show-Header {

    Clear-Host

    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "                  QUICK TRANSFER" -ForegroundColor Cyan
    Write-Host "             LAPTOP TO LAPTOP TRANSFER" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""

}

# ------------------------------------------------------------
# GET LOCAL IP
# ------------------------------------------------------------

function Get-LocalIP {

    $ip = Get-NetIPAddress `
        -AddressFamily IPv4 `
        -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notlike "127.*" -and
            $_.IPAddress -notlike "169.254.*"
        } |
        Select-Object -First 1 -ExpandProperty IPAddress

    return $ip
}

# ------------------------------------------------------------
# TEST CONNECTION
# ------------------------------------------------------------

function Test-Receiver {

    param(
        [string]$IP
    )

    Write-Host ""
    Write-Host "Connecting to $IP..." -ForegroundColor Yellow
    Write-Host ""

    try {

        $test =
            Test-NetConnection `
                -ComputerName $IP `
                -Port $Port `
                -WarningAction SilentlyContinue

        if ($test.TcpTestSucceeded) {

            Write-Host "✓ DEVICE FOUND" -ForegroundColor Green
            Write-Host "✓ Port $Port is reachable" -ForegroundColor Green
            Write-Host ""

            return $true

        }
        else {

            Write-Host "✗ DEVICE NOT REACHABLE" -ForegroundColor Red
            Write-Host ""

            return $false
        }

    }
    catch {

        Write-Host "✗ Connection failed" -ForegroundColor Red

        return $false
    }
}

# ------------------------------------------------------------
# SEND FILE
# ------------------------------------------------------------

function Send-File {

    param(
        [string]$IP
    )

    Write-Host ""
    Write-Host "--------------------------------------------------------"
    Write-Host "                    SEND FILE"
    Write-Host "--------------------------------------------------------"
    Write-Host ""

    $file = Read-Host "Enter file path"

    if (!(Test-Path $file -PathType Leaf)) {

        Write-Host ""
        Write-Host "File not found." -ForegroundColor Red
        Start-Sleep -Seconds 2
        return
    }

    $info = Get-Item $file

    Write-Host ""
    Write-Host "File      : $($info.Name)" -ForegroundColor Cyan
    Write-Host "Size      : $([math]::Round($info.Length / 1MB,2)) MB"
    Write-Host "Receiver  : $IP"
    Write-Host ""

    $confirm = Read-Host "Send this file? (Y/N)"

    if ($confirm -notmatch "^[Yy]$") {

        Write-Host "Cancelled." -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        return
    }

    try {

        $client = New-Object System.Net.Http.HttpClient

        $stream =
            [System.IO.File]::OpenRead($file)

        $content =
            New-Object System.Net.Http.StreamContent($stream)

        $content.Headers.Add(
            "X-File-Name",
            $info.Name
        )

        $url = "http://$IP`:$Port/"

        Write-Host ""
        Write-Host "Uploading..." -ForegroundColor Yellow
        Write-Host ""

        $response =
            $client.PostAsync(
                $url,
                $content
            ).Result

        $stream.Close()
        $content.Dispose()
        $client.Dispose()

        if ($response.IsSuccessStatusCode) {

            Write-Host ""
            Write-Host "========================================================"
            Write-Host "                 TRANSFER COMPLETE" -ForegroundColor Green
            Write-Host "========================================================"
            Write-Host ""

        }
        else {

            Write-Host ""
            Write-Host "Transfer failed." -ForegroundColor Red

        }

    }
    catch {

        Write-Host ""
        Write-Host "Transfer error:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow

    }

    Write-Host ""
    Read-Host "Press ENTER to continue"
}

# ------------------------------------------------------------
# RECEIVE SERVER
# ------------------------------------------------------------

function Start-Receiver {

    $folder =
        Join-Path $env:USERPROFILE "Downloads\QuickTransfer"

    if (!(Test-Path $folder)) {

        New-Item `
            -ItemType Directory `
            -Path $folder `
            -Force |
            Out-Null
    }

    $listener =
        New-Object System.Net.HttpListener

    $listener.Prefixes.Add(
        "http://+:$Port/"
    )

    try {

        $listener.Start()

    }
    catch {

        Write-Host ""
        Write-Host "Unable to start receiver." -ForegroundColor Red
        Write-Host ""
        Write-Host "Run this program once as Administrator."
        Write-Host ""

        Read-Host "Press ENTER"
        return
    }

    $myIP = Get-LocalIP

    Write-Host ""
    Write-Host "========================================================"
    Write-Host "                 RECEIVER ACTIVE" -ForegroundColor Green
    Write-Host "========================================================"
    Write-Host ""

    Write-Host "Your IP : $myIP" -ForegroundColor Cyan
    Write-Host "Port    : $Port"
    Write-Host ""
    Write-Host "Receive folder:"
    Write-Host $folder
    Write-Host ""
    Write-Host "Waiting for files..."
    Write-Host "Press CTRL+C to stop the receiver."
    Write-Host ""

    while ($listener.IsListening) {

        try {

            $context =
                $listener.GetContext()

            $request =
                $context.Request

            $response =
                $context.Response

            if ($request.HttpMethod -eq "POST") {

                $name =
                    $request.Headers["X-File-Name"]

                if ([string]::IsNullOrWhiteSpace($name)) {

                    $name = "received_file"

                }

                $name =
                    [System.IO.Path]::GetFileName($name)

                $destination =
                    Join-Path $folder $name

                # ------------------------------------------------
                # PREVENT OVERWRITE
                # ------------------------------------------------

                if (Test-Path $destination) {

                    $base =
                        [System.IO.Path]::GetFileNameWithoutExtension(
                            $name
                        )

                    $ext =
                        [System.IO.Path]::GetExtension($name)

                    $number = 1

                    do {

                        $newName =
                            "$base ($number)$ext"

                        $destination =
                            Join-Path $folder $newName

                        $number++

                    }
                    while (Test-Path $destination)

                }

                Write-Host ""
                Write-Host "Incoming file:" -ForegroundColor Yellow
                Write-Host $name

                $output =
                    [System.IO.File]::Create(
                        $destination
                    )

                $request.InputStream.CopyTo($output)

                $output.Close()

                $response.StatusCode = 200

                $message =
                    [System.Text.Encoding]::UTF8.GetBytes(
                        "OK"
                    )

                $response.ContentLength64 =
                    $message.Length

                $response.OutputStream.Write(
                    $message,
                    0,
                    $message.Length
                )

                $response.Close()

                Write-Host ""
                Write-Host "✓ FILE RECEIVED" -ForegroundColor Green
                Write-Host "Saved to:"
                Write-Host $destination -ForegroundColor Cyan
                Write-Host ""
                Write-Host "Waiting for next file..."
            }

            else {

                $response.StatusCode = 200

                $message =
                    [System.Text.Encoding]::UTF8.GetBytes(
                        "QUICK TRANSFER ONLINE"
                    )

                $response.ContentLength64 =
                    $message.Length

                $response.OutputStream.Write(
                    $message,
                    0,
                    $message.Length
                )

                $response.Close()
            }

        }
        catch {

            Write-Host ""
            Write-Host "Receiver error:" -ForegroundColor Red
            Write-Host $_.Exception.Message
        }
    }

    $listener.Stop()
}

# ============================================================
# MAIN PROGRAM
# ============================================================

while ($true) {

    Show-Header

    $myIP = Get-LocalIP

    Write-Host "MY DEVICE"
    Write-Host "IP Address : $myIP" -ForegroundColor Green
    Write-Host ""

    Write-Host "--------------------------------------------------------"
    Write-Host ""
    Write-Host "[1] Send File"
    Write-Host "[2] Receive Files"
    Write-Host "[3] Change Receiver IP"
    Write-Host "[4] Show My IP"
    Write-Host "[5] Exit"
    Write-Host ""

    $choice =
        Read-Host "Select option"

    # --------------------------------------------------------
    # SEND
    # --------------------------------------------------------

    if ($choice -eq "1") {

        Write-Host ""
        Write-Host "========================================================"
        Write-Host "                 CONNECTION PROCESS"
        Write-Host "========================================================"
        Write-Host ""

        $receiverIP =
            Read-Host "Enter the IP address of the device to send to"

        if ([string]::IsNullOrWhiteSpace($receiverIP)) {

            Write-Host "No IP entered." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }

        $connected =
            Test-Receiver $receiverIP

        if ($connected) {

            Send-File $receiverIP

        }
        else {

            Write-Host ""
            Write-Host "Cannot connect to $receiverIP." `
                -ForegroundColor Red

            Write-Host ""
            Read-Host "Press ENTER to return to menu"
        }

        # IMPORTANT:
        # Do NOT exit here.
        continue
    }

    # --------------------------------------------------------
    # RECEIVE
    # --------------------------------------------------------

    elseif ($choice -eq "2") {

        Start-Receiver

        continue
    }

    # --------------------------------------------------------
    # SHOW IP
    # --------------------------------------------------------

    elseif ($choice -eq "4") {

        Write-Host ""
        Write-Host "Your IP address:" -ForegroundColor Green
        Write-Host $myIP -ForegroundColor Cyan
        Write-Host ""

        Read-Host "Press ENTER"
        continue
    }

    # --------------------------------------------------------
    # CHANGE IP
    # --------------------------------------------------------

    elseif ($choice -eq "3") {

        Write-Host ""
        Write-Host "You will enter the receiver IP when"
        Write-Host "you choose Send File."
        Write-Host ""

        Read-Host "Press ENTER"
        continue
    }

    # --------------------------------------------------------
    # EXIT
    # --------------------------------------------------------

    elseif ($choice -eq "5") {

        Write-Host ""
        Write-Host "Closing Quick Transfer..."
        Start-Sleep -Seconds 1
        exit
    }

    else {

        Write-Host ""
        Write-Host "Invalid option." -ForegroundColor Red
        Start-Sleep -Seconds 2
        continue
    }
}