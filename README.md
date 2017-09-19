# ldapaudit


This script queries the local Metasploit Database and extracts common LDAP host and port information. It then connects to the LDAP server(s) and queries the DN information and displays it. The script also attempts an anonymous BIND and if successfull attempts to query user authentication data such as historical passwords, if accounts are locked out, last password change, etc. This information is available by default on OpenLDAP installations.

The script supports LDAP and LDAPS, and makes a change to the /etc/ldap/ldap.conf file to get LDAPS working on the client.

Script written and tested on Kali Linux.


To use the script:

1. If you haven't already initialized your Metasploit database. Run service postgresql start and then msfdb init
2. Populate Metasploit with your host/port data by running msfconsole and then running db_import *.nessus and/or db_import *.xml to import Nessus or Nmap (XML) data. I assume no workspace is used in Metasploit. If you are using a workspace, edit the ldapaudit.rc file and add workspace <workspacename> as the first line
3. ./ldapaudit.rc
4. Look for any globs of data that come back which includes account information. If found, the line underneath the glob will be the command to run to get a cleaner looking copy.

This tool is very fast, it takes about .5-1 second per host check. 
