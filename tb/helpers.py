def make_fixed_point_input(decimal_value):
    # Shift the decimal value by 2^32 (to account for 32 bits fractional part)
    scaled_value = round(decimal_value * (1 << 32))
    
    # Mask to ensure the value fits in a 64-bit signed integer (two's complement)
    if scaled_value >= 0:
        fixed_point_value = scaled_value & ((1 << 64) - 1)
    else:
        fixed_point_value = ((1 << 64) + scaled_value) & ((1 << 64) - 1)
    
    return fixed_point_value


def make_fixed_point_input_signed(decimal_value):
    # Check if the input value is within the allowable range for Q1.32 format
    if decimal_value < -2.0 or decimal_value >= 2.0:
        raise ValueError("Input value is out of the allowable range for Q1.32 fixed-point format")

    # Scale the decimal value to the fixed-point format Q1.32 (1 integer bit + 32 fractional bits)
    scaled_value = round(decimal_value * (1 << 32))  # This scales to 32 fractional bits

    # Mask to ensure the value fits in a 64-bit signed integer (two's complement)
    # Ensure that the value fits in the range [-2^63, 2^63 - 1]
    if scaled_value >= 0:
        # Positive value; fit it into a 64-bit signed integer
        fixed_point_value = scaled_value & ((1 << 64) - 1)
    else:
        # Negative value; convert to two's complement format
        fixed_point_value = (scaled_value + (1 << 64)) & ((1 << 64) - 1)
    
    # Format the value as a hexadecimal string
    hex_value = f"0x{fixed_point_value:016X}"
    
    return hex_value




def convert_fixed_point_output(fixed_point):
    # Mask to extract the integer part (upper 32 bits)
    integer_mask = 0xFFFFFFFF00000000
    # Mask to extract the fractional part (lower 32 bits)
    fractional_mask = 0x00000000FFFFFFFF
    
    # Extract the integer part
    integer_part = (fixed_point & integer_mask) >> 32
    
    # Extract the fractional part
    fractional_part = fixed_point & fractional_mask
    
    # Convert the fractional part to decimal by dividing by 2^32
    fractional_decimal = fractional_part / (1 << 32)
    
    # Combine the integer and fractional parts
    decimal_value = integer_part + fractional_decimal
    
    # Adjust for signed numbers
    if integer_part & 0x80000000:  # Check if the sign bit is set
        decimal_value -= (1 << 32)  # Adjust for negative numbers
    
    return decimal_value



print(make_fixed_point_input(100))

print(convert_fixed_point_output(0xFFFF_FFFF_1000_0000))