# cpanel-spamassassin Auto-Delete Spam Checker
This script searches for cPanel accounts with SpamAssassin auto-delete Spam enabled and allows to disable this feature when the flag `--auto-disabled` is used.

It's an attempt to automate the process explained here: https://support.cpanel.net/hc/en-us/articles/360052927113?input_string=spamassassin+auto-delete

### Usage
- Download the script
- Make it executable `chmod +x script.sh`
- execute `./script.sh`

### Optional flags
You can display all matched users in a minimal format by using `--minimal` flag.
Example: `./script.sh --minimal`

### Disable Auto-delete
You can disable Auto-delete for all matched users when using `--auto-disable` flag.
Example: `./script.sh --auto-disable`

> [!IMPORTANT]
> JQ package is required.
