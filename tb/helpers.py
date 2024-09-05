def make_fixed_point_input(decimal_value):
    # Shift the decimal value by 2^32 (to account for 32 bits fractional part)
    scaled_value = round(decimal_value * (1 << 32))
    
    # Mask to ensure the value fits in a 64-bit signed integer (two's complement)
    if scaled_value >= 0:
        fixed_point_value = scaled_value & ((1 << 64) - 1)
    else:
        fixed_point_value = ((1 << 64) + scaled_value) & ((1 << 64) - 1)
    
    return fixed_point_value

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

print(make_fixed_point_input(0.125*0.05))