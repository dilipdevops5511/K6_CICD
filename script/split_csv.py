import csv
import os

def split_csv(input_file, output_dir, num_parts):
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    # Open the input CSV file
    with open(input_file, 'r', newline='') as csvfile:
        reader = csv.reader(csvfile)
        headers = next(reader)  # Read headers
        total_rows = sum(1 for row in reader)  # Count total rows

        # Calculate rows per part
        rows_per_part = total_rows // num_parts
        remainder = total_rows % num_parts
        
        # Rewind to start of file
        csvfile.seek(0)
        next(reader)  # Skip headers
        
        # Create output files
        output_files = []
        for i in range(num_parts):
            part_filename = os.path.join(output_dir, f'data_part{i + 1}.csv')
            output_files.append(open(part_filename, 'w', newline=''))
            csv.writer(output_files[i]).writerow(headers)  # Write headers

        # Distribute rows among output files
        current_output = 0
        current_row = 0
        for row in reader:
            csv.writer(output_files[current_output]).writerow(row)
            current_row += 1
            if current_row >= rows_per_part + (1 if current_output < remainder else 0):
                current_output += 1
                current_row = 0

        # Close all output files
        for file in output_files:
            file.close()

if __name__ == "__main__":
    input_file = 'data.csv'        # Path to the input CSV file
    output_directory = 'split_data' # Directory to store split CSV files
    num_parts = 3                  # Number of parts to split into

    split_csv(input_file, output_directory, num_parts)
