#!/bin/bash

# # Define colors...
# RED=`tput bold && tput setaf 1`
# GREEN=`tput bold && tput setaf 2`
# YELLOW=`tput bold && tput setaf 3`
# BLUE=`tput bold && tput setaf 4`
# NC=`tput sgr0`

# function RED(){
# 	echo -e "\n${RED}${1}${NC}"
# }
# function GREEN(){
# 	echo -e "\n${GREEN}${1}${NC}"
# }
# function YELLOW(){
# 	echo -e "\n${YELLOW}${1}${NC}"
# }
# function BLUE(){
# 	echo -e "\n${BLUE}${1}${NC}"
# }
# function CheckError(){
# 	if [ $? -eq 1 ] || [ $ERRORFLAG -eq 1 ]
# 	then
# 		RED "[-]${NC} $@"
# 		exit 1
# 	fi
# }
# function SHOWHELPANDEXIT(){
# 	echo "${BLUE}Usage: sudo ./ignition_key.sh [user_id{1000-1500}]${NC}\nLeave black to use default user_id: 1000"
# 	exit 0
# }

# if [ $1 = '-h' ] || [ $1 = '--help' ]
# then
# 	SHOWHELPANDEXIT
# fi

# i=1

# if [ -e added.repos ]
# then 
# 	echo true
# fi
FILECACHE=filename.cache # Needs to have a blank last line.
FILENAMES=()

# readarray -t FILENAMES $FILECACHE

FILENAMES=('Standard-Apps' 'Python-Apps' 'Python-Packages')

for file in "filenames/${FILENAMES[@]}"
do
	file=filenames/$file
	echo $file
	if [ -z $file ]
	then
		continue
	fi
	echo $file
	if [ $file = "Python-Packages" ]
	then
		# while read line; 
		# do
		# 	# if [ -z $line ]
		# 	# then
		# 	# 	continue
		# 	# fi
		# 	echo "$line"
		# done < $file
		continue
	fi
	while read line; 
	do
		if [ -z $line ]
		then
			continue
		fi
		echo $line
	done < $file
	echo
done
echo 'DONE'