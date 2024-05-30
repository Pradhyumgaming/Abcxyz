# Log file location
$logFile = "$env:TEMP\setup_log.txt"

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFile
}

# Function to run a process with a timeout
function Start-ProcessWithTimeout {
    param (
        [string]$filePath,
        [string]$arguments = "",
        [int]$timeoutSeconds
    )
    try {
        Log-Message "Starting process $filePath with arguments $arguments and timeout of $timeoutSeconds seconds."
        $process = Start-Process -FilePath $filePath -ArgumentList $arguments -PassThru -Wait
        $process | Wait-Process -Timeout $timeoutSeconds
        if (!$process.HasExited) {
            Log-Message "Process $filePath timed out after $timeoutSeconds seconds."
            $process.Kill()
            throw "Process $filePath timed out after $timeoutSeconds seconds."
        } else {
            Log-Message "Process $filePath completed successfully."
        }
    } catch {
        Log-Message "Error running process $filePath: $_"
        throw
    }
}

# Start logging
Log-Message "Starting setup script..."

# Disable the Windows Firewall for Domain, Public, and Private profiles
try {
    Log-Message "Disabling Windows Firewall..."
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    Log-Message "Windows Firewall disabled."
} catch {
    Log-Message "Error disabling Windows Firewall: $_"
    throw
}

# Install Chrome Remote Desktop Host
try {
    $chromeRemoteDesktopHostUrl = 'https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi'
    $chromeRemoteDesktopHostInstaller = "$env:TEMP\chromeremotedesktophost.msi"
    
    Log-Message "Downloading Chrome Remote Desktop Host from $chromeRemoteDesktopHostUrl..."
    Invoke-WebRequest -Uri $chromeRemoteDesktopHostUrl -OutFile $chromeRemoteDesktopHostInstaller -Verbose
    Log-Message "Downloaded Chrome Remote Desktop Host."

    Log-Message "Installing Chrome Remote Desktop Host..."
    Start-ProcessWithTimeout -FilePath $chromeRemoteDesktopHostInstaller -TimeoutSeconds 300
    Log-Message "Installed Chrome Remote Desktop Host."

    Remove-Item $chromeRemoteDesktopHostInstaller
    Log-Message "Deleted Chrome Remote Desktop Host installer."
} catch {
    Log-Message "Error installing Chrome Remote Desktop Host: $_"
    throw
}

# Install Google Chrome
try {
    $chromeInstallerUrl = 'https://dl.google.com/chrome/install/latest/chrome_installer.exe'
    $chromeInstaller = "$env:TEMP\chrome_installer.exe"
    
    Log-Message "Downloading Google Chrome from $chromeInstallerUrl..."
    Invoke-WebRequest -Uri $chromeInstallerUrl -OutFile $chromeInstaller -Verbose
    Log-Message "Downloaded Google Chrome."

    Log-Message "Installing Google Chrome..."
    Start-ProcessWithTimeout -FilePath $chromeInstaller -Arguments '/install' -TimeoutSeconds 300
    Log-Message "Installed Google Chrome."

    Remove-Item $chromeInstaller
    Log-Message "Deleted Google Chrome installer."
} catch {
    Log-Message "Error installing Google Chrome: $_"
    throw
}

Log-Message "Setup script completed successfully."
