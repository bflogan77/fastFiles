#!/bin/bash


function populateLastLs(){  #look for .lastLs.txt and use its contents if it exists
	if [ ! -e .lastLs.txt ]
	then
		echo $(ls) > .lastLs.txt
	fi
	IFS=' ' read -r -a lastLs < .lastLs.txt
}

function numericArgFinder(){
	count=0
	for arg in ${args[@]}
	do
		numFiles=${#lastLs[@]}
		re='^[0-9]+' 
		if [[ $arg =~ $re ]] #this is not commutative.  regex must follow =~
		then
			if [ $arg -lt $numFiles ] #check if the numeric arg is valid
			then
				args[$count]=${lastLs[$arg]}
			else
				echo "numeric arg \"$arg\" greater than number of files"
				return 1
			fi
		fi
		count=$(($count+1))
	done
	#echo args post arg finder: ${args[@]}
}

args=( "$@" )
files=$(ls -1)
red="\e[1;31m"
green="\e[1;32m"
cyan="\e[1;36m"
yellow="\e[1;33m"
reset="\e[0m"
populateLastLs
numericArgFinder

if [ ${args[0]} = "ls" ] #do certain things for ls or cd, otherwise parse numeric args
then  #TODO: look for incompatible LS options
	labeledLs=()
	lastLs=$(${args[@]} -1)
	echo $lastLs > .lastLs.txt
	count=0
	colCount=$(tput cols)
	longestFname=0
	for file in $lastLs
	do #create a labeledLs variable (ls with prepended numbers) and track the longest name
		nameLength=$((${#file}+${#count}+2))
		if [ "$nameLength" -gt "$longestFname" ]
		then
			longestFname=$nameLength
		fi
		labeledLs+=($count\)$file)
		#echo -e $count\) $file
		count=$(($count+1))
	done
	displayCols=$(($colCount/$longestFname))
	count=0
	for label in  ${labeledLs[@]}
	do #print nicely formatted ls with numbered filenames
		if [ "$count" -gt "0" ]
		then
			if [ "$(($count%$displayCols))" -eq "0" ]
			then
				printf "\n" #start a new line every displayCols columns
			fi
		fi
		#TODO: print in nice colors
		printf "%-"$longestFname"s" $label
		count=$(($count+1))
	done
	printf "\n"
elif [ ${args[0]} = "cd" ]
then
	rm -f .lastLs.txt
	${args[@]}
else #execute any other command with parsed args
	${args[@]}
	#return 0
	exit
fi

