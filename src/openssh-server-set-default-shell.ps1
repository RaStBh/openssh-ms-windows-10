
# This file is part of "OpenSSH on Windows 10".
#
# Copyright (C)  2026  Ralf Stephan
#
# "OpenSSH on Windows 10" is free software: you can redistribute it and/or 
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# "OpenSSH on Windows 10" is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with "OpenSSH on Windows 10".  If not, see 
# <https://www.gnu.org/licenses/>.



# This script sets PowerShell as the default shell for incoming SSH sessions.
#
# To revert to cmd.exe (the original Windows default) instead, either:
#
#   Remove the DefaultShell registry value entirely (cmd.exe is used when no
#   value is set):
#     Remove-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell
#     Restart-Service sshd
#
#   Or explicitly point DefaultShell at cmd.exe:
#     New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\cmd.exe" -PropertyType String -Force
#     Restart-Service sshd
#
# Either way, sshd must be restarted afterward for the change to take effect.



# Check if PowerShell is already set as the default shell for SSH sessions;
# set it if not. Without this, incoming SSH sessions land in cmd.exe.
#
# Note: for accounts in the local Administrators group, an SSH session using
# this shell starts already elevated (no UAC prompt appears over SSH).

$registryPath = "HKLM:\SOFTWARE\OpenSSH";

$desiredShell = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe";

# Get the current DefaultShell value, if any.

$currentShell = (Get-ItemProperty -Path $registryPath -Name DefaultShell -ErrorAction SilentlyContinue).DefaultShell;

# Check if PowerShell is already the default shell; set it if not.

if ($currentShell -eq $desiredShell) {

    # Notify user.

    Write-Host "PowerShell is already set as the default SSH shell.";

}
else {

    # Notify user.

    Write-Host "PowerShell is not set as the default SSH shell. Setting it now...";

    # Set PowerShell as the default shell.

    New-ItemProperty -Path $registryPath -Name DefaultShell -Value $desiredShell -PropertyType String -Force;

    # Restart sshd so the change takes effect.

    Restart-Service -Name sshd;

    # Notify user.

    Write-Host "PowerShell is now set as the default SSH shell.";

}

# Verify final state.
Get-ItemProperty -Path $registryPath -Name DefaultShell -ErrorAction SilentlyContinue;
