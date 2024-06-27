import pandas as pd
import numpy as np

# Load the CSV data
csv_data = pd.read_csv('data/combined.csv')

# Split data into three parts
split_data = np.array_split(csv_data, 3)

# Save the split data
split_data[0].to_csv('data/combined_us_east_1.csv', index=False)
split_data[1].to_csv('data/combined_us_west_2.csv', index=False)
split_data[2].to_csv('data/combined_eu_west_1.csv', index=False)

print("CSV data split and saved to 'data/' directory.")
