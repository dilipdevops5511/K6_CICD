import json

# Paths to the fetched k6_report.json files
file1_path = '/home/ubuntu/a.json'
file2_path = '/home/ubuntu/b.json'

# Function to read and parse JSON file
def read_json_file(file_path):
    with open(file_path, 'r') as f:
        # Read entire file content
        content = f.read()
        
        # Split content by lines (assuming each line contains a JSON object)
        lines = content.splitlines()
        
        # Initialize an empty list to store parsed JSON objects
        json_data = []
        
        # Parse each line as JSON and append to json_data list
        for line in lines:
            if line.strip():  # Skip empty lines
                json_data.append(json.loads(line))
        
        return json_data

# Function to merge two JSON files
def merge_json_files(files_data):
    merged_data = {
        'data': {
            'result': []
        }
    }
    
    for file_data in files_data:
        merged_data['data']['result'].extend(file_data['data']['result'])
    
    return merged_data

try:
    # Read JSON files
    json_data1 = read_json_file(file1_path)
    json_data2 = read_json_file(file2_path)

    # Merge JSON files
    merged_data = merge_json_files(json_data1 + json_data2)

    # Write merged data to a new JSON file
    merged_file_path = '/home/ubuntu/merged_k6_report.json'
    with open(merged_file_path, 'w') as merged_file:
        json.dump(merged_data, merged_file, indent=4)

    print(f"Merged JSON report saved to: {merged_file_path}")

except FileNotFoundError:
    print("One or both of the JSON files were not found.")
except json.JSONDecodeError as e:
    print(f"Error decoding JSON: {e}")
except KeyError as e:
    print(f"KeyError: {e} - Check if the expected structure ('data' -> 'result') exists in your JSON files.")
except Exception as e:
    print(f"An error occurred: {e}")
