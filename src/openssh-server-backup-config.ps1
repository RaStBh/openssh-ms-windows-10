
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



# Back up the OpenSSH server configuration folder (sshd_config, host keys,
# administrators_authorized_keys) before making changes, upgrading, or uninstalling.



$sourcePath = "C:\ProgramData\ssh";

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss";

$backupPath = "C:\ProgramData\ssh-backup-$timestamp";

# Check if the source folder exists; back it up if so.

if (-not (Test-Path -Path $sourcePath)) {

    # Notify user.

    Write-Host "No configuration folder found at $sourcePath. Nothing to back up.";

}
else {

    # Notify user.

    Write-Host "Backing up $sourcePath to $backupPath...";

    # Copy the entire folder, including subfolders and host keys.

    Copy-Item -Path $sourcePath -Destination $backupPath -Recurse;

    # Notify user.

    Write-Host "Backup complete.";

}

# Verify final state.

Get-ChildItem -Path "C:\ProgramData" -Filter "ssh-backup-*" -Directory;
