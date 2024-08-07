import numpy as np

# Define the number of fractional bits
fractional_bits = 8
total_bits = 10
max_int = 2 ** (total_bits - 1)

# Generate lookup table
lookup_table = []

for i in range(2 ** total_bits):
    fixed_point_value = (i - max_int) / float(2 ** fractional_bits)
    exp_value = np.exp(fixed_point_value)
    lookup_table.append(exp_value)

# Save to a memory initialization file
with open("exp_lut.mem", "w") as file:
    for value in lookup_table:
        file.write(f"{int(value * (2 ** 8)):04x}\n")
