
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



# Set the ssh-agent service to start automatically on boot.
# Note: ssh-agent ships disabled by default, unlike sshd. This script only
# changes the startup type; it does not start the service immediately.
# Use openssh-agent-start.ps1 to start it.

# Start the agent automatically on MS-Windows boot.

Set-Service -Name ssh-agent -StartupType 'Automatic';

# Verify final state.

Get-Service -Name ssh-agent;
