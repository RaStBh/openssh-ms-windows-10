
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



# Add the default ed25519 private key to ssh-agent.

$privateKeyPath = "$HOME\.ssh\id_ed25519";

# Check if ssh-agent is running; stop here if not.

$service = Get-Service -Name ssh-agent;

if ($service.Status -ne 'Running') {

    # Notify user.

    Write-Host "ssh-agent is not running. Start it first (see openssh-agent-start.ps1).";

    return;

}

# Check if the key file exists; add it if so.

if (-not (Test-Path -Path $privateKeyPath)) {

    # Notify user.

    Write-Host "No private key found at $privateKeyPath. Generate one first (see openssh-client-keygen.ps1).";

}

else {

    # Notify user.

    Write-Host "Adding key $privateKeyPath to ssh-agent...";

    # Add key to ssh-agent.

    ssh-add $privateKeyPath;

    # Notify user.

    Write-Host "Key has been added to ssh-agent.";

}

# Verify final state: list keys currently held by ssh-agent.

ssh-add -l;
