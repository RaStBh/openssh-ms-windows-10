
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



# Get the availability of OpenSSH client.

$capability = Get-WindowsCapability -Online -Name 'OpenSSH.Client~~~~0.0.1.0';

# Check if the OpenSSH client is installed; uninstall it if so.

if ($capability.State -ne 'Installed') {
  
    # Notify user.
  
    Write-Host "The OpenSSH client is not installed.";
    
} 
else {
        
    # Notify user.
          
    Write-Host "The OpenSSH client is installed. Uninstalling now...";
    
    # Uninstall client.
    
    Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0;
        
    # Notify user.
    
    Write-Host "The OpenSSH client is now uninstalled.";
}

# Verify final state.

Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*';

# Get the availability of OpenSSH client.

Get-WindowsCapability -Online -Name 'OpenSSH.Client~~~~0.0.1.0';
