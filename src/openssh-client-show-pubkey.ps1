
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



# Display the public key so it can be copied and pasted onto a remote server.
# On the remote server, paste this into:
#   - C:\Users\<username>\.ssh\authorized_keys (standard user), or
#   - C:\ProgramData\ssh\administrators_authorized_keys (administrator), or
#   - ~/.ssh/authorized_keys on Linux/macOS.



# The path to the public key.

$publicKeyPath = "$HOME\.ssh\id_ed25519.pub";

# Check if the public key exists; show it if so.

if (-not (Test-Path -Path $publicKeyPath)) {

    # Notify user.

    Write-Host "No public key found at $publicKeyPath. Generate one first (see openssh-client-keygen.ps1).";
}
else {

    # Notify user.

    Write-Host "Public key ($publicKeyPath):";

    Write-Host "";

    # Show key content.

    Get-Content -Path $publicKeyPath;

    Write-Host "";

    Write-Host "Copy the line above and paste it into the remote server's authorized_keys file.";
}
