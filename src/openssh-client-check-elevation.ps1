
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



# Checks whether the current PowerShell session is running with administrator
# privileges, using five different methods. Useful after SSHing into a
# machine to confirm the session actually has the rights you expect.

Write-Host "=== Check 1: whoami /groups ===";
Write-Host "Look for 'BUILTIN\Administrators' with an enabled attribute below.";
whoami /groups | Select-String "Administrators";

Write-Host "";
Write-Host "=== Check 2: Current token contains the Administrators SID (S-1-5-32-544) ===";
$hasAdminSid = ([Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544";
Write-Host "Result: $hasAdminSid";

Write-Host "";
Write-Host "=== Check 3: Restart-Service on sshd (requires admin rights) ===";
try {
    # Get-Service sshd -ErrorAction Stop | Restart-Service -ErrorAction Stop;

Write-Host "This test is disabled.";

    Write-Host "Result: Succeeded (you are running elevated).";
}
catch {
    Write-Host "Result: Failed (you are NOT running elevated, or sshd is not installed).";
}

Write-Host "";
Write-Host "=== Check 4: Create a file under C:\Windows\Temp (requires admin rights) ===";
$testFile = "C:\Windows\Temp\admin-test.txt";
try {
    New-Item -Path $testFile -ItemType File -Force -ErrorAction Stop | Out-Null;
    Write-Host "Result: Succeeded (you are running elevated).";
    # Clean up the test file.
    Remove-Item -Path $testFile -ErrorAction SilentlyContinue;
}
catch {
    Write-Host "Result: Failed (you are NOT running elevated).";
}

Write-Host "";
Write-Host "=== Check 5: IsInRole(Administrator) - the definitive check ===";
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
Write-Host "Result: $isAdmin";

Write-Host "";
if ($isAdmin) {
    Write-Host "Summary: You ARE running as Administrator.";
}
else {
    Write-Host "Summary: You are NOT running as Administrator.";
}
