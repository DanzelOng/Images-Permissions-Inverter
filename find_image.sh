#!/bin/bash

# Check for any jpg or png files using find and store the result temporarily
IMAGE_FILES=$(find . -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" \))

# if IMAGE_FILES is empty then exit script
if [[ -z $IMAGE_FILES ]]; then
	echo "No images file present in $(pwd)"
	exit 1
else
	echo
	echo "---------- Image files in $(pwd) ----------"
	echo
	# retrieve output from IMAGE_FILES and get the filename and size in bytes
	echo "$IMAGE_FILES" | xargs -I{} ls -l "{}" | awk '{ gsub("./","",$NF); printf "%s Size: %d bytes\n", $NF, $5 }'
	
fi 
echo

# get the total size of the files in bytes
TOTAL_SIZE=$(find . -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" \) -exec stat -c %s {} \; | awk '{sum += $1} END {print sum}')

# output the total size in bytes
echo "Total size of files: $TOTAL_SIZE bytes"
echo

# check if total size < 5_000_000
if [[ $TOTAL_SIZE -lt 5000000 ]]; then
    echo "total image size is small"
    
# total size >= 5_000_000
else
    echo "total image size is NOT small"
fi
echo

echo "---------- Current File Permissions ----------"
echo
# format the output of each file starting from the file name follwed by the owner, group and others permissions
find . -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" \) -exec ls -l {} \; | awk '{ gsub("./","",$9);
        printf "%s owner %s group %s others %s\n", $9, substr($1,2,3), substr($1,5,3), substr($1,8,3)
    }'
    
echo
while true;
do
    # prompt user to enter their user type
    read -p "Enter your user type (owner/group/others) : " USER_TYPE
    # convert input to lowercase
    USER_TYPE=${USER_TYPE,,}
    USER=$USER_TYPE
    
    # prompt user to enter the file operation
    read -p "Choose the desired file operation (read/write/execute): " OPERATION
    # convert input to lowercase
    OPERATION=${OPERATION,,}
    FILE_OPERATION=$OPERATION
    
    # create 2 boolean variables to store validation outcome of user type and file operation type
    valid_user=false
    valid_operation=false
    
    # check if user type is valid
    if [[ $USER_TYPE != "owner" && $USER_TYPE != "group" && $USER_TYPE != "others" ]]; then
        echo "Invalid user. Please enter 'owner', 'group', or 'others'."
    else
    	valid_user=true
    fi
    
    # check if file operation type is valid
    if [[ $OPERATION != "read" && $OPERATION != "write" && $OPERATION != "execute" ]]; then
        echo "Invalid operation. Please enter 'read', 'write', or 'execute'."
    else	
    	valid_operation=true
    fi
    # break the while loop if both user type and file operation type are valid
    if  [[ $valid_user == true && $valid_operation == true ]]; then
    	break
    else
    	echo
    fi
done

# convert user type to respective chmod user type formats ('u', 'g', 'o')
case $USER_TYPE in
    owner) USER_TYPE="u";;
    group) USER_TYPE="g";;
    others) USER_TYPE="o";;
esac

# convert file operation type to respective chmod file formats ('r', 'w', 'x')
case $OPERATION in
    read) OPERATION="r";;
    write) OPERATION="w";;
    execute) OPERATION="x";;
esac

# cut extracts the substring based on the POSITION value
find . -type f \( -iname "*.png" -o -iname "*.jpg" \) -exec bash -c '
FILE="$0"
USERTYPE="$1"
OPERATION="$2"

# Determine the position of permissions based on user type
# owner permissions are in positions 2-4.
# group permissions are in positions 5-7.
# others permissions are in positions 8-10.
case $USERTYPE in
    u) POSITION=2;;
    g) POSITION=5;;
    o) POSITION=8;;
esac

# Extract the current permissions for the given user type
CURRENT_PERMISSIONS=$(stat -c "%A" "$FILE" | cut -c "$POSITION-$((POSITION+2))")

# Check if the desired operation (r, w, or x) is already set
# invert permissions 
if [[ $CURRENT_PERMISSIONS == *"$OPERATION"* ]]; then
    chmod "$USERTYPE-$OPERATION" "$FILE"
else
    chmod "$USERTYPE+$OPERATION" "$FILE"
fi
' {} "$USER_TYPE" "$OPERATION" \;

echo
echo "Permissions inverted!"
echo

echo "-------- Successfully inverted '$FILE_OPERATION' file permissions for '$USER' --------"
echo
# get file information for only .jpg or .png files
find . -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" \) -exec ls -l {} \; | 

# format the output of each file starting from the file name follwed by the owner, group and others permissions
awk '{ gsub("./","",$9);
	printf "%s owner %s group %s others %s\n", $9, substr($1,2,3), substr($1,5,3), substr($1,8,3)
	}'

echo
echo "---------- Current Date and Time ----------"
echo
current_date_time=$(date +"%d-%m-%y:%H:%M")
echo "Current date and time: $current_date_time"