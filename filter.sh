#!/bin/bash
VERSION="1.0.0"
BLUE='\033[0;34m' #Define the colour blue
NC='\033[0m' #Define no colour - when applying colour to any text it must be reset to no colour by the end of the line to ensure other strings of text do not accidentally change colour
RAM=$1 #The first argument inputted will be taken as the minimum RAM required by the user.
Storage_Min=$2 #The second argument will be the minimum storage desired by the user.
CSV=$3 #These find the arguments entered by the user as per the assignment requirements
#Ideally ensure this script is in the same directory as the csv file you intend to use for ease of usere access.
matches=0; #I was considering adding: dirsuffix=$(date +"%Y_%m_%d_%H_%M_%S") dir="bu_$(date +"%Y_%m_%d_%H_%M_%S")" path="/" sep="_" As it finds the current directory but the source file is actually given by the user itself.
rows=() #This is used later to store all the models that meet the requirements of the user based on the arguments provided
declare -A brands #Create an array to store the brands #I used declare for the brands as I will need to count how many suitable devices each brand has
#The following if Statements are designed to check if the user is appropriately using the program by examing the arguments they provided and then providing help on how to resolve errors.
if (( $# != 3 )); then #Uses the default variable $# to identify how many arguments were inputted and then returns an error if there are not exactly 3
    echo "Version number: $VERSION"
    echo "There are not enough arguments provided for the script to run properly"
    echo "Please ensure there are 3 arguments in the order Mimimum_RAM (GB), Minimum Storage (GB), and then the source csv"
    echo "For example: ./filter.sh 16 128 source.csv" #provides an example to the user if the make a mistake
    exit 1 #Exit 1 for all errors
fi
#The following if statements simply check if the first 2 arguments are integers as RAM and Storage must be integer values. I could not use > 0 because the code would crash if a string was inputted.
if ! [[ "$1" =~ ^[0-9]+$ ]]; then #the ^[0-9]+$ checks that only digits are being used and will fail if any string values are used
    echo "For miminum RAM you have entered the value $1 which is not a positive integer. Please enter a numerical value eg 8"
    exit 1 
fi

if ! [[ "$2" =~ ^[0-9]+$ ]]; then
    echo "For miminum Storage you have entered the value $2 which is not a positive integer." 
    echo "Please enter a numerical value eg 128"
    exit 1
fi

if [[ ! -f "$CSV" || ! -r "$3" ]]; then #-f checks if the 3rd argument can be found and -r checks if it can be read
    echo "CSV content could not be found please check the desired csv filename is the 3rd argument and is working"
    echo "You may need to ensure that the file has read permissions enabled and you have entered the correct name with the appropriate extension eg source.csv"
    echo "You can enter the first few letters of the filename and then press TAB to autocomplete."
    echo "If pressing TAB does not autocomplete the filename please ensure you are in the correct working directory and that the file is accessible."
    exit 1
fi #Checks if the 3rd argument is a file and that it can be found with information inside


read -r _ < "$CSV" #Clears the header as the header of the CSV is just categories and does not need to be read
# This is where the while loop will now read the remainder of the file.
while IFS=',' read -r smartphone brand model ram storage color final_price \
    || [[ -n "$smartphone" ]]; do #added this to fix a problem by ensuring the last line of the csv is read even if the file does not end with a newline character (which the provided file will not unless you manually change it to a text csv in Libra Office)
    #echo "Debug $smartphone $brand $model $ram $storage $color $final_price" #Just used for debugging
    if (( ram >= RAM && storage >= Storage_Min)); then #This is where the the while loop filters for the models with sufficient RAM and Storage based on the arguemnts provided by the user.
        ((matches++)) #Counts how many matches
        ((brands["$brand"]++)) #Counts how many different brands have at least one model that meets the requirements
        value=$(printf "%-20s | %-20s | %-20s | $%-19s\n" "$brand" "$model" "$color" "$final_price") #Finds the valyues to be printed later
        rows+=("$value") #Adds the values to the array to make it easier to print later
            
    fi
done < "$CSV" #Uses the CSV provided by the user for the while loop

echo "$matches devices were found with ${RAM}GB RAM and ${Storage_Min}GB Storage" #Uses the matches variable to indicate how many mathces have been found
#This next stage produces all the important output 
for brand in "${!brands[@]}"; do #for loop that prints each brand and how many matches it has
    printf "%-10s (%d)\n" "$brand" "${brands[$brand]}"
done | sort #The | sort will ensure the results are alphabetical order
printf "${BLUE}%-20s | %-20s | %-20s | %-20s\n${NC}" "BRAND" "MODEL" "COLOUR" "PRICE" #The ${BLUE} signals to use blue when creating the first row of the column which is then cancelled by the ${NC} to ensure no other lines print in blue
for row in "${rows[@]}"; do
    echo "$row" #prints all the rows stored earlier by the value=$(printf "%-20s | %-20s | %-20s | $%-19s\n" "$brand" "$model" "$color" "$final_price")
done | sort #once again added a sort for alphabetical order as I noticed the example in the assignment was was ordered alphabetically.
#echo "Number of rows found: $(( ${#rows[@]} + 0))" #enable for debugging
exit 0
