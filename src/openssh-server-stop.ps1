
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



# Get the status of the OpenSSH server service.

$service = Get-Service -Name sshd;

# Check if the OpenSSH server is running; stop it if so.

if ($service.Status -ne 'Running') {

    # Notify user.

    Write-Host "The OpenSSH server is already stopped.";

}
else {

    # Notify user.

    Write-Host "The OpenSSH server is running. Stopping now...";

    # Stop server.

    Stop-Service -Name sshd;

    # Notify user.

    Write-Host "The OpenSSH server is now stopped.";
}

# Verify final state.

Get-Service -Name sshd;
