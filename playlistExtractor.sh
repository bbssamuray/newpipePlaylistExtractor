#!/bin/bash

set -o pipefail -e
#Exit script if there are any errors

tempDB=""
playlistData=()
override=""
sourceName=""

getPlaylistData(){
	
	#Name of .db or .zip file.
	
	if [[ -z $sourceName ]]
	then
		sourceName="newpipe.db"
		#newpipe.db will be default if no input file is given
	fi

	if [[ ! -f "$sourceName" ]]
	then
    		echo "$sourceName does not exist, quitting."
		exit 1
	fi


	if [[ "$sourceName" == *.zip ]]
	then

		echo "Getting newpipe.db from $sourceName."
		tempDB=$(mktemp)
		unzip -p "$sourceName" newpipe.db > "$tempDB" || (rm temp.db && exit 1)
		sourceName=$tempDB

	elif [[ "$sourceName" != *.db ]]
	then 
		echo "Only .db and .zip files are supported."
		exit 1
	fi
	
	#Put all of the playlists into an array
	#Requires bash 4.4 or newer
	mapfile -t playlistData < <(sqlite3 "$sourceName" "SELECT uid,name FROM playlists;" | sort -g)

}

outputPlaylistFile(){

	sqlite3 "$sourceName" "SELECT url || \" #\" || title FROM streams WHERE uid IN (SELECT stream_id FROM playlist_stream_join WHERE playlist_id == $1);" > "$2".txt

}


helpMessage(){

	# Display Help
	echo "Extracts urls from Newpipe playlists."
	echo "Accepts either the .zip obtained from the \"export database\" function in the settings menu or the newpipe.db inside of the zip."
	echo
	echo "Usage: playlistExtractor [-o] [database|zip name]"
	echo
	echo "options:"
	echo "-h    Print this help message."
	echo "-o    Overrides files instead of skipping"
   	echo
}

main(){
        
	while getopts ":ho" option; do
   		case $option in
			h) #Display help message
        		helpMessage
	        	exit 0;;
      		o) #override
				override="true"
				shift 1;;
			\?) # Invalid option
				echo "Error: Invalid option"
         		exit 1;;
   		esac
	done
	if [[ "" || ! -f "newpipe.db" ]]     
	then
		echo "thats true"
	fi

	getPlaylistData "$1"

	for (( i=0; i<${#playlistData[@]}; i++ ))
	do
		id=$(echo "${playlistData[$i]}" | cut -d "|" -f 1)
		name=$(echo "${playlistData[$i]}" | cut -d "|" -f 2-)
		echo "Getting $name..."
		if [[ "$override" || ! -f "$name.txt" ]]
		then
			sqlite3 "$sourceName" "SELECT url || \" #\" || title FROM streams WHERE uid IN (SELECT stream_id FROM playlist_stream_join WHERE playlist_id == $id);" > "$name".txt
		else
			echo "$name.txt already exists, skipping."
		fi
	done
		
	
	if [[ -n $tempDB ]]
	then
		echo "Deleting temporary database..."
		rm "$tempDB"
	fi

}     

main "$@"

