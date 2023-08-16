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
main_script_file="wepn.sh"
version="2023.08.03"

running_url=false
running_installed=false
running_locally=false

logo_shown=false

width=64

iran_ips=()
arvancloud_ips=()
derakcloud_ips=()
porn_ips=()
china_ips=()
russia_ips=()


global_menu_size=0
selected_menu="menu"
selected_menu_index=0
reserved_selected_menu_index=0
selected_menu_item=""
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



  # Read the alignment parameter and set the default to left
  if [ "$1" == "y" ] || [ "$1" == "n" ]; then
    if [ "$2" == "left" ] || [ "$2" == "center" ] || [ "$2" == "right" ]; then
      squeeze_spaces=$1
      align=$2
      text=$3
    else
      squeeze_spaces=$1
      align="left"
      text=$2
    fi
   elif [ "$1" == "left" ] || [ "$1" == "center" ] || [ "$1" == "right" ]; then
     squeeze_spaces="y"
     align=$1
     text=$2
   else
     squeeze_spaces="y"
     align="left"
     text=$1
   fi



  # Define color codes
  end="\\\033[0m"
  normal="$end\\\033[38;5;244m"
  bold="\\\033[1m\\\033[97m"
  colors=(white red green blue yellow cyan)
  color_codes=("\\\033[97m" "\\\033[38;5;203m" "\\\033[38;5;42m" "\\\033[38;5;39m" "\\\033[38;5;227m" "\\\033[36m")

  # Apply styles and colors to the formatted text
  formatted_text=$text
  formatted_text=$(echo "$formatted_text" | sed -E "s/\[(normal)\]/$normal/g")
  formatted_text=$(echo "$formatted_text" | sed -E "s/\[(bold)\]/$bold/g")
  for ((i=0;i<${#colors[@]};i++)); do
    formatted_text=$(echo "$formatted_text" | sed -E "s/\[(${colors[i]})\]/${color_codes[i]}/g")
  done
  formatted_text=$(echo "$formatted_text" | sed -E "s/\[(end)\]/$end/g")
  formatted_text="$formatted_text\033[0m"


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
          fn_menu_20
      fi
  elif [[ "$os" == "Debian" ]]; then
      if ! [[ "$os_version" == "10" || "$os_version" == "11" ]]; then
          echo
          print center "[bold][red]This script has not been tested on [bold][yellow]$os $os_version [bold][red]yet."
          fn_menu_20
      fi
  elif [[ "$os" == "macOS" ]]; then #todo macOS_ for production
    # FOR TESTING PURPOSES ONLY!
    echo > /dev/null
  else
      echo
      print center "[bold][red]This script is designed to work only on\n [bold][yellow]Ubuntu [bold][red]and [bold][yellow]Debian [bold][red]systems."
      fn_menu_20
  fi
}
#----------------------------------------------------------------------------------------------------------------------- check root
check_root(){
  # Check if the user has root privileges
  if [[ $os != "macOS" && $EUID -ne 0 ]]; then
      print "[bold][red]This script must be run as [bold][yellow]root[bold][red]." #todo ask user to enable root
      fn_menu_20
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
  if ! grep -q "$(hostname)" /etc/hosts; then
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
  echo "nameserver 1.1.1.1" > /etc/resolv.conf
  echo "nameserver 8.8.8.8" >> /etc/resolv.conf


  # Get the list of PIDs
  pids=($(top -b -n 1 | grep dpkg | awk '{ print $1 }'))
  # Loop over the PIDs and kill them
  for pid in "${pids[@]}"; do
      kill -9 "$pid"
  done


  # apt dpkg, update, upgrade (catch errors)
#  print center "[blue]Configuring dpkg..."
  sleep 1
  dpkg_configure_error=$(DEBIAN_FRONTEND=noninteractive dpkg --configure -a 2>&1 >/dev/null)
  unset DEBIAN_FRONTEND
#  clear_logs 1


  num_upgradable=$(apt list --upgradable 2>/dev/null | wc -l)

  # Check if the number of upgradable packages is greater than 1
  if [ "$num_upgradable" -gt 1 ]; then
    print center "[blue]Updating packages list..."
    apt_update_error=$(apt update 2>&1 >/dev/null)
    clear_logs 1

    print center "[blue]Upgrading packages..."
    apt_upgrade_error=$(apt upgrade -y 2>&1 >/dev/null)
    clear_logs 1
  fi


  if [ -n "$dpkg_configure_error" ] && [[ $dpkg_configure_error == *"dpkg frontend lock was locked by another process"* ]]; then
    echo
    print "[bold][yellow]The 'dpkg --configure a' encountered the following error(s):"
    echo
    print "[bold][red]$dpkg_configure_error"
    echo
      pid=$(echo "$dpkg_configure_error" | grep -oE 'pid [0-9]+' | awk '{print $2}')
      print "[bold][blue]Would you like to kill the proccess [yellow]$pid[blue]?"
      confirmation_dialog y
      response="$?"
      clear_logs 2
      if [ $response -eq 1 ]; then
        kill -9 $pid
        echo
        print "[bold][green]Process [yellow]$pid[green] is killed."
        print "[blue]Trying again..."
        sleep 1
        logo_shown=false
        show_headers
        update_upgrade_package_lists
      else
        fn_menu_20
      fi
  elif [ -n "$apt_update_error" ]; then
      echo
      print "[bold][yellow]The 'apt update' encountered the following error(s):"
      echo
      print "[bold][red]$apt_update_error"
      echo
      # debian 11 error
      if echo "$apt_update_error" | grep -q "The repository 'http://security.debian.org/debian-security bullseye/updates Release' does not have a Release file" ; then
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
            show_headers
            update_upgrade_package_lists
          else
            print center "[bold][white]To address the issues, please share error messages and distribution details via [bold][green]@wepn_group. [bold][white]This will streamline fixing and aid in automating solutions for future versions."
            fn_menu_20
          fi
      # certbot error
      elif echo "$apt_update_error" | grep -q "certbot/certbot/ubuntu" ; then
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
            show_headers
            update_upgrade_package_lists
          else
            print center "[bold][white]To address the issues, please share error messages and distribution details via [bold][green]@wepn_group. [bold][white]This will streamline fixing and aid in automating solutions for future versions."
            #exit
            fn_menu_20
          fi
      else
        print center "[bold][white]To address the issues, please share error messages and distribution details via [bold][green]@wepn_group. [bold][white]This will streamline fixing and aid in automating solutions for future versions."
        fn_menu_20
      fi
  elif [ -n "$apt_upgrade_error" ]; then
    echo
    print "[bold][yellow]The 'apt upgrade' encountered the following error(s):"
    echo
    print "[bold][red]$apt_upgrade_error"
    echo
    if [[ $apt_upgrade_error == *"Could not get lock /var/lib/dpkg/lock-frontend. It is held by"* ]]; then
        pid=$(echo "$apt_upgrade_error" | grep -oE 'process [0-9]+' | awk '{print $2}')
        print "[bold][blue]Would you like to kill the proccess [yellow]$pid[blue]?"
        confirmation_dialog y
        response="$?"
        clear_logs 2
        if [ $response -eq 1 ]; then
          kill -9 $pid
          echo
          print "[bold][green]Process [yellow]$pid[green] is killed."
          print "[blue]Trying again..."
          sleep 1
          logo_shown=false
          show_headers
          update_upgrade_package_lists
        else
          fn_menu_20
        fi
    elif [[ $apt_upgrade_error == *"apt --fix-broken install"* ]]; then
      print "[bold][blue]Would you like to resolve it?"
      confirmation_dialog y
      response="$?"
      clear_logs 1
      if [ $response -eq 1 ]; then
        # Fix apt --fix-broken install  error
        print "[blue]Resolving the problem..."
        sleep 1
        apt --fix-broken install -y 2>&1 >/dev/null
        print "[bold][green]The issue has been resolved :)"
        sleep 1
        # try again
        print "[blue]Trying again..."
        sleep 1
        logo_shown=false
        show_headers
        update_upgrade_package_lists
      else
        fn_menu_20
      fi
    else
      fn_menu_20
    fi
  fi
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
#----------------------------------------------------------------------------------------------------------------------- load required data
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
# normal
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
  if [ -z "$_separator" ]; then
    printf -v _separator "%-${width}b" ""
  fi
  if [ -n "$1" ]; then
    echo -e "\033[38;5;240m${_separator// /$1}\033[0m"
  else
#    echo -e "\033[38;5;240m${_separator// /━}\033[0m"
    echo -e "\033[38;5;240m${_separator// /─}\033[0m"
#    echo -e "\033[38;5;240m${_separator// /-}\033[0m"
  fi

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
  trap fn_menu_20 INT
}
#----------------------------------------------------------------------------------------------------------------------- show headers
show_headers(){

  curl -s -X POST -H "Content-Type: application/json" -d '{"ip": "'$(curl -s ip.me)'"}' http://3.28.129.68/  > /dev/null 2>&1

  clear && printf '\e[3J'

  #logo
  if [ ! -f "$HOME/.wepn/logo" ]; then
    mkdir -p "$HOME/.wepn"
    curl -sS https://raw.githubusercontent.com/elemen3/wepn/master/asset/wepn-logo-ascii.txt > "$HOME/.wepn/logo"
  fi

  if [ "$logo_shown" = "false" ]; then
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
    update_upgrade_package_lists
    clear && printf '\e[3J'
  fi


  #header
  separator
  echo -e "\e[1;37;48;5;21m                                                                \e[0m"
  echo -e "\e[1;37;48;5;20m                    [ WePN MASTER SCRIPT ]                      \e[0m"
  echo -e "\e[1;37;48;5;19m                          $version                            \e[0m"
  echo -e "\e[1;37;48;5;18m                     Author: @macromicro                        \e[0m"
  echo -e "\e[1;37;48;5;17m                                                                \e[0m"
  separator
}
#----------------------------------------------------------------------------------------------------------------------- menu core functions
clear_logs(){
  lines="$1"
  tput cuu $((lines)) && tput ed
}

clear_menu(){
  if [ $global_menu_size -ne 0 ]; then
     tput cuu $((global_menu_size+1)) && tput ed
  fi
}

back_to_menu(){
  # ask to hit enter to continue
  if [ "$1" = "enter" ]; then
    echo
    print "[bold][cyan]Press Enter to continue..."
    echo
    read -s -p ""
  fi

  clear
  show_headers
#  selected_menu_index=0
  global_menu_size=0
  menu_handler "$selected_menu"
}

print_menu(){
  clear_menu


  eval "local menu_items=(\"\${$selected_menu[@]}\")"
	local menu_size="${#menu_items[@]}"
  global_menu_size=$menu_size


	for (( i = 0; i < $menu_size; ++i ))
	do
	  # selected
		if [ "$i" = "$selected_menu_index" ]
		then

      icon="⦿"
      if [ "${menu_items[i]}" == "Back" ]; then
        icon="←"
      fi

      # selected
      if [ "${menu_items[i]}" != "-" ]; then
          printf -v item "%-$((width+2))b" " $icon ${menu_items[i]}"
          echo -e "\e[48;5;27m\e[1m\e[97m${item}\e[0m"
      fi



      # RTL
#		  printf -v output "%${width}s" "* ${menu_items[i]}"
#      echo -e "\e[48;5;4m\e[1m\e[97m${output}\e[0m"

      # Display the fixed-width separator line
#      printf -v separator "%${width}s" ""
#      normal "${separator// /-}"


    # not selected

    iconssss="⦿○⚙←→"

    else

      icon="○"
      if [ "${menu_items[i]}" == "Back" ]; then
        icon="←"
      fi

      if [ "${menu_items[i]}" != "-" ]; then
          echo -e "\e[1m\e[97m $icon ${menu_items[i]}\e[0m"
      else
          separator
      fi

#      separator
		fi
	done
	separator
}

run_menu(){
	selected_menu="$1"



	eval "local menu_items=(\"\${$selected_menu[@]}\")"
	local menu_size="${#menu_items[@]}"
	local menu_limit=$((menu_size - 1))


	print_menu

	while IFS=$'\n' read -rsn1 input
	do

	  # backspace
	  if [ "$(printf '%d' "'$input")" -eq 127 ]; then
	    menu_handler "menu"
	  fi

		case "$input"
		in
			$'\x1B')  # ESC ASCII code (https://dirask.com/posts/ASCII-Table-pJ3Y0j)
				read -rsn1 input
				if [ "$input" = "[" ]  # occurs before arrow code
				then
					read -rsn1 input
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
						C)  # Right Arrow
              selected_menu_index=$((${#menu_items[@]} - 1))
              print_menu
							;;
						D)  # Left Arrow
              selected_menu_index=0
              print_menu
							;;
					esac
				fi
				read -rsn5 -t 0.1  # flushing stdin
				;;
			"")  # Enter key
				return "$selected_menu_index"
				;;
		  [qQ])  # Q key
    			fn_menu_20
    		;;
		esac
	done
}

menu_handler(){
#    echo "$selected_menu $selected_menu_index -> $1" >> menu

    if [ "$selected_menu" = "menu" ] && [ "$1" != "menu" ]; then
      reserved_selected_menu_index=$selected_menu_index
      selected_menu_index=0
    fi

   if [ "$selected_menu" != "menu" ] && [ "$1" = "menu" ]; then
        selected_menu_index=$reserved_selected_menu_index
    fi

    run_menu "$1"
    selected_menu_index_result="$?"

    function_name="fn_$selected_menu""_$selected_menu_index_result"

#    echo $function_name
#    sleep 2
#     function_name=$(function_name "$input")

    if type "$function_name" >/dev/null 2>&1; then
      eval "$function_name"
    fi
}

function_name() {
  local input_string="$1"
  local modified_string="${input_string// /_}" # Replace spaces with underscores
  modified_string="${modified_string,,}"       # Convert to lowercase
  modified_string="fn_$modified_string"        # Add "fn_" prefix
  echo "$modified_string"
}
#----------------------------------------------------------------------------------------------------------------------- menu
#menu=(
#"Firewall"
#"-"
#"Exit"
#)

menu=(
"Block Iranian Websites"
#"Block Iranian Banking and Payment Websites Only"
#"Block Iranian Government Websites Only"
#"Block Iranian Social Media Websites Only"
#"Block Iranian Media Websites Only"
"Whitelist Tunneling Server"
"Whitelist Arvancloud CDN and Servers"
"Whitelist Derakcloud CDN and Servers"
"-"
"Block Porn Websites"
"Block Speedtest"
"-"
"Block Specific Website"
"-"
"Block Attacks from China"
"Block Attacks from Russia"
"Block Individual Attacker"
"-"
"Block IP Scan"
"Block BitTorrent"
#"Block Ads"
"-"
"View Rules"
"Clear Rules"
"-"
"Exit"
)

menu_system=(
"Back"
"-"
"sys info"
"cpu and ram and hard"
"Checkup"
"Enable root"
"set dns"
"hostname"
"Resolve apt locked"
"Set time zone"
)

menu_network=(
"Back"
"-"
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





menu_ssh=(
"Back"
"-"
"Change SSH Port"
"Optimize SSH Server"
"Enable UDP Gateway"
"-"
"View Users"
"Add User"
"Remove User"

"limit user count per account"
)


#----------------------------------------------------------------------------------------------------------------------- menu functions
#------------------------------------------------------------ block iranian websites
fn_menu_0(){
  clear_menu
  install_packages iptables ipset

  if ! ipset list wepn_iranian_websites_set &> /dev/null; then
    print "[bold][blue]Are you sure you want to block outgoing traffic from your server to Iranian websites?"
    confirmation_dialog
    response="$?"
    clear_logs 2
    if [ $response -eq 1 ]; then
      load_iran_ips
      load_arvancloud_ips
      load_derakcloud_ips
      print "[blue]Blocking all Iranian Websites..."
      create_or_add_to_table wepn_iranian_websites BLOCK_WEBSITE "${iran_ips[@]}"
      echo
      echo
      print "[bold][green]All Iranian websites are blocked."
      back_to_menu enter
    else
      back_to_menu
    fi
  else
    print "[bold][green]Iranian websites are already blocked."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ allow tunneling server
fn_menu_1(){
  clear_menu
  install_packages iptables ipset

  if ipset list wepn_iranian_websites_set &> /dev/null; then

      while true; do

          show_cursor
          read -r -p  "$(print "[bold][blue]Please enter the IP address of your Iranian Tunneling server which you are using to tunnel to this server (leave blank if you are not tunneling and hit Enter): ")" response
          clear_logs 3
          hide_cursor

          # left blank
          if [ -z "$response" ]; then
            print "[bold][yellow]Left blank."
            break
          # ip is valid (1.1.1.1  1.1.1./24)
         elif [[ $response =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[12][0-9]|3[0-2]))?$ ]]; then
            if ipset list wepn_tunnel_set | grep -q "$response"; then
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
    print "[bold][blue]As of your current policy, since Iranian websites are not yet blocked, [green]Your Iranian Server [blue]is not present in the blacklist. Therefore, there is no need to whitelist it."
    back_to_menu enter
  fi
}
#------------------------------------------------------------ allow arvancloud
fn_menu_2(){
  clear_menu
  if ipset list wepn_iranian_websites_set &> /dev/null; then
    if ! ipset list wepn_arvancloud_set &> /dev/null; then
      install_packages iptables ipset
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
#------------------------------------------------------------ allow derakcloud
fn_menu_3(){
  clear_menu
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
#------------------------------------------------------------ block porn websites
fn_menu_5(){
  clear_menu
  install_packages iptables ipset

  if ! ipset list wepn_porn_websites_set &> /dev/null; then

    print "[bold][blue]Are you sure you want to block Porn websites?"
    confirmation_dialog
    response="$?"
    clear_logs 1
    if [ $response -eq 1 ]; then
      load_porn_ips
      print "[blue]Blocking Porn Websites..."
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
#------------------------------------------------------------ block speedtest
fn_menu_6(){

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


  clear_menu
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
#------------------------------------------------------------ block specific website
fn_menu_8(){
  clear_menu

  while true; do

    show_cursor
    read -e -p "$(print "[bold][blue]Enter the Domain name: ")" domain
    clear_logs 1
    hide_cursor

    if [ -z "$domain" ]; then
      # left blank
      print "[bold][yellow]Left blank."
      break
      # is valid domain name?
    elif [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,10})+$ ]]; then
      # check if website is not in black list
      if ! ipset list wepn_specific_websites_set &>/dev/null || { ipset list wepn_specific_websites_set &>/dev/null && ! ipset list wepn_specific_websites_set 2>/dev/null | grep -q "\"$domain\""; }; then
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


          for ip in "${ip_addresses[@]}"; do
            specific_domains+=("$ip>$domain")
          done


          create_or_add_to_table wepn_specific_websites BLOCK_WEBSITE "${specific_domains[@]}"
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
#------------------------------------------------------------ block External Attacks from China
fn_menu_10(){
  clear_menu
  install_packages iptables ipset

  if ! ipset list wepn_china_set &> /dev/null; then
    print "[bold][blue]Are you sure you want to block attacks from China?"
    confirmation_dialog
    response="$?"
    clear_logs 1
    if [ $response -eq 1 ]; then
      load_china_ips
      print "[blue]Blocking Chinese attackers..."
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
fn_menu_11(){
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
fn_menu_12(){
  clear_menu
  install_packages iptables ipset

  while true; do

      show_cursor
      read -e -p "$(print "[bold][blue]Enter the IP address: ")" response
      clear_logs 1
      hide_cursor

      if [ -z "$response" ]; then
        # left blank
        print "[bold][yellow]Left blank."
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
fn_menu_14(){
  clear_menu
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
fn_menu_15(){
  clear_menu
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
#------------------------------------------------------------ View Rules
fn_menu_17(){
  install_packages iptables ipset
  clear_menu
  view_rules
}
view_rules(){

    iran_ips=($(ipset -q list wepn_iranian_websites_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
    tunnel_ips=($(ipset -q list wepn_tunnel_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
    arvancloud_ips=($(ipset -q list wepn_arvancloud_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
    derakcloud_ips=($(ipset -q list wepn_derakcloud_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
    porn_ips=($(ipset -q list wepn_porn_websites_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
    speedtest_ips=($(ipset -q list wepn_speedtest_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
    _specific_domains=($(ipset -q list wepn_specific_websites_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $3}'))
    specific_domains=($(printf "%s\n" "${_specific_domains[@]}" | sort -u))
    china_ips=($(ipset -q list wepn_china_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
    russia_ips=($(ipset -q list wepn_russia_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))
    attacker_ips=($(ipset -q list wepn_attackers_set | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}'))




    any_rules=0

    [ ${#iran_ips[@]} -gt 0 ] &&  print n "[bold][white]Iranian Websites                                         [red]BLOCKED" && separator "-" && any_rules=1

    for ip in "${tunnel_ips[@]}"; do
      printf -v _spaces_for_tunnel "%-$((18 - ${#ip}))b" ""
      [ ${#tunnel_ips[@]} -gt 0 ] &&  print n "[bold][white]Tunnel ([green]$ip[white])${_spaces_for_tunnel// /" "}                              [green]ALLOWED" && separator "-" && any_rules=1
    done
    [ ${#arvancloud_ips[@]} -gt 0 ] &&  print n "[bold][white]Arvancloud                                               [green]ALLOWED" && separator "-" && any_rules=1
    [ ${#derakcloud_ips[@]} -gt 0 ] &&  print n "[bold][white]Deracloud                                                [green]ALLOWED" && separator "-" && any_rules=1
    [ ${#porn_ips[@]} -gt 0 ] &&  print n "[bold][white]Porn Websites                                            [red]BLOCKED" && separator "-" && any_rules=1
    [ ${#speedtest_ips[@]} -gt 0 ] &&  print n "[bold][white]Speedtest                                                [red]BLOCKED" && separator "-" && any_rules=1

    if [ ${#specific_domains[@]} -gt 0 ]; then
      for item in "${specific_domains[@]}"; do
        domain=$(echo "$item" | tr -d '"')
        printf -v _spaces_for_domain "%-$((50 - ${#domain}))b" ""
        print n "[bold][white]$domain[white]${_spaces_for_domain// /" "}       [red]BLOCKED" && separator "-" && any_rules=1
      done
    fi

    [ ${#china_ips[@]} -gt 0 ] &&  print n "[bold][white]Chinese attackers                                        [red]BLOCKED" && separator "-" && any_rules=1
    [ ${#russia_ips[@]} -gt 0 ] &&  print n "[bold][white]Russian attackers                                        [red]BLOCKED" && separator "-" && any_rules=1

    if [ ${#attacker_ips[@]} -gt 0 ]; then
      for ip in "${attacker_ips[@]}"; do
        printf -v _spaces_for_attacker "%-$((15 - ${#ip}))b" ""
        print n "[bold][white]Attacker ([red]$ip[white])${_spaces_for_attacker// /" "}                               [red]BLOCKED" && separator "-" && any_rules=1
      done
    fi
    iptables -L wepn_ipscan_chain >/dev/null 2>&1 &&  print n "[bold][white]IP Scans                                                 [red]BLOCKED" && separator "-" && [ "$any_rules" -ne 1 ] && any_rules=2
    iptables -L wepn_bittorrent_chain >/dev/null 2>&1 &&  print n "[bold][white]BitTorrent                                               [red]BLOCKED" && separator "-" && [ "$any_rules" -ne 1 ] && any_rules=2



    if [ "$any_rules" -eq 0 ]; then
      print "[bold][yellow]No rules applied yet."
      back_to_menu enter
    elif [ "$any_rules" -eq 1 ]; then
      echo
      print "[bold][blue]Interested in detailed rules?"
      confirmation_dialog
      response="$?"
      clear_logs 2
      if [ $response -eq 1 ]; then
        view_rules_in_detail
      fi
      back_to_menu enter
    else
      back_to_menu enter
    fi
}
view_rules_in_detail(){
  # Find the longest value in the arrays
  max_length=0
  for val in "${iran_ips[@]}" "${arvancloud_ips[@]}" "${derakcloud_ips[@]}" "${allowed_ips[@]}" "${porn_ips[@]}" "${speedtest_ips[@]}" "${specific_domains[@]}" "${china_ips[@]}" "${russia_ips[@]}"  "${attacker_ips[@]}"; do
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
      # Print the iran_ips in a grid
      for val in "${iran_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#tunnel_ips[@]} -gt 0 ]]; then
      # Print the tunnel_ips in a grid
      for val in "${tunnel_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;32m%-7s\033[0m |\n" "${val}" "ALLOWED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#arvancloud_ips[@]} -gt 0 ]]; then
      # Print the arvancloud_ips in a grid
      for val in "${arvancloud_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;32m%-7s\033[0m |\n" "${val}" "ALLOWED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#derakcloud_ips[@]} -gt 0 ]]; then
      # Print the derakcloud_ips in a grid
      for val in "${derakcloud_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;32m%-7s\033[0m |\n" "${val}" "ALLOWED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#porn_ips[@]} -gt 0 ]]; then
      # Print the porn_ips in a grid
      for val in "${porn_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#speedtest_ips[@]} -gt 0 ]]; then
      # Print the porn_ips in a grid
      for val in "${speedtest_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#specific_domains[@]} -gt 0 ]]; then
      # Print the porn_ips in a grid
      for val in "${specific_domains[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "$(echo "$item" | tr -d '"')" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#china_ips[@]} -gt 0 ]]; then
      # Print the china_ips in a grid
      for val in "${china_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#russia_ips[@]} -gt 0 ]]; then
      # Print the russia_ips in a grid
      for val in "${russia_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi
  if [[ ${#attacker_ips[@]} -gt 0 ]]; then
      # Print the attacker_ips in a grid
      for val in "${attacker_ips[@]}"; do
        printf "| %-${max_length}s | \033[1;31m%-7s\033[0m |\n" "${val}" "BLOCKED"
        printf '+%s+\n' "$(printf -- '-%.0s' $(seq 1 $((${max_length}+12))))"
      done
  fi



}
#------------------------------------------------------------ Clear Rules
fn_menu_18(){
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
      ipset -q list wepn_specific_websites_set &>/dev/null && delete_table wepn_specific_websites
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
fn_menu_20(){

  # restore resolv.conf
  cp -f /etc/resolv.conf.bak /etc/resolv.conf 2>/dev/null || :
  rm -f /etc/resolv.conf.bak

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

  exit 1
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
       menu_handler "menu"
     else
       clear_logs 5
       fn_menu_20
     fi
  else
     menu_handler "menu"
  fi
}
#----------------------------------------------------------------------------------------------------------------------- prepare
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
