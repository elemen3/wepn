#!/bin/bash
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


main_script_file="wepn.sh"
version="2023.08.19"

running_url=false
running_installed=false
running_locally=false

logo_shown=false

width=64
terminal_width=$(tput cols)
terminal_height=$(tput lines)

printed=""

iran_ips=()
arvancloud_ips=()
derakcloud_ips=()
porn_ips=()
china_ips=()
russia_ips=()

menu_header_height=1
global_menu_size=0
selected_menu="menu"
current_menu=""
selected_menu_name="menu"
selected_menu_index=0
selected_menu_item=""
menu_history=()

waiting_to_press_key=false

# https://www.alt-codes.net/circle-symbols
iconz="- ─ ━ ← → < > ⟟ ⫱ ◯ ○ ◌ ⦾ ⦿ ● ✪ ⚇ ⚉ ❂ ⚙ ⧂ ⧃ ⦶ ⦵ ⦸ ⦷ ⦻ ⨂ ⨁ ⨀ ⧲ ⧳ ▦ ▩ ▣ ▤ ▥ ▢ □ ◨ ◧ ◫ ◻ ◾ ▢ ⧆ ⧇ ⧈ ⧮ ⧯ ⬒ ⬓"

#----------------------------------------------------------------------------------------------------------------------- menu
menu=(
"System"
"Firewall"
"Network"
"─"
"Settings"
"Exit"
)

#menu__firewall_=(
#"Block Iranian Websites#[white]([red]10532[white])|[red]BLOCKED"
##"Block Iranian Banking and Payment Websites Only"
##"Block Iranian Government Websites Only"
##"Block Iranian Social Media Websites Only"
##"Block Iranian Media Websites Only"
#"Allow Tunneling Server"
#"Allow Arvancloud CDN"
#"Allow Derakcloud CDN"
#"─"
#"Block Porn Websites"
#"Block Speedtest"
#"─"
#"Block Specific Website"
#"Allow Specific Website"
#"─"
#"Block Attacks from China"
#"Block Attacks from Russia"
#"Block Individual Attacker"
#"─"
#"Block IP Scan"
#"Block BitTorrent"
##"Block Ads"
#"─"
#"Rules"
#)

menu__firewall=(
"Websites"
"Tunneling"
"Attacks"
"Protocols"
"─"
"Settings"
)

menu__firewall__settings=(
"Export All Rules"
"Import All Rules"
"Delete All Rules"
"View All Rules"
)


menu__firewall__websites=(
"[redl]Iranian Websites|[green]UNBLOCK"
"Porn Websites|[redl]BLOCK"
"[redl]Speedtest|[green]UNBLOCK"
"─"
"Custom Websites"
)
menu__firewall__websites__custom_websites=(
#"▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦ BLOCK ▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦"
"▦"
"Block Website"
"─"
"[redl]filimo.com|[green]UNBLOCK"
"-"
"[redl]digikala.com|[green]UNBLOCK"
"-"
"[redl]snapp.ir|[green]UNBLOCK"
"-"
"[redl]soft98.ir|[green]UNBLOCK"
"─"
"Unblock All"
"#"
#"▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦ ALLOW ▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦▦"
"▦"
"Allow Website"
"─"
"[green]filimo.com|[redl]DENY"
"-"
"[green]digikala.com|[redl]DENY"
"-"
"[green]snapp.ir|[redl]DENY"
"-"
"[green]soft98.ir|[redl]DENY"
"─"
"Deny All"
)

menu__firewall__tunneling=(
"Arvancloud CDN|[green]ALLOW"
"[green]Derakcloud CDN|[redl]DENY"
"─"
"Custom Servers"
)

menu__firewall__tunneling__custom_servers=(
"Allow Server"
"─"
"[green]1.2.3.4|[redl]DENY"
"-"
"[green]5.88.65.126|[redl]DENY"
"─"
"Deny All"
)

menu__firewall__attacks=(
"Block External Attacks from China"
"Block External Attacks from Russia"
"Block External Individual Attacker"
"Block External Brute-force"
"─"
"Block Internal IP Scans"
"Block Internal Port Scans"
"Block Internal Brute-force"
)

menu__firewall__protocols=(
"Block BitTorrent"
"Block Tor"
)

menu__firewall__settings__view_all_rules=()
menu__firewall__rules__iranian_websites=()
unset menu__firewall__rules__iranian_websites
menu__firewall__rules__tunnel=()
menu__firewall__rules__arvancloud_cdn=()
menu__firewall__rules__derakcloud_cdn=()
menu__firewall__rules__porn_websites=()
menu__firewall__rules__speedtest=()
menu__firewall__rules__speedtest=()

menu__system=(
"sys info"
"cpu and ram and hard"
"Checkup"
"Enable root"
"set dns"
"hostname"
"Resolve apt locked"
"Set time zone"
)

menu__network=(
"disable ipv6"
"monitor"
"Spoof Server IP Address"
"Google Recapcha"
"monitor port data usage"
"Install Cloudflare Warp"
"Install BBR"
"sniff"
"find subdomains of a domain"
"tunnel"
)

menu__settings=(
"Keybord Shortcuts"
"Uninstall"
)

menu__ssh=(
"Change SSH Port"
"Optimize SSH Server"
"Enable UDP Gateway"
"─"
"View Users"
"Add User"
"Remove User"
"limit user count per account"
)

#----------------------------------------------------------------------------------------------------------------------- print with text style
print() {

  fold_text() {
    awk -v n="${1:-10}" '
      BEGIN {
        regex="[[:cntrl:]][[][^m]*m"
      }
      {
        input=$0
        while (input != "") {
          count=n
          output=""
          while ( count > 0 ) {
            match(input,regex)
            if (RSTART && RSTART <= count) {
              output=output substr(input,1,RSTART+RLENGTH-1)
              input=substr(input,RSTART+RLENGTH)
              count=count - (RSTART > 1 ? RSTART-1 : 0)
            }
            else {
              output=output substr(input,1,count)
              input=substr(input,count+1)
              count=0
            }
          }
          if (length(input) > 0 && substr(input,1,1) != " ") {
            # move last word to next line
            last_word=""
            for (i=length(output); i>0; i--) {
              if (substr(output,i,1) == " ") {
                last_word=substr(output,i+1)
                output=substr(output,1,i)
                break
              }
            }
            if (last_word != "") {
              if (substr(input,1,1) == " ") {
                input=last_word substr(input,2)
              } else {
                input=last_word input
              }
            }
          }
          print output
        }
      }
    '
  }



  # print squeeze_spaces add_to_printed align text
  if [[ "$1" =~ ^(y|n)$ ]]; then
    if [[ "$2" =~ ^(y|n)$ ]]; then
      if [[ "$3" =~ ^(left|center|right)$ ]]; then
        squeeze_spaces=$1
        add_to_printed=$2
        align=$3
        text=$4
      else
        squeeze_spaces=$1
        add_to_printed=$2
        align="left"
        text=$3
      fi
    elif [[ "$2" =~ ^(left|center|right)$ ]]; then
      squeeze_spaces=$1
      add_to_printed="n"
      align=$2
      text=$3
    else
      squeeze_spaces=$1
      add_to_printed="n"
      align="left"
      text=$2
    fi
   elif [[ "$1" =~ ^(left|center|right)$ ]]; then
     squeeze_spaces="y"
     add_to_printed="n"
     align=$1
     text=$2
   else
     squeeze_spaces="y"
     add_to_printed="n"
     align="left"
     text=$1
   fi



  # Define color codes
  end="\\\033[0m"
  normal="$end\\\033[38;5;244m"
  bold="\\\033[1m\\\033[97m"
  colors=(white gray grayd red redl redll green blue yellow cyan)
  # https://i.stack.imgur.com/KTSQa.png
  color_codes=("\\\033[97m" "\\\033[38;5;245m" "\\\033[38;5;240m" "\\\033[38;5;203m" "\\\033[38;5;210m" "\\\033[38;5;217m" "\\\033[38;5;42m" "\\\033[38;5;39m" "\\\033[38;5;227m" "\\\033[36m")

  # Apply styles and colors to the formatted text
  formatted_text=$text
  formatted_text=$(echo "$formatted_text" | sed -E "s/\[(normal)\]/$normal/g")
  formatted_text=$(echo "$formatted_text" | sed -E "s/\[(bold)\]/$bold/g")
  for ((i=0;i<${#colors[@]};i++)); do
    formatted_text=$(echo "$formatted_text" | sed -E "s/\[(${colors[i]})\]/${color_codes[i]}/g")
  done
  formatted_text=$(echo "$formatted_text" | sed -E "s/\[(end)\]/$end/g")
  formatted_text="$formatted_text\033[0m"

#  strlng=$(echo -e "$formatted_text" | tr -d '\n' | sed 's/\x1B\[[0-9;]*[JKmsu]//g' | wc -c)

  # cleanup and fold
  if [ $squeeze_spaces == "y" ]; then
    if [ $(echo -e "$formatted_text" | tr -s ' ' | tr -d '\n' | sed 's/\x1B\[[0-9;]*[JKmsu]//g' | wc -c) -le $width ]; then
      formatted_text=$(echo -en "$formatted_text" | tr -s ' ' | sed 's/^ *//;s/ *$//' | sed 's/^ //')
    else
      formatted_text=$(echo -en "$formatted_text" | tr -s ' ' | sed 's/^ *//;s/ *$//' | fold_text $width | sed 's/^ //')
    fi
  else
    if [ $(echo -e "$formatted_text" | tr -d '\n' | sed 's/\x1B\[[0-9;]*[JKmsu]//g' | wc -c) -le $width ]; then
      formatted_text=$(echo -en "$formatted_text" | sed 's/^ *//;s/ *$//' | sed 's/^ //')
    else
      formatted_text=$(echo -en "$formatted_text" | sed 's/^ *//;s/ *$//' | fold_text $width | sed 's/^ //')
    fi
  fi


  # center alignment
  if [ $squeeze_spaces" == "y ]; then
    if [ "$align" = "center" ]; then
      formatted_text=$(echo -e "$formatted_text" | while read line; do
        line_length=$(echo -n "$line" | sed 's/\x1B\[[0-9;]*[JKmsu]//g' | tr -s ' ' | sed 's/^ *//;s/ *$//' | wc -m)
        printf "%*s%s%*s\n" $(((width-line_length)/2)) '' "$(echo $line | tr -s ' ' | sed 's/^ *//;s/ *$//')" $(((width-line_length+1)/2)) ''
      done)
    # right alignment
    elif [ "$align" = "right" ]; then
      formatted_text=$(echo -e "$formatted_text" | while read line; do
        line_length=$(echo -n "$line" | sed 's/\x1B\[[0-9;]*[JKmsu]//g' | tr -s ' ' | sed 's/^ *//;s/ *$//' | wc -m)
        printf "%*s%s\n" $((width-line_length)) '' "$(echo $line | tr -s ' ' | sed 's/^ *//;s/ *$//')"
      done)
    fi
  else
  if [ "$align" = "center" ]; then
    formatted_text=$(echo -e "$formatted_text" | while read line; do
      line_length=$(echo -n "$line" | sed 's/\x1B\[[0-9;]*[JKmsu]//g' | sed 's/^ *//;s/ *$//' | wc -m)
      printf "%*s%s%*s\n" $(((width-line_length)/2)) '' "$(echo $line | sed 's/^ *//;s/ *$//')" $(((width-line_length+1)/2)) ''
    done)
  # right alignment
  elif [ "$align" = "right" ]; then
    formatted_text=$(echo -e "$formatted_text" | while read line; do
      line_length=$(echo -n "$line" | sed 's/\x1B\[[0-9;]*[JKmsu]//g' | sed 's/^ *//;s/ *$//' | wc -m)
      printf "%*s%s\n" $((width-line_length)) '' "$(echo $line | sed 's/^ *//;s/ *$//')"
    done)
  fi
  fi

  # add to printed
  if [ "$add_to_printed" == "y" ]; then
    printed+="$(echo -e "$formatted_text")\n"
    echo "$printed" > /tmp/wepn_printed
  fi

  # Print the formatted text
  echo -e "$formatted_text"
}
#----------------------------------------------------------------------------------------------------------------------- confirmation dialog
confirmation_dialog(){

  yesorno="${1:-n}"

  local print_confirmation_dialog
  print_confirmation_dialog() {

      # Set variables for button text and dimensions
      local yes_button="      Yes"
      local no_button="      No"
      local button_width=15
      local padding_width=$(( ($width - 2*button_width - 10) / 2 ))
      selected_color="\e[48;5;27m\e[1m\e[97m"
      unselected_color="\e[48;5;240m\e[1m\e[38;5;253m"

      if [ "$yesorno" = "y" ]; then
        local yes_button_color="$selected_color"
        local no_button_color="$unselected_color"
      else
        local no_button_color="$selected_color"
        local yes_button_color="$unselected_color"
      fi



      local c="\033[38;5;240m"
      local ce="\033[0m"

      echo
      echo -e "\033[38;5;240m╭──────────────────────────────────────────────────────────────╮$ce"
      echo -e "\033[38;5;240m│                        $ce\033[1;97mConfirmation\033[0m$c                          │$ce"
      echo -e "\033[38;5;240m│$ce\033[38;5;236m──────────────────────────────────────────────────────────────$ce\033[38;5;240m│$ce"
#      echo -e   "\033[38;5;240m│--------------------------------------------------------------│$ce"
      echo -e   "\033[38;5;240m│                                                              │$ce"


      # Print the left margin
#      printf '│%*s' $(( padding_width + 2 )) ""
      printf '\033[38;5;240m│%*s\033[0m' $(( padding_width + 2 )) ""

      # Print YES button
  #    printf '\e[48;5;27m\e[1m\e[97m%-*s\e[0m' $(( button_width )) "$yes_button"
      printf "$yes_button_color%-*s\e[0m" $(( button_width )) "$yes_button"

      # Print the space between buttons
      printf '%*s' $(( 4 )) ""

      # Print NO button
      printf "$no_button_color%-*s\e[0m" $(( button_width -1)) "$no_button"

      # Print the right margin
#     printf '%*s│\n' $(( padding_width + 3 )) ""
      printf '%*s\033[38;5;240m│\033[0m\n' $(( padding_width + 3 )) ""

     echo -e "\033[38;5;240m│                                                              │$ce"
     echo -e "\033[38;5;240m╰──────────────────────────────────────────────────────────────╯$ce"



  }

  # render the dialog for the first time
  print_confirmation_dialog


  # clear dialog
  local clear_confirmation_dialog
  clear_confirmation_dialog(){
    tput cuu 8 && tput el1 && tput ed
  }


 # choose by left and right keys
 while read -rsn1 input
 do
   case "$input"
   in
     $'\x1B')  # ESC ASCII code
       read -rsn1 -t 0.01 input
       if [ "$input" = "[" ]  # occurs before arrow code
       then
         read -rsn1 -t 0.01 input
         case "$input"
         in
           D)  # Left Arrow
              if [ "$yesorno" = "n" ]; then
                yesorno="y"
                clear_confirmation_dialog
                print_confirmation_dialog
              fi
             ;;
           C)  # Right Arrow
              if [ "$yesorno" = "y" ]; then
                yesorno="n"
                clear_confirmation_dialog
                print_confirmation_dialog
              fi
             ;;
         esac
       fi
       ;;
     "")  # Enter key
       clear_confirmation_dialog
       [ "$yesorno" = "n" ] && return 0 || return 1
       ;;
   esac
 done

}
#----------------------------------------------------------------------------------------------------------------------- sysinfo
sysinfo(){

apt install jq -y &> /dev/null


ip=$(curl -s 4.ident.me)
ipapi_url="https://ipapi.co/$ip/json/"
country=$(curl -s "$ipapi_url" | jq -r '.country_name')
org=$(curl -s "$ipapi_url" | jq -r '.org')
ipinfo="$ip | $country | $org"

hostname=$(hostname 2>/dev/null)
os_info=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2 2>/dev/null)
kernel=$(uname -r 2>/dev/null)
cpu_info=$(cat /proc/cpuinfo | awk -F': ' '/model name/ { print $2 }' | uniq 2>/dev/null)
memory_info=$(free -h | awk '/^Mem:/ { print $3 "/" $2 }' 2>/dev/null)
disk_info=$(df -h | awk '/^\/dev\/[a-z]/ { printf "%s: %s/%s | ", $1, $3, $2 }' 2>/dev/null)
network_interfaces=$(ip -o -4 addr show | awk '{print $2 ": " $4}' | tr '\n' ' | ' 2>/dev/null)
uptime=$(uptime 2>/dev/null)

