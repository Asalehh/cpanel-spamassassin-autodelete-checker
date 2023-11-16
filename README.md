# cpanel-spamassassin Auto-Delete Spam Checker
This script searches for cPanel accounts with SpamAssassin auto-delete Spam enabled and allows to disable this feature when the flag `--auto-disabled` is used.


#Usage
- Download the script
- change permission `chmod +x script.sh`
- execute `./script.sh`

#Optional flags
You can display all matched users in a minimal format by using `--minimal` flag.
Example: `./script.sh --minimal`

#Disable Auto-delete
You can disable Auto-delete for all matched users when using `--auto-disable` flag.
Example: `./script.sh --auto-disable`

> [!IMPORTANT]
> JQ package is required.
