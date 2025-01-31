#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

input_file="$1"
output_file="$2"
temp_file="temp_cleaned.csv"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found."
    exit 1
fi

# Remove carriage return characters from the input file and save to a temporary file
tr -d '\r' < "$input_file" > "$temp_file"

# Write the additional headers to the output file
echo "#constant measurement,co2_intensity" > "$output_file"
echo "#datatype dateTime:RFC3339,tag,tag,tag,field,field,field,field,tag,boolean,ignore" >> "$output_file"

# Read the cleaned temporary CSV file line by line
while IFS=, read -r datetime country zone_name zone_id ci_direct ci_lca low_carbon_pct renewable_pct data_source data_estimated data_estimation_method; do
    # Check if the line is the header
    if [[ "$datetime" == "Datetime (UTC)" ]]; then
        # Write the header to the output file
        echo "DatetimeT(UTC)Z,Country,Zone Name,Zone Id,Carbon Intensity gCO₂eq/kWh (direct),co2_intensity,Low Carbon Percentage,Renewable Percentage,Data Source,Data Estimated,Data Estimation Method" >> "$output_file"
    else
        # Replace the space between date and time with 'T' to match RFC3339 format
        datetime="${datetime// /T}"
        # Append 'Z' to the datetime if not already present
        if [[ "$datetime" != *"Z" ]]; then
            datetime="${datetime}Z"
        fi
        # Write the modified line to the output file
        echo "$datetime,$country,$zone_name,$zone_id,$ci_direct,$ci_lca,$low_carbon_pct,$renewable_pct,$data_source,$data_estimated,$data_estimation_method" >> "$output_file"
    fi
done < "$temp_file"

# Remove the temporary file
rm "$temp_file"

