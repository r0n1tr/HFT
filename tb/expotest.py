import numpy as np
import math

# Generate 1000 linearly spaced values between -1.0 and 1.0
array_size = 1_000_000
x_values = np.linspace(-1.0, 1.0, array_size)

# Calculate the exponential of each value
exp_values = np.exp(x_values)

# Round the exponential values to 5 decimal places
exp_values_rounded = np.round(exp_values, 5)
print(exp_values_rounded)

# Define the base_order variable
base_order = 100

def lookup_exp_value(input_value):
    # Ensure the input_value is within the valid range
    if input_value < -1.0 or input_value > 1.0:
        raise ValueError("Input value must be between -1.0 and 1.0 inclusive.")

    # Calculate the corresponding index
    index = int(round((input_value + 1.0) * (array_size-1) / 2.0))
    
    # Retrieve the exponential value from the array and multiply by base_order
    return base_order * exp_values_rounded[index]

# # Example usage
# counter = 0
# for i in range (len(exp_values)):
#     exp_value = lookup_exp_value(x_values[i])
#     test_base = 100 * np.exp(x_values[i])
# #print(f"actual value: {math.floor(test_base)} // calculated value: {math.floor(exp_value)}")
#     if(math.floor(test_base) != math.floor(exp_value)) :
#         print(f"not equal {math.floor(test_base)} to {math.floor(exp_value)}")
#         counter += 1

# Write the rounded exponential values to a .mem file
with open("exp_values.mem", "w") as mem_file:
    for value in exp_values_rounded:
        # Convert the floating point value to fixed point q32.32 format
        fixed_point_value = int(value * (1 << 32))
        
        # Convert to 64-bit hexadecimal representation
        hex_value = f"{fixed_point_value:016X}"
        
        # Write the hexadecimal value to the file
        mem_file.write(hex_value + "\n")

print("Exponential values have been written to exp_values.mem")        


# print("success")
# print(f"counter: {counter}")
    

