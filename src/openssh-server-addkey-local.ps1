
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



# Add this user's own public key to their local authorized_keys file,
# so this account can SSH into this machine using key-based authentication.
# Always targets the standard per-user file (not administrators_authorized_keys).



$sshDir = "$HOME\.ssh";

# The path to the public key.

$publicKeyPath = "$sshDir\id_ed25519.pub";

# The path to the authorized keys.

$authorizedKeysPath = "$sshDir\authorized_keys";

# Check if the public key exists; stop here if not.

if (-not (Test-Path -Path $publicKeyPath)) {

    # Notify user.

    Write-Host "No public key found at $publicKeyPath. Generate one first (see openssh-client-keygen.ps1).";
}
else {

    # Read the public key content.

    $publicKey = Get-Content -Path $publicKeyPath;

    # Check if authorized_keys already exists and already contains this key.

    $alreadyPresent = $false;
    if (Test-Path -Path $authorizedKeysPath) {
        $existingContent = Get-Content -Path $authorizedKeysPath;
        if ($existingContent -contains $publicKey) {
            $alreadyPresent = $true;
        }
    }

    # ???

    if ($alreadyPresent) {
      
        # Notify user.
        
        Write-Host "This public key is already present in $authorizedKeysPath.";
        
    }
    else {
      
        # Notify user.

        Write-Host "Adding public key to $authorizedKeysPath...";

        # Append key to authorized_keys (creates the file if it doesn't exist).

        Add-Content -Path $authorizedKeysPath -Value $publicKey;

        # Notify user.

        Write-Host "Public key added.";

    }

    # Lock down ACLs: only this user and SYSTEM should have access, or sshd will reject the file.

    Write-Host "Setting restrictive permissions on $authorizedKeysPath...";

    icacls.exe $authorizedKeysPath /inheritance:r;

    icacls.exe $authorizedKeysPath /grant "$($env:USERNAME):F";

    icacls.exe $authorizedKeysPath /grant "SYSTEM:F";

    # Notify user.

    Write-Host "Permissions set.";

}

# Verify final state.

Get-Content -Path $authorizedKeysPath -ErrorAction SilentlyContinue;
