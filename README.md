# Newpipe Playlist Extractor
This small bash script extracts your offline playlists from [Newpipe](https://github.com/TeamNewPipe/NewPipe "Newpipe Github Page") databases.
When given a database, it will open files with the names of your Newpipe playlists, containing video urls and names.

# Usage
`playlistExtractor.sh [-o] File`
"File" is the exported zip from the app.
With the -o flag, files will be overwritten if they already exist.

# Requirements
This scirpt requires `sqlite3` and `unzip`.
Both of them can be installed by using the following command on Debian based distros:
`sudo apt install unzip sqlite3`

