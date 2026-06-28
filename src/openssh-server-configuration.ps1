
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



# Configuration files are located in <%programdata%\ssh\>, with the main server
# configuration in sshd_config. For key-based authentication, public keys should
# be added to <C:\Users\<username>\.ssh\authorized_keys> for standard users or
# <C:\ProgramData\ssh\administrators_authorized_keys> for administrators.
# Ensure inbound traffic is allowed on TCP port 22 by enabling the default firewall rule.



# Get Windows Firewall OpenSSH server rule.

$firewallRule = Get-NetFirewallRule -Name *OpenSSH-Server* -ErrorAction SilentlyContinue;

# Check if the OpenSSH server firewall rule exists; enable it if so.

if ($null -eq $firewallRule) {

    # Notify user.

    Write-Host "The OpenSSH server firewall rule was not found.";

}
else {

    # Notify user.

    Write-Host "The OpenSSH server firewall rule was found. Enabling now...";

    # Enable firewall rule.

    Enable-NetFirewallRule -Name *OpenSSH-Server*;

    # Notify user.

    Write-Host "The OpenSSH server firewall rule is now enabled.";

}

# Check firewall rule.

Get-NetFirewallRule -Name *OpenSSH-Server* -ErrorAction SilentlyContinue;

# Start the server automatically on MS-Windows boot.

Set-Service -Name sshd -StartupType 'Automatic';
