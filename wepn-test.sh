#!/usr/bin/env bash
#
# COPYRIGHT (c) 2023 macromicro
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# DESCRIPTION: Master Script for VPN Admins
# AUTHOR: macromicro
# TELEGRAM GROUP: @wepn_group

#----------------------------------------------------------------------------------------------------------------------- vars
main_script_file="wepn-test.sh"
installed_version=""
latest_version=""

running_url=false
running_installed=false
running_locally=false

width=64

iranips=()
arvancloud_ips=()

global_menu_size=0
selected_menu=""
selected_menu_item=""
#----------------------------------------------------------------------------------------------------------------------- colors
break_string() {
  local str="$1"
  local words=($str)
  local line=""

  for ((i=0; i<${#words[@]}; i++)); do
    if (( ${#line} + ${#words[i]} + 1 <= $width )); then
      # add the next word to the current line.
      if [[ -z "$line" ]]; then
        line="${words[i]}"
      else
        line="$line ${words[i]}"
      fi
    else
      # output the current line and start a new one.
      echo "${line}"
      line="${words[i]}"
    fi
  done

  # output the final line, if there is one.
  if [[ -n "$line" ]]; then
    echo "${line}"
  fi
}

normal() {
  broken_text=$(break_string "$1")
  echo -e "\033[38;5;250m$broken_text\033[0m"
}

bold() {
  broken_text=$(break_string "$1")
  echo -e "\033[1m\033[97m$broken_text\033[0m"
}

green(){
  broken_text=$(break_string "$1")
  echo -e "\033[32m$broken_text\033[0m"
}
greenbold(){
  broken_text=$(break_string "$1")
  echo -e "\033[1m\033[32m$broken_text\033[0m"
}
greenbg(){
  broken_text=$(break_string "$1")
  echo -e "\033[42m\033[30m$broken_text\033[0m";
}

blue(){
  broken_text=$(break_string "$1")
  echo -e "\033[34m$broken_text\033[0m"
}
bluebold(){
  broken_text=$(break_string "$1")
  echo -e "\033[1m\033[34m$broken_text\033[0m"
}
bluebg(){
  broken_text=$(break_string "$1")
  echo -e "\033[44m\033[30m$broken_text\033[0m"
}

red(){
  broken_text=$(break_string "$1")
  echo -e "\033[31m$broken_text\033[0m"
}
redbold(){
  broken_text=$(break_string "$1")
  echo -e "\033[1m\033[31m$broken_text\033[0m"
}
redbg(){
  broken_text=$(break_string "$1")
  echo -e "\033[41m\033[30m$broken_text\033[0m"
}
#----------------------------------------------------------------------------------------------------------------------- set run mode
set_run_mode(){
  if [[ "$0" == /dev* ]]; then
    running_url=true
  #  echo "The script is being executed from a URL"
  elif [[ "$0" == "/usr/local/bin/wepn" ]]; then
    running_installed=true
  #  echo "The script is being executed locally"
  else
    running_locally=true
  #  echo "The script is being executed locally but not .wpn dir"
  fi
}
#----------------------------------------------------------------------------------------------------------------------- get latest version number
get_latest_version_number(){
  # Set the username and repository name
  USERNAME="elemen3"
  REPO_NAME="wepn"

  # Set the branch name and file path
  BRANCH_NAME="master"
  FILE_PATH="$main_script_file"

  # Get the timestamp of the last commit for the file
  TIMESTAMP=$(curl -s "https://api.github.com/repos/${USERNAME}/${REPO_NAME}/commits?path=${FILE_PATH}&sha=${BRANCH_NAME}&per_page=1" | grep -oE "\"date\": \"[^\"]+\"" | cut -d'"' -f4 | head -n1)

  if [ -n "$TIMESTAMP" ]; then

    if [[ "$(uname)" == "Darwin" ]]; then
      FORMATTED_DATETIME=$(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$TIMESTAMP" "+%Y.%m.%d.%H%M%S")
    else
      date -u -d "$TIMESTAMP" "+%Y.%m.%d.%H%M%S"
    fi
  fi

  echo "$FORMATTED_DATETIME"
}
#----------------------------------------------------------------------------------------------------------------------- install wepn
install_wepn(){

  mkdir -p "$HOME/.wepn"
  touch "$HOME/.wepn/settings"

  # not installed
  if ! test -f "/usr/local/bin/wepn"; then
      blue "Installing WePN..."
      sleep 0.5
      curl -s "https://raw.githubusercontent.com/elemen3/wepn/master/$main_script_file" -o /usr/local/bin/wepn
      chmod +x /usr/local/bin/wepn

      latest_version="$(get_latest_version_number)"
      echo "version=$latest_version" > "$HOME/.wepn/settings"

      echo
      blue "WePN is installed on your system."
      echo $(blue "From now on, simply issue") $(greenbold "wepn") $(blue " command to run the script.")
      echo

      bluebold "Press Enter to continue..."
      read -p ""

  # already installed and running via wepn cmd
  elif $running_installed ; then

    blue "Checking for updates..."
    installed_version=$(cat "$HOME/.wepn/settings" | grep version | awk '{split($0,a,"="); print a[2]}')
    latest_version="$(get_latest_version_number)"

    if [ -n "$latest_version" && -n "$installed_version" && "$installed_version" != "$latest_version" ]; then

      echo $(blue "You are running the outdated version (")$(redbold "$installed_version")$(blue ")!")
      echo $(blue "Installing the new version (")$(greenbold "$latest_version")$(blue ")...")
      sleep 0.5

      curl -s "https://raw.githubusercontent.com/elemen3/wepn/master/$main_script_file" -o /usr/local/bin/wepn
      chmod +x /usr/local/bin/wepn

      latest_version="$(get_latest_version_number)"
      sed -i.bak "s/version=.*/version=$latest_version/" "$HOME/.wepn/settings" && rm "$HOME/.wepn/settings.bak"

      bluebold "WePN is updated :)"

#    else
#      blue "WePN is UP-TO-DATE."
    fi

  fi
}
#----------------------------------------------------------------------------------------------------------------------- install wget and curl first
install_wget_and_curl(){

  echo "nameserver 1.1.1.1" > /etc/resolv.conf

    # Check if curl is installed
    if ! command -v curl &> /dev/null
    then
        blue "Installing curl..."
        sleep 0.5

        # Install curl using apt on Debian 11, Ubuntu 18.04, and Ubuntu 20.04
        if [ -x "$(command -v apt)" ]; then
            apt update &> /dev/null
            apt install curl -y &> /dev/null
        # Install curl using yum on CentOS 8
        elif [ -x "$(command -v yum)" ]; then
            yum update -y >/dev/null 2>&1
            yum install curl -y >/dev/null 2>&1
        else
            redbold "Unsupported distribution. Exiting..."
            fn_menu_4
        fi

    fi

    # Check if wget is installed
    if ! command -v wget &> /dev/null
    then
        blue "Installing wget..."
        sleep 0.5

        # Install wget using apt on Debian 11, Ubuntu 18.04, and Ubuntu 20.04
        if [ -x "$(command -v apt)" ]; then
            apt update &> /dev/null
            apt install wget -y &> /dev/null
        # Install wget using yum on CentOS 8
        elif [ -x "$(command -v yum)" ]; then
            yum update -y >/dev/null 2>&1
            yum install wget -y >/dev/null 2>&1
        else
            redbold "Unsupported distribution. Exiting..."
            fn_menu_4
        fi

    fi
}
#----------------------------------------------------------------------------------------------------------------------- install required packages
install_required_packages(){

  echo "nameserver 1.1.1.1" > /etc/resolv.conf

  # Check if iptables-save is installed
  if ! command -v iptables-save &> /dev/null
  then
      blue "Installing iptables..."
      sleep 0.5

      # Install iptables using apt on Debian 11, Ubuntu 18.04, and Ubuntu 20.04
      if [ -x "$(command -v apt)" ]; then
          apt update &> /dev/null
          apt install iptables -y &> /dev/null
      # Install iptables using yum on CentOS 8
      elif [ -x "$(command -v yum)" ]; then
          yum update -y >/dev/null 2>&1
          yum install iptables -y >/dev/null 2>&1
      else
          redbold "Unsupported distribution. Exiting..."
          fn_menu_4
      fi

  fi

  # Check if iptables-persistent is installed
  if ! (dpkg -s iptables-persistent >/dev/null 2>&1 || rpm -q iptables-services >/dev/null 2>&1);
  then
      blue "Installing iptables-persistent..."

      # Install iptables-persistent using apt on Debian 11, Ubuntu 18.04, and Ubuntu 20.04
      if [ -x "$(command -v apt)" ]; then
          apt update &> /dev/null
          echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
          echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
          echo "iptables-persistent iptables-persistent/autosave_v4 seen true" | debconf-set-selections
          echo "iptables-persistent iptables-persistent/autosave_v6 seen true" | debconf-set-selections
          apt install -y iptables-persistent &> /dev/null
      # Install iptables-persistent using yum on CentOS 8
      elif [ -x "$(command -v yum)" ]; then
          yum update -y >/dev/null 2>&1
          echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
          echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
          echo "iptables-persistent iptables-persistent/autosave_v4 seen true" | debconf-set-selections
          echo "iptables-persistent iptables-persistent/autosave_v6 seen true" | debconf-set-selections
          yum install iptables-persistent -y >/dev/null 2>&1
      else
          redbold "Unsupported distribution. Exiting..."
          fn_menu_4
      fi

  fi
}
#----------------------------------------------------------------------------------------------------------------------- load required data
load_iranips(){
  #normal "Loading the most up-to-date IP addresses..."
  blue "Loading Iran IP ranges..."
  sleep 0.5

  # URL of the text file to read
  url="https://raw.githubusercontent.com/elemen3/wepn/master/iran_ip_ranges.txt"

  # Read the file from the URL line by line
  while read -r line; do
    #Ignore blank lines and lines starting with #
    if [[ -n "$line" && "${line:0:1}" != "#" ]]; then
      # Add the current line to the array
      iranips+=("$line")
    fi
  done < <(curl -s "$url")
}
load_arvancloud_ips(){

  blue "Loading Arvancloud IP ranges..."
  sleep 0.5

  # URL of the text file to read
    url="https://www.arvancloud.ir/fa/ips.txt"

    # Read the file from the URL line by line
   while read line || [ -n "$line" ] ; do
      #Ignore blank lines and lines starting with #
      if [[ -n "$line" && "${line:0:1}" != "#" ]]; then
        # Add the current line to the array
        arvancloud_ips+=("$line")
      fi
    done < <(curl -s "$url")

    # set it manually
    if [[ ${#arvancloud_ips[@]} -eq 0 || " ${arvancloud_ips[*]} " =~ " <html " ]]; then
      arvancloud_ips=(
      185.143.232.0/22
      92.114.16.80/28
      2.146.0.0/28
      46.224.2.32/29
      83.123.255.56/31
      188.229.116.16/29
      164.138.128.28/31
      94.182.182.28/30
      185.17.115.176/30
      5.213.255.36/31
      185.228.238.0/28
      94.182.153.24/29
      94.101.182.0/27
      158.255.77.238/31
      81.12.28.16/29
      176.65.192.202/31
      2.144.3.128/28
      89.45.48.64/28
      37.32.16.0/27
      37.32.17.0/27
      37.32.18.0/27
      37.32.19.0/27
      185.215.232.0/22
      )
    fi

}
#----------------------------------------------------------------------------------------------------------------------- hide/show cursor
hide_cursor(){
  tput civis
}
show_cursor(){
  tput cnorm
}
#----------------------------------------------------------------------------------------------------------------------- progressbar
# normal
_show_progress() {
    local current=$1
    local total=$2
    local bar_size=$(($(tput cols) - 11))
    local progress=$((current * bar_size / total))
    local rest=$((bar_size - progress))
    local bar=$(printf "%${progress}s" | tr ' ' '#')
    local restbar=$(printf "%${rest}s")
    printf "[%s%s] %d%%" "$bar" "$restbar" $((current * 100 / total))
    printf "\r"
}
# blue bold
show_progress() {
    local current=$1
    local total=$2
    local bar_size=$(($width - 7))
    local progress=$((current * bar_size / total))
    local rest=$((bar_size - progress))
    local bar=$(printf "%${progress}s" | tr ' ' '#')
    local restbar=$(printf "%${rest}s")
    printf "\033[1;34m[%s%s]\033[0m \033[1;34m%d%%\033[0m" "$bar" "$restbar" $((current * 100 / total))
    printf "\r"
}
#----------------------------------------------------------------------------------------------------------------------- seperator
seperator(){
#  printf -v separator "%-${width}b" ""
  s="----------------------------------------------------------------"
  echo -e "\033[38;5;250m$s\033[0m"
#  echo -e "\033[38;5;250m${s// /-}\033[0m"
#  normal "${separator// /-}"
}
#----------------------------------------------------------------------------------------------------------------------- prepare screen
prepare_screen(){

  # get terminal default bg color
  #default_bg_color=$(echo "rgb:0a0a/1212/1e1e" | sed 's/rgb:\(..\)\(..\)\(..\)\/\(..\)\(..\)\(..\)/\1\2\3/g' | xxd -r -p | xxd -p -u -l 3 | tr '[:upper:]' '[:lower:]')
  #echo $default_bg_color

  # set terminal default foreground color
  echo -ne '\e]10;#a9a9a9\e\\'

  # set terminal default background color
  echo -ne '\e]11;#0a121e\e\\'
  #echo -ne '\e]10;\e\\'

  hide_cursor

  # Set up the trap to call the exit function when the script is interrupted
  trap fn_menu_4 INT
}
#----------------------------------------------------------------------------------------------------------------------- show headers
show_headers(){
  clear && printf '\e[3J'

  #logo
  if [ ! -f "$HOME/.wepn/logo" ]; then
    mkdir -p "$HOME/.wepn"
    wget -q https://raw.githubusercontent.com/elemen3/wepn/master/asset/wepn-logo-ascii.txt -O "$HOME/.wepn/logo"
  fi

  cat "$HOME/.wepn/logo"

  #header
  seperator
  echo -e "\e[1;37;48;5;21m                                                                \e[0m"
  echo -e "\e[1;37;48;5;20m                    [ WePN MASTER SCRIPT ]                      \e[0m"
  echo -e "\e[1;37;48;5;19m                      Author: macromicro                        \e[0m"
  echo -e "\e[1;37;48;5;18m                 Telegram Group: @wepn_group                    \e[0m"
  echo -e "\e[1;37;48;5;17m                                                                \e[0m"
  seperator
}
#----------------------------------------------------------------------------------------------------------------------- menu functions
#------------------------------------------------------------------------------------------------------- ssh

#------------------------------------------------------------------------------------------------------- block iran ips
view_existing_settings(){
#  iptables-save | grep -i "443"

  # Define the arrays
  rejected_ips=($(iptables-save | grep -- '--dport 443.*REJECT\>' | awk '{print $4}'))
  accepted_ips=($(iptables-save | grep -- '--dport 443.*ACCEPT\>' | awk '{print $4}'))

  # check if they are not epmty
  if [[ ${#rejected_ips[@]} -gt 0 || ${#accepted_ips[@]} -gt 0 ]]; then

      # Find the longest value in the arrays
      max_length=0
      for val in "${rejected_ips[@]}" "${accepted_ips[@]}"; do
        len=${#val}
        if ((len > max_length)); then
          max_length=$len
        fi
      done

      # Print the top border line
      printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"

      # Print the header row
#      printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "IP RANGE" "STATUS"
      printf "|\033[1m %-${max_length}s\033[0m | \033[1;37m%-7s\033[0m |\n" "IP RANGE" "STATUS"


      # Print the border line below the header row
      printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"


      if [[ ${#rejected_ips[@]} -gt 0 ]]; then
          # Print the rejected_ips in a grid
          for val in "${rejected_ips[@]}"; do
            printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
            printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
          done
      fi
      if [[ ${#accepted_ips[@]} -gt 0 ]]; then
          # Print the accepted_ips in a grid
          for val in "${accepted_ips[@]}"; do
            printf "| %-${max_length}s | \033[1;32m%-7s\033[0m |\n" "${val}" "ALLOWED"
            printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
          done
      fi
  else
      greenbold "No rules are applied yet."
  fi


}

block_all(){

  index=0
  for ip in "${iranips[@]}"
  #  for (( i=0; i<${#iranips[@]}; i++ ))
  do
#    ip="${iranips[$i]}"
    if ! iptables -C OUTPUT -d "$ip" -p tcp --dport 443 -j REJECT &> /dev/null; then
      iptables -A OUTPUT -d "$ip" -p tcp --dport 443 -j REJECT
    fi
    show_progress $((index + 1)) ${#iranips[@]}
    ((index++))
  done
  echo

  # allow arvancloud
#  for ip in "${arvancloud_ips[@]}"
#  do
#    iptables -A OUTPUT -d "$ip" -p tcp --dport 443 -j ACCEPT
#  done
}

clear_rules(){
  blue "Cleaning up..."

  index=0
  # for (( i=0; i<${#iranips[@]}; i++ ))
  for ip in "${iranips[@]}"
  do
#    ip="${iranips[$i]}"
    if iptables -C OUTPUT -d "$ip" -p tcp --dport 443 -j REJECT &> /dev/null; then
      iptables -D OUTPUT -d "$ip" -p tcp --dport 443 -j REJECT
    fi
    show_progress $((index + 1)) ${#iranips[@]}
    ((index++))
  done
  echo

  # also delete rules which are added for ArvanCloud
  for aip in "${arvancloud_ips[@]}"
  do
    if iptables -C OUTPUT -d "$aip" -p tcp --dport 443 -j ACCEPT &> /dev/null; then
      iptables -D OUTPUT -d "$aip" -p tcp --dport 443 -j ACCEPT
    fi
  done

  greenbold "Cleaned up."
}

allow_arvancloud(){
    for ip in "${arvancloud_ips[@]}"
    do
      if ! iptables -C OUTPUT -d "$ip" -p tcp --dport 443 -j ACCEPT &> /dev/null; then
         iptables -A OUTPUT -d "$ip" -p tcp --dport 443 -j ACCEPT
      fi
    done

    greenbold "Arvancloud is whitelisted."
}

save_rules(){
  iptables-save > /etc/iptables/rules.v4
#  ip6tables-save > /etc/iptables/rules.v6
  greenbold "Saved."
}
#----------------------------------------------------------------------------------------------------------------------- menu core functions
hit_enter(){
  selected_menu_index=0
  echo
  bluebold "Press Enter to continue..."
  echo
  read -p ""
  clear
  show_headers
  global_menu_size=0
  menu_handler "$selected_menu"
}

clear_menu(){
  if [ $global_menu_size -ne 0 ]; then
     tput cuu $((global_menu_size+1)) && tput ed
  fi
}

print_menu(){
  clear_menu


  eval "local menu_items=(\"\${$selected_menu[@]}\")"
	local menu_size="${#menu_items[@]}"
  global_menu_size=$menu_size


	for (( i = 0; i < $menu_size; ++i ))
	do
		if [ "$i" = "$selected_menu_index" ]
		then

      icon="⦿"
      if [ "${menu_items[i]}" == "Back" ]; then
        icon="←"
      fi

      if [ "${menu_items[i]}" != "-" ]; then
          printf -v item "%-$((width+2))b" " $icon ${menu_items[i]}"
          echo -e "\e[48;5;27m\e[1m\e[97m${item}\e[0m"
      else
          printf -v item "%-${width}b" " $icon ${menu_items[i]}"
          seperator
      fi




      # RTL
#		  printf -v output "%${width}s" "* ${menu_items[i]}"
#      echo -e "\e[48;5;4m\e[1m\e[97m${output}\e[0m"

      # Display the fixed-width separator line
#      printf -v separator "%${width}s" ""
#      normal "${separator// /-}"



    else

      icon="○"
      if [ "${menu_items[i]}" == "Back" ]; then
        icon="←"
      fi

      if [ "${menu_items[i]}" != "-" ]; then
          echo " $(bold "$icon") "$(bold "${menu_items[i]}")
      else
          seperator
      fi

#      seperator
		fi
	done
	seperator
}

run_menu(){
#	local function_arguments=($@)

	selected_menu="$1"

	if [ -z "$2" ]; then
    selected_menu_index=0
  else
    selected_menu_index="$2"
  fi

	eval "local menu_items=(\"\${$selected_menu[@]}\")"
	local menu_size="${#menu_items[@]}"
	local menu_limit=$((menu_size - 1))


	print_menu

	while read -rsn1 input
	do
		case "$input"
		in
			$'\x1B')  # ESC ASCII code (https://dirask.com/posts/ASCII-Table-pJ3Y0j)
				read -rsn1 -t 0.1 input
				if [ "$input" = "[" ]  # occurs before arrow code
				then
					read -rsn1 -t 0.1 input
					case "$input"
					in
						A)  # Up Arrow

							if [ "$selected_menu_index" -ge 1 ]
							then
							  tobe_selected_menu_item="${menu_items[$((selected_menu_index - 1))]}"

							  if [ "$tobe_selected_menu_item" != "-" ]; then
							    selected_menu_index=$((selected_menu_index - 1))
							  else
                  selected_menu_index=$((selected_menu_index - 2))
							  fi
                print_menu

							fi
							;;
						B)  # Down Arrow

							if [ "$selected_menu_index" -lt "$menu_limit" ]
							then
							  tobe_selected_menu_item="${menu_items[$((selected_menu_index + 1))]}"

								if [ "$tobe_selected_menu_item" != "-" ]; then
                  selected_menu_index=$((selected_menu_index + 1))
                else
                  selected_menu_index=$((selected_menu_index + 2))
                fi
                print_menu
							fi
							;;
					esac
				fi
				read -rsn5 -t 0.1  # flushing stdin
				;;
			"")  # Enter key
				return "$selected_menu_index"
				;;
		esac
	done
}

menu_handler(){
    run_menu "$1" 0
    selected_menu_index_result="$?"

    function_name="fn_$selected_menu""_$selected_menu_index_result"

    if type "$function_name" >/dev/null 2>&1; then
      eval "$function_name"
    fi
}
#----------------------------------------------------------------------------------------------------------------------- menu
menu=(
"SSH"
"Cloudflare"
"Block Iranian Websites"
"-"
"Exit"
)

menu_ssh=(
'Back'
'Change SSH Port'
)

menu_cloudflare=(
'Back'
'Show scanned IPs'
)

menu_block_ir_websites=(
'Back'
'View applied rules'
'Block outgoing traffic from this server to Iranian websites'
'Allow Arvancloud CDN and Servers'
'Clear all rules applied by this script'
'Save settings'
)
#------------------------------------------------------------------------------------------------------- root
# ssh
fn_menu_0(){
  menu_handler "menu_ssh"
}

# cloudflare
fn_menu_1(){
  menu_handler "menu_cloudflare"
}

# block_ir_websites
fn_menu_2(){
  menu_handler "menu_block_ir_websites"
}

# exit
fn_menu_4(){

  echo

  width=$((width-2))
  exit_msg1="Appreciate your taking the time to play with my script."
  exit_msg2="I hope you found it helpful."
  exit_msg3="Feedback and bug reports are warmly welcomed."
  exit_msg4="❤ ❤ ❤"
  exit_msg5="❤ ❤"
  exit_msg6="❤"

  padding=$(( ($width - ${#exit_msg1}) / 2 ))
  printf "\033[1;34m%*s%s%*s\033[0m\n" $padding '' "$exit_msg1" $padding ''
  sleep 0.2
  padding=$(( ($width - ${#exit_msg2}) / 2 ))
  printf "\033[1;34m%*s%s%*s\033[0m\n" $padding '' "$exit_msg2" $padding ''
  sleep 0.2
  padding=$(( ($width - ${#exit_msg3}) / 2 ))
  printf "\033[1;34m%*s%s%*s\033[0m\n" $padding '' "$exit_msg3" $padding ''
  sleep 0.2
  echo
  padding=$(( ($width - ${#exit_msg4}) / 2 ))
  printf "\033[1;34m%*s%s%*s\033[0m\n" $padding '' "$exit_msg4" $padding ''
  sleep 0.2
  padding=$(( ($width - ${#exit_msg5}) / 2 ))
  printf "\033[1;34m%*s%s%*s\033[0m\n" $padding '' "$exit_msg5" $padding ''
  sleep 0.2
  padding=$(( ($width - ${#exit_msg6}) / 2 ))
  printf "\033[1;34m%*s%s%*s\033[0m\n" $padding '' "$exit_msg6" $padding ''
  echo

  sleep 1


  tput sc
  show_cursor

  clear && printf '\e[3J'



  exit 1
}
#------------------------------------------------------------------------------------------------------- ssh
# back
fn_menu_ssh_0(){
  menu_handler "menu"
}

# ssh > change ssh port
fn_menu_ssh_1(){
  green "TODO..." #TODO
#  view_existing_settings
  hit_enter
}
#------------------------------------------------------------------------------------------------------- cloudflare
# back
fn_menu_cloudflare_0(){
  menu_handler "menu"
}

# cloudflare > show scannet IPs
fn_menu_cloudflare_1(){
  green "TODO..." #TODO
#  view_existing_settings
  hit_enter
}
#------------------------------------------------------------------------------------------------------- block iran ips
# back
fn_menu_block_ir_websites_0(){
  menu_handler "menu"
}

# block_ir_websites > view_existing_settings
fn_menu_block_ir_websites_1(){
  view_existing_settings
  hit_enter
}

# block_ir_websites > block all
fn_menu_block_ir_websites_2(){

  show_cursor
  read -p "$(bluebold "Are you absolutely sure you want to block outgoing traffic from your server to Iranian websites? [y/N]: ")" response
  response=${response:-N}

  if [[ $response =~ ^[Yy]$ ]]; then

    while true; do

        show_cursor
        read -p "$(bluebold "Please enter the IP address of your Iranian server which you are using to tunnel to this server (leave blank if you are not tunneling): ")" response

        hide_cursor

        if [ -z "$response" ]; then
          # no tunneling
            blue "Blocking all..."
            block_all
            break
        elif [[ $response =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
            blue "Blocking all excluding your Iranian server..."
            block_all
            # exclude irsrv ip addr
            iptables -A OUTPUT -d $response -p tcp --dport 443 -j ACCEPT
            break
        else
            redbold "IP address '$response' is not valid. Please try again."
        fi
    done

    greenbold "All Iranian websites are blocked."
  fi

  hide_cursor
  hit_enter
}

# block_ir_websites > allow arvancloud
fn_menu_block_ir_websites_3(){
  allow_arvancloud
  hit_enter
}

# block_ir_websites > clear rules
fn_menu_block_ir_websites_4(){
  clear_rules
  hit_enter
}

# block_ir_websites > save settings
fn_menu_block_ir_websites_5(){
  save_rules
  hit_enter
}
#----------------------------------------------------------------------------------------------------------------------- prepare
prepare_screen
install_wget_and_curl
show_headers
set_run_mode
install_required_packages
install_wepn
load_iranips
load_arvancloud_ips
#----------------------------------------------------------------------------------------------------------------------- RUN
show_headers
menu_handler "menu"
