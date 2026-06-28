
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


param(
    [Parameter(Mandatory = $true)]
    [string]$PublicKeyFile
)

$sshDir = "$HOME\.ssh";

# Add an arbitrary public key (e.g. copied over from another machine) to
# either this user's authorized_keys or the machine-wide
# administrators_authorized_keys file. Asks which target to use.
#
# Usage:
#   .\openssh-server-addkey-remote.ps1 -PublicKeyFile "C:\path\to\someone.pub"

# Check if the given public key file exists; stop here if not.
if (-not (Test-Path -Path $PublicKeyFile)) {
    # Notify user.
    Write-Host "No public key file found at $PublicKeyFile.";
}
else {
    # Read the public key content.
    $publicKey = Get-Content -Path $PublicKeyFile;

    # Ask which file to target.
    Write-Host "Where should this key be added?";
    Write-Host "  [1] This user's authorized_keys (standard user)";
    Write-Host "  [2] administrators_authorized_keys (local Administrators group)";
    $choice = Read-Host "Enter 1 or 2";

    if ($choice -eq '1') {
        $targetPath = "$sshDir\authorized_keys";
    }
    elseif ($choice -eq '2') {
        $targetPath = "C:\ProgramData\ssh\administrators_authorized_keys";
    }
    else {
        # Notify user.
        Write-Host "Invalid choice. Run the script again and enter 1 or 2.";
        $targetPath = $null;
    }

    if ($null -ne $targetPath) {
        # Check if this key is already present; add it if not.
        $alreadyPresent = $false;
        if (Test-Path -Path $targetPath) {
            $existingContent = Get-Content -Path $targetPath;
            if ($existingContent -contains $publicKey) {
                $alreadyPresent = $true;
            }
        }

        if ($alreadyPresent) {
            # Notify user.
            Write-Host "This public key is already present in $targetPath.";
        }
        else {
            # Notify user.
            Write-Host "Adding public key to $targetPath...";
            # Append key (creates the file if it doesn't exist).
            Add-Content -Path $targetPath -Value $publicKey;
            # Notify user.
            Write-Host "Public key added.";
        }

        # Lock down ACLs: only the owning account(s) and SYSTEM should have access,
        # or sshd will reject the file. Uses the well-known SID *S-1-5-32-544 for
        # the built-in Administrators group instead of its English name, since the
        # group is localized (e.g. "Administratoren" on German Windows) and the
        # English name fails to resolve there.
        Write-Host "Setting restrictive permissions on $targetPath...";
        icacls.exe $targetPath /inheritance:r;
        if ($choice -eq '1') {
            icacls.exe $targetPath /grant "$($env:USERNAME):F";
            icacls.exe $targetPath /grant "SYSTEM:F";
        }
        else {
            icacls.exe $targetPath /grant "*S-1-5-32-544:F";
            icacls.exe $targetPath /grant "SYSTEM:F";
        }
        # Notify user.
        Write-Host "Permissions set.";

        # Verify final state. If this PowerShell session isn't running elevated,
        # the ACL tightening above can make this file unreadable here even though
        # the key was added successfully — show a clear message instead of an error.
        try {
            Get-Content -Path $targetPath -ErrorAction Stop;
        }
        catch {
            Write-Host "Could not read $targetPath back to verify (likely because this session isn't running as Administrator). The key was still added successfully above.";
        }
    }
}
