
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



# Get the availability of OpenSSH server.

$capability = Get-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0';

# Check if the OpenSSH server is installed; install it if not.

if ($capability.State -eq 'Installed') {

    # Notify user.

    Write-Host "The OpenSSH server is already installed.";

}
else {

    # Notify user.

    Write-Host "The OpenSSH server is not installed. Installing now...";

    # Install server.

    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0;

    # Notify user.

    Write-Host "The OpenSSH server is now installed.";
}

# Verify final state.

Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*';

# Get the availability of OpenSSH server.

Get-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0';
