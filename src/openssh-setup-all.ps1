
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



# Full first-time setup: installs and configures the OpenSSH server, OpenSSH
# client, and ssh-agent, then starts the services. Run this once on a fresh
# machine instead of running each individual script by hand.
#
# Assumes this script is run from the same folder as the other scripts.
# Run as Administrator.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path;

function Run-Step {
    param([string]$Name, [string]$ScriptFile)
    Write-Host "";
    Write-Host "=== $Name ===";
    & (Join-Path $scriptDir $ScriptFile);
}

# Server: install, configure, start, set default shell to PowerShell.

Run-Step "Installing OpenSSH server" "openssh-server-installation.ps1";
Run-Step "Configuring OpenSSH server (firewall + auto-start)" "openssh-server-configuration.ps1";
Run-Step "Starting OpenSSH server" "openssh-server-start.ps1";
Run-Step "Setting PowerShell as the default SSH shell" "openssh-server-set-default-shell.ps1";

# Client: install. (No service or firewall rule to configure.)

Run-Step "Installing OpenSSH client" "openssh-client-installation.ps1";
Run-Step "Checking OpenSSH client configuration" "openssh-client-configuration.ps1";

# Agent: configure (set to Automatic), start.

Run-Step "Configuring ssh-agent (auto-start)" "openssh-agent-configuration.ps1";
Run-Step "Starting ssh-agent" "openssh-agent-start.ps1";

Write-Host "";
Write-Host "=== Setup complete ===";

Write-Host "Next steps: generate a key pair (openssh-client-keygen.ps1), then";
Write-Host "add key to the agent (openssh-agent-addkey.ps1) and/or to a server's";
Write-Host "authorized_keys (openssh-client-show-pubkey.ps1 / openssh-server-addkey-local.ps1).";
