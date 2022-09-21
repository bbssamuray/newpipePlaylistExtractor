#!/bin/bash
#SELECT title FROM streams WHERE uid IN (SELECT stream_id FROM playlist_stream_join WHERE playlist_id == 3);

set -o pipefail -e
#Exit script if there are any errors
 
outFileName="output.txt"

outputFile(){

	tempDB=""
	sourceName=$1
	#Name of .db or .zip file.
	
	if [[ -z $sourceName ]]
	then
		sourceName="newpipe.db"
	fi

	if [[ ! -f "$sourceName" ]]
	then
    		echo "$sourceName does not exist, quitting."
		exit 1
	fi


	if [[ "$sourceName" == *.zip ]]
	then
		if test -f "temp.db"
		then
    			echo "temp.db already exists, please delete it before proceeding."
    			exit 1
		fi

		echo "Getting newpipe.db from $sourceName."
		tempDB="temp.db"
		unzip -p "$sourceName" newpipe.db > "$tempDB" || (rm temp.db && exit 1)
		sourceName=$tempDB

	elif [[ "$sourceName" != *.db ]]
	then 
		echo "Only .db and .zip files are supported."
		exit 1
	fi


	sqlite3 $sourceName "SELECT uid,name FROM playlists;" | sort -g
	read -p "Enter the id of playlist you want to extract:" playlistID
	sqlite3 $sourceName "SELECT url FROM streams WHERE uid IN (SELECT stream_id FROM playlist_stream_join WHERE playlist_id == $playlistID);" > "$outFileName"

	if [[ ! -z $tempDB ]]
	then
		echo "Deleting temporary database..."
		rm $tempDB
	fi


}

helpMessage()
{
	# Display Help
	echo "Extracts urls from Newpipe playlists."
	echo "Accepts either the .zip obtained from the \"export database\" function in the settings menu or the newpipe.db inside of the zip."
	echo
	echo "Usage: playlistExtractor [-o fileName] [database|zip name]"
	echo
	echo "options:"
	echo "-h    Print this help message."
	echo "-o    Output file. output.txt by default"
   	echo
}

main(){
        
	while getopts ":ho:" option; do
   		case $option in
			h) #Display help message
        			helpMessage
	        		exit 0;;
      			o) #Set output file
				echo $OPTARG 123
	        		outFileName=$OPTARG
				shift 2;;
			\?) # Invalid option
				echo "Error: Invalid option"
         			exit 0;;
   		esac
	done        
	
	outputFile $1
}     

main $@




