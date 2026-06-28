
This file is part of "OpenSSH on Windows 10".

Copyright (C)  2026  Ralf Stephan

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.

A copy of the license is included in the section entitled "GNU
Free Documentation License".

---

# OpenSSH on Windows 10 — Scripts and Configuration

This repository contains PowerShell scripts to install, configure, and manage the OpenSSH server and client on Windows 10, along with reference information on the relevant configuration files.

All scripts must be run from an **elevated (Administrator) PowerShell** session. If script execution is blocked, see [Execution Policy](#execution-policy) below.

---

## Scripts

### Installation / Uninstallation

| Script | Purpose |
|---|---|
| `openssh-server-installation.ps1` | Checks whether the OpenSSH server feature is installed; installs it if missing. |
| `openssh-server-uninstallation.ps1` | Checks whether the OpenSSH server feature is installed; uninstalls it if present. |
| `openssh-client-installation.ps1` | Checks whether the OpenSSH client feature is installed; installs it if missing. |
| `openssh-client-uninstallation.ps1` | Checks whether the OpenSSH client feature is installed; uninstalls it if present. |

### Server Configuration

| Script | Purpose |
|---|---|
| `openssh-server-configuration.ps1` | Enables the Windows Firewall rule for inbound SSH traffic (TCP port 22) and sets the `sshd` service to start automatically on boot. Does not edit `sshd_config`. |
| `openssh-server-set-default-shell.ps1` | Checks whether PowerShell is already set as the default shell for incoming SSH sessions; sets it (via the `HKLM:\SOFTWARE\OpenSSH\DefaultShell` registry value) and restarts `sshd` if not. Without this, SSH sessions default to `cmd.exe`. |

### Client Configuration

| Script | Purpose |
|---|---|
| `openssh-client-configuration.ps1` | Reminder script — there is nothing that needs to be configured for the OpenSSH client (no service, no firewall rule). |
| `openssh-client-keygen.ps1` | Checks whether an ed25519 key pair already exists at `~/.ssh/id_ed25519`; generates one (no passphrase, unattended) if not. Top-of-file comments explain how to generate RSA or passphrase-protected keys manually instead. |

### SSH Agent Configuration

| Script | Purpose |
|---|---|
| `openssh-agent-configuration.ps1` | Sets the `ssh-agent` service's startup type to Automatic. The service ships **Disabled** by default on Windows, unlike `sshd`, so this step is required before it can be started. Does not start the service. |

### SSH Agent Management

| Script | Purpose |
|---|---|
| `openssh-agent-start.ps1` | Checks if `ssh-agent` is running; starts it if not. Shows final service status. |
| `openssh-agent-stop.ps1` | Checks if `ssh-agent` is running; stops it if so. Shows final service status. |
| `openssh-agent-restart.ps1` | Checks if `ssh-agent` is running. If running, restarts it. If not running, notifies the user to start it first instead of restarting. |
| `openssh-agent-status.ps1` | Reports the current status of the `ssh-agent` service. |
| `openssh-agent-addkey.ps1` | Checks that `ssh-agent` is running and that the default ed25519 private key exists, then adds the key to the agent via `ssh-add`. Lists all keys currently held by the agent afterward. |

### Service Management

| Script | Purpose |
|---|---|
| `openssh-server-start.ps1` | Checks if the `sshd` service is running; starts it if not. Shows final service status. |
| `openssh-server-stop.ps1` | Checks if the `sshd` service is running; stops it if so. Shows final service status. |
| `openssh-server-restart.ps1` | Checks if the `sshd` service is running. If running, restarts it. If not running, notifies the user to start it first instead of restarting. |
| `openssh-server-status.ps1` | Reports the current status of the `sshd` service. |

### Connecting

| Script | Purpose |
|---|---|
| `openssh-client-connect.ps1` | Template script containing the `ssh username@ip_address` command. Edit the username and IP address before running. |

### Key Distribution

| Script | Purpose |
|---|---|
| `openssh-client-show-pubkey.ps1` | Displays the contents of the local public key (`id_ed25519.pub`) so it can be copied and pasted into a remote server's `authorized_keys` file. Does not transfer anything itself. |
| `openssh-server-addkey-local.ps1` | Adds this user's own public key to their local `authorized_keys` file (always the standard per-user file, not `administrators_authorized_keys`), so this account can SSH into this machine. Skips if the key is already present. Sets restrictive ACLs on the file afterward, since `sshd` rejects loosely-permissioned `authorized_keys` files. |
| `openssh-server-addkey-remote.ps1` | Adds an **arbitrary** public key (e.g. copied over from another machine) to this machine. Takes the path to a `.pub` file as a parameter, then asks interactively whether to add it to the standard user's `authorized_keys` or to `administrators_authorized_keys`. Sets restrictive ACLs afterward. Use this to build a mesh of machines that can all SSH into each other. |

### Backup

| Script | Purpose |
|---|---|
| `openssh-server-backup-config.ps1` | Copies the entire `C:\ProgramData\ssh\` folder (config, host keys, `administrators_authorized_keys`) to a timestamped backup folder. Run before upgrading, reconfiguring, or uninstalling the server. |

### Combined Setup

| Script | Purpose |
|---|---|
| `openssh-setup-all.ps1` | Runs the full first-time setup in order: installs, configures, and starts the OpenSSH server; sets PowerShell as the default SSH shell; installs the OpenSSH client; configures and starts ssh-agent. Calls the individual scripts above rather than duplicating their logic — must be run from the same folder as the other scripts. |

---

## Server Configuration

### Where the server configuration files live

| File | Path | Purpose |
|---|---|---|
| Main server config | `C:\ProgramData\ssh\sshd_config` | Controls how the SSH server behaves (ports, authentication methods, logging, etc.) |
| Host keys | `C:\ProgramData\ssh\ssh_host_*` | The server's own identity keys, generated automatically on install. |
| Authorized keys (standard users) | `C:\Users\<username>\.ssh\authorized_keys` | Public keys allowed to log in as that specific user. |
| Authorized keys (administrators) | `C:\ProgramData\ssh\administrators_authorized_keys` | Used **instead of** the per-user file for any account that is a member of the local Administrators group. |

> **Important:** for accounts in the local Administrators group, Windows ignores `C:\Users\<username>\.ssh\authorized_keys` entirely and only reads `administrators_authorized_keys`. This file requires restricted ACLs (only `Administrators` and `SYSTEM`) or the server will reject it.

### What goes into `sshd_config`

`sshd_config` is a plain-text file, one setting per line, in the form `Keyword Value`. Lines starting with `#` are comments.

#### Example file

```text
# Network
Port 22
AddressFamily any
ListenAddress 0.0.0.0

# Authentication
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
AuthorizedKeysFile	.ssh/authorized_keys

# Logging
SyslogFacility AUTH
LogLevel INFO

# Subsystems
Subsystem	sftp	sftp-server.exe

# Misc
PrintMotd no
```

#### Explanation of each setting

| Setting | Explanation |
|---|---|
| `Port 22` | The TCP port the server listens on. Default is 22; change only if you have a reason to (e.g. avoiding scans on the default port). |
| `AddressFamily any` | Which IP protocol families to accept connections on. `any` allows both IPv4 and IPv6; can be restricted to `inet` (IPv4 only) or `inet6` (IPv6 only). |
| `ListenAddress 0.0.0.0` | Which local network interface(s) to bind to. `0.0.0.0` means listen on all available interfaces. |
| `PubkeyAuthentication yes` | Allows clients to authenticate using SSH key pairs instead of a password. Recommended to keep `yes`. |
| `PasswordAuthentication no` | Disables logging in with just a username and password. Setting this to `no` (after key-based auth is confirmed working) significantly reduces brute-force attack risk. |
| `PermitEmptyPasswords no` | Refuses login for any account that has a blank password, regardless of `PasswordAuthentication`. Should always be `no`. |
| `AuthorizedKeysFile .ssh/authorized_keys` | Path (relative to the user's home directory) where the server looks for that user's allowed public keys. |
| `SyslogFacility AUTH` | Categorizes SSH log messages under the "AUTH" logging facility, used by Windows Event Log on this platform. |
| `LogLevel INFO` | How much detail is logged. Useful values: `INFO` (normal), `VERBOSE`, `DEBUG`, `DEBUG3` (very detailed, for troubleshooting). |
| `Subsystem sftp sftp-server.exe` | Registers the SFTP subsystem so clients can transfer files (via `sftp` or `scp`), not just open shell sessions. |
| `PrintMotd no` | Whether to display a "message of the day" banner on login. Usually left `no` on Windows since there's no MOTD file by default. |

After changing `sshd_config`, the service must be restarted for changes to take effect — use `openssh-server-restart.ps1`.

### Default shell and administrative access

By default, incoming SSH sessions on Windows land in `cmd.exe`. Use `openssh-server-set-default-shell.ps1` to switch this to PowerShell.

There is no separate elevation step for SSH sessions — a UAC consent prompt has no desktop to display on over SSH. Instead:

- If the connecting account is a member of the local **Administrators** group (and therefore authenticated via `administrators_authorized_keys`), its SSH session starts **already elevated** — no prompt, no extra steps.
- If the connecting account is a **standard user** (authenticated via the per-user `authorized_keys`), its SSH session runs with standard, non-elevated rights, exactly as expected.

In other words: whether an SSH session can do administrative work is determined entirely by **which account's key was used to log in**, not by anything configured during the session itself. To give an account administrative access to a machine, its public key needs to be in that machine's `administrators_authorized_keys` (see `openssh-server-addkey-remote.ps1`), not its per-user `authorized_keys`.

---

## Client Configuration

### Where the client configuration files live

| File | Path | Purpose |
|---|---|---|
| Per-user client config | `C:\Users\<username>\.ssh\config` | Defines connection shortcuts and default options for outgoing SSH connections from this user account. |
| System-wide client config | `C:\ProgramData\ssh\ssh_config` | Same purpose as above, but applies to all users on the machine unless overridden by their personal config. |
| Known hosts | `C:\Users\<username>\.ssh\known_hosts` | Stores the fingerprints of remote servers this client has previously connected to, to detect unexpected changes (e.g. spoofing). Populated automatically as you connect to new hosts — not manually configured upfront. |
| Private/public key pair | `C:\Users\<username>\.ssh\id_ed25519` and `id_ed25519.pub` | The client's own identity for key-based authentication. Generated by `openssh-client-keygen.ps1`. |

### What goes into the client `config` file

The client config uses the same `Keyword Value` syntax as the server, but is organized into `Host` blocks — each block applies only to connections matching that host alias or pattern.

#### Example file

```text
Host myserver
    HostName 192.168.1.50
    User myuser
    Port 22
    IdentityFile ~/.ssh/id_ed25519

Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

#### Explanation of each setting

| Setting | Explanation |
|---|---|
| `Host myserver` | Defines an alias. Once set up, running `ssh myserver` applies all settings below it without needing to type the full connection details. |
| `HostName 192.168.1.50` | The actual address (IP or domain name) to connect to when this alias is used. |
| `User myuser` | The username to log in as, so you don't have to type `user@host` every time. |
| `Port 22` | The port to connect to on the remote server. Only needed if the server doesn't use the default port 22. |
| `IdentityFile ~/.ssh/id_ed25519` | Which private key to use for this connection, useful if you have multiple key pairs for different servers. |
| `Host *` | A wildcard block that applies to **all** connections, regardless of alias — typically placed at the end of the file as a set of defaults. |
| `ServerAliveInterval 60` | How often (in seconds) the client sends a "keep-alive" signal to the server, to prevent the connection from being dropped due to inactivity. |
| `ServerAliveCountMax 3` | How many keep-alive signals can go unanswered before the client gives up and closes the connection. |

---

## Private and Public Keys Generation

The script `openssh-client-keygen.ps1` generates an ed25519 key pair without a passphrase (unattended).
For other key types or with a passphrase, run ssh-keygen manually using oneof the patterns below instead of this script:

RSA, without passphrase:

```
ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\id_rsa" -N '""'
```

RSA, with passphrase (omit -N to be prompted interactively):

```
ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\id_rsa"
```

ed25519, without passphrase (same as this script):

```
ssh-keygen -t ed25519 -f "$HOME\.ssh\id_ed25519" -N '""'
```

ed25519, with passphrase (omit -N to be prompted interactively):

```
ssh-keygen -t ed25519 -f "$HOME\.ssh\id_ed25519"
```

Note: -b 4096 sets the RSA key length in bits; ed25519 has a fixed key length and does not use -b. Omitting -N lets ssh-keygen prompt you to type (and confirm) a passphrase interactively instead of generating one with no passphrase.

Use a passphrase when...

* The key lives on a normal workstation or laptop — anything that could be lost, stolen, or accessed by someone else (family member, coworker, attacker with malware). Without a passphrase, anyone who gets a copy of your private key file can use it immediately, no second factor needed.
* The key is used for interactive, human-initiated logins — you sitting at a terminal typing ssh myserver once in a while. The minor friction of typing a passphrase is a small cost for a real security benefit, especially since ssh-agent lets you unlock it once per session.
* The key grants access to anything sensitive — production servers, financial systems, anything where unauthorized access would actually hurt.
* Compliance or organizational policy requires it — many corporate security policies mandate passphrase-protected keys.

Skip the passphrase when...

* The key is used for unattended automation — a script, scheduled task, CI/CD pipeline, or cron-job-equivalent that needs to connect with no human present to type anything. A passphrase-protected key can't be unlocked by a script unless you build in some other secrets-handling mechanism (and at that point, you've usually just moved the secret somewhere else).
* The key lives on a server-to-server connection where the "client" is itself a hardened, access-controlled machine — e.g. a backup server pulling from another server nightly. The security boundary is the server's own access controls, not the key's passphrase.
* You're doing local testing/throwaway work — a VM you'll destroy in an hour, a sandbox environment with nothing sensitive on it.

The middle ground: passphrase + ssh-agent

This is what most security-conscious people actually do day to day: use a passphrase, but load the key into ssh-agent (or Windows' equivalent, ssh-agent service / Pageant) once per login session. You type the passphrase once, and every subsequent ssh connection in that session reuses the unlocked key — no repeated typing, but the key on disk is still encrypted at rest.

---

## SSH Agent

`ssh-agent` is a background service that holds decrypted private keys in memory for the duration of a session. It lets you unlock a passphrase-protected key once (via `ssh-add`) instead of typing the passphrase every time you connect.

- It ships as part of the OpenSSH Client install, but its Windows service is **Disabled** by default — it must be explicitly enabled before it can be started. This is why a separate configuration script exists for it (`openssh-agent-configuration.ps1`), distinct from the start/stop/restart/status scripts.
- It is most useful for keys protected with a passphrase. For unattended, no-passphrase keys (like the one `openssh-client-keygen.ps1` generates by default), `ssh-agent` is optional since there's no passphrase to cache.
- Keys are added to the agent with `ssh-add` (wrapped by `openssh-agent-addkey.ps1`) and listed with `ssh-add -l`.
- Keys held by the agent are cleared when the service stops or the machine restarts; they need to be re-added afterward.

---

## Execution Policy

### "Execution of scripts is disabled on this system"

Example error:

```
.\openssh-server-installation.ps1
.\openssh-server-installation.ps1 : Die Datei "C:\...\openssh-server-installation.ps1" kann nicht geladen werden, da die
Ausführung von Skripts auf diesem System deaktiviert ist. Weitere Informationen finden Sie unter "about_Execution_Policies"
(https:/go.microsoft.com/fwlink/?LinkID=135170).
    + CategoryInfo          : Sicherheitsfehler: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

This means the execution policy is blocking scripts entirely (e.g. the default `Restricted` policy). Fix with one of:

```powershell
# Enable for the current session only:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Enable persistently for your user account (recommended):
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

To see which policy scope is actually in effect (useful if a managed/Pro machine has a stricter policy set centrally that a per-user change can't override):

```powershell
Get-ExecutionPolicy -List
```

If `MachinePolicy` or `UserPolicy` shows anything other than `Undefined`, that scope was set centrally (Group Policy or MDM) and overrides any `CurrentUser`/`LocalMachine` setting — it can't be changed with `Set-ExecutionPolicy` from a normal account.

### "File is not digitally signed" even under RemoteSigned

If the error specifically says the file **is not digitally signed** (rather than "running scripts is disabled"), and `Get-ExecutionPolicy -List` shows `RemoteSigned` is active, the script file itself is likely flagged as having been downloaded from the internet — this happens automatically when a file arrives via browser download, certain USB transfers, or extraction from a downloaded zip. `RemoteSigned` treats such files as "remote" and blocks them unless signed, even though they're sitting on local disk.

Check for the flag:

```powershell
Get-Item .\scriptname.ps1 -Stream Zone.Identifier -ErrorAction SilentlyContinue
```

If this returns a result (rather than nothing), remove the flag:

```powershell
# Single file:
Unblock-File -Path .\scriptname.ps1

# All scripts in the current folder at once:
Get-ChildItem -Path . -Filter *.ps1 | Unblock-File
```

---

## Planned / Not Yet Created

- Scripts to edit `sshd_config` directly (currently configuration of this file is manual).

## GNU Free Documentation License

Version 1.3, 3 November 2008

Copyright (C) 2000, 2001, 2002, 2007, 2008 Free Software Foundation,
Inc. <https://fsf.org/>

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

## 0. PREAMBLE

The purpose of this License is to make a manual, textbook, or other
functional and useful document "free" in the sense of freedom: to
assure everyone the effective freedom to copy and redistribute it,
with or without modifying it, either commercially or noncommercially.
Secondarily, this License preserves for the author and publisher a way
to get credit for their work, while not being considered responsible
for modifications made by others.

This License is a kind of "copyleft", which means that derivative
works of the document must themselves be free in the same sense. It
complements the GNU General Public License, which is a copyleft
license designed for free software.

We have designed this License in order to use it for manuals for free
software, because free software needs free documentation: a free
program should come with manuals providing the same freedoms that the
software does. But this License is not limited to software manuals; it
can be used for any textual work, regardless of subject matter or
whether it is published as a printed book. We recommend this License
principally for works whose purpose is instruction or reference.

## 1. APPLICABILITY AND DEFINITIONS

This License applies to any manual or other work, in any medium, that
contains a notice placed by the copyright holder saying it can be
distributed under the terms of this License. Such a notice grants a
world-wide, royalty-free license, unlimited in duration, to use that
work under the conditions stated herein. The "Document", below, refers
to any such manual or work. Any member of the public is a licensee,
and is addressed as "you". You accept the license if you copy, modify
or distribute the work in a way requiring permission under copyright
law.

A "Modified Version" of the Document means any work containing the
Document or a portion of it, either copied verbatim, or with
modifications and/or translated into another language.

A "Secondary Section" is a named appendix or a front-matter section of
the Document that deals exclusively with the relationship of the
publishers or authors of the Document to the Document's overall
subject (or to related matters) and contains nothing that could fall
directly within that overall subject. (Thus, if the Document is in
part a textbook of mathematics, a Secondary Section may not explain
any mathematics.) The relationship could be a matter of historical
connection with the subject or with related matters, or of legal,
commercial, philosophical, ethical or political position regarding
them.

The "Invariant Sections" are certain Secondary Sections whose titles
are designated, as being those of Invariant Sections, in the notice
that says that the Document is released under this License. If a
section does not fit the above definition of Secondary then it is not
allowed to be designated as Invariant. The Document may contain zero
Invariant Sections. If the Document does not identify any Invariant
Sections then there are none.

The "Cover Texts" are certain short passages of text that are listed,
as Front-Cover Texts or Back-Cover Texts, in the notice that says that
the Document is released under this License. A Front-Cover Text may be
at most 5 words, and a Back-Cover Text may be at most 25 words.

A "Transparent" copy of the Document means a machine-readable copy,
represented in a format whose specification is available to the
general public, that is suitable for revising the document
straightforwardly with generic text editors or (for images composed of
pixels) generic paint programs or (for drawings) some widely available
drawing editor, and that is suitable for input to text formatters or
for automatic translation to a variety of formats suitable for input
to text formatters. A copy made in an otherwise Transparent file
format whose markup, or absence of markup, has been arranged to thwart
or discourage subsequent modification by readers is not Transparent.
An image format is not Transparent if used for any substantial amount
of text. A copy that is not "Transparent" is called "Opaque".

Examples of suitable formats for Transparent copies include plain
ASCII without markup, Texinfo input format, LaTeX input format, SGML
or XML using a publicly available DTD, and standard-conforming simple
HTML, PostScript or PDF designed for human modification. Examples of
transparent image formats include PNG, XCF and JPG. Opaque formats
include proprietary formats that can be read and edited only by
proprietary word processors, SGML or XML for which the DTD and/or
processing tools are not generally available, and the
machine-generated HTML, PostScript or PDF produced by some word
processors for output purposes only.

The "Title Page" means, for a printed book, the title page itself,
plus such following pages as are needed to hold, legibly, the material
this License requires to appear in the title page. For works in
formats which do not have any title page as such, "Title Page" means
the text near the most prominent appearance of the work's title,
preceding the beginning of the body of the text.

The "publisher" means any person or entity that distributes copies of
the Document to the public.

A section "Entitled XYZ" means a named subunit of the Document whose
title either is precisely XYZ or contains XYZ in parentheses following
text that translates XYZ in another language. (Here XYZ stands for a
specific section name mentioned below, such as "Acknowledgements",
"Dedications", "Endorsements", or "History".) To "Preserve the Title"
of such a section when you modify the Document means that it remains a
section "Entitled XYZ" according to this definition.

The Document may include Warranty Disclaimers next to the notice which
states that this License applies to the Document. These Warranty
Disclaimers are considered to be included by reference in this
License, but only as regards disclaiming warranties: any other
implication that these Warranty Disclaimers may have is void and has
no effect on the meaning of this License.

## 2. VERBATIM COPYING

You may copy and distribute the Document in any medium, either
commercially or noncommercially, provided that this License, the
copyright notices, and the license notice saying this License applies
to the Document are reproduced in all copies, and that you add no
other conditions whatsoever to those of this License. You may not use
technical measures to obstruct or control the reading or further
copying of the copies you make or distribute. However, you may accept
compensation in exchange for copies. If you distribute a large enough
number of copies you must also follow the conditions in section 3.

You may also lend copies, under the same conditions stated above, and
you may publicly display copies.

## 3. COPYING IN QUANTITY

If you publish printed copies (or copies in media that commonly have
printed covers) of the Document, numbering more than 100, and the
Document's license notice requires Cover Texts, you must enclose the
copies in covers that carry, clearly and legibly, all these Cover
Texts: Front-Cover Texts on the front cover, and Back-Cover Texts on
the back cover. Both covers must also clearly and legibly identify you
as the publisher of these copies. The front cover must present the
full title with all words of the title equally prominent and visible.
You may add other material on the covers in addition. Copying with
changes limited to the covers, as long as they preserve the title of
the Document and satisfy these conditions, can be treated as verbatim
copying in other respects.

If the required texts for either cover are too voluminous to fit
legibly, you should put the first ones listed (as many as fit
reasonably) on the actual cover, and continue the rest onto adjacent
pages.

If you publish or distribute Opaque copies of the Document numbering
more than 100, you must either include a machine-readable Transparent
copy along with each Opaque copy, or state in or with each Opaque copy
a computer-network location from which the general network-using
public has access to download using public-standard network protocols
a complete Transparent copy of the Document, free of added material.
If you use the latter option, you must take reasonably prudent steps,
when you begin distribution of Opaque copies in quantity, to ensure
that this Transparent copy will remain thus accessible at the stated
location until at least one year after the last time you distribute an
Opaque copy (directly or through your agents or retailers) of that
edition to the public.

It is requested, but not required, that you contact the authors of the
Document well before redistributing any large number of copies, to
give them a chance to provide you with an updated version of the
Document.

## 4. MODIFICATIONS

You may copy and distribute a Modified Version of the Document under
the conditions of sections 2 and 3 above, provided that you release
the Modified Version under precisely this License, with the Modified
Version filling the role of the Document, thus licensing distribution
and modification of the Modified Version to whoever possesses a copy
of it. In addition, you must do these things in the Modified Version:

-   A. Use in the Title Page (and on the covers, if any) a title
    distinct from that of the Document, and from those of previous
    versions (which should, if there were any, be listed in the
    History section of the Document). You may use the same title as a
    previous version if the original publisher of that version
    gives permission.
-   B. List on the Title Page, as authors, one or more persons or
    entities responsible for authorship of the modifications in the
    Modified Version, together with at least five of the principal
    authors of the Document (all of its principal authors, if it has
    fewer than five), unless they release you from this requirement.
-   C. State on the Title page the name of the publisher of the
    Modified Version, as the publisher.
-   D. Preserve all the copyright notices of the Document.
-   E. Add an appropriate copyright notice for your modifications
    adjacent to the other copyright notices.
-   F. Include, immediately after the copyright notices, a license
    notice giving the public permission to use the Modified Version
    under the terms of this License, in the form shown in the
    Addendum below.
-   G. Preserve in that license notice the full lists of Invariant
    Sections and required Cover Texts given in the Document's
    license notice.
-   H. Include an unaltered copy of this License.
-   I. Preserve the section Entitled "History", Preserve its Title,
    and add to it an item stating at least the title, year, new
    authors, and publisher of the Modified Version as given on the
    Title Page. If there is no section Entitled "History" in the
    Document, create one stating the title, year, authors, and
    publisher of the Document as given on its Title Page, then add an
    item describing the Modified Version as stated in the
    previous sentence.
-   J. Preserve the network location, if any, given in the Document
    for public access to a Transparent copy of the Document, and
    likewise the network locations given in the Document for previous
    versions it was based on. These may be placed in the "History"
    section. You may omit a network location for a work that was
    published at least four years before the Document itself, or if
    the original publisher of the version it refers to
    gives permission.
-   K. For any section Entitled "Acknowledgements" or "Dedications",
    Preserve the Title of the section, and preserve in the section all
    the substance and tone of each of the contributor acknowledgements
    and/or dedications given therein.
-   L. Preserve all the Invariant Sections of the Document, unaltered
    in their text and in their titles. Section numbers or the
    equivalent are not considered part of the section titles.
-   M. Delete any section Entitled "Endorsements". Such a section may
    not be included in the Modified Version.
-   N. Do not retitle any existing section to be Entitled
    "Endorsements" or to conflict in title with any Invariant Section.
-   O. Preserve any Warranty Disclaimers.

If the Modified Version includes new front-matter sections or
appendices that qualify as Secondary Sections and contain no material
copied from the Document, you may at your option designate some or all
of these sections as invariant. To do this, add their titles to the
list of Invariant Sections in the Modified Version's license notice.
These titles must be distinct from any other section titles.

You may add a section Entitled "Endorsements", provided it contains
nothing but endorsements of your Modified Version by various
parties—for example, statements of peer review or that the text has
been approved by an organization as the authoritative definition of a
standard.

You may add a passage of up to five words as a Front-Cover Text, and a
passage of up to 25 words as a Back-Cover Text, to the end of the list
of Cover Texts in the Modified Version. Only one passage of
Front-Cover Text and one of Back-Cover Text may be added by (or
through arrangements made by) any one entity. If the Document already
includes a cover text for the same cover, previously added by you or
by arrangement made by the same entity you are acting on behalf of,
you may not add another; but you may replace the old one, on explicit
permission from the previous publisher that added the old one.

The author(s) and publisher(s) of the Document do not by this License
give permission to use their names for publicity for or to assert or
imply endorsement of any Modified Version.

## 5. COMBINING DOCUMENTS

You may combine the Document with other documents released under this
License, under the terms defined in section 4 above for modified
versions, provided that you include in the combination all of the
Invariant Sections of all of the original documents, unmodified, and
list them all as Invariant Sections of your combined work in its
license notice, and that you preserve all their Warranty Disclaimers.

The combined work need only contain one copy of this License, and
multiple identical Invariant Sections may be replaced with a single
copy. If there are multiple Invariant Sections with the same name but
different contents, make the title of each such section unique by
adding at the end of it, in parentheses, the name of the original
author or publisher of that section if known, or else a unique number.
Make the same adjustment to the section titles in the list of
Invariant Sections in the license notice of the combined work.

In the combination, you must combine any sections Entitled "History"
in the various original documents, forming one section Entitled
"History"; likewise combine any sections Entitled "Acknowledgements",
and any sections Entitled "Dedications". You must delete all sections
Entitled "Endorsements".

## 6. COLLECTIONS OF DOCUMENTS

You may make a collection consisting of the Document and other
documents released under this License, and replace the individual
copies of this License in the various documents with a single copy
that is included in the collection, provided that you follow the rules
of this License for verbatim copying of each of the documents in all
other respects.

You may extract a single document from such a collection, and
distribute it individually under this License, provided you insert a
copy of this License into the extracted document, and follow this
License in all other respects regarding verbatim copying of that
document.

## 7. AGGREGATION WITH INDEPENDENT WORKS

A compilation of the Document or its derivatives with other separate
and independent documents or works, in or on a volume of a storage or
distribution medium, is called an "aggregate" if the copyright
resulting from the compilation is not used to limit the legal rights
of the compilation's users beyond what the individual works permit.
When the Document is included in an aggregate, this License does not
apply to the other works in the aggregate which are not themselves
derivative works of the Document.

If the Cover Text requirement of section 3 is applicable to these
copies of the Document, then if the Document is less than one half of
the entire aggregate, the Document's Cover Texts may be placed on
covers that bracket the Document within the aggregate, or the
electronic equivalent of covers if the Document is in electronic form.
Otherwise they must appear on printed covers that bracket the whole
aggregate.

## 8. TRANSLATION

Translation is considered a kind of modification, so you may
distribute translations of the Document under the terms of section 4.
Replacing Invariant Sections with translations requires special
permission from their copyright holders, but you may include
translations of some or all Invariant Sections in addition to the
original versions of these Invariant Sections. You may include a
translation of this License, and all the license notices in the
Document, and any Warranty Disclaimers, provided that you also include
the original English version of this License and the original versions
of those notices and disclaimers. In case of a disagreement between
the translation and the original version of this License or a notice
or disclaimer, the original version will prevail.

If a section in the Document is Entitled "Acknowledgements",
"Dedications", or "History", the requirement (section 4) to Preserve
its Title (section 1) will typically require changing the actual
title.

## 9. TERMINATION

You may not copy, modify, sublicense, or distribute the Document
except as expressly provided under this License. Any attempt otherwise
to copy, modify, sublicense, or distribute it is void, and will
automatically terminate your rights under this License.

However, if you cease all violation of this License, then your license
from a particular copyright holder is reinstated (a) provisionally,
unless and until the copyright holder explicitly and finally
terminates your license, and (b) permanently, if the copyright holder
fails to notify you of the violation by some reasonable means prior to
60 days after the cessation.

Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License. If your rights have been terminated and not permanently
reinstated, receipt of a copy of some or all of the same material does
not give you any rights to use it.

## 10. FUTURE REVISIONS OF THIS LICENSE

The Free Software Foundation may publish new, revised versions of the
GNU Free Documentation License from time to time. Such new versions
will be similar in spirit to the present version, but may differ in
detail to address new problems or concerns. See
<https://www.gnu.org/licenses/>.

Each version of the License is given a distinguishing version number.
If the Document specifies that a particular numbered version of this
License "or any later version" applies to it, you have the option of
following the terms and conditions either of that specified version or
of any later version that has been published (not as a draft) by the
Free Software Foundation. If the Document does not specify a version
number of this License, you may choose any version ever published (not
as a draft) by the Free Software Foundation. If the Document specifies
that a proxy can decide which future versions of this License can be
used, that proxy's public statement of acceptance of a version
permanently authorizes you to choose that version for the Document.

## 11. RELICENSING

"Massive Multiauthor Collaboration Site" (or "MMC Site") means any
World Wide Web server that publishes copyrightable works and also
provides prominent facilities for anybody to edit those works. A
public wiki that anybody can edit is an example of such a server. A
"Massive Multiauthor Collaboration" (or "MMC") contained in the site
means any set of copyrightable works thus published on the MMC site.

"CC-BY-SA" means the Creative Commons Attribution-Share Alike 3.0
license published by Creative Commons Corporation, a not-for-profit
corporation with a principal place of business in San Francisco,
California, as well as future copyleft versions of that license
published by that same organization.

"Incorporate" means to publish or republish a Document, in whole or in
part, as part of another Document.

An MMC is "eligible for relicensing" if it is licensed under this
License, and if all works that were first published under this License
somewhere other than this MMC, and subsequently incorporated in whole
or in part into the MMC, (1) had no cover texts or invariant sections,
and (2) were thus incorporated prior to November 1, 2008.

The operator of an MMC Site may republish an MMC contained in the site
under CC-BY-SA on the same site at any time before August 1, 2009,
provided the MMC is eligible for relicensing.

## ADDENDUM: How to use this License for your documents

To use this License in a document you have written, include a copy of
the License in the document and put the following copyright and
license notices just after the title page:

        Copyright (C)  YEAR  YOUR NAME.
        Permission is granted to copy, distribute and/or modify this document
        under the terms of the GNU Free Documentation License, Version 1.3
        or any later version published by the Free Software Foundation;
        with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
        A copy of the license is included in the section entitled "GNU
        Free Documentation License".

If you have Invariant Sections, Front-Cover Texts and Back-Cover
Texts, replace the "with … Texts." line with this:

        with the Invariant Sections being LIST THEIR TITLES, with the
        Front-Cover Texts being LIST, and with the Back-Cover Texts being LIST.

If you have Invariant Sections without Cover Texts, or some other
combination of the three, merge those two alternatives to suit the
situation.

If your document contains nontrivial examples of program code, we
recommend releasing these examples in parallel under your choice of
free software license, such as the GNU General Public License, to
permit their use in free software.
