
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



# This script generates an ed25519 key pair without a passphrase (unattended).
# For other key types or with a passphrase, run ssh-keygen manually using one
# of the patterns below instead of this script:
#
#   RSA, without passphrase:
#     ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\id_rsa" -N '""'
#
#   RSA, with passphrase (omit -N to be prompted interactively):
#     ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\id_rsa"
#
#   ed25519, without passphrase (same as this script):
#     ssh-keygen -t ed25519 -f "$HOME\.ssh\id_ed25519" -N '""'
#
#   ed25519, with passphrase (omit -N to be prompted interactively):
#     ssh-keygen -t ed25519 -f "$HOME\.ssh\id_ed25519"
#
# Note: -b 4096 sets the RSA key length in bits; ed25519 has a fixed key
# length and does not use -b. Omitting -N lets ssh-keygen prompt you to type
# (and confirm) a passphrase interactively instead of generating one with no
# passphrase.



# Path to the .ssh directory and the default ed25519 key pair.
$sshDir = "$HOME\.ssh";
$privateKeyPath = "$sshDir\id_ed25519";
$publicKeyPath = "$sshDir\id_ed25519.pub";
# Check if a key pair already exists; generate one if not.
if (Test-Path -Path $privateKeyPath) {
    # Notify user.
    Write-Host "An SSH key pair already exists at $privateKeyPath.";
}
else {
    # Ensure the .ssh directory exists; ssh-keygen does not create it on Windows.
    if (-not (Test-Path -Path $sshDir)) {
        New-Item -Path $sshDir -ItemType Directory | Out-Null;
    }
    # Notify user.
    Write-Host "No SSH key pair found. Generating a new ed25519 key pair now...";
    # Generate key pair (ed25519, no passphrase, unattended).
    ssh-keygen -t ed25519 -f $privateKeyPath -N '""';
    # Check the actual result instead of assuming success.
    if ($LASTEXITCODE -eq 0 -and (Test-Path -Path $privateKeyPath)) {
        # Notify user.
        Write-Host "The SSH key pair has been generated at $privateKeyPath.";
    }
    else {
        # Notify user.
        Write-Host "ssh-keygen did not complete successfully. No key pair was created.";
    }
}
# Verify final state.
Get-ChildItem -Path $sshDir -Filter "id_ed25519*" -ErrorAction SilentlyContinue;
# Show fingerprint
Write-Host "fingerprint:"
ssh-keygen -lf $publicKeyPath;

