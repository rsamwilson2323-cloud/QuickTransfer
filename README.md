# ⚡ QUICK TRANSFER

A lightweight Windows laptop-to-laptop file transfer utility built with **Windows Batch and PowerShell**. QUICK TRANSFER allows users to send files directly between two Windows devices over a local network without requiring Python, Node.js, third-party applications, or cloud storage.

The project uses a PowerShell-based HTTP receiver and sender to establish direct device-to-device communication. With a simple console interface, IP address detection, connection testing, file transfer, and automatic duplicate filename handling, QUICK TRANSFER provides a straightforward way to transfer files between computers.

> **Important:** Both devices must be connected to a network that allows communication between them. QUICK TRANSFER currently uses HTTP without encryption or authentication. Use it only on trusted private networks and do not transfer confidential or sensitive files over untrusted networks.

---

## 📑 Table of Contents

- [Features](#-features)
- [Architecture Overview](#-architecture-overview)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [How It Works](#-how-it-works)
- [Console Interface](#-console-interface)
- [File Transfer System](#-file-transfer-system)
- [Network Communication](#-network-communication)
- [Installation](#-installation)
- [Usage](#-usage)
- [Logging and Storage](#-logging-and-storage)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)
- [Limitations](#-limitations)
- [Privacy and Security](#-privacy-and-security)
- [Future Improvements](#-future-improvements)
- [License](#-license)
- [Author](#-author)

---

## ✨ Features

### ⚡ Direct Laptop-to-Laptop File Transfer

- Transfers files directly between two Windows computers.
- Uses local network communication.
- No cloud storage or external file-sharing service required.
- Supports files of different types.
- Supports file paths containing spaces.
- Uses HTTP POST requests for file transmission.
- Displays file name and size before sending.
- Requires user confirmation before uploading.
- Displays transfer completion or failure information.

### 📡 Network and IP Address Detection

- Automatically detects the local IPv4 address.
- Displays the device's IP address in the main menu.
- Allows users to enter the receiving device's IP address.
- Tests connectivity before starting a transfer.
- Checks whether the receiver's communication port is reachable.
- Uses TCP port `8080` by default.

### 📥 File Receiving System

- Starts a built-in HTTP receiver.
- Automatically creates the QuickTransfer download directory.
- Receives incoming files through HTTP POST requests.
- Saves received files directly to the destination folder.
- Displays incoming file information.
- Confirms successful file reception.
- Continues listening for additional incoming files.
- Allows users to stop the receiver using `CTRL+C`.

### 🛡️ Automatic Duplicate File Protection

- Checks whether a file with the same name already exists.
- Prevents existing files from being overwritten.
- Automatically generates an alternative filename.
- Uses numbered filenames such as:

```text
document.txt
document (1).txt
document (2).txt
document (3).txt
```

### 🖥️ Simple Console Interface

- Clean console-based interface.
- Displays device information.
- Provides an interactive menu.
- Includes connection status messages.
- Displays transfer progress states.
- Provides error messages when connections fail.
- Allows users to return to the main menu.
- Supports continuous operation until the user exits.

### 🔧 Lightweight Windows Utility

- Built using Windows Batch and PowerShell.
- No Python installation required.
- No Node.js installation required.
- No external runtime dependencies.
- Uses native .NET networking classes available through Windows PowerShell.
- Runs through a simple `.bat` launcher.

---

## 🏗️ Architecture Overview

QUICK TRANSFER consists of two primary components:

| Component | Technology | Responsibility |
|---|---|---|
| Launcher | Windows Batch (`.bat`) | Starts the PowerShell application. |
| Transfer Engine | Windows PowerShell 5.1 | Handles IP detection, connections, file sending, receiving, and storage. |
| HTTP Communication | .NET `HttpClient` and `HttpListener` | Transfers files between devices. |
| File Storage | Windows File System | Stores received files in the Downloads directory. |

### Architecture Diagram

```text
             ┌────────────────────────┐
             │         USER           │
             │  Laptop A / Laptop B   │
             └───────────┬────────────┘
                         │
                         ▼
             ┌────────────────────────┐
             │     QUICK TRANSFER     │
             │     Batch Launcher     │
             │    QuickTransfer.bat   │
             └───────────┬────────────┘
                         │
                         ▼
             ┌────────────────────────┐
             │   PowerShell Engine    │
             │   QuickTransfer.ps1    │
             └───────────┬────────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
     ┌─────────────────┐   ┌─────────────────┐
     │   SEND FILE     │   │  RECEIVE FILE   │
     │                 │   │                 │
     │  HttpClient     │   │  HttpListener   │
     └────────┬────────┘   └────────┬────────┘
              │                     │
              └──────────┬──────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  Local Network       │
              │  HTTP - Port 8080    │
              └──────────┬───────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  Receiving Device    │
              │                      │
              │  Downloads/          │
              │  QuickTransfer/      │
              └──────────────────────┘
```

The sender uses `HttpClient` to upload the selected file. The receiver uses `HttpListener` to accept incoming requests and save the received content to the destination directory.

---

## 🧰 Tech Stack

### Windows Automation

- **Windows Batch** — application launcher.
- **Windows PowerShell 5.1** — application logic and console interface.
- **.NET HttpClient** — sends files through HTTP requests.
- **.NET HttpListener** — receives incoming HTTP requests.
- **.NET FileStream** — reads and writes file data.
- **Windows Networking** — local IPv4 detection and TCP connectivity testing.

### Platform and Development

- Windows 10.
- Windows 11.
- Windows PowerShell 5.1.
- Local Wi-Fi or Ethernet network.
- Windows Firewall configuration where required.

**No Python, Node.js, database, or third-party runtime is required.**

---

## 📁 Project Structure

```text
QuickTransfer/
│
├── QuickTransfer.bat
│
├── QuickTransfer.ps1
│
├── README.md
│
└── LICENSE
```

### File Description

| File | Description |
|---|---|
| `QuickTransfer.bat` | Starts the PowerShell application. |
| `QuickTransfer.ps1` | Contains the complete file transfer implementation. |
| `README.md` | Project documentation. |
| `LICENSE` | Project license information. |

---

## ⚙️ How It Works

### 1. Application Startup

The user launches `QuickTransfer.bat`.

The batch file changes the working directory to the project location and starts the PowerShell script.

```bat
@echo off
cd /d "%~dp0"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0QuickTransfer.ps1"

pause
```

### 2. IP Address Detection

The application identifies the local IPv4 address using Windows networking commands.

It filters out loopback and automatic private link-local addresses.

The detected IP address is displayed in the main menu.

Example:

```text
MY DEVICE

IP Address : 192.168.1.10
```

### 3. Establishing a Connection

When the user selects Send File, the application asks for the receiver's IP address.

It then checks the receiver using `Test-NetConnection`.

The application tests TCP port `8080` before attempting the transfer.

If the port is reachable, the sender continues to the file-selection process.

### 4. Sending a File

The user enters the full path of the file.

The application:

- Verifies that the file exists.
- Retrieves its filename and size.
- Displays receiver information.
- Requests confirmation.
- Opens the file as a stream.
- Creates an HTTP POST request.
- Sends the file to the receiving device.

### 5. Receiving a File

The receiving device starts the built-in HTTP listener.

The listener waits for incoming requests on port `8080`.

When a POST request arrives, the application:

- Reads the incoming filename.
- Extracts the filename without accepting directory components.
- Checks for duplicate filenames.
- Creates a new destination file.
- Copies the incoming data into the destination.
- Returns a successful HTTP response.

### 6. Saving and Verification

Received files are stored in:

```text
%USERPROFILE%\Downloads\QuickTransfer\
```

If a file with the same name already exists, the application creates a numbered alternative.

The receiver displays the saved file location and continues waiting for additional files.

---

## 🖥️ Console Interface

QUICK TRANSFER provides an interactive menu with five options.

### Main Menu

```text
========================================================
                  QUICK TRANSFER
             LAPTOP TO LAPTOP TRANSFER
========================================================

MY DEVICE
IP Address : 192.168.1.10

--------------------------------------------------------

[1] Send File
[2] Receive Files
[3] Change Receiver IP
[4] Show My IP
[5] Exit

Select option:
```

### Menu Description

| Option | Function |
|---|---|
| 1 | Connect to another device and send a file. |
| 2 | Start the file receiving server. |
| 3 | Displays how to specify the receiver IP when sending. |
| 4 | Displays the local IP address. |
| 5 | Exits the application. |

---

## 📤 File Transfer System

QUICK TRANSFER uses HTTP communication to transfer files between two devices.

### Sender Workflow

```text
Select Send File
       |
       ▼
Enter Receiver IP
       |
       ▼
Test TCP Connection
       |
       ▼
Enter File Path
       |
       ▼
Verify File Exists
       |
       ▼
Display File Information
       |
       ▼
Confirm Transfer
       |
       ▼
Send HTTP POST Request
       |
       ▼
Receive Server Response
       |
       ▼
Display Transfer Result
```

### Receiver Workflow

```text
Select Receive Files
       |
       ▼
Create Download Directory
       |
       ▼
Start HTTP Listener
       |
       ▼
Wait for Incoming Request
       |
       ▼
Read File Name
       |
       ▼
Check Duplicate Filename
       |
       ▼
Save Incoming File
       |
       ▼
Return HTTP Response
       |
       ▼
Wait for Next File
```

### Transfer Configuration

| Configuration | Value |
|---|---|
| Protocol | HTTP |
| Default Port | `8080` |
| Request Method | POST |
| Sender | .NET HttpClient |
| Receiver | .NET HttpListener |
| Transfer Mode | File stream |
| Storage Location | Downloads/QuickTransfer |
| Network | Local Wi-Fi / Ethernet |

---

## 🌐 Network Communication

QUICK TRANSFER is designed for direct communication between computers on the same accessible local network.

### Example Network Setup

| Device | Role | Example IP |
|---|---|---|
| Laptop A | Sender | `192.168.1.10` |
| Laptop B | Receiver | `192.168.1.20` |

Both devices should be connected to the same Wi-Fi network or an appropriately configured Ethernet network.

### Connection URL

The sender communicates with the receiver using:

```text
http://192.168.1.20:8080/
```

Replace the example address with the actual IP address displayed on the receiving device.

### Important Network Requirements

- Both devices must be powered on.
- Both devices must be connected to an accessible network.
- The receiver must be running before sending.
- TCP port `8080` must be reachable.
- Windows Firewall must permit the required inbound connection.
- Network isolation or guest Wi-Fi restrictions must not block device-to-device communication.

---

## 🚀 Installation

### Prerequisites

- Windows 10 or Windows 11.
- Windows PowerShell 5.1.
- Two Windows devices for device-to-device transfers.
- Wi-Fi or Ethernet connectivity.
- Administrator privileges may be required to register or start the HTTP listener, depending on Windows URL ACL configuration.

### Quick Start

**1. Clone the repository**

```bash
git clone https://github.com/rsamwilson2323-cloud/QuickTransfer.git
```

**2. Open the project directory**

```bash
cd QuickTransfer
```

**3. Run the application**

Double-click:

```text
QuickTransfer.bat
```

Alternatively, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\QuickTransfer.ps1
```

**4. Start receiving on the destination laptop.**

Select option:

```text
[2] Receive Files
```

**5. Send files from the other laptop.**

Select:

```text
[1] Send File
```

Enter the receiver's IP address and follow the instructions.

---

## 📖 Usage

### Example: Transfer a File Between Two Laptops

Suppose you want to send a PDF document from Laptop A to Laptop B.

**Laptop B — Receiver**

1. Open QUICK TRANSFER.
2. Select option `2`.
3. Start the receiving server.
4. Note the displayed IP address.
5. Keep the receiver running.

Example:

```text
========================================================
                 RECEIVER ACTIVE
========================================================

Your IP : 192.168.1.20
Port    : 8080

Receive folder:
C:\Users\User\Downloads\QuickTransfer

Waiting for files...
Press CTRL+C to stop the receiver.
```

**Laptop A — Sender**

1. Open QUICK TRANSFER.
2. Select option `1`.
3. Enter Laptop B's IP address.
4. Wait for the connection test.
5. Enter the file path.
6. Review the file information.
7. Confirm the transfer using `Y`.

Example:

```text
========================================================
                 CONNECTION PROCESS
========================================================

Enter the IP address of the device to send to:
192.168.1.20

✓ DEVICE FOUND
✓ Port 8080 is reachable

--------------------------------------------------------
                    SEND FILE
--------------------------------------------------------

Enter file path:
D:\Documents\Project_Report.pdf

File      : Project_Report.pdf
Size      : 2.45 MB
Receiver  : 192.168.1.20

Send this file? (Y/N)
```

### Transfer Complete

After successful transmission:

```text
========================================================
                 TRANSFER COMPLETE
========================================================
```

The received file will be available on Laptop B at:

```text
C:\Users\User\Downloads\QuickTransfer\Project_Report.pdf
```

---

## 📂 File Storage

### Default Receiving Directory

```text
%USERPROFILE%\Downloads\QuickTransfer\
```

The application automatically creates this directory if it does not already exist.

### Duplicate Filename Handling

QUICK TRANSFER prevents existing files from being overwritten.

Example:

```text
QuickTransfer/
│
├── Report.pdf
├── Report (1).pdf
├── Report (2).pdf
└── Report (3).pdf
```

The receiver automatically chooses the next available numbered filename.

---

## 🧪 Testing

QUICK TRANSFER can be tested using two Windows computers connected to the same local network.

### Recommended Test Scenarios

| # | Test Scenario | Expected Result |
|---|---|---|
| 1 | Start the application | Main menu appears. |
| 2 | Detect local IP | IPv4 address is displayed when available. |
| 3 | Start receiver | HTTP listener starts successfully. |
| 4 | Connect to receiver | TCP port connectivity is verified. |
| 5 | Send a PDF file | File is transferred successfully. |
| 6 | Send an image | Image is received correctly. |
| 7 | Send a large file | File is streamed to the receiver. |
| 8 | Duplicate filename | Numbered filename is generated. |
| 9 | Enter invalid file path | File-not-found message appears. |
| 10 | Enter unreachable IP | Connection failure is displayed. |
| 11 | Cancel transfer | Upload is not started. |
| 12 | Send multiple files | Receiver accepts successive requests. |
| 13 | Stop receiver | Listener stops using CTRL+C. |
| 14 | Exit application | Application closes. |

### Testing Warning

Use test files and trusted private networks. Verify received files after transmission. Do not use confidential files for testing over unsecured networks.

---

## 🛠️ Troubleshooting

### 1. Device Not Reachable

Possible causes:

- Incorrect receiver IP address.
- Receiver is not running.
- Devices are connected to different networks.
- Windows Firewall blocks port `8080`.
- Wi-Fi access-point isolation is enabled.

Solutions:

- Verify the receiver's IP address.
- Start the receiver before sending.
- Check both devices' network connections.
- Verify that TCP port `8080` is allowed through Windows Firewall.

### 2. Unable to Start Receiver

The application may fail to start `HttpListener` because of HTTP URL reservation permissions or port conflicts.

Solutions:

- Try running the application as Administrator.
- Check whether another application is using port `8080`.
- Inspect HTTP URL reservations if listener access is denied.
- Check whether Windows Firewall or security policies are blocking the listener.

### 3. Connection Refused

Possible causes:

- Receiver is stopped.
- Port `8080` is not listening.
- Incorrect IP address.
- Firewall restrictions.

Solutions:

- Restart the receiver.
- Confirm that the displayed IP address is correct.
- Check the listening port.
- Verify network connectivity.

### 4. File Not Found

- Check the complete file path.
- Verify the filename and extension.
- Use quotation marks when entering paths containing spaces if needed.
- Confirm that the file exists before sending.

### 5. File Already Exists

QUICK TRANSFER automatically generates a numbered filename instead of overwriting the existing file.

For example:

```text
photo.jpg
photo (1).jpg
photo (2).jpg
```

### 6. Transfer Fails

- Check the receiver connection.
- Verify available disk space.
- Check destination folder permissions.
- Review the sender and receiver error messages.
- Check whether the network connection was interrupted.

---

## ⚠️ Limitations

- Designed primarily for Windows-to-Windows file transfers.
- Both devices need an accessible local network connection.
- Uses HTTP rather than HTTPS.
- Does not provide built-in encryption or sender authentication.
- Does not currently provide password-protected transfers.
- Uses a fixed default communication port of `8080`.
- Transfers individual files rather than entire folders.
- Does not currently provide a graphical user interface.
- Does not include a built-in transfer history or persistent logging system.
- Does not provide a dedicated transfer progress percentage.
- The receiver uses a sequential request-processing loop.
- Network isolation and firewall restrictions can prevent communication.
- Large-file transfers depend on available memory, storage, and network stability.
- IP detection may select an address belonging to an unintended network adapter.
- Internet-based transfers and remote access are not implemented.

---

## 🔒 Privacy and Security

QUICK TRANSFER is designed as a local Windows file transfer utility.

Security considerations:

- No cloud storage is required.
- No external file-sharing service is required.
- Files are sent directly to the specified IP address.
- Received files are stored locally.
- Duplicate filenames are handled without overwriting existing files.

**Important security limitations:**

- HTTP transfers are not encrypted.
- There is no built-in authentication or authorization mechanism.
- The receiver listens on a wildcard HTTP prefix.
- Any device able to reach the listener may be able to submit files.
- Received files should be scanned and checked before opening.
- Use only on trusted private networks.
- Avoid exposing port `8080` to the public internet.

Review the source code before running the application with elevated privileges.

---

## 🗺️ Future Improvements

Potential development directions include:

- Password-protected device connections.
- HTTPS-based encrypted file transfers.
- QR-code-based device pairing.
- Automatic device discovery.
- Multiple-file selection.
- Complete folder transfers.
- Drag-and-drop file sharing.
- Real-time transfer progress.
- Transfer speed monitoring.
- Pause and resume functionality.
- Transfer history and detailed logs.
- Custom receiving directories.
- Configurable communication ports.
- Improved network adapter selection.
- File integrity verification using SHA-256.
- Modern Windows desktop graphical interface.
- Improved large-file transfer performance.

---

## 📄 License

This project is released under the **MIT License**. See the [`LICENSE`](LICENSE) file for the complete license terms.

---

## 👨‍💻 Author

**R. Sam Wilson**

GitHub: https://github.com/rsamwilson2323-cloud

Repository: https://github.com/rsamwilson2323-cloud/QuickTransfer

---

*Built as a lightweight Windows utility for simple, direct, and convenient laptop-to-laptop file transfers over a local network.*
