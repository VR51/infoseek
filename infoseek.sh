#!/bin/bash
clear
###
#
#	WOS InfoSEEK 1.0.0
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
#	  Query the World of Spectrum database.
#		See http://live.worldofspectrum.org/using-the-api/basics for more information about the database.
#
#
#	TO RUN:
#
#	  Ensure the script is executable.
#		Set the API key and returned data FORMAT in the CONFIGURATIONS
#		Then, from the command line:
#
#			bash infoseek.sh or ./infoseek.sh
#
#		Follow the prompts.
#
#	LIMITATIONS
#
#		You are expected to have read the WoS API guide at http://live.worldofspectrum.org/using-the-api/basics
#
#
###

# CONFIGURATIONS




API=test
FORMAT=php # php, json, jsonp or xml





# NOTHING ELSE TO CONFIGURE

# Locate Where We Are
filepath="$(dirname "$(readlink -f "$0")")"
# A Little precaution
cd "$filepath"

# API Options


# Parent (main menu)

seekType=( publishers publisher magazines countries distribution_status distribution_status_types roles entry_types machine_types origin_types protection_schemes turn_types )

# Child (sub menus)

publishers=( limit offset label_from label_from_slug label_from_became label_from_became_slug last_owner last_owner_slug distribution_status is_folded country publisher random )
publisher=( EXPERIMENTAL limit offset id slug )
magazines=( limit offset magazine slug language medium random )
countries=( EXPERIMENTAL limit offset id slug )
distribution_status=( EXPERIMENTAL limit offset id status slug )
distribution_status_types=( EXPERIMENTAL limit offset id type slug )
roles=( EXPERIMENTAL limit offset id type slug )
entry_types=( EXPERIMENTAL limit offset id status slug )
machine_types=( EXPERIMENTAL limit offset id status slug )
origin_types=( EXPERIMENTAL limit offset id status slug )
protection_schemes=( EXPERIMENTAL limit offset id scheme slug )
turn_types=( EXPERIMENTAL limit offset id status slug )


# Do some work...

function infoseek_run() {
	
	## Open shell if not already running in one
	
	tty -s
	if test "$?" -ne 0 ; then
		infoseek_run
	fi
	
	## Prompt for repositories and files to install
	
	printf "INFOSEEK\n\n"
	printf "Retrieves data from The World of Spectrum database API. Not all of the API features work yet. API options listed with EXPERIMENTAL in line 0 are not yet active, or, if they are, they are experimentally so.\n\n"
	printf "Multiple criteria can be searched together. Type SEND (or just press the Enter key) when ready to request information from the WoS archive.\n\n"
	printf "Press any key to start your search.\n\n"
	read something
	
	clear
	infoseek_prompt "Choose a search category:" "${seekType[*]}"
	
	if test ${#what[@]} -ne 0 ; then
		if test ${what[-1]} == 'n'; then
			exit 0
		fi
	fi
	
	clear
	title=${seekType[${what[0]}]}
	title=( $(sed "s/_/ /g" <<< "$title") )
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
	
	# Build Query String	
	query+=( "X-API-KEY=$API&format=$FORMAT" )
	c=1
	while [ $c -lt ${#what[@]} ]; do
	
		query+=( "&${seekInfoArray[${what[$c]}]}=" )
		let c=c+1
		query+=( "${what[$c]}" )
		let c=c+1
		
	done
	
	query=( $(sed "s/ //g" <<< "${query[*]}") )

	# FOR DEBUGGING
	# echo "http://live.worldofspectrum.org/infoseek/api/${seekType[${what[0]}]}?$query"
	# exit
	info=$(wget -qO- "http://live.worldofspectrum.org/infoseek/api/${seekType[${what[0]}]}?$query")
	
	# PARSE IT (some other time)
	
	#pre=''
	#post=''

	#info=$(sed "s/'q' =>.*//g" <<< "$info")
	#info=$(sed "s/'//g" <<< "$info")
	#info=$(sed "s/=>/|/g" <<< "$info")
	
	echo "$info"

	exit 0

}


function infoseek_prompt() {

	bold=$(tput bold)
	normal=$(tput sgr0)

  while true; do

		# Question
		printf "${1} (SEND to send request):\n\n"
		
		if test ${#2} -ne 0; then
			# Options Available
			
			n=0
			for i in ${2}; do
				i=( $(sed "s/_/ /g" <<< "$i") )
				if test ${child[$n]} ;then
					string="[$n] ${i[*]^} (${child[$n]})" # [Number] Criteria (Current Value)
				else
					string="[$n] ${i[*]^}" # [Number] Criteria
				fi
				printf "$string\n"
				let n=n+1
			done

			printf "\nChoose an option (0 to $(( n -1 ))) then press Enter (SEND to send request).\n"
			
			printf "\n"

			read REPLY
			
			
			case $REPLY in
			
			[0-9]|[0-9][0-9])
				what+=( "$REPLY" )
				printf "\n"
				return 0
			;;

			''|[sS][eE][nN][dD])
				exit='n'
				printf "\n"
				return 1
			;;

			*)
				
			esac
			
		else
			# Search String
		
			printf "\n"

			read REPLY
			
			case $REPLY in

			''|[sS][eE][nN][dD])
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


## Boot

infoseek_run "$@"

# Exit is at end of infoseek_run()

# FOR DEBUGGING

# declare -p what seekType sType
