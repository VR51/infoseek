#!/bin/bash
clear
###
#
#	InfoSEEK 1.0.2 (WOS Edition)
#
#	Lead Author: Lee Hodson
#	Donate: paypal.me/vr51
#	Website: https://journalxtra.com
#	First Written: 3rd Sep. 2017
#	First Release: 3rd Sep. 2017
#	This Release: 3rd Sep. 2017
#
#	Copyright 2017 Lee Hodson <https://journalxtra.com>
#	License: GPL3
#
#	Programmer: Lee Hodson <journalxtra.com>, VR51 <vr51.com>
#
#	Use of this program is at your own risk
#
#	USE TO:
#
#	  Query the World of Spectrum API database.
#		See http://live.worldofspectrum.org/using-the-api/basics for more information about the database.
#
#		This can be used as a generic program to work with API systems. Change the configs to adapt the program to a different API. Read the code comments for more details.
#
#
#	TO RUN:
#
#		Set the API key and returned data FORMAT in the CONFIGURATIONS (the current configs will work fine for WoS)
#	  Ensure the script is executable.
#		Then, from the command line:
#
#			bash infoseek.sh or ./infoseek.sh or just click the program file.
#
#		Follow the prompts.
#
#	LIMITATIONS
#
#		The program is easy to use and fairly self explanatory.
#		You are expected to have read the World of Spectrum API guide at http://live.worldofspectrum.org/using-the-api/basics
#
#
###

###
#
# CONFIGURATIONS
#
###

# General
# Bad form to use capitals for non globals, I know, but, hey, I wrote this script and I care more about readability than I do about your arrogance.

APIURI='http://live.worldofspectrum.org/infoseek/api' # Where to send API requests. No trailing slash.

APIKEYTITLE='X-API-KEY' # The text before that announces the API KEY e.g. X-API-KEY=test
APIKEY='test' # Your API key.

FORMATTITLE='format' # The text that announces the format for the returned values e.g. 'format=php'
FORMAT='php' # php, json, jsonp or xml.

USERNAMETITLE=''
USERNAME=''

USERPASSTITLE=''
USERPASS=''

WELCOME123='true' # 'true' to display welcome message. Anything else to disable the message.


# Advanced

# NOTHING ELSE TO CONFIGURE
# 	Unless you know what you are doing....
#
# 	The API we want to access uses URI query strings to send information to a web server which then returns data based on the string variables passed.
# 	A query string is the section that comes after a question mark in a URI e.g. example.com/?time=now
#		Queries in query strings are sent in 'key name=value' format e.g time=now or timezone=GMT or day=tomorrow.
# 	Multiple queries can be sent in the same query string. Multiple queries are separated by an ampersand (&) e.g. example.com/?time=now&timezone=GMT
#
# 	This BASH program converts query strings into a menu format.
#
#			The key name part of the query string is treated as a top level menu in the program options.
#			The possible values that correspond to a specific key are treated as secondary level menus.
#
#		In the below configuration parameters the seekType is the parent key. The child parameters are the values that can be used with a parent key.
#
#		More key/value sets can be added, viz
#
#			1) Add a key to the seekType array (This is the parent key).
#			2) create a new array that is the same name as the key (This is the child value array).
#			3) Add values for the key into the child value array.
#
#		For example seekType=( publishers ) corresponds with child arrary publishers=( limit offset label )
#

# Parent (main menu)

seekType=( publishers publisher magazines countries distribution_status distribution_status_types roles entry_types machine_types origin_types protection_schemes turn_types quit_program )

# Child (sub menus)

publishers=( limit offset label_from label_from_slug label_from_became label_from_became_slug last_owner last_owner_slug distribution_status is_folded country publisher random quit_program )
publisher=( EXPERIMENTAL limit offset id slug quit_program )
magazines=( limit offset magazine slug language medium random quit_program )
countries=( EXPERIMENTAL limit offset id slug quit_program )
distribution_status=( EXPERIMENTAL limit offset id status slug quit_program )
distribution_status_types=( EXPERIMENTAL limit offset id type slug quit_program )
roles=( EXPERIMENTAL limit offset id type slug quit_program )
entry_types=( EXPERIMENTAL limit offset id status slug quit_program )
machine_types=( EXPERIMENTAL limit offset id status slug quit_program )
origin_types=( EXPERIMENTAL limit offset id status slug quit_program )
protection_schemes=( EXPERIMENTAL limit offset id scheme slug quit_program )
turn_types=( EXPERIMENTAL limit offset id status slug quit_program )


# NO USER SERVICEABLE PARTS BELOW HERE

# Locate Where We Are
filepath="$(dirname "$(readlink -f "$0")")"
# A Little precaution
cd "$filepath"


# Do some work...

