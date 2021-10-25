#! /usr/bin/bash


# Sort arguments after scriptCAll
# -ru means start at cd /, or root folder
#
function sort_args()
{
# This var is for checking if input is a number in case of option -d
re='^[0-9]+$'
# This loop itarate each argument, until no more arguments to check
while [ ! -z $1 ] || [ $1 ! = "" ]
do
	OPT=
	PAR=
	# Arguments at command line input in the format of:
	#
	#	-option 
	#	or
	#	-option parameter
	#
	#	Example: ./script -ru
	#	or
	#		./script -d /home/kali/Desktop
	#
	# This lines are extracting arguments appears after command
	# into two vars
	OPT=$1
	PAR=$2
	# Switch the first argument of the two,
	# Then if found match, checking validation of option argument
	case ${OPT} in
	"-d")
		if [ -d "${PAR}" ]; then
  			cd "${PAR}"
  			echo -en "Running successfull! \nStart at path ${PAR} with -d option: \n"
		else
			echo -en "Error: Source option requires valid dir path! \n"
			exit 1
		fi ;;
	
	"-ru")  
		if [[ -z ${PAR} ]] || [[ ${PAR} = "" ]]; then
			cd /
			echo -en "Running successfull \nroot mode on:\n"
		else
			echo -en "Error: Root option requires no adding parameters! \n"
			exit 1
		fi ;;	
	*)
		echo -en "Error: ivalid option detected! \n"
		exit 1 ;;
	esac
	shift; shift;
	# If does not exit, the loop iterate to next 2 arguments
	# by shifting twice the last checked argumnets
	
done
}

function find_files()
{
	local DEPTH_LVL=$1
	
	# Get list of all objects in current dir
	local LISTALL=`ls -a`
	# Get number of objects by counting lines
	local LISTSIZE=`echo -e "${LISTALL}" | wc -l`
	# This is kinda index
	local LINE=1
	# Stores current file name from list
	local CRNTFILE=
	
	while [ ${LINE} -le $((${LISTSIZE})) ];
	do
		# Refresh current file container
		unset CRNTFILE
		# Cut file from list, and adding 1 to LINE
		CRNTFILE=`echo -e "${LISTALL}" | head -n ${LINE} | tail -n1`
		LINE=$((LINE + 1))
		
		# Break out if gets to end of list
		if [ -z "${CRNTFILE}" ] || [ "${CRNTFILE}" = "" ]; then
			break
		fi
		
		# Skipping those dots from lists head
		if [ "${CRNTFILE}" == "." ] || [ "${CRNTFILE}" == ".." ]; then
			continue 1
		fi
		
		# Check if current entry is a directory. if so, cd there
		# and begin new search
		if [ -d "${CRNTFILE}" ]; then
			for (( i=0 ; i < ${DEPTH_LVL}+1 ; i++ ))
			do
				printf " *"
			done
			echo "Dir found: ${CRNTFILE}"			
			cd "${CRNTFILE}"
			find_files "$((DEPTH_LVL + 1))"
			cd ..
			PID=$!
			wait $PID
			continue 1
		fi
		
		# If not a dir looking for file, exe or simple
		if [ -f "${CRNTFILE}" ] || [ -x "${CRNTFILE}" ]; then
			for (( i=0 ; i < ${DEPTH_LVL}+1 ; i++ ))
			do
				printf " *"
			done
			echo "File found: ${CRNTFILE}"
		fi
		
	done
}
sort_args $@
find_files "0"
		
