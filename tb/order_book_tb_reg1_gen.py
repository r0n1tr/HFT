def convert_to_32bit(stock_id, order_type, quantity):
    
    stock_id_bin = format(stock_id, '02b')
    order_type_bin = format(order_type, '02b')
    quantity_bin = format(quantity, '016b')
    
    
    concatenated_bin = '0' * 12 + stock_id_bin + order_type_bin + quantity_bin
    
    
    result = int(concatenated_bin, 2)
    
    return result


stock_id = 2       
order_type = 0     
quantity = 39

result = convert_to_32bit(stock_id, order_type, quantity)
print(f"32-bit decimal result: {result}")