function infoseek_run() {
	
	## Open shell if not already running in one
	
	tty -s
	if test "$?" -ne 0 ; then
		infoseek_launch
	fi
	
	## Prompt for repositories and files to install
	
	printf "INFOSEEK\n\n"
	
	if test $WELCOME123 == 'true'; then
		printf "Retrieve data from The World of Spectrum database API. Not all of the API features work yet. API options listed with EXPERIMENTAL as their first option are not yet active, or, if they are, they are experimentally so.\n\n"
		printf "Multiple criteria can be searched together. Type SEND (or just press the Enter key with no option selected) when ready to request information from the WoS archive.\n\n"
		printf "This welcome message will not show the next time you run this program.\n\n"
		printf "Press any key to start your search.\n\n"
		read something
		sed -i "s/WELCOME123=''/WELCOME123=''/" "$0"
	fi
	
	clear
	infoseek_prompt "Choose a search category:" "${seekType[*]}"
	
	if test ${#what[@]} -ne 0 ; then
		if test ${what[-1]} == 'n'; then
			exit 0
		fi
	fi
	
	clear
	title="${seekType[${what[0]}]//_/ }"
	printf "${title^^}\n\n"
	
	
	# Use variable value as the name of the array to peek.
	seekInfo="${seekType[${what[0]}]}"
	seekInfo=$seekInfo[*]
	seekInfo=${!seekInfo}
	
	# Map the value's namesake array to a new array so we can access the data
	seekInfoArray+=( $seekInfo )
	
	while [ "$exit" != "n" ]; do
	
		infoseek_prompt "Choose criteria to search by within $title?" "$seekInfo"
		if test "$exit" != "n" ; then
			infoseek_prompt "Enter the search criteria:"
		fi
		
		clear
	
	done
	
	## Build Query String
	
	# Generic string part built from user configs
	if test "$APIKEYTITLE"; then
		query+=( "$APIKEYTITLE=$APIKEY" )
	fi
	
	if test "$FORMATTITLE"; then
		query+=( "&$FORMATTITLE=$FORMAT" )
	fi
	
	if test "$USERNAMETITLE"; then
		query+=( "&$USERNAMETITLE=$USERNAME" )
	fi
	
	if test "$USERPASSTITLE"; then
		query+=( "&$USERPASSTITLE=$USERPASS" )
	fi
	
	c=1
	while [ $c -lt ${#what[@]} ]; do
	
		query+=( "&${seekInfoArray[${what[$c]}]}=" )
		let c=c+1
		infoseek_rawurlencode "${what[$c]}"
		query+=( "${ENCODED}" )
		let c=c+1
		
	done
	
	# Custom string part built from user input
	query=( $(sed "s/ //g" <<< "${query[*]}") ) # Remove whitespace

	# FOR DEBUGGING
	# echo "$APIURI/${seekType[${what[0]}]}?$query"
	# read something
	# exit
	info=$(wget -qO- "$APIURI/${seekType[${what[0]}]}?$query")
	
	# PARSE IT (some other time)
	
	#pre=''
	#post=''

	#info=$(sed "s/'q' =>.*//g" <<< "$info")
	#info=$(sed "s/'//g" <<< "$info")
	#info=$(sed "s/=>/|/g" <<< "$info")
	
	echo "$info"
	read something

	exit 0

}


function infoseek_prompt() {

	bold=$(tput bold)
	normal=$(tput sgr0)

  while true; do

		# Question
		printf "${1}:\n\n"
		
		if test ${#2} -ne 0; then
			# Options Available
			
			n=0
			for i in ${2}; do
				i=( $(sed "s/_/ /g" <<< "$i") )
				if test "${child[$n]}"; then
					string="[$n] ${i[*]^} (${child[$n]})" # [Number] Criteria (Current Value)
				else
					string="[$n] ${i[*]^}" # [Number] Criteria
				fi
				printf "$string\n"
				let n=n+1
			done

			printf "\nChoose an option (0 to $(( n -1 ))) then press Enter.\n"
			printf "\nTo send your request press the Enter key with no option selected or text entered.\n"
			printf "\nPress Ctrl+C to quit the program at any time.\n"
			
			printf "\n"

			read REPLY
			
			
			case $REPLY in
			
			$(( n - 1 )))
				exit 0
			;;
			
			[0-9]|[0-9][0-9])
				what+=( "$REPLY" )
				printf "\n"
				return 0
			;;

			'')
				exit='n'
				printf "\n"
				return 1
			;;
			
			[qQ])
				exit 0
			;;

			*)
				
			esac
			
		else
			# Search String
		
			printf "\n"

			read REPLY
			
			case $REPLY in
			
			'')
				exit='n'
				printf "\n"
				return 1
			;;

			*)
				what+=( "$REPLY" )
				
				# Map the child criteria to the search string e.g. 11 => ocean
				child[${what[-2]}]="${what[-1]}"
				printf "\n"
				return 0
				
			esac
			
		fi

  done
  
}

## Encode search strings

function infoseek_rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  ENCODED="${encoded}"
}

## launch terminal

function infoseek_launch() {

		terminal=( konsole gnome-terminal x-terminal-emulator xdg-terminal terminator urxvt rxvt Eterm aterm roxterm xfce4-terminal termite lxterminal xterm )
		for i in ${terminal[@]}; do
			if command -v $i > /dev/null 2>&1; then
				exec $i -e "$0"
				# break
			else
				printf "\nUnable to automatically determine the correct terminal program to run e.g Console or Konsole. Please run this program from the command line.\n"
				read something
				exit 1
			fi
		done
}

## Boot

infoseek_run "$@"

# Exit is at end of infoseek_run()

# FOR DEBUGGING

# declare -p what seekType sType
