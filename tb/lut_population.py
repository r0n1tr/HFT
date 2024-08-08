import numpy as np

def float_to_fixed(value, frac_bits=8):
    """Converts a floating-point number to fixed-point representation."""
    fixed_value = int(round(value * (1 << frac_bits)))
    return fixed_value

def fixed_to_hex(value, width=16):
    """Converts a fixed-point number to a hexadecimal string with specified width."""
    return f"{value & ((1 << width) - 1):0{width // 4}X}"

# Define the range and number of steps
x_min = -1.0
x_max = 1.0
num_steps = 1000  # Number of steps in the lookup table
step_size = (x_max - x_min) / (num_steps - 1)

# Initialize the lookup table
lookup_table = []

# Populate the lookup table
for i in range(num_steps):
    x = x_min + i * step_size
    y = np.exp(x)
    y_fixed = float_to_fixed(y)
    lookup_table.append(y_fixed)

# Write the lookup table to a .mem file
with open('exp_lut.mem', 'w') as f:
    for value in lookup_table:
        hex_value = fixed_to_hex(value, width=16)  # Use 16-bit fixed-point format
        f.write(f"{hex_value}\n")

print("Lookup table written to 'lookup_table.mem'")


# printed in fixed point precision when taken into exp module we need to /256 to express the correct value of e^x