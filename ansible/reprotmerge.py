import json

# Paths to the fetched k6_report.json files
file1_path = '/home/ubuntu/3.89.225.78_k6_report.json'
file2_path = '/home/ubuntu/54.234.217.103_k6_report.json'

# Function to read and parse JSON file
def read_json_file(file_path):
    with open(file_path, 'r') as f:
        data = json.load(f)
    return data

# Function to merge two JSON files
def merge_json_files(file1, file2):
    # Assuming 'data' -> 'result' structure
    merged_data = {
        'data': {
            'result': file1['data']['result'] + file2['data']['result']
        }
    }
    return merged_data

try:
    # Read JSON files
    json_data1 = read_json_file(file1_path)
    json_data2 = read_json_file(file2_path)

    # Merge JSON files
    merged_data = merge_json_files(json_data1, json_data2)

    # Write merged data to a new JSON file
    merged_file_path = '/path/to/merged_k6_report.json'
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
