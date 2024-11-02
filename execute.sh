#!/bin/zsh

# Check if the user provided the number of elements, min, and max as arguments
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <number_of_random_numbers> <min_value> <max_value>"
  exit 1
fi

# Parameters
count=$1
min=$2
max=$3
json_file="./smart-monkey-config.json"
folder_to_remove="./seeds-results"

# Ensure min is less than max
if (( min >= max )); then
  echo "Error: min_value should be less than max_value."
  exit 1
fi

# Create an empty associative array to store unique random numbers
declare -A unique_numbers

# Generate unique random numbers until we reach the desired count
while [ "${#unique_numbers[@]}" -lt "$count" ]; do
  rand_num=$(shuf -i "$min"-"$max" -n 1)
  unique_numbers[$rand_num]=1  # Add the number to the associative array
done

# Print all unique random numbers
echo "Generated random numbers:"
seeds_file="seeds"
: > "$seeds_file" 

for number in "${(@k)unique_numbers}"; do
  echo $number >> "$seeds_file"
done

if [ -d "$folder_to_remove" ]; then
  rm -rf "$folder_to_remove"
  echo "Removed output folder: $folder_to_remove"
fi
mkdir ./seeds-results;

for number in "${(@k)unique_numbers}"; do
  # Update the JSON file's "seed" field
  if [ -f "$json_file" ]; then
    # Use jq to update the seed in the JSON file
    jq --argjson seed $number '.env.seed = $seed' $json_file > tmp.$$.json && mv tmp.$$.json $json_file
    echo "Updated seed to $seed_number in $json_file"
  else
    echo "Error: JSON file not found at $json_file"
    exit 1
  fi

  # Run the npm command
  npm run smart-monkey
  mkdir ./seeds-results/seed-$number; mv ./results/* ./seeds-results/seed-$number; mv ./cypress/screenshots/**/*.png ./seeds-results/seed-$number
done

