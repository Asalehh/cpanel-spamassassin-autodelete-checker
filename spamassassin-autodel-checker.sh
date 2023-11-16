#!/bin/bash
# Find cPanel accounts with SpamAssassin Spam Auto-delete enabled
# this script allows auto disabling Auto-delete option for all accounts
# Works only on RHEL 7/8/9

# JQ Package is required to parse JSON
# Function to check if jq is installed and install it if needed
check_and_install_jq() {
    if ! command -v jq &>/dev/null; then
        echo "[INFO] jq is not installed. Installing..."
        sudo yum -y install jq
        echo
    else
        echo "[INFO] jq package is already installed. Proceeding..."
        echo
    fi
}

# Check and install jq
check_and_install_jq

# Function to make the API call and display the result for users with spam_auto_delete value of 1
get_spam_settings() {
    username=$1
    minimal_flag=$2
    auto_disable_flag=$3

    # Exclude "system" and "nobody" users
    if [[ "$username" != "system" && "$username" != "nobody" ]]; then

        # Make the cPanel API call
        api_response=$(uapi --output=jsonpretty \
                            --user="$username" \
                            Email \
                            get_spam_settings)

        # Extract the value of "spam_auto_delete" from the API response
        spam_auto_delete_value=$(echo "$api_response" | jq -r '.result.data.spam_auto_delete')

        # Check if the value is 1 and display the result
        if [ "$spam_auto_delete_value" == "1" ]; then
            echo "--- Matched Accounts ---"
            # if --minimal flag is used
            if [ -n "$minimal_flag" ]; then
                echo "$username"
            else
                echo "Username: $username"
                echo "spam_auto_delete: $spam_auto_delete_value"
                echo "------------------------"
            fi


            # Check if the --auto-disable flag is used
            if [ -n "$auto_disable_flag" ]; then
                echo 
                echo "[INFO] $username - Disabling SpamAssassin auto-delete ..."

                # Run the uapi command and capture the output
                api_response=$(uapi --output=jsonpretty --user="$username" Email disable_spam_autodelete 2>&1)

                # Check the spam_auto_delete value in the API response
                spam_auto_delete_status=$(echo "$api_response" | jq -r '.result.data.spam_auto_delete')

                if [ "$spam_auto_delete_status" == "0" ]; then
                    echo "[SUCCESS] $username - SpamAssassin auto-delete DISABLED"
                else
                    echo "[**FAIL**] $username - SpamAssassin auto-delete not changed"
                fi

                echo "------------------------"
            fi

            return 0  # Match found
        fi
    fi
    return 1  # No match found
}

# List all cPanel usernames
usernames=$(ls /var/cpanel/users/ | sed 's/\.//')

# Check for the --minimal and --auto-disable flags
minimal_flag=""
auto_disable_flag=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --minimal)
            minimal_flag="--minimal"
            ;;
        --auto-disable)
            auto_disable_flag="--auto-disable"
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Flag to track if any matching users were found
any_matches=false

# Inform the user about the process
echo "[INFO] Checking cPanel accounts for SpamAssassin settings..."
echo

# Loop through each username and call the function
for user in $usernames; do
    if get_spam_settings "$user" "$minimal_flag" "$auto_disable_flag"; then
        any_matches=true
    fi
done

# Display a message if no matching users were found
if [ "$any_matches" == "false" ]; then
    echo 
    echo "[INFO] No cPanel accounts with SpamAssassin auto-delete enabled found."
    echo
else
    echo 
    echo "[DONE] Finished checking cPanel accounts."
    echo
fi
