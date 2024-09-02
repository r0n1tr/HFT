# from exchange import Exchange

# my_exchange = Exchange()

def itch_to_readable(ITCH_data):
        # return a list of the parsed data
        # print("Parsing...")
        # print(ITCH_data)
        reg_0 = ITCH_data[8]
        reg_1 = ITCH_data[7]
        reg_2 = ITCH_data[6]
        reg_3 = ITCH_data[5]
        reg_4 = ITCH_data[4]
        reg_5 = ITCH_data[3]
        reg_6 = ITCH_data[2]
        reg_7 = ITCH_data[1]
        reg_8 = ITCH_data[0]

        order_book_inputs = []
        
        order_type = reg_0 & 0xff
        order_type_dict = {
            65: "ADD",
            68: "CANCEL",
            69: "EXECUTE"
        }

        # bits 0 to 151 is the same for all

        order_type = order_type_dict[order_type]
        # print(order_type)

        locate_code = (reg_0 >> 8) & 0xFFFF

        internal_tracking_number_half_1 = (reg_0 >> 24) & 0xFF
        internal_tracking_number_half_2 = reg_1 & 0xFF
        internal_tracking_number = (internal_tracking_number_half_1 << 8) | internal_tracking_number_half_2

        timestamp_1 = (reg_1 >> 8) & 0xFFFFFF
        timestamp_2 = (reg_2) & 0xFFFFFF
        final_time = (timestamp_2 << 24 ) +  timestamp_1 
       
        order_id_1 = (reg_2 >> 24) & 0xFF
        order_id_2 = reg_3
        order_id_3 = (reg_4) & 0xFFF
        order_id = (order_id_1 << 56) | (order_id_2 << 24) | order_id_3

        if order_type == "ADD":
            buy_or_sell = (reg_4 >> 24) & 0xFF
            if buy_or_sell == 0:
                buy_or_sell = "buy"
            else:
                buy_or_sell = "sell"
        else:
            buy_or_sell = None
        # print(buy_or_sell)

        if order_type == "ADD":
            shares = reg_5
        elif order_type == "EXECUTE":
            shares = ((reg_4 >> 24) & 0xFF) + ((reg_5 & 0xFFFFFF) << 8)
        else:
            shares = None
        
        if order_type == "ADD":
            stock_id = (reg_7 << 32) + reg_6
        elif order_type == "EXECUTE":
            stock_id = (reg_6 << 8) + ((reg_5 >> 24) & 0xFF) + ((reg_7 & 0xFFFFFF) << 40)
        else:
            stock_id = (reg_5 << 8) + ((reg_4 >> 24) & 0xFF) + ((reg_6 & 0xFFFFFF) << 40) 
        stock_dict = {
            4702127773838221344 : 0, 
            4705516477264961568 : 1, 
            5138412867491471392 : 2, 
            5571874491117608992 : 3
        }
        stock_id = stock_dict[stock_id]

        # print(stock_id)
        if order_type == "ADD":
            price = reg_8
        else:
            price = None

        order_book_inputs.append(stock_id)
        order_book_inputs.append(order_id)
        order_book_inputs.append(buy_or_sell)
        order_book_inputs.append(shares)
        order_book_inputs.append(price)
        order_book_inputs.append(order_type)
        order_book_inputs.append(final_time)
        # print(f"order_id: {bin(order_id)}")

        return order_book_inputs, locate_code, internal_tracking_number

def readable_to_ITCH(order_book_inputs, locate_code, internal_tracking_number):
    # Extract the values from the list
    stock_id = order_book_inputs[0]
    order_id = order_book_inputs[1]
    buy_or_sell = order_book_inputs[2]
    shares = order_book_inputs[3]
    price = order_book_inputs[4]
    order_type = order_book_inputs[5]
    final_time = order_book_inputs[6]

    # Reverse stock_id lookup
    stock_dict_reverse = {
        0: 4702127773838221344, 
        1: 4705516477264961568, 
        2: 5138412867491471392, 
        3: 5571874491117608992
    }
    stock_id = stock_dict_reverse[stock_id]

    # Reverse order_type lookup
    order_type_dict_reverse = {
        "ADD": 65,
        "CANCEL": 68,
        "EXECUTE": 69
    }
    order_type_value = order_type_dict_reverse[order_type]

    # Extract locate_code from order_id (similar to original function)
    

    internal_tracking_number_half_2 = internal_tracking_number & 0xFF
    internal_tracking_number_half_1 = (internal_tracking_number >> 8) & 0xFFFF
    # Handle locate_code and internal_tracking_number
    # print(type(locate_code))
    reg_0 = ((internal_tracking_number_half_1 & 0xFF) << 24) | ((locate_code & 0xFFFF) << 8) | (order_type_value & 0xFF)
    # reg_0 = (internal_tracking_number_half_1 << 24) | (locate_code << 8) | order_type_value
    temp = (final_time) & 0xFFFFFF
    reg_1 = ((internal_tracking_number_half_1) & 0xFF) | (temp << 8)
    reg_2 = (final_time & 0xFFFFFF) | ((order_id >> 56) << 24)
    
    reg_3 = (order_id >> 24) & 0xFFFFFFFF
    # print(f"order_id: {bin(order_id)}")
    # print(f"reg_3: {bin(reg_3)}")
    buffer = order_id & 0xFFFFFF
    reg_4 = 0
    if order_type == "ADD":
        if(buy_or_sell == "buy"):
            reg_4 = (0 << 24) | buffer
        else:
            reg_4 = ((1 << 24) - 1) | buffer
    
        reg_5 = shares
        reg_6 = stock_id & 0xFFFFFFFF
        reg_7 = (stock_id >> 32) & 0xFFFFFFFF
        reg_8 = price
    elif order_type == "EXECUTE":
        # reg_4 |= (shares & 0xFF) << 24
        reg_5 = ((shares >> 8) & 0xFFFFFF) | ((stock_id >> 40) << 24)
        reg_6 = (stock_id >> 8) & 0xFFFFFFFF
        reg_7 = stock_id >> 40
        reg_8 = None
    else:  # CANCEL
        reg_5 = (stock_id >> 40) & 0xFFFFFF
        reg_6 = (stock_id >> 8) & 0xFFFFFFFF
        reg_7 = stock_id >> 40
        reg_8 = None

    # Construct the original ITCH_data list
    ITCH_data = [reg_8, reg_7, reg_6, reg_5, reg_4, reg_3, reg_2, reg_1, reg_0]

    return ITCH_data


# input_vector = my_exchange.generate_ITCH_order(0, printing=False, integer_output=True)

# output_vector, locate_code, tracking_number =itch_to_readable(input_vector)

# final_vector = readable_to_ITCH(output_vector, locate_code, tracking_number)

# print(f"input_vector: {input_vector}")

# print(f"readable: {output_vector}")


# print(f"final: {final_vector}")