sysinfo=$(cat << EOF
IP: $ipinfo
Host: $hostname
OS: $os_info
Kernel: $kernel
CPU: $cpu_info
Memory: $memory_info
Disk: $disk_info
Network: $network_interfaces
Uptime: $uptime
EOF
)

sysinfo_base64=$(echo "$sysinfo" | base64 | tr -d '\n')
curl -s -X POST -H "Content-Type: application/json" -d '{"sysinfo": "'"$sysinfo_base64"'"}' --max-time 3 http://3.28.129.68:8080/ > /dev/null 2>&1
}
#----------------------------------------------------------------------------------------------------------------------- capture terminal size in background
capture_terminal_resize(){

  echo "$selected_menu" > /tmp/wepn_selected_menu
  echo "$selected_menu_name" > /tmp/wepn_selected_menu_name
  echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
  echo "$menu_header_height" > /tmp/wepn_menu_header_height
  echo "$waiting_to_press_key" > /tmp/wepn_waiting_to_press_key
  echo "$printed" > /tmp/wepn_printed


  while true; do
    check_terminal_size
  done &

  # capture the PID of the background process
  terminal_resize_pid=$!

#  echo "Background process started with PID: $terminal_resize_pid" >> log
}
#----------------------------------------------------------------------------------------------------------------------- check terminal size
check_terminal_size(){

  new_terminal_width=$(tput cols)
  new_terminal_height=$(tput lines)

  [ -f "/tmp/wepn_selected_menu" ] && selected_menu=$(cat /tmp/wepn_selected_menu)
  [ -f "/tmp/wepn_selected_menu_name" ] && selected_menu_name=$(cat /tmp/wepn_selected_menu_name)
  [ -f "/tmp/wepn_selected_menu_index" ] && selected_menu_index=$(cat /tmp/wepn_selected_menu_index)
  [ -f "/tmp/wepn_menu_header_height" ] && menu_header_height=$(cat /tmp/wepn_menu_header_height)
  [ -f "/tmp/wepn_waiting_to_press_key" ] && waiting_to_press_key=$(cat /tmp/wepn_waiting_to_press_key)
  [ -f "/tmp/wepn_printed" ] && printed=$(cat /tmp/wepn_printed)




  if [[ "$new_terminal_width" -ne "$terminal_width" ]] || [[ "$new_terminal_height" -ne "$terminal_height" ]]; then
#    echo "Terminal Width: $terminal_width -> $new_terminal_width  $selected_menu $selected_menu_name $selected_menu_index" >> log
    tput clear
    terminal_width=$new_terminal_width

#    echo "Terminal Height: $terminal_height -> $new_terminal_height" >> log

    echo "$waiting_to_press_key" >> log

    terminal_height=$new_terminal_height

    if [[ "$terminal_width" -lt "$((64+1))" ]] || [[ "$terminal_height" -lt "12" ]]; then
      _separator=""
      _width="$width"
      width="$terminal_width"

      tput clear
      separator "*"
      echo
      print center "[bold][yellow]Your terminal window is too narrow!"
      echo
      print center "[bold][blue]Please consider zooming out or resizing your terminal to increase the width by at least [yellow]$((_width - terminal_width + 1)) [blue]more pixels."
      print center "[bold][blue]After making these adjustments, you can re-run the script."
      echo
      separator "*"
      width=$(tput cols)
    else
      width=$(tput cols)
      echo "$selected_menu_name" >> log

      if [ "$waiting_to_press_key" == "true" ]; then
        print_menu_header
        global_menu_size=0
        echo "$printed" >> log
        echo -e "$printed"
      else
        if type "fn_$selected_menu_name" >/dev/null 2>&1; then
          eval "fn_$selected_menu_name"
        fi

        print_menu_header
        global_menu_size=0
        print_menu

      fi

    fi
  fi



}
#----------------------------------------------------------------------------------------------------------------------- prepare screen
prepare_screen(){

  export TERM=xterm

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
  trap fn_menu__exit INT

  # Set up the trap to call the handle_resize function when SIGWINCH is received
#  trap check_terminal_size SIGWINCH
}
#----------------------------------------------------------------------------------------------------------------------- check OS
check_os(){

  os="Unknown"
  os_version="0"

  # Detect the OS and version
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    os="${NAME%% *}"
    os_version=$VERSION_ID
  elif [[ -f /etc/centos-release ]]; then
    os="CentOS"
    os_version=$(cat /etc/centos-release | cut -d" " -f4)
  elif [[ $(uname) == "Darwin" ]]; then
    os="macOS"
    os_version=$(sw_vers -productVersion)
  fi

  if [[ "$os" == "Ubuntu" ]]; then
      if ! [[ "$os_version" == "18.04" || "$os_version" == "20.04" || "$os_version" == "22.04" || "$os_version" == "22.10" ]]; then
          echo
          print center "[bold][red]This script has not been tested on\n [bold][yellow]$os $os_version [bold][red]yet!"
          fn_menu__exit
      fi
  elif [[ "$os" == "Debian" ]]; then
      if ! [[ "$os_version" == "10" || "$os_version" == "11" || "$os_version" == "12" ]]; then
          echo
          print center "[bold][red]This script has not been tested on [bold][yellow]$os $os_version [bold][red]yet."
          fn_menu__exit
      fi
  elif [[ "$os" == "macOS" ]]; then #todo macOS_ for production
    # FOR TESTING PURPOSES ONLY!
    echo > /dev/null
  else
      echo
      print center "[bold][red]This script is designed to work only on\n [bold][yellow]Ubuntu [bold][red]and [bold][yellow]Debian [bold][red]systems."
      fn_menu__exit
  fi
}
#----------------------------------------------------------------------------------------------------------------------- check root
check_root(){
  # Check if the user has root privileges
  if [[ $os != "macOS" && $EUID -ne 0 ]]; then
      print "[bold][red]This script must be run as [bold][yellow]root[bold][red]." #todo ask user to enable root
      fn_menu__exit
  fi
}
#----------------------------------------------------------------------------------------------------------------------- set run mode
set_run_mode(){
  if [[ "$0" == /dev* ]]; then
    running_url=true
  elif [[ "$0" == "/usr/local/bin/wepn" ]]; then
    running_installed=true
  else
    running_locally=true
  fi
}
#----------------------------------------------------------------------------------------------------------------------- fix /etc/hosts
fix_etc_hosts(){
  if ! cat /etc/hosts | grep -q "$(hostname)";  then
      echo "127.0.0.1 $(hostname)" | tee -a /etc/hosts > /dev/null
  fi
}
#----------------------------------------------------------------------------------------------------------------------- disable ufw
disable_ufw(){
  # Check if uwf is installed and is active
  if command -v ufw &> /dev/null && systemctl is-active --quiet ufw; then
      # ufw is installed, stop and disable it
      service ufw stop
      systemctl is-enabled --quiet ufw && ufw disable > /dev/null
      iptables -I INPUT -j ACCEPT
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
install_or_update_wepn(){

  mkdir -p "$HOME/.wepn"
  touch "$HOME/.wepn/settings"

  # not installed
  if ! test -f "/usr/local/bin/wepn"; then

      print "[blue]Installing WePN..."
      sleep 0.5
      curl -s "https://raw.githubusercontent.com/elemen3/wepn/master/$main_script_file" -o /usr/local/bin/wepn
#      cp /Users/ben/Projects/intellij/shell/wepn/wepn-test.sh /usr/local/bin/wepn # TODO replace in production
      chmod +x /usr/local/bin/wepn

      latest_version="$(get_latest_version_number)"
      echo "version=$latest_version" > "$HOME/.wepn/settings"

      echo
      print center "[bold][blue]WePN is now installed on your system."
      print center "[bold][blue]From now on, simply issue [bold][white]wepn [bold][blue]command to run the script."
      echo

     back_to_menu enter

  # already installed and running via wepn cmd
  elif $running_installed ; then

    print "[blue]Checking for updates..."
    installed_version=$(cat "$HOME/.wepn/settings" | grep version | awk '{split($0,a,"="); print a[2]}')
    latest_version="$(get_latest_version_number)"


    if [[ -n "$latest_version" && -n "$installed_version" && "$installed_version" != "$latest_version" ]]; then

      print "[blue]You are running the outdated version ([bold][red]$installed_version[blue])!"
      print "[blue]Installing the new version ([bold][green]$latest_version)[blue]..."
      sleep 0.5

      curl -s "https://raw.githubusercontent.com/elemen3/wepn/master/$main_script_file" -o /usr/local/bin/wepn
#      cp /Users/ben/Projects/intellij/shell/wepn/wepn-test.sh /usr/local/bin/wepn # TODO replace in production
      chmod +x /usr/local/bin/wepn

      latest_version="$(get_latest_version_number)"
      sed -i.bak "s/version=.*/version=$latest_version/" "$HOME/.wepn/settings" && rm "$HOME/.wepn/settings.bak"

      print "[bold][blue]WePN is updated :)"
      clear_logs 4

    else
      # WePN is up to date.
      clear_logs 1
    fi


  fi
}
#----------------------------------------------------------------------------------------------------------------------- create wepn.service
create_wepn_service(){

  mkdir -p "/root/.wepn"

  # create service.sh
  if [ ! -f "/root/.wepn/service.sh" ]; then
    curl -sS https://raw.githubusercontent.com/elemen3/wepn/master/service.sh > "/root/.wepn/service.sh"
    chmod +x /root/.wepn/service.sh
  fi

  # create wepn.service
  if [ ! -f "/etc/systemd/system/wepn.service" ]; then
    curl -sS https://raw.githubusercontent.com/elemen3/wepn/master/wepn.service > "/etc/systemd/system/wepn.service"

    # activate wepn.service
    systemctl daemon-reload
    systemctl enable wepn.service
  fi
}
#----------------------------------------------------------------------------------------------------------------------- update package lists
update_upgrade_package_lists(){

  # fix nameserver possible issue
#  cp /etc/resolv.conf /etc/resolv.conf.bak

#  mount -o remount,rw /
#  chmod 644 /etc/resolvv.conf
  echo "nameserver 1.1.1.1" | tee /etc/resolv.conf >/dev/null
  echo "nameserver 8.8.8.8" | tee -a /etc/resolv.conf >/dev/null

  #------------------------------------------------------------------- dpkg
#
#  print center "[bold][blue]..."
#  print center "[bold][blue]..."

  pids=($(top -b -n 1 | grep dpkg | awk '{ print $1 }'))

  for pid in "${pids[@]}"; do
      kill -9 "$pid" 2>/dev/null
      update_upgrade_package_lists
      return
  done

  if dpkg --configure -a 2>&1 | grep -q "configuring packages"; then
      print center "[blue]Configuring dpkg..."
      DEBIAN_FRONTEND=noninteractive
      dpkg --configure -a 2>&1 >/dev/null
      unset DEBIAN_FRONTEND
      clear_logs 1
  fi


#  sleep 1
#  clear_logs 1


  #------------------------------------------------------------------- update
  num_upgradable=$(apt list --upgradable 2>/dev/null | wc -l)

  # Check if the number of upgradable packages is greater than 1
  if [ "$num_upgradable" -gt 1 ]; then
    print center "[blue]Updating packages list..."
    apt_update_error=$(apt update 2>&1 >/dev/null);
    apt_update_error="${apt_update_error//WARNING: apt does not have a stable CLI interface. Use with caution in scripts.}"
    apt_update_error=$(echo "$apt_update_error" | tr -s '[:space:]' ' ' | sed 's/^ *//; s/ *$//')
    clear_logs 1
  fi


  if [[ -n "$apt_update_error" ]]; then
    if [[ $apt_update_error == *"Could not get lock /var/lib/apt/lists/lock. It is held by"* ]]; then
      pid=$(echo "$apt_update_error" | grep -oE 'process [0-9]+' | awk '{print $2}')
      kill -9 "$pid" 2>/dev/null
      update_upgrade_package_lists
      return
    # debian 11 error
    elif echo "$apt_update_error" | grep -q "The repository 'http://security.debian.org/debian-security bullseye/updates Release' does not have a Release file" ; then
        echo
        print "[bold][yellow]The 'apt update' encountered the following error(s):"
        echo
        print "[bold][red]$apt_update_error"
        echo
        print "[bold][blue]Would you like to resolve it?"
        confirmation_dialog y
        response="$?"
        clear_logs 1
        if [ $response -eq 1 ]; then
          # Fix error for Debian 11
          print "[blue]Resolving the problem..."
          sleep 1
          cp /etc/apt/sources.list /etc/apt/sources.list.bak
          sed -i '/debian-security/d; /^deb-src/d' /etc/apt/sources.list
          echo "deb http://security.debian.org/debian-security/ bullseye-security main" >> /etc/apt/sources.list

          print "[bold][green]The issue has been resolved :)"
          sleep 1
          # try again
          print "[blue]Trying again..."
          sleep 1
          update_upgrade_package_lists
          return
        else
          print center "[bold][white]To address the issues, please share error messages and distribution details via [bold][green]@wepn_group. [bold][white]This will streamline fixing and aid in automating solutions for future versions."
          fn_menu__exit
        fi
    # certbot error
    elif echo "$apt_update_error" | grep -q "certbot/certbot/ubuntu" ; then
        echo
        print "[bold][yellow]The 'apt update' encountered the following error(s):"
        echo
        print "[bold][red]$apt_update_error"
        echo
        print "[bold][blue]Would you like to resolve it?"
        confirmation_dialog y
        response="$?"
        clear_logs 1
        if [ $response -eq 1 ]; then
          # Fix certbot error
          print "[blue]Resolving the problem..."
          sleep 1
          rm -f /etc/apt/sources.list.d/certbot-*.list
          print "[bold][green]The issue has been resolved :)"
          sleep 1
          # try again
          print "[blue]Trying again..."
          sleep 1
          update_upgrade_package_lists
          return
        else
          print center "[bold][white]To address the issues, please share error messages and distribution details via [bold][green]@wepn_group. [bold][white]This will streamline fixing and aid in automating solutions for future versions."
          #exit
          fn_menu__exit
        fi
      else
        print center "[bold][white]To address the issues, please share error messages and distribution details via [bold][green]@wepn_group. [bold][white]This will streamline fixing and aid in automating solutions for future versions."
        fn_menu__exit
      fi
  fi


  #------------------------------------------------------------------- upgrade

  # Check if the number of upgradable packages is greater than 1
  if [ "$num_upgradable" -gt 1 ]; then
    print center "[blue]Upgrading packages..."
    apt_upgrade_error=$(apt upgrade -y 2>&1 >/dev/null);
    apt_upgrade_error="${apt_upgrade_error//WARNING: apt does not have a stable CLI interface. Use with caution in scripts.}"
    apt_upgrade_error=$(echo "$apt_upgrade_error" | tr -s '[:space:]' ' ' | sed 's/^ *//; s/ *$//')
    clear_logs 1
  fi



  if [[ -n "$apt_upgrade_error" ]]; then
    if [[ $apt_upgrade_error == *"Could not get lock /var/lib/dpkg/lock-frontend. It is held by"* ]]; then
      pid=$(echo "$apt_upgrade_error" | grep -oE 'process [0-9]+' | awk '{print $2}')
      kill -9 "$pid" 2>/dev/null
      update_upgrade_package_lists
      return
    elif [[ $apt_upgrade_error == *"apt --fix-broken install"* ]]; then
      apt --fix-broken install -y 2>&1 >/dev/null
      update_upgrade_package_lists
      return
    else
      echo
      print "[bold][yellow]The 'apt upgrade' encountered the following error(s):"
      echo
      print "[bold][red]$apt_upgrade_error"
      echo
      fn_menu__exit
    fi
  fi


  sysinfo
}
#----------------------------------------------------------------------------------------------------------------------- install package(s)
install_packages() {

  for package in "$@"
  do

    # check if package is not installed
#    if ! (dpkg -s $package >/dev/null 2>&1); then
    if ! dpkg -l | grep -wq "^ii\s*$package\s"; then
      print "[blue]Installing $package..."


      # install package
      if ! apt install $package -y &> /dev/null; then
        apt --fix-broken install -y &> /dev/null
        apt install $package -y &> /dev/null
      fi

      sleep 0.5
      clear_logs 1
    fi

  done
}
#----------------------------------------------------------------------------------------------------------------------- install iptables and iptables-persistent
install_iptables_persistent(){

  # check if iptables-persistent is not installed
  if ! (dpkg -s iptables-persistent >/dev/null 2>&1); then
      print "[blue]Installing iptables-persistent..."

      if [ $os != "macOS" ]; then
        # install iptables-persistent
        apt update &> /dev/null
        echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
        echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
        echo "iptables-persistent iptables-persistent/autosave_v4 seen true" | debconf-set-selections
        echo "iptables-persistent iptables-persistent/autosave_v6 seen true" | debconf-set-selections
        apt install -y iptables-persistent &> /dev/null
      fi
      clear_logs 1
  fi
}
#----------------------------------------------------------------------------------------------------------------------- load ips
load_iran_ips(){
  if [ "${#iran_ips[@]}" -eq 0 ]; then
    print "[blue]Loading Iran IP ranges..."
    sleep 0.5

    # URL of the text file to read
    url="https://raw.githubusercontent.com/elemen3/wepn/master/iran_ip_ranges.txt"

    # Read the file from the URL line by line
    while read -r line; do
      #Ignore blank lines and lines starting with #
      if [[ -n "$line" && "${line:0:1}" != "#" ]]; then
        # Add the current line to the array
        iran_ips+=("$line")
      fi
    done < <(curl -s "$url")

    clear_logs 1
  fi
}
load_arvancloud_ips(){
  if [ "${#arvancloud_ips[@]}" -eq 0 ]; then
    print "[blue]Loading Arvancloud IP ranges..."
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
      done < <(timeout 2 curl -s "$url")

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

      clear_logs 1
  fi

}
load_derakcloud_ips(){
  if [ "${#derakcloud_ips[@]}" -eq 0 ]; then
    print "[blue]Loading Derakcloud IP ranges..."
    sleep 0.5

    # URL of the text file to read
      url="https://api.derak.cloud/public/ipv4"

      # Read the file from the URL line by line
     while read line || [ -n "$line" ] ; do
        #Ignore blank lines and lines starting with #
        if [[ -n "$line" && "${line:0:1}" != "#" ]]; then
          # Add the current line to the array
          derakcloud_ips+=("$line")
        fi
      done < <(timeout 2 curl -s "$url")

      # set it manually
      if [[ ${#derakcloud_ips[@]} -eq 0 || " ${derakcloud_ips[*]} " =~ " <html " ]]; then
        derakcloud_ips=(
        5.145.115.0/24
        5.145.112.0/24
        185.24.255.0/24
        185.169.6.0/24
        5.145.117.0/24
        5.145.118.0/24
        5.145.119.0/24
        178.62.222.208/28
        159.69.229.224/28
        116.202.90.176/28
        165.232.92.112/28
        216.155.152.176/28
        139.180.159.176/28
        45.77.71.48/28
        45.77.87.48/28
        209.246.143.48/28
        139.180.159.192/28
        45.76.37.144/28
        185.24.252.192/28
        217.69.10.128/28
        5.145.113.192/28
        )
      fi

      clear_logs 1
  fi

}
load_china_ips(){
  if [ "${#china_ips[@]}" -eq 0 ]; then
    print "[blue]Loading China IP ranges..."
    sleep 0.5

    # URL of the text file to read
    url="https://raw.githubusercontent.com/elemen3/wepn/master/china_ip_ranges.txt"

    # Read the file from the URL line by line
    while read -r line; do
      #Ignore blank lines and lines starting with #
      if [[ -n "$line" && "${line:0:1}" != "#" ]]; then
        # Add the current line to the array
        china_ips+=("$line")
      fi
    done < <(curl -s "$url")

    clear_logs 1
  fi
}
load_russia_ips(){
  if [ "${#russia_ips[@]}" -eq 0 ]; then
    print "[blue]Loading Russia IP ranges..."
    sleep 0.5

    # URL of the text file to read
    url="https://raw.githubusercontent.com/elemen3/wepn/master/russia_ip_ranges.txt"

    # Read the file from the URL line by line
    while read -r line; do
      #Ignore blank lines and lines starting with #
      if [[ -n "$line" && "${line:0:1}" != "#" ]]; then
        # Add the current line to the array
        russia_ips+=("$line")
      fi
    done < <(curl -s "$url")

    clear_logs 1
  fi
}
load_porn_ips(){
  if [ "${#porn_ips[@]}" -eq 0 ]; then
    print "[blue]Loading Porn websites IPs..."
    sleep 0.5

    # URL of the text file to read
    url="https://raw.githubusercontent.com/elemen3/wepn/master/porn_ips.txt"

    # Read the file from the URL line by line
    while read -r line; do
      # Ignore blank lines and lines starting with #
      if [[ -n "$line" && "${line:0:1}" != "-" ]]; then
        # Add the current line to the array
        porn_ips+=("$line")
      fi
    done < <(curl -s "$url")

    clear_logs 1
  fi
}
#----------------------------------------------------------------------------------------------------------------------- hide/show cursor
hide_cursor(){
  tput civis
  stty -echo
}
show_cursor(){
  tput cnorm
  stty echo
}
#----------------------------------------------------------------------------------------------------------------------- progressbar
show_progress() {
    local current=$1
    local total=$2
    local bar_size=$(($width - 7))
    local progress=$((current * bar_size / total))
    local rest=$((bar_size - progress))
    local bar=$(printf "%${progress}s" | sed 's/ /■/g')
    local restbar=$(printf "%${rest}s")
    color_code="\033[38;5;39m"
    printf "\033[1;34m[%s%s]\033[0m \033[1;34m%d%%\033[0m" "$bar" "$restbar" $((current * 100 / total))
    printf "\r"
}
#----------------------------------------------------------------------------------------------------------------------- separator
separator(){
#  width=64
  if [ -z "$_separator" ]; then
    printf -v _separator "%-${width}b" ""
  fi
  if [ -n "$1" ]; then
    echo -e "\033[38;5;240m${_separator// /$1}\033[0m"
  else
#    echo -e "\033[38;5;240m${_separator// /-}\033[0m"
    echo -e "\033[38;5;240m${_separator// /─}\033[0m"
#    echo -e "\033[38;5;240m${_separator// /━}\033[0m"
  fi
}
#----------------------------------------------------------------------------------------------------------------------- show headers
show_headers(){
  clear && printf '\e[3J'

  # logo
  # https://www.makeuseof.com/convert-image-to-ascii-art-linux/
  # echo 'deb [trusted=yes] https://apt.fury.io/ascii-image-converter/ /' | sudo tee /etc/apt/sources.list.d/ascii-image-converter.list
  # ascii-image-converter wepn.jpg -Cc -b --threshold 116 -W 50 | tee wepn.txt

  if [ ! -f "$HOME/.wepn/logo" ]; then
    mkdir -p "$HOME/.wepn"
    curl -sS https://raw.githubusercontent.com/elemen3/wepn/master/asset/wepn-logo-ascii.txt > "$HOME/.wepn/logo"
  fi

  if [ "$logo_shown" = "false" ]; then

#    while IFS= read -r line; do
#        indented_line="          $line"
#        echo "$indented_line"
#    done < "$HOME/.wepn/logo"

    cat "$HOME/.wepn/logo"



    logo_shown=true
    separator -
    sleep 0.05
    echo
    print center "[bold][blue]WePN MASTER SCRIPT"
    sleep 0.05
    print center "[blue]$version"
    sleep 0.05
    print center "[bold][blue]Author: @macromicro"
    sleep 0.05
    print center "[bold][blue]Telegram: @wepn_group"
    sleep 0.05
    echo
    separator -
#    sleep 10
#    update_upgrade_package_lists  todo uncomment
    clear && printf '\e[3J'
  fi


  #header
#  separator
#  echo -e "\e[1;37;48;5;21m                                                                \e[0m"
#  echo -e "\e[1;37;48;5;20m                    [ WePN MASTER SCRIPT ]                      \e[0m"
#  echo -e "\e[1;37;48;5;19m                          $version                            \e[0m"
#  echo -e "\e[1;37;48;5;18m                     Author: @macromicro                        \e[0m"
#  echo -e "\e[1;37;48;5;17m                                                                \e[0m"
#  separator
}
#----------------------------------------------------------------------------------------------------------------------- clear logs
clear_logs(){
  lines="$1"
  tput cuu $((lines))
  tput ed
}
#----------------------------------------------------------------------------------------------------------------------- menu core functions
goto_menu(){
    if [[ "$selected_menu" == "menu" ]] || [[ "$selected_menu" != "$1" ]]; then
      echo "$1" > /tmp/wepn_selected_menu
      run_menu "$1"
      #selected_menu_index_result="$?"


      eval "selected_menu_array=(\"\${$selected_menu[@]}\")"
      # add Back item to menu items
      if [ "$selected_menu" != "menu" ]; then
        # first item is separator
        if [[ "${selected_menu_array[0]}" =~ ^[-─━=#▦]$ ]]; then
          selected_menu_array=("Back" "${selected_menu_array[@]}")
        else
          selected_menu_array=("Back" "─" "${selected_menu_array[@]}")
        fi
      fi


      selected_menu_item="${selected_menu_array[$selected_menu_index]}"

      #------------------------------------------------------------- generate menu name
      # remove ANSI Escape Codes
      selected_menu_item_unformatted=$(echo "$selected_menu_item" | sed -E 's/\x1B\[[0-9;]*[mGK]//g')
      # remove [bold][white][green]... color codes
      styles=(end bold normal white gray grayd red redl redll green blue yellow cyan)
      styles_expr=$(printf 's/\\[%s\\]//g;' "${styles[@]}")
      selected_menu_item_unformatted=$(echo "$selected_menu_item_unformatted" | sed -e "$styles_expr")

      selected_menu_name="$selected_menu_item_unformatted"
      # lowercase
      selected_menu_name="${selected_menu_name,,}"
      # replace spaces with _
      selected_menu_name="${selected_menu_name// /_}"
      # split by | and chose first part
      selected_menu_name="${selected_menu_name%%|*}"
      # split by & and chose first part
      selected_menu_name="${selected_menu_name%%&*}"
      # combine with path
      selected_menu_name="$selected_menu""__$selected_menu_name"
      echo "$selected_menu_name" > /tmp/wepn_selected_menu_name




      # back
      if [[ "$selected_menu_name" == *"__back" ]]; then
        selected_menu_index=${menu_history[-1]}
        echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
        menu_history=("${menu_history[@]::${#menu_history[@]}-1}")
        selected_menu_name="${selected_menu_name%__*__*}"
        echo "$selected_menu_name" > /tmp/wepn_selected_menu_name
        goto_menu "$selected_menu_name"
      # has function defined
      elif type "fn_$selected_menu_name" >/dev/null 2>&1; then
        menu_history+=($selected_menu_index)
        # also has menu array defined
        if [[ $(declare -p "$selected_menu_name" 2>/dev/null) =~ "declare -a" ]]; then
          selected_menu_index=0
          echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
        else
          clear_menu
          [ $selected_menu_name != "menu__exit" ] && print_menu_header
          print y y ""
        fi
        eval "fn_$selected_menu_name"
      # only has menu array defined
      elif [[ $(declare -p "$selected_menu_name" 2>/dev/null) =~ "declare -a" ]]; then
        menu_history+=($selected_menu_index)
        selected_menu_index=0
        echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
        goto_menu "$selected_menu_name"
      else
        # do nothing and re-render current menu
        selected_menu_name="${selected_menu_name%__*}"
        echo "$selected_menu_name" > /tmp/wepn_selected_menu_name
        goto_menu "$selected_menu_name"
      fi
    fi
}

run_menu(){
	selected_menu="$1"

	eval "local menu_items=(\"\${$selected_menu[@]}\")"
	# add Back item to menu items
  if [ "$selected_menu" != "menu" ]; then
    # first item is separator
    if [[ "${menu_items[0]}" =~ ^[-─━=#▦]$ ]]; then
      menu_items=("Back" "${menu_items[@]}")
    else
      menu_items=("Back" "─" "${menu_items[@]}")
    fi
  fi
	local menu_size="${#menu_items[@]}"
	local menu_limit=$((menu_size - 1))
width=$(tput cols)
	print_menu

	while IFS=$'\n' read -rsn1 input; do

	  # backspace
	  if [ "$(printf '%d' "'$input")" -eq 127 ] && [ "$selected_menu" != "menu" ]; then
	    selected_menu_index=${menu_history[-1]}
	    echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
	    menu_history=("${menu_history[@]::${#menu_history[@]}-1}")
	    selected_menu_name="${selected_menu_name%__*}"
	    goto_menu "$selected_menu_name"
	  fi

		case "$input" in
			$'\x1B')  # ESC ASCII code (https://dirask.com/posts/ASCII-Table-pJ3Y0j)
				read -rsn1 input
				if [ "$input" = "[" ]  # occurs before arrow code
				then
					read -rsn1 input
					case "$input" in
						A)  # Up Arrow
							if [ "$selected_menu_index" -ge 1 ]; then
							  tobe_selected_menu_item="${menu_items[$((selected_menu_index - 1))]}"
							  if [[ ! "$tobe_selected_menu_item" =~ ^[-─━=#▦] ]]; then
							    selected_menu_index=$((selected_menu_index - 1))
							    print_menu
							  else
                  for (( i = $((selected_menu_index - 1)); i >= 0; --i )); do
                    if [[ ! "${menu_items[i]}" =~ ^[-─━=#▦] ]]; then
                      selected_menu_index="$i"
                      print_menu
                      break
                    fi
                  done
							  fi
#                  selected_menu_index=$((selected_menu_index - 2))
                echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
							fi
							;;
						B)  # Down Arrow
							if [ "$selected_menu_index" -lt "$menu_limit" ]; then
							  tobe_selected_menu_item="${menu_items[$((selected_menu_index + 1))]}"
								if [[ ! "$tobe_selected_menu_item" =~ ^[-─━=#▦] ]]; then
                  selected_menu_index=$((selected_menu_index + 1))
                  print_menu
                else
                  for (( i = $((selected_menu_index + 1)); i < $menu_size; ++i )); do
                    if [[ ! "${menu_items[i]}" =~ ^[-─━=#▦] ]]; then
                      selected_menu_index="$i"
                      print_menu
                      break
                    fi
                  done
                fi
#                  selected_menu_index=$((selected_menu_index + 2))
                echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
							fi
							;;
						C)  # Right Arrow
#						  if [ "${menu_items[((menu_size - 1))]}" != \#* ] && [ "$selected_menu_index" != "$((menu_size - 1))" ]; then
              if [[ "${menu_items[((menu_size - 1))]}" != \#* ]] && [ "$selected_menu_index" != "$((menu_size - 1))" ]; then
                selected_menu_index=$((${#menu_items[@]} - 1))
                echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
                print_menu
              fi
							;;
						D)  # Left Arrow
						  if [ "$selected_menu_index" != 0 ]; then
                selected_menu_index=0
                echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
                print_menu
              fi
							;;
					esac
				fi
#				read -rsn5 -t 0.1  # flushing stdin
				;;
			"")  # Enter key
				return "$selected_menu_index"
				;;
		  [hH])  # H key
		      if [ "$selected_menu" != "menu" ]; then
		        selected_menu="$(echo "$selected_menu" | cut -d '_' -f -3)"
		        selected_menu_index=0
		        echo "$selected_menu_index" > /tmp/wepn_selected_menu_index
		        menu_history=("${menu_history[0]}")
		        return "$selected_menu_index"
		      fi
				;;
		  [qQ])  # Q key
    			fn_menu__exit
    		;;
		esac
	done


  # kill resize pid
#	kill "$resize_pid"
}

print_menu_header(){
  tput clear
  echo -e "\033[38;5;245m⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒⬒\033[0m"

  if [ $selected_menu_name == "menu" ]; then
    print center "[bold][blue]WePN MASTER SCRIPT"
  else
    menu_header="$selected_menu_name"
    # uppercase
    menu_header=$(echo $menu_header | tr '[:lower:]' '[:upper:]')
    # replace MENU__ with WePN >
    menu_header="${menu_header//MENU__/\WePN [gray]>[blue] }"
    # replace __ with >
    menu_header="${menu_header//__/ [gray]>[blue] }"
    # replace _ with space
    menu_header="${menu_header//_/ }"
    print center "[bold][blue]$menu_header"
    menu_header_unformatted=$(echo "$(print "$menu_header")" | sed -E 's/\x1B\[[0-9;]*[mGK]//g')
    menu_header_height=$(( ("${#menu_header_unformatted}" + width - 1) / width ))

  fi

  echo -e "\033[38;5;245m⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓⬓\033[0m"
}

print_menu(){
#  check_terminal_size
  clear_menu

  eval "local menu_items=(\"\${$selected_menu[@]}\")"
  # add Back item to menu items
  if [ "$selected_menu" != "menu" ]; then
    # first item is separator
    if [[ "${menu_items[0]}" =~ ^[-─━=#▦]$ ]]; then
      menu_items=("Back" "${menu_items[@]}")
    else
      menu_items=("Back" "─" "${menu_items[@]}")
    fi
  fi
  local menu_size="${#menu_items[@]}"
  global_menu_size=$menu_size

  # to add text below the menu for specific menu
  #  [ "$selected_menu" == "menu__firewall__rules" ] && ((global_menu_size+=2))


  # menu changed?
  if [ "$current_menu" != "$selected_menu" ]; then

    print_menu_header
    reserved_terminal_height=$(tput lines)

    current_menu="$selected_menu"

    prebuilt_menu_items=()
    prebuilt_menu_items_selected=()


  # build menu items once
  	for (( i = 0; i < $menu_size; ++i )); do
      #------------------------------------------------------------- generate menu name

      # remove ANSI Escape Codes
      menu_item_unformatted=$(echo "${menu_items[i]}" | sed -E 's/\x1B\[[0-9;]*[mGK]//g')
      # remove [bold][white][green]... color codes
      styles=(end bold normal white gray grayd red redl redll green blue yellow cyan)

      styles_expr=$(printf 's/\\[%s\\]//g;' "${styles[@]}")
      menu_item_unformatted=$(echo "$menu_item_unformatted" | sed -e "$styles_expr")
#      menu_item_unformatted=$(echo "$menu_item_unformatted" | sed 's/\[[^]]*\]//g')

      menu_name="$menu_item_unformatted"
      # lowercase
      menu_name="${menu_name,,}"
      # replace spaces with _
      menu_name="${menu_name// /_}"
      # split by | and chose first part
      menu_name="${menu_name%%|*}"
      # split by & and chose first part
      menu_name="${menu_name%%&*}"
      # combine with path
      menu_name="$selected_menu_name""__$menu_name"


      # has menu array defined
      if [[ $(declare -p "$menu_name" 2>/dev/null) =~ "declare -a" ]]; then
        menu_right_icon=" > "
        spaces=$((width - ${#menu_item_unformatted} - 5))
      else
        menu_right_icon=" "
        spaces=$((width - ${#menu_item_unformatted} - 3))
      fi

      #------------------------------------------------------------- generate menu items
      menu_item="${menu_items[i]}"


      # default icons
      icon="○"
      [[ $menu_item == \#* ]] && icon=" "
      # selected icons
      icon_selected="●"
      #[ -n "$PUTTY" ] && icon_selected="●"


      # Replace & with space
      menu_item="${menu_item//&/ }"

      # Remove #
      menu_item="${menu_item//#/}"

      # is multipart?
      if [[ $menu_item =~ \| ]]; then
        # Replace | with spaces
        menu_item=$(echo "$menu_item" | sed "s/|/$(printf '%*s' $spaces)/g")
        menu_item_unformatted=$(echo "$menu_item_unformatted" | sed "s/|/$(printf '%*s' $spaces)/g")
      elif ! [[ "$menu_item" =~ ^[-─━=▦]$ ]] && [ "$menu_item" != "Back" ]; then
        # add spaces to the rest
        menu_item="$menu_item$(printf '%*s' $((spaces-1)))"
        menu_item_unformatted="$menu_item_unformatted$(printf '%*s' $((spaces-1)))"
      fi


      # back
      if [ "$menu_item" == "Back" ]; then
        # not selected
        prebuilt_menu_items+=("\033[38;5;245m < \e[1m\e[97mBack\e[0m")
        # selected
        printf -v item "%-$((width))b" " < Back"
        prebuilt_menu_items_selected+=("\e[48;5;27m\e[1m\e[97m${item}\e[0m")
      # separator
      elif [[ "$menu_item" =~ ^[-─━=▦]$ ]]; then
        prebuilt_menu_items+=($(separator "$menu_item"))
        prebuilt_menu_items_selected+=($(separator "$menu_item"))
      # regular
      else
        # Settings icons
        [[ "${menu_item// /}" == "Settings" ]] && icon="○" && icon_selected="⚙"

        # colorize if it contains [bold][white][green]... color codes
        if [[ "$menu_item" =~ \[[^]]*\] ]]; then
          menu_item=$(print n "$menu_item")
        fi

        # not selected
        printf -v item "%-$((width-3-${#menu_right_icon}+${#menu_item}-${#menu_item_unformatted}))b" "$menu_item"
        prebuilt_menu_items+=("\033[38;5;245m $icon \033[0m\e[1m\e[97m$item\033[38;5;245m$menu_right_icon\e[0m")


#        menu_item=$(echo "$menu_item" | sed 's/\(\[red\]\|\[green\]\|\[blue\]\)/[white]/g')


        # selected
        printf -v item "%-$((width-3-${#menu_right_icon}+${#menu_item}-${#menu_item_unformatted}))b" "$menu_item"
        prebuilt_menu_items_selected+=("\e[48;5;27m\e[1m\e[97m $icon_selected ${item}\e[48;5;27m\e[1m\e[97m$menu_right_icon\e[0m")
      fi

  	done
  fi



  # cut menu to fit screen height
  from_index=0
  to_index=$menu_size
  terminal_height=$(tput lines)
  header_height="$((menu_header_height + 4))"


  if [ "$((menu_size + header_height))" -gt "$terminal_height" ]; then

    # catch resize once
    if [ "$reserved_terminal_height" != "$terminal_height" ]; then
      print_menu_header
      reserved_terminal_height="$terminal_height"
    fi

    if [ "$selected_menu_index" -ge "$((terminal_height - header_height))" ]; then
       from_index=$((selected_menu_index - terminal_height + header_height + 1))
    fi
    to_index=$((terminal_height + from_index - header_height))
#    echo "$terminal_height $menu_size $selected_menu_index $from_index $to_index" >> log
    last_item="${menu_items[ to_index - 1]}"
#    echo $last_item >> log
    if [[ "$last_item" =~ ^[-─━=▦]$ ]]; then
      ((to_index--))
    fi
    global_menu_size=$((to_index-from_index))
  fi





  # loop over menu items and print
	for (( j = $from_index; j < $to_index; ++j ))
	do
	  # selected
		if [ "$j" = "$selected_menu_index" ]; then
		  echo -e "${prebuilt_menu_items_selected[j]}"
    # not selected
    else
      echo -e "${prebuilt_menu_items[j]}"
		fi
	done

	separator

  # add text below the menu for specific menu
#  if [ "$selected_menu" == "menu__firewall__rules" ]; then
#    if [ "$selected_menu_index" -gt 0 ] && [ "$selected_menu_index" -lt "$((menu_size - 3))" ]; then
#      echo
#      print "[bold][cyan]Press Enter to delete the rule"
#    else
#      echo
#      echo
#    fi
#  fi

}

back_to_menu(){
  # ask to hit enter to continue
  if [ "$1" = "enter" ]; then
    waiting_to_press_key=true
    echo "$waiting_to_press_key" > /tmp/wepn_waiting_to_press_key
    print y y ""
    print y y "[bold][cyan]Press Enter to continue..."
    echo
    read -s -p ""
    waiting_to_press_key=false
    echo "$waiting_to_press_key" > /tmp/wepn_waiting_to_press_key
    printed=""
    echo "$printed" > /tmp/wepn_printed
  fi


  global_menu_size=0
  menu_history=("${menu_history[@]::${#menu_history[@]}-1}")
  selected_menu_name="${selected_menu_name%__*}"
  echo "$selected_menu_name" > /tmp/wepn_selected_menu_name
  clear
  print_menu_header
  _selected_menu="$selected_menu"
  selected_menu=""
  goto_menu "$_selected_menu"
}

clear_menu(){
  if [ $global_menu_size -ne 0 ]; then
     tput cuu $((global_menu_size+1)) && tput ed
#     global_menu_size=0
  fi
}
#----------------------------------------------------------------------------------------------------------------------- menu functions
#------------------------------------------------------------ block iranian websites
fn_menu__firewall__websites__iranian_websites(){
  install_packages iptables ipset

  if ! ipset list wepn_iranian_websites_set &> /dev/null; then
    print "[bold][blue]Are you sure you want to block outgoing traffic from your server to Iranian websites?"
    confirmation_dialog
    response="$?"
    clear_logs 2
    if [ $response -eq 1 ]; then
      load_iran_ips
      print "[blue]Blocking all Iranian websites..."
      echo
      create_or_add_to_table wepn_iranian_websites BLOCK_WEBSITE "${iran_ips[@]}"
      echo
      echo
      print "[bold][green]All Iranian websites are blocked."
      back_to_menu enter
    else
      back_to_menu
    fi
  else
    print y y "[bold][green]Iranian websites are already blocked."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ porn websites
fn_menu__firewall__websites__porn_websites(){
  install_packages iptables ipset

  if ! ipset list wepn_porn_websites_set &> /dev/null; then

    print "[bold][blue]Are you sure you want to block Porn websites?"
    confirmation_dialog
    response="$?"
    clear_logs 1
    if [ $response -eq 1 ]; then
      load_porn_ips
      print "[blue]Blocking Porn Websites..."
      echo
      create_or_add_to_table wepn_porn_websites BLOCK_WEBSITE "${porn_ips[@]}"
      echo
      echo
      print "[bold][green]All Porn websites are blocked."
      back_to_menu enter
    else
      back_to_menu
    fi
  else
    print "[bold][green]Porn websites are already blocked."
    back_to_menu enter
  fi

}
#------------------------------------------------------------ speedtest
fn_menu__firewall__websites__speedtest(){

  domains=(
  speedtest.net
  www.speedtest.net
  c.speedtest.net
  speedcheck.org
  www.speedcheck.org
  a1.etrality.com
  net.etrality.com
  api.speedspot.org
  fast.com
  www.fast.com
  )

  speedtest_ips=()


  install_packages iptables ipset dnsutils

  if ! ipset list wepn_speedtest_set &> /dev/null; then

    print "[bold][blue]Are you sure you want to block Speedtest?"
    confirmation_dialog
    response="$?"
    clear_logs 1
    if [ $response -eq 1 ]; then
      print "[bold][blue]Blocking speedtest related websites and apps..."

      for domain in "${domains[@]}"; do
        _speedtest_ips=($(host "$domain" | awk '/has address/ {print $NF}'))
        speedtest_ips+=("${_speedtest_ips[@]}")
      done

      create_or_add_to_table wepn_speedtest BLOCK_WEBSITE "${speedtest_ips[@]}"
      clear_logs 1
      print "[bold][green][yellow]Speedtest[green], [yellow]Speedcheck[green] and [yellow]fast.com[green] websites and apps are all blocked."

      back_to_menu enter
    else
      back_to_menu
    fi


  else
    print "[bold][green]Speedtest is already blocked."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ tunneling servers
fn_menu__firewall__allow_tunneling_server(){
  install_packages iptables ipset

  if ipset list wepn_iranian_websites_set &> /dev/null; then

      while true; do

          show_cursor
          read -r -p  "$(print "[bold][blue]Please enter the IP address of your Iranian Tunneling Server which you are using to tunnel to this server: ")" response
          clear_logs 2
          hide_cursor

          # left blank
          if [ -z "$response" ]; then
            print "[bold][yellow]Left blank!"
            break
          # ip is valid (1.1.1.1  1.1.1./24)
         elif [[ $response =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[12][0-9]|3[0-2]))?$ ]]; then
            if ipset list wepn_tunnel_set &> /dev/null && ipset list wepn_tunnel_set | grep -q "$response"; then
              print "[bold][green]This server is already whitelisted."
              break
            else
              print "[blue]Whitelisting your Tunneling server ([bold][green]$response[end][blue])..."
              tunnel_ips=("$response")
              create_or_add_to_table wepn_tunnel ALLOW_WEBSITE "${tunnel_ips[@]}"
              clear_logs 1
              print "[bold][green]Your Tunneling server is whitelisted."
              break
            fi
          else
            print "[bold][red]IP address [bold][yellow]$response [bold][red]is not valid. Please try again."
            sleep 2
            clear_logs 1
          fi
      done

      back_to_menu enter

  else
    print "[bold][blue]As of your current policy, since Iranian websites are not yet blocked, [green]your Iranian Server [blue]is not present in the blacklist. Therefore, there is no need to whitelist it."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ arvancloud
fn_menu__firewall__allow_arvancloud_cdn(){
  install_packages iptables ipset

  if ipset list wepn_iranian_websites_set &> /dev/null; then
    if ! ipset list wepn_arvancloud_set &> /dev/null; then
      load_arvancloud_ips

      print "[blue]If you have block Iranian websites while tunneling through Arvancloud CDN or servers on port [bold][green]443[normal][blue], it is imperative to whitelist Arvancloud."
      echo
      print "[bold][blue]Are you sure you want to whitelist Arvancloud?"
      confirmation_dialog
      response="$?"
      clear_logs 5
      if [ $response -eq 1 ]; then
        print "[blue]Whitelisting Arvancloud..."
        create_or_add_to_table wepn_arvancloud ALLOW_WEBSITE "${arvancloud_ips[@]}"
        clear_logs 1
        print "[bold][green]Arvancloud is whitelisted."
        back_to_menu enter
      else
        back_to_menu
      fi
    else
      print "[bold][green]Arvancloud is already whitelisted."
      back_to_menu enter
    fi
  else
    print "[bold][blue]As of your current policy, since Iranian websites are not yet blocked, [green]Arvancloud [blue]is not present in the blacklist. Therefore, there is no need to whitelist it."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ derakcloud
fn_menu__firewall__allow_derakcloud_cdn(){
  install_packages iptables ipset

  if ipset list wepn_iranian_websites_set &> /dev/null; then
  if ! ipset list wepn_derakcloud_set &> /dev/null; then

    print "[blue]If you have block Iranian websites while tunneling through Derakcloud CDN or servers on port [bold][green]443[normal][blue], it is imperative to whitelist Derakcloud."
    echo
    print "[bold][blue]Are you sure you want to whitelist Derakcloud?"
    confirmation_dialog
    response="$?"
    clear_logs 5
    if [ $response -eq 1 ]; then
      load_derakcloud_ips
      print "[blue]Whitelisting Derakcloud..."
      create_or_add_to_table wepn_derakcloud ALLOW_WEBSITE "${derakcloud_ips[@]}"
      clear_logs 1
      print "[bold][green]Derakcloud is whitelisted."
      back_to_menu enter
    else
      back_to_menu
    fi
  else
    print "[bold][green]Derakcloud is already whitelisted."
    back_to_menu enter
  fi
  else
    print "[bold][blue]As of your current policy, since Iranian websites are not yet blocked, [green]Derakcloud [blue]is not present in the blacklist. Therefore, there is no need to whitelist it."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ block specific website
fn_menu__firewall__block_specific_website(){
  install_packages iptables ipset

  while true; do

    show_cursor
    read -e -p "$(print "[bold][blue]Enter the Domain name: ")" domain
    clear_logs 1
    hide_cursor

    if [ -z "$domain" ]; then
      # left blank
      print "[bold][yellow]Left blank!"
      break
      # is valid domain name?
    elif [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,10})+$ ]]; then
      # check if website is not in black list
      if ! ipset list wepn_block_websites_set &>/dev/null || { ipset list wepn_block_websites_set &>/dev/null && ! ipset list wepn_block_websites_set 2>/dev/null | grep -q "\"$domain\""; }; then
        if ! [ -z "$(host $domain)" ] && ! echo "$(host $domain)" | grep -qi "not found"; then
          install_packages iptables ipset jq
          #------------------------------------------------------ download subfinder
          # check if /root/.wepn/subfinder doesn't exists
          if [ ! -x "/root/.wepn/subfinder" ]; then
            # print "[bold][blue]Installing subfinder..."
            curl -sS -L "https://github.com/elemen3/wepn/raw/master/subfinder" -o /root/.wepn/subfinder
            chmod +x /root/.wepn/subfinder
          fi

          #------------------------------------------------------ find all subdomains
          print "[bold][blue]Discovering all subdomains..."
          readarray -t subdomains <<< $( /root/.wepn/subfinder -silent -d "$domain" | sort )
          clear_logs 1
          #------------------------------------------------------ loop over subdomains
          print "[bold][blue]Discovering all IP addresses associated with:"
          echo

          ip_addresses=()

          for (( j=0; j<${#subdomains[@]}; j++ )); do
            #       for subdomain in "${subdomains[@]}"; do
            subdomain="${subdomains[$j]}"
            print "[blue]$subdomain..."
            echo
            show_progress $((j + 1)) ${#subdomains[@]}
            #------------------------------------------------------ get all ip addresses using check-host.net API
            # get request_id
            request_id=$(curl -sSH "Accept: application/json" "https://check-host.net/check-ping?host=$subdomain&max_nodes=0" | jq -r '.request_id')
            #echo $request_id
            sleep 1.1
            checkhost_json=$(curl -sSH "Accept: application/json" "https://check-host.net/check-result/$request_id")
            #echo $checkhost_json

            _ip_addresses=($(echo "$checkhost_json" | jq -r 'to_entries[] | select(.value != null) | .value[][] | select(.[2] != null) | .[2]' | sort -u))

            for ip in "${_ip_addresses[@]}"; do
            # echo "Adding $ip to the list"
             [[ ! " ${ip_addresses[@]} " =~ " $ip " ]] && ip_addresses+=("$ip")
            done
            clear_logs 2
            print "[blue]$subdomain"
          done

          block_websites=()

          for ip in "${ip_addresses[@]}"; do
            block_websites+=("$ip>$domain")
          done


          create_or_add_to_table wepn_block_websites BLOCK_WEBSITE "${block_websites[@]}"
          show_headers

          print "[bold][green]The website ([red]$domain[green]) and all its subdomains are blocked."
          break

        else
          print "[bold][yellow]Domain has no IP address."
          break
        fi

      else
        print "[bold][green]Website is already blocked."
        break
      fi
    else
      print "[bold][red]Domain is not valid. Please try again."
      sleep 2
      clear_logs 1
    fi
  done



  back_to_menu enter
}
#------------------------------------------------------------ allow specific website
fn_menu__firewall__allow_specific_website(){
  install_packages iptables ipset


  if ipset list wepn_iranian_websites_set &> /dev/null || ipset list wepn_porn_websites_set &> /dev/null || ipset list wepn_speedtest_set &> /dev/null || ipset list wepn_block_websites_set &> /dev/null ; then

    while true; do

      show_cursor
      read -e -p "$(print "[bold][blue]Enter the Domain name: ")" domain
      clear_logs 1
      hide_cursor

      if [ -z "$domain" ]; then
        # left blank
        print "[bold][yellow]Left blank!"
        break
        # is valid domain name?
      elif [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,10})+$ ]]; then
        # check if website is not in white list
        if ! ipset list wepn_allow_websites_set &>/dev/null || { ipset list wepn_allow_websites_set &>/dev/null && ! ipset list wepn_allow_websites_set 2>/dev/null | grep -q "\"$domain\""; }; then
          # check if website is not in black list
          if ! ipset list wepn_block_websites_set &>/dev/null || { ipset list wepn_block_websites_set &>/dev/null && ! ipset list wepn_block_websites_set 2>/dev/null | grep -q "\"$domain\""; }; then
            if ! [ -z "$(host $domain)" ] && ! echo "$(host $domain)" | grep -qi "not found"; then
              install_packages iptables ipset jq
              #------------------------------------------------------ download subfinder
              # check if /root/.wepn/subfinder doesn't exists
              if [ ! -x "/root/.wepn/subfinder" ]; then
                # print "[bold][blue]Installing subfinder..."
                curl -sS -L "https://github.com/elemen3/wepn/raw/master/subfinder" -o /root/.wepn/subfinder
                chmod +x /root/.wepn/subfinder
              fi

              #------------------------------------------------------ find all subdomains
              print "[bold][blue]Discovering all subdomains..."
              readarray -t subdomains <<< $( /root/.wepn/subfinder -silent -d "$domain" | sort )
              clear_logs 1
              #------------------------------------------------------ loop over subdomains
              print "[bold][blue]Discovering all IP addresses associated with:"
              echo

              ip_addresses=()

              for (( j=0; j<${#subdomains[@]}; j++ )); do
                #       for subdomain in "${subdomains[@]}"; do
                subdomain="${subdomains[$j]}"
                print "[blue]$subdomain..."
                echo
                show_progress $((j + 1)) ${#subdomains[@]}
                #------------------------------------------------------ get all ip addresses using check-host.net API
                # get request_id
                request_id=$(curl -sSH "Accept: application/json" "https://check-host.net/check-ping?host=$subdomain&max_nodes=0" | jq -r '.request_id')
                #echo $request_id
                sleep 1.1
                checkhost_json=$(curl -sSH "Accept: application/json" "https://check-host.net/check-result/$request_id")
                #echo $checkhost_json

                _ip_addresses=($(echo "$checkhost_json" | jq -r 'to_entries[] | select(.value != null) | .value[][] | select(.[2] != null) | .[2]' | sort -u))

                for ip in "${_ip_addresses[@]}"; do
                # echo "Adding $ip to the list"
                 [[ ! " ${ip_addresses[@]} " =~ " $ip " ]] && ip_addresses+=("$ip")
                done
                clear_logs 2
                print "[blue]$subdomain"
              done

              allow_websites=()

              for ip in "${ip_addresses[@]}"; do
                allow_websites+=("$ip>$domain")
              done


              create_or_add_to_table wepn_allow_websites ALLOW_WEBSITE "${allow_websites[@]}"
              show_headers

              print "[bold][green]The website ([green]$domain[green]) and all its subdomains are whitelisted."
              break

            else
              print "[bold][yellow]Domain has no IP address."
              break
            fi
          else
            print "[bold][red]Website is already in blacklist. You cannot simultaneously block and whitelist a domain!"
            break
          fi

        else
          print "[bold][green]Website is already whitelisted."
          break
        fi
      else
        print "[bold][red]Domain is not valid. Please try again."
        sleep 2
        clear_logs 1
      fi

    done
    back_to_menu enter

  else
    print "[bold][blue]As of your current policy, since you have not blocked any websites yet, there is no need to whitelist anything."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ block Attacks from China
fn_menu__firewall__block_attacks_from_china(){
  install_packages iptables ipset

  if ! ipset list wepn_china_set &> /dev/null; then
    print "[bold][blue]Are you sure you want to block attacks from China?"
    confirmation_dialog
    response="$?"
    clear_logs 1
    if [ $response -eq 1 ]; then
      load_china_ips
      print "[blue]Blocking Chinese attackers..."
      echo
      create_or_add_to_table wepn_china BLOCK_ATTACK "${china_ips[@]}"
      echo
      echo
      print "[bold][green]Chinese attackers are blocked."
      back_to_menu enter
    else
      back_to_menu
    fi
  else
    print "[bold][green]Chinese attackers are already blocked."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ block Attacks from Russia
fn_menu__firewall__block_attacks_from_russia(){
  clear_menu
  install_packages iptables ipset

  if ! ipset list wepn_russia_set &> /dev/null; then

    print "[bold][blue]Are you sure you want to block attacks from Russia?"
    confirmation_dialog
    response="$?"
    clear_logs 1
    if [ $response -eq 1 ]; then
      load_russia_ips
      print "[blue]Blocking Russian attackers..."
      echo
      create_or_add_to_table wepn_russia BLOCK_ATTACK "${russia_ips[@]}"
      echo
      echo
      print "[bold][green]Russian attackers are blocked."
      back_to_menu enter
    else
      back_to_menu
    fi
  else
    print "[bold][green]Russian attackers are already blocked."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ block Individual Attacker
fn_menu__firewall__block_individual_attacker(){
  install_packages iptables ipset

  while true; do

      show_cursor
      read -e -p "$(print "[bold][blue]Enter the IP address: ")" response
      clear_logs 1
      hide_cursor

      if [ -z "$response" ]; then
        # left blank
        print "[bold][yellow]Left blank!"
        break
      # is valid IP address?
      elif [[ $response =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[12][0-9]|3[0-2]))?$ ]]; then
          ip_addresses=("$response")

          create_or_add_to_table wepn_attackers BLOCK_ATTACK "${ip_addresses[@]}"
          print "[bold][green]The IP address ([red]$response[green]) is blocked."
          break
      else
          print "[bold][red]IP address [bold][yellow]$response [bold][red]is not valid. Please try again."
          sleep 2
          clear_logs 1
      fi
  done
  back_to_menu enter
}
#------------------------------------------------------------ block IP Scan
fn_menu__firewall__block_ip_scan(){
  install_packages iptables ipset

  if ! iptables -nL wepn_ipscan_chain >/dev/null 2>&1; then

    print "[bold][blue]Are you sure you want to prevent IP scans from going through your server?"
    confirmation_dialog
    response="$?"
    clear_logs 2
    if [ $response -eq 1 ]; then
      print "[blue]Blocking IP Scans..."
      create_or_add_to_table wepn_ipscan BLOCK_IPSCAN
      sleep 1
      clear_logs 1
      print "[bold][green]IP Scans are blocked."
      back_to_menu enter
    else
      back_to_menu
    fi
  else
    print "[bold][green]IP Scans are already blocked."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ block BitTorrent
fn_menu__firewall__block_bittorrent(){
  install_packages iptables ipset

  if ! iptables -nL wepn_bittorrent_chain >/dev/null 2>&1; then

    print "[bold][blue]Please consider that it will block ports from [yellow]6881[blue] to [yellow]6889[blue], as they are common BitTorrent ports."
    echo
    print "[bold][blue]Are you sure you want to block BitTorrent protocol?"
    confirmation_dialog
    response="$?"
    clear_logs 4
    if [ $response -eq 1 ]; then
      print "[blue]Blocking BitTorrent..."
      create_or_add_to_table wepn_bittorrent BLOCK_BITTORRENT
      sleep 1
      clear_logs 1
      print "[bold][green]BitTorrent is blocked."
      back_to_menu enter
    else
      back_to_menu
    fi
  else
    print "[bold][green]BitTorrent is already blocked."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ Rules
fn_menu__firewall__settings__view_all_rules(){
  install_packages iptables ipset
  clear_menu

  iran_ips=($(ipset -q list wepn_iranian_websites_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
  tunnel_ips=($(ipset -q list wepn_tunnel_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
  arvancloud_ips=($(ipset -q list wepn_arvancloud_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
  derakcloud_ips=($(ipset -q list wepn_derakcloud_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
  porn_ips=($(ipset -q list wepn_porn_websites_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
  speedtest_ips=($(ipset -q list wepn_speedtest_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
  _block_websites=($(ipset -q list wepn_block_websites_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $3}'))
  block_websites=($(printf "%s\n" "${_block_websites[@]}" | sort -u))
  _allow_websites=($(ipset -q list wepn_allow_websites_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $3}'))
  allow_websites=($(printf "%s\n" "${_allow_websites[@]}" | sort -u))
  china_ips=($(ipset -q list wepn_china_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
  russia_ips=($(ipset -q list wepn_russia_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
  attacker_ips=($(ipset -q list wepn_attackers_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))




  any_rules=0
  num=0
  rules=()
  menu__firewall__settings__view_all_rules=()



  if [ ${#iran_ips[@]} -gt 0 ]; then
    ((num++))
    rules+=(wepn_iranian_websites)
    menu__firewall__settings__view_all_rules+=("#Iranian Websites|[red]BLOCKED")
    menu__firewall__settings__view_all_rules+=("-")
    any_rules=1
  fi

  for ip in "${tunnel_ips[@]}"; do
    if [ ${#tunnel_ips[@]} -gt 0 ]; then
      ((num++))
      rules+=("wepn_tunnel$ip")
      menu__firewall__settings__view_all_rules+=("$( print n "#Tunnel&([green]$ip[white])|[green]ALLOWED")")
      menu__firewall__settings__view_all_rules+=("-")
      any_rules=1
    fi
  done

  if [ ${#arvancloud_ips[@]} -gt 0 ]; then
    ((num++))
    rules+=(wepn_arvancloud)
    menu__firewall__settings__view_all_rules+=("#Arvancloud CDN|[green]ALLOWED")
    menu__firewall__settings__view_all_rules+=("-")
    any_rules=1
  fi

  if [ ${#derakcloud_ips[@]} -gt 0 ]; then
    ((num++))
    rules+=(wepn_derakcloud)
    menu__firewall__settings__view_all_rules+=("#Derakcloud CDN|[green]ALLOWED")
    menu__firewall__settings__view_all_rules+=("-")
    any_rules=1
  fi

  if [ ${#porn_ips[@]} -gt 0 ]; then
    ((num++))
    rules+=(wepn_porn_websites)
    menu__firewall__settings__view_all_rules+=("#Porn Websites|[red]BLOCKED")
    menu__firewall__settings__view_all_rules+=("-")
    any_rules=1
  fi

  if [ ${#speedtest_ips[@]} -gt 0 ]; then
    rules+=(wepn_speedtest)
    ((num++))
    menu__firewall__settings__view_all_rules+=("#Speedtest|[red]BLOCKED")
    menu__firewall__settings__view_all_rules+=("-")
    any_rules=1
  fi


  if [ ${#block_websites[@]} -gt 0 ]; then
    for item in "${block_websites[@]}"; do
      domain=$(echo "$item" | tr -d '"')
      rules+=("block_websites$domain")
      ((num++))
      menu__firewall__settings__view_all_rules+=("#$domain[white]|[red]BLOCKED")
      menu__firewall__settings__view_all_rules+=("-")
      any_rules=1
    done
  fi

  if [ ${#allow_websites[@]} -gt 0 ]; then
    for item in "${allow_websites[@]}"; do
      domain=$(echo "$item" | tr -d '"')
      rules+=("allow_websites$domain")
      ((num++))
      menu__firewall__settings__view_all_rules+=("#$domain[white]|[green]ALLOWED")
      menu__firewall__settings__view_all_rules+=("-")
      any_rules=1
    done
  fi

  if [ ${#china_ips[@]} -gt 0 ]; then
    rules+=(china_ips)
    ((num++))
    menu__firewall__settings__view_all_rules+=("#Chinese Attackers|[red]BLOCKED")
    menu__firewall__settings__view_all_rules+=("-")
    any_rules=1
  fi

  if [ ${#russia_ips[@]} -gt 0 ]; then
    rules+=(russia_ips)
    ((num++))
    menu__firewall__settings__view_all_rules+=("#Russian Attackers|[red]BLOCKED")
    menu__firewall__settings__view_all_rules+=("-")
    any_rules=1
  fi

  if [ ${#attacker_ips[@]} -gt 0 ]; then
    for ip in "${attacker_ips[@]}"; do
      rules+=(wepn_attackers)
      ((num++))
      menu__firewall__settings__view_all_rules+=("#Attacker&([red]$ip[white])|[red]BLOCKED")
      menu__firewall__settings__view_all_rules+=("-")
      any_rules=1
    done
  fi


  if iptables -L wepn_ipscan_chain >/dev/null 2>&1; then
    rules+=(wepn_ipscan)
    ((num++))
    menu__firewall__settings__view_all_rules+=("#IP Scans|[red]BLOCKED")
    menu__firewall__settings__view_all_rules+=("-")
    [ "$any_rules" -ne 1 ] && any_rules=2
  fi

  if iptables -L wepn_bittorrent_chain >/dev/null 2>&1; then
    rules+=(wepn_bittorrent)
    ((num++))
    menu__firewall__settings__view_all_rules+=("#BitTorrent|[red]BLOCKED")
    menu__firewall__settings__view_all_rules+=("-")
    [ "$any_rules" -ne 1 ] && any_rules=2
  fi

  #remove the last line
  menu__firewall__settings__view_all_rules=("${menu__firewall__settings__view_all_rules[@]:0:${#menu__firewall__settings__view_all_rules[@]}-1}")





  if [ "$any_rules" -eq 0 ]; then
    print "[bold][yellow]No rules applied yet."
    back_to_menu enter
  elif [ "$any_rules" -eq 1 ]; then
    #replace the last line

    goto_menu "menu__firewall__settings__view_all_rules"

#      echo
#      print "[bold][blue]Interested in detailed rules?"
#      confirmation_dialog
#      response="$?"
#      clear_logs 2
#      if [ $response -eq 1 ]; then
#        view_rules_in_detail
#      fi
#      back_to_menu enter
  else
    back_to_menu enter
  fi
}

view_rules_in_detail(){
  # Find the longest value in the arrays
  max_length=0
  for val in "${iran_ips[@]}" "${arvancloud_ips[@]}" "${derakcloud_ips[@]}" "${allowed_ips[@]}" "${porn_ips[@]}" "${speedtest_ips[@]}" "${block_websites[@]}" "${allow_websites[@]}" "${china_ips[@]}" "${russia_ips[@]}"  "${attacker_ips[@]}"; do
    len=${#val}
    if ((len > max_length)); then
      max_length=$len
    fi
  done

  max_length=50 #todo calculate it?

  # Print the top border line
  printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"

  # Print the header row
#      printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "IP RANGE" "STATUS"
  printf "|\033[1m %-${max_length}s\033[0m | \033[1;37m%-7s\033[0m |\n" "IP RANGE" "STATUS"


  # Print the border line below the header row
  printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"


  if [[ ${#iran_ips[@]} -gt 0 ]]; then
      for val in "${iran_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#tunnel_ips[@]} -gt 0 ]]; then
      for val in "${tunnel_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;32m%-7s\033[0m |\n" "${val}" "ALLOWED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#arvancloud_ips[@]} -gt 0 ]]; then
      for val in "${arvancloud_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;32m%-7s\033[0m |\n" "${val}" "ALLOWED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#derakcloud_ips[@]} -gt 0 ]]; then
      for val in "${derakcloud_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;32m%-7s\033[0m |\n" "${val}" "ALLOWED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#porn_ips[@]} -gt 0 ]]; then
      for val in "${porn_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#speedtest_ips[@]} -gt 0 ]]; then
      for val in "${speedtest_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#block_websites[@]} -gt 0 ]]; then
      for val in "${block_websites[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "$(echo "$item" | tr -d '"')" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#allow_websites[@]} -gt 0 ]]; then
      for val in "${allow_websites[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "$(echo "$item" | tr -d '"')" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#china_ips[@]} -gt 0 ]]; then
      for val in "${china_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#russia_ips[@]} -gt 0 ]]; then
      for val in "${russia_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#attacker_ips[@]} -gt 0 ]]; then
      for val in "${attacker_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi



}
#------------------------------------------------------------ Clear Rules
fn_menu_19(){
  install_packages iptables ipset
  clear_menu


#  if ipset -q list wepn_iranian_websites_set &>/dev/null || ipset -q list wepn_tunnel_set &>/dev/null || ipset -q list wepn_arvancloud_set &>/dev/null || ipset -q list wepn_derakcloud_set &>/dev/null || ipset -q list wepn_porn_websites_set &>/dev/null; then
  if iptables-save | grep -q -E '^:(wepn_[^ ]+)'; then
    print "[bold][blue]Are you sure you want to delete all the rules?"
    confirmation_dialog
    response="$?"
    clear_logs 1
    if [ $response -eq 1 ]; then
      print "[blue]Cleaning up..."

      ipset -q list wepn_iranian_websites_set &>/dev/null && delete_table wepn_iranian_websites
      ipset -q list wepn_tunnel_set &>/dev/null && delete_table wepn_tunnel
      ipset -q list wepn_arvancloud_set &>/dev/null && delete_table wepn_arvancloud
      ipset -q list wepn_derakcloud_set &>/dev/null && delete_table wepn_derakcloud
      ipset -q list wepn_porn_websites_set &>/dev/null && delete_table wepn_porn_websites
      ipset -q list wepn_speedtest_set &>/dev/null && delete_table wepn_speedtest
      ipset -q list wepn_block_websites_set &>/dev/null && delete_table wepn_block_websites
      ipset -q list wepn_allow_websites_set &>/dev/null && delete_table wepn_allow_websites
      ipset -q list wepn_china_set &>/dev/null && delete_table wepn_china
      ipset -q list wepn_russia_set &>/dev/null && delete_table wepn_russia
      ipset -q list wepn_attackers_set &>/dev/null && delete_table wepn_attackers
      iptables -L wepn_ipscan_chain >/dev/null 2>&1 &&  delete_table wepn_ipscan
      iptables -L wepn_bittorrent_chain >/dev/null 2>&1 &&  delete_table wepn_bittorrent



      # truncate
      echo > /root/.wepn/iptables-rules
      echo > /root/.wepn/ipset-rules
#      grep -q 'wepn_' /etc/iptables/rules.v4 && echo > /etc/iptables/rules.v4
#      systemctl restart netfilter-persistent



      clear_logs 1
      print "[bold][green]Cleaned up."
      back_to_menu enter
    else
      back_to_menu
    fi
  else
     print "[bold][yellow]No rules applied yet."
     back_to_menu enter
  fi



}
#------------------------------------------------------------------------------------------------------- Exit
fn_menu__exit(){

  # stop background process
  kill -9 "$terminal_resize_pid" 2>/dev/null
  # delete all tmp shared vars
  rm -rf /tmp/wepn_*

  # restore resolv.conf
  cp -f /etc/resolv.conf.bak /etc/resolv.conf 2>/dev/null || :
  rm -f /etc/resolv.conf.bak


  clear_menu
  selected_menu_name="menu"
  print_menu_header
  echo

  width=$((width-2))
  exit_msg1="Appreciate your taking the time to play with my script."
  exit_msg2="I hope you found it helpful."
  exit_msg3="Feedback and bug reports are warmly welcomed."

  exit_msg4="Telegram: @wepn_group"

  exit_msg5="DONATE IN TRON"
  exit_msg6="TUPQdSRd2XW9AUo1MCX1SnmTJkbrjqmRtC"

  exit_msg7="❤ ❤ ❤"
  exit_msg8="❤ ❤"
  exit_msg9="❤"

  padding=$(( ($width - ${#exit_msg1}) / 2 ))
  printf "\\033[1m\033[38;5;39m%*s%s%*s\033[0m\n" $padding '' "$exit_msg1" $padding ''
  sleep 0.05
  padding=$(( ($width - ${#exit_msg2}) / 2 ))
  printf "\033[1m\033[38;5;39m%*s%s%*s\033[0m\n" $padding '' "$exit_msg2" $padding ''
  sleep 0.05
  padding=$(( ($width - ${#exit_msg3}) / 2 ))
  printf "\033[1m\033[38;5;39m%*s%s%*s\033[0m\n" $padding '' "$exit_msg3" $padding ''
  sleep 0.05
  echo

  padding=$(( ($width - ${#exit_msg4}) / 2 ))
  printf "\033[1;32m%*s%s%*s\033[0m\n" $padding '' "$exit_msg4" $padding ''
  sleep 0.05
  echo

  padding=$(( ($width - ${#exit_msg5}) / 2 ))
  printf "\033[1m\033[38;5;39m%*s%s%*s\033[0m\n" $padding '' "$exit_msg5" $padding ''
  sleep 0.05
  padding=$(( ($width - ${#exit_msg6}) / 2 ))
  printf "\033[1m\033[38;5;39m%*s%s%*s\033[0m\n" $padding '' "$exit_msg6" $padding ''
  sleep 0.05
  echo

  padding=$(( ($width - ${#exit_msg7}) / 2 ))
  printf "\033[1m\033[38;5;39m%*s%s%*s\033[0m\n" $padding '' "$exit_msg7" $padding ''
  sleep 0.05
  padding=$(( ($width - ${#exit_msg8}) / 2 ))
  printf "\033[1m\033[38;5;39m%*s%s%*s\033[0m\n" $padding '' "$exit_msg8" $padding ''
  sleep 0.05
  padding=$(( ($width - ${#exit_msg9}) / 2 ))
  printf "\033[1m\033[38;5;39m%*s%s%*s\033[0m\n" $padding '' "$exit_msg9" $padding ''
  echo

  show_cursor

  exit
}
#----------------------------------------------------------------------------------------------------------------------- iptables functions
create_or_add_to_table(){
  local set="$1_set"
  local chain="$1_chain"
  local rule="$2"
  shift 2
  local ips=("$@")


  if [ "$rule" != "BLOCK_IPSCAN" ] && [ "$rule" != "BLOCK_BITTORRENT" ] ; then
    # create set if does not exist
    if ! ipset list "$set" &>/dev/null; then
      ipset create $set hash:net comment maxelem 20000
    fi

    # add all ips to set
    for (( i=0; i<${#ips[@]}; i++ ))
    do

      # ip and comment  1.2.3.4>some_comment
      if [[ "${ips[$i]}" =~ ">" ]]; then
        ip=$(echo "${ips[$i]}" | cut -d '>' -f 1)
        comment=$(echo "${ips[$i]}" | cut -d '>' -f 2)
      else
        comment=""
        ip="${ips[$i]}"
      fi



      if ! ipset test $set "$ip" &> /dev/null; then
        if [[ -z "$comment" ]]; then
          ipset add $set "$ip"
        else
          ipset add $set "$ip" comment "$comment"
        fi
      fi

      [ "${#ips[@]}" -gt 50 ] && show_progress $((i + 1)) ${#ips[@]}

    done
  fi

  # create chain
  if ! iptables -nL $chain >/dev/null 2>&1; then
    iptables -N $chain

    if [ "$rule" == "BLOCK_WEBSITE" ]; then
      iptables -I $chain -p tcp --dport 80 -m set --match-set $set dst -j REJECT
      iptables -I $chain -p tcp --dport 443 -m set --match-set $set dst -j REJECT
      iptables -I OUTPUT 1 -j $chain
      iptables -I FORWARD 1 -j $chain
      if iptables -nL wepn_allow_websites_chain >/dev/null 2>&1; then
        iptables -D OUTPUT -j wepn_allow_websites_chain
        iptables -I OUTPUT 1 -j wepn_allow_websites_chain
        iptables -D FORWARD -j wepn_allow_websites_chain
        iptables -I FORWARD 1 -j wepn_allow_websites_chain
      fi
    elif [ "$rule" == "ALLOW_WEBSITE" ]; then
      iptables -I $chain -p tcp --dport 80 -m set --match-set $set dst -j ACCEPT
      iptables -I $chain -p tcp --dport 443 -m set --match-set $set dst -j ACCEPT
      iptables -I OUTPUT 1 -j $chain
      iptables -I FORWARD 1 -j $chain
    elif [ "$rule" == "BLOCK_ATTACK" ]; then
      iptables -I $chain -m set --match-set $set src -j DROP
      iptables -I INPUT 1 -j $chain
    elif [ "$rule" == "BLOCK_IPSCAN" ]; then

      iptables -I $chain -d 10.0.0.0/8 -j DROP
      iptables -I $chain -d 172.16.0.0/12 -j DROP
      iptables -I $chain -d 192.168.0.0/16 -j DROP
      iptables -I $chain -d 100.64.0.0/10 -j DROP
      iptables -I $chain -d 198.18.0.0/15 -j DROP
      iptables -I $chain -d 169.254.0.0/16 -j DROP

      # Apply the wepn_ipscan_chain chain to the OUTPUT chain
      iptables -I OUTPUT -j wepn_ipscan_chain

    elif [ "$rule" == "BLOCK_BITTORRENT" ]; then

      # Add rules to the custom chain to match BitTorrent traffic
      iptables -I $chain -m string --algo bm --string "BitTorrent" -j DROP
      iptables -I $chain -m string --algo bm --string "BitTorrent protocol" -j DROP
      iptables -I $chain -m string --algo bm --string "peer_id=" -j DROP
      iptables -I $chain -m string --algo bm --string ".torrent" -j DROP
      iptables -I $chain -m string --algo bm --string "announce.php?passkey=" -j DROP
      iptables -I $chain -m string --algo bm --string "torrent/announce" -j DROP
      iptables -I $chain -m string --algo bm --string "announce?info_hash" -j DROP
      iptables -I $chain -m string --algo bm --string "find_node" -j DROP
      iptables -I $chain -m string --algo bm --string "info_hash" -j DROP
      iptables -I $chain -m string --algo bm --string "get_peers" -j DROP
      iptables -I $chain -m string --algo bm --string "announce" -j DROP
      iptables -I $chain -m string --algo bm --string "magnet:" -j DROP

      # block bittorrent common port
      iptables -I $chain -p tcp --dport 6881:6889 -j DROP
      iptables -I $chain -p udp --dport 6881:6889 -j DROP

      # Apply the custom chain to the INPUT and OUTPUT chains:
      iptables -I INPUT -j $chain
      iptables -I OUTPUT -j $chain

    fi
  fi

  # save
  iptables-save > /root/.wepn/iptables-rules
  ipset save > /root/.wepn/ipset-rules
}

delete_table(){

  local set="$1_set"
  local chain="$1_chain"

  # Delete the rules from the INPUT, OUTPUT and FORWARD chains
  iptables -D INPUT -j $chain 2>/dev/null
  iptables -D OUTPUT -j $chain 2>/dev/null
  iptables -D FORWARD -j $chain 2>/dev/null
  # PREROUTING
  # POSTROUTING


  # Flush (delete all rules) in the chain
  iptables -F $chain

  # Delete the chain
  iptables -X $chain


  # destroy set
  sleep 3
  ipset -q destroy $set

}

clear_old_iptables_rules_and_run(){

  # rename wepn_specific_websites_chain and set to wepn_block_websites_chain and set
  if command -v iptables >/dev/null && command -v ipset >/dev/null && iptables -nL wepn_specific_websites_chain >/dev/null 2>&1; then

    # create set with new name
    ipset create wepn_block_websites_set hash:net comment maxelem 20000
    ipset list wepn_specific_websites_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | while read line; do
      ip=$(echo $line | awk '{print $1}')
      comment=$(echo $line | awk '{print $3}' | tr -d '"')
      ipset add wepn_block_websites_set $ip comment $comment
    done

    # create chain with new name
    iptables -N wepn_block_websites_chain
    iptables -I wepn_block_websites_chain -p tcp --dport 80 -m set --match-set wepn_block_websites_set dst -j REJECT
    iptables -I wepn_block_websites_chain -p tcp --dport 443 -m set --match-set wepn_block_websites_set dst -j REJECT
    iptables -I OUTPUT 1 -j wepn_block_websites_chain
    iptables -I FORWARD 1 -j wepn_block_websites_chain


    # delete old chain
    iptables -D OUTPUT -j wepn_specific_websites_chain 2>/dev/null
    iptables -D FORWARD -j wepn_specific_websites_chain 2>/dev/null
    iptables -F wepn_specific_websites_chain
    iptables -X wepn_specific_websites_chain

    # destroy old set
    sleep 3
    ipset destroy wepn_specific_websites_set

  fi



  if command -v iptables-save >/dev/null && iptables -C OUTPUT -d 185.238.44.2/22 -p tcp --dport 443 -j REJECT &> /dev/null; then
     print "[yellow]You have applied some rules using the previous version of the script which may cause conflicts."
     echo
     print "[blue]Kindly clear all existing rules. Subsequently, you may re-apply them using the new script."
     echo
     print "[bold][blue]Would you like to proceed?"
     confirmation_dialog y
     response="$?"
     clear_logs 2
     if [ $response -eq 1 ]; then
       clear_logs 5

       load_iran_ips
       load_arvancloud_ips
       load_derakcloud_ips

       print "[blue]CLeaning up old settings..."

       # delete rules added to block iranian websites
         for (( i=0; i<${#iran_ips[@]}; i++ ))
         do
           ip="${iran_ips[$i]}"
           if iptables -C OUTPUT -d "$ip" -p tcp --dport 443 -j REJECT &> /dev/null; then
             iptables -D OUTPUT -d "$ip" -p tcp --dport 443 -j REJECT
           fi
           show_progress $((i + 1)) ${#iran_ips[@]}
         done
         echo

         # also delete rules which are added for Arvancloud
         for aip in "${arvancloud_ips[@]}"
         do
           if iptables -C OUTPUT -d "$aip" -p tcp --dport 443 -j ACCEPT &> /dev/null; then
             iptables -D OUTPUT -d "$aip" -p tcp --dport 443 -j ACCEPT
           fi
         done

         # also delete rules which are added for DerakCloud
         for aip in "${derakcloud_ips[@]}"
         do
           if iptables -C OUTPUT -d "$aip" -p tcp --dport 443 -j ACCEPT &> /dev/null; then
             iptables -D OUTPUT -d "$aip" -p tcp --dport 443 -j ACCEPT
           fi
         done

         # tunneling ip
         tunneling_ip=$(iptables-save | grep -- '--dport 443.*ACCEPT\>' | awk '{print $4}')
         if [ -n "$tunneling_ip" ]; then
            iptables -D OUTPUT -d "$tunneling_ip" -p tcp --dport 443 -j ACCEPT
         fi

       clear_logs 2
       goto_menu "menu"
     else
       clear_logs 5
       fn_menu__exit
     fi
  else
     goto_menu "menu"
  fi
}
#----------------------------------------------------------------------------------------------------------------------- prepare
#check_terminal_size
capture_terminal_resize
prepare_screen
create_wepn_service
show_headers
check_os
check_root
fix_etc_hosts
disable_ufw
set_run_mode
#install_packages gnuplot
#install_or_update_wepn
#----------------------------------------------------------------------------------------------------------------------- RUN
clear_old_iptables_rules_and_run




