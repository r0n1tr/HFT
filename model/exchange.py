import random
import datetime
import time

order_ids = []

def generate_order_id():
    while True:
        number = random.randint(536870912, 4294967295)
        if number not in order_ids:
            order_ids.append(number)
            return number

own_order_ids = []
def generate_own_order_id():
    while True:
        number = random.randint(0, 536870911)
        own_order_ids.append(number)
        return number


def generate_timestamp():
    current_time = time.time()
    now = datetime.datetime.now()
    nine_thirty_am = datetime.datetime(now.year, now.month, now.day, 9, 30)
    nine_thirty_am_timestamp = time.mktime(nine_thirty_am.timetuple())
    seconds_since_nine_thirty = current_time - nine_thirty_am_timestamp
    return round(seconds_since_nine_thirty)


def generate_order_price(stock_id):
    if stock_id == 0:
        return round(random.normalvariate(1000000, 30))
    elif stock_id == 1:
        return round(random.normalvariate(2000000, 40))
    elif stock_id == 2:
        return round(random.normalvariate(3000000, 50))
    elif stock_id == 3:
        return round(random.normalvariate(4000000, 60))
    else:
        raise ValueError(f"Unexpected stock_id valud: {stock_id}, expected values between 0-3")


def generate_order_quantity():
    return random.randint(100, 200)

locate_codes = []

def generate_locate_codes():
    for _ in range(4):
        locate_codes.append(random.randint(0, 45536))

existing_tracking_numbers = []
tracking_numbers = {}

def generate_tracking_number():
    while True:
        number = random.randint(1, 45536)
        if number not in existing_tracking_numbers:
            existing_tracking_numbers.append(number)
            return number

def convert_to_hex (number, bits):
    if number < 0:
        raise ValueError("Number must be non-negative")

    max_value = (1 << bits) - 1

    if number > max_value:
        raise ValueError(f"Number exceeds the maximum value for {bits}-bit representation")
    
    hex_string = f"{number:0{bits // 4}X}"
    
    return hex_string


def convert_to_int_list(order_list):
    # Output a list of 9 32 bit numbers - one for each register
    # input: [order_type, timestamp, order_id, order_side, order_quantity, stock_id, order_price]
    if len(order_list) != 7:
        raise ValueError(f"Invalid order list length : {len(order_list)}, expected 7 items only")
    
    stock_ids = [4702127773838221344, 4705516477264961568, 5138412867491471392, 5571874491117608992] # AAPL, AMZN, GOOGL, MSFT in that order

    order_type = order_list[0]
    input_time = order_list[1]
    order_id = order_list[2]
    order_side = order_list[3]

    if order_side == 'buy':
        order_side = 0
    elif order_side == 'sell':
        order_side = 1
    else:
        order_side = None

    order_quantity = order_list[4]
    stock_id = order_list[5]
    order_price = order_list[6]

    if order_type == "ADD":
        '''     
        ADD Order Format:
        Bytes:      Bits:       Message:
        1           0-7:        "A" for add order
        2           8-23:       Locate code identifying the security - a random number associated with a specific stock, new every day
        2           24-39:      Internal tracking number
        6           40-87:      Timestamp - nanoseconds since midnight - we will just do seconds since start of trading day
        8           88-151:     Order ID
        1           152-159:    Buy or sell indicator - 0 or 1
        4           160-191:    Number of shares / order quantity
        8           192-255:    Stock ID
        4           255-287:    Price
        '''
        hex_message = convert_to_hex(65, 8)
        hex_locate_code = convert_to_hex((locate_codes[stock_id]), 16)
        hex_tracking_number = convert_to_hex((tracking_numbers[order_id]), 16)
        hex_timestamp = convert_to_hex(input_time, 48)
        hex_order_id = convert_to_hex(order_id, 64)
        hex_buy_or_sell = convert_to_hex(order_side, 8)
        hex_quantity = convert_to_hex(order_quantity, 32)
        hex_stock_id = convert_to_hex(stock_ids[stock_id], 64)
        hex_price = convert_to_hex(order_price, 32)

        output_list = [hex_price, hex_stock_id, hex_quantity, hex_buy_or_sell, hex_order_id, hex_timestamp, hex_tracking_number, hex_locate_code, hex_message]
        # print(output_list)
        joined = ''.join(output_list)
        # print(joined)
        register_length = 8
        order_length = len(joined)
        hex_parts = [joined[i:i+register_length] for i in range(0, order_length, register_length)]
        # print(hex_parts)
        integer_parts = [int(h, 16) for h in hex_parts]
        # print(integer_parts)
        return integer_parts

        
        
    elif order_type == "CANCEL":
        '''
        CANCEL Order Format - It's actually DELETE that we are doing according to documentation
        Bytes:      Bits:       Message:
        1           0-7:        "D" for delete order
        2           8-23:       Locate Code for the Stock
        2           24-39:      Internal tracking number 
        6           40-87:      Timestamp
        8           88-151:     Order ID
        8           152-215:    Stock ID - Not part of documentation, but we need this because of how we implemented the order book cancel function
                    216-287:    0s for 32 bit register allignment
        '''
        hex_message = convert_to_hex(68, 8)
        hex_locate_code = convert_to_hex((locate_codes[stock_id]), 16)
        hex_tracking_number = convert_to_hex((tracking_numbers[order_id]), 16)
        hex_timestamp = convert_to_hex(input_time, 48)
        hex_order_id = convert_to_hex(order_id, 64)
        hex_buy_or_sell = convert_to_hex(0, 8)
        hex_quantity = convert_to_hex(0, 32)
        hex_stock_id = convert_to_hex(stock_ids[stock_id], 64)
        hex_price = convert_to_hex(0, 32)

        output_list = [hex_price, hex_buy_or_sell, hex_quantity, hex_stock_id, hex_order_id, hex_timestamp, hex_tracking_number, hex_locate_code, hex_message]
        # print(output_list)
        joined = ''.join(output_list)
        # print(joined)
        register_length = 8
        order_length = len(joined)
        hex_parts = [joined[i:i+register_length] for i in range(0, order_length, register_length)]
        # print(hex_parts)
        integer_parts = [int(h, 16) for h in hex_parts]
        # print(integer_parts)
        return integer_parts

    elif order_type == "EXECUTE":
        '''
        EXECUTE Order Format - 
        Bytes:      Bits:       Message:
        1           0-7:        "E" for execute order
        2           8-23:       Locate Code for the Stock
        2           24-39:      Internal tracking number 
        6           40-87:      Timestamp
        8           88-151:     Order ID
        4           152-183:    Number of shares
        8           184-247:    Stock ID - Not part of documentation, but we need this because of how we implemented the order book execute function
                    248-287:    0s for 32 bit register allignment
        '''
        hex_message = convert_to_hex(69, 8)
        hex_locate_code = convert_to_hex((locate_codes[stock_id]), 16)
        hex_tracking_number = convert_to_hex((tracking_numbers[order_id]), 16)
        hex_timestamp = convert_to_hex(input_time, 48)
        hex_order_id = convert_to_hex(order_id, 64)
        hex_buy_or_sell = convert_to_hex(0, 8)
        hex_quantity = convert_to_hex(order_quantity, 32)
        hex_stock_id = convert_to_hex(stock_ids[stock_id], 64)
        hex_price = convert_to_hex(0, 32)

        output_list = [hex_price, hex_buy_or_sell, hex_stock_id, hex_quantity, hex_order_id, hex_timestamp, hex_tracking_number, hex_locate_code, hex_message]
        # print(output_list)
        joined = ''.join(output_list)
        # print(joined)
        register_length = 8
        order_length = len(joined)
        hex_parts = [joined[i:i+register_length] for i in range(0, order_length, register_length)]
        # print(hex_parts)
        integer_parts = [int(h, 16) for h in hex_parts]
        # print(integer_parts)
        return integer_parts

    else:
        raise ValueError(f"Inavlid order type: {order_type}, expected add, cancel or execute only")


class Exchange:
    NUM_STOCKS = 4

    def __init__(self):
        self.order_book_0 = {}
        self.order_book_1 = {}
        self.order_book_2 = {}
        self.order_book_3 = {}
        generate_locate_codes()
    

    def generate_ITCH_order(self, stock_id, order_id=None, order_price=None, order_quantity=None, order_side=None, integer_output=True, printing=False):
        if order_id is not None and order_price is not None and order_quantity is not None and order_side is not None:
            # print(f"Arguments received: order_id={order_id}, order_price={order_price}, order_quantity={order_quantity}, order_side={order_side}")
            # The second variant of generate_ITCH_order
            timestamp = generate_timestamp()
            tracking_numbers[order_id] = generate_tracking_number()
            var = "EXECUTE"
            hex_format = convert_to_int_list([var, timestamp, order_id, order_side, order_quantity, stock_id, order_price])
            if(printing):
                print(f"Order From Exchange: {hex_format}")
            return hex_format
        else:
            # The first variant of generate_ITCH_order
            order_type = self.generate_order_type(stock_id)
            if order_type == "ADD":
                timestamp, order_id, order_price, order_quantity, order_side = self.create_add_order(stock_id)
            elif order_type == "CANCEL":
                timestamp, order_id, order_price, order_quantity, order_side = self.create_cancel_order(stock_id)
            elif order_type == "EXECUTE":
                timestamp, order_id, order_price, order_quantity, order_side = self.create_execute_order(stock_id)
            else:
                raise ValueError(f"Invalid order_type: {order_type}. Expected: 'ADD', 'CANCEL' or 'EXECUTE'")
            
            if not integer_output:
                if printing:
                    # print(f"Order from Exchange: {[order_type, timestamp, order_id, order_side, order_quantity, stock_id, order_price]}")
                    return [order_type, timestamp, order_id, order_side, order_quantity, stock_id, order_price]
            else:
                hex_format = convert_to_int_list([order_type, timestamp, order_id, order_side, order_quantity, stock_id, order_price])
                if printing:
                    print(f"Order From Exchange: {hex_format}")
                return hex_format

    def generate_order_type(self, stock_id):
        order_types = ["ADD", "EXECUTE", "CANCEL"]
        if stock_id == 0:
            print(f"LENGTH0: {len(self.order_book_0)}")
            if(len(self.order_book_0) < 10):
                return "ADD"
            else:
                return random.choice(order_types)
        elif stock_id == 1:
            print(f"LENGTH1: {len(self.order_book_1)}")
            if(len(self.order_book_1) < 10):
                return "ADD"
            else:
                return random.choice(order_types)
        elif stock_id == 2:
            print(f"LENGTH2: {len(self.order_book_2)}")
            if(len(self.order_book_2) < 10):
                return "ADD"
            else:
                return random.choice(order_types)
        elif stock_id == 3:
            print(f"LENGTH3: {len(self.order_book_3)}")
            if(len(self.order_book_3) < 10):
                return "ADD"
            else:
                return random.choice(order_types)
        else:
            raise ValueError(f"Unexpected stock_id value: {stock_id}, expected values between 0-3")
        

    def create_add_order(self, stock_id):
        timestamp = generate_timestamp()
        order_id = generate_order_id()
        order_price = generate_order_price(stock_id)
        order_quantity = generate_order_quantity()
        order_side = random.choice(["buy", "sell"])

        if stock_id == 0:
            self.order_book_0[order_id] = {
                'side' : order_side,
                'price' : order_price,
                'quantity' : order_quantity,
                'time' : timestamp
            }
        elif stock_id == 1:
            self.order_book_1[order_id] = {
                'side' : order_side,
                'price' : order_price,
                'quantity' : order_quantity,
                'time' : timestamp
            }
        elif stock_id == 2:
            self.order_book_2[order_id] = {
                'side' : order_side,
                'price' : order_price,
                'quantity' : order_quantity,
                'time' : timestamp
            }
        elif stock_id == 3:
            self.order_book_3[order_id] = {
                'side' : order_side,
                'price' : order_price,
                'quantity' : order_quantity,
                'time' : timestamp
            }
        else:
            raise ValueError(f"Invalid stock id: {stock_id}, expected 0-3")
        
        tracking_numbers[order_id] = generate_tracking_number()
        return timestamp, order_id, order_price, order_quantity, order_side


    def create_cancel_order(self, stock_id):
        timestamp = generate_timestamp()
        order_id = self.pick_random_id(stock_id)
        self.remove_order_from_book(stock_id, order_id)
        order_price = None
        order_quantity = None
        order_side = None
        return timestamp, order_id, order_price, order_quantity, order_side
    

    def create_execute_order(self, stock_id):
        if stock_id == 0:
            order_book = self.order_book_0
        elif stock_id == 1:
            order_book = self.order_book_1
        elif stock_id == 2:
            order_book = self.order_book_2
        elif stock_id == 3:
            order_book = self.order_book_3
        else:
            raise ValueError(f"Unexpected stock_id value: {stock_id}, expected values between 0-3")

        timestamp = generate_timestamp()
        order_price = None
        order_side = None
        order_id = self.select_order_id_closest_to_best_price(stock_id)
        order_quantity = min(generate_order_quantity(), order_book[order_id]['quantity'])
        order_book[order_id]['quantity'] -= order_quantity
        if (order_book[order_id]['quantity'] == 0):
            self.remove_order_from_book(stock_id, order_id)
        
        return timestamp, order_id, order_price, order_quantity, order_side


    def pick_random_id(self, stock_id):
        if stock_id == 0:
            return random.choice(list(self.order_book_0.keys()))
        elif stock_id == 1:
            return random.choice(list(self.order_book_1.keys()))
        elif stock_id == 2:
            return random.choice(list(self.order_book_2.keys()))
        elif stock_id == 3:
            return random.choice(list(self.order_book_3.keys()))
        else:
            raise ValueError(f"Unexpected stock_id valud: {stock_id}, expected values between 0-3")
    

    def remove_order_from_book(self, stock_id, order_id):
        if stock_id == 0:
            self.order_book_0.pop(order_id)
        elif stock_id == 1:
            self.order_book_1.pop(order_id)
        elif stock_id == 2:
            self.order_book_2.pop(order_id)
        elif stock_id == 3:
            self.order_book_3.pop(order_id)
        else:
            raise ValueError(f"Unexpected stock_id valud: {stock_id}, expected values between 0-3")
    

    def get_best_bid_and_sell_prices(self, stock_id):
        if stock_id == 0:
            order_book = self.order_book_0
        elif stock_id == 1:
            order_book = self.order_book_1
        elif stock_id == 2:
            order_book = self.order_book_2
        elif stock_id == 3:
            order_book = self.order_book_3
        else:
            raise ValueError(f"Unexpected stock_id value: {stock_id}, expected values between 0-3")
        
        best_bid = None
        best_sell = None
        
        for order_id, order in order_book.items():
            side = order['side']
            price = order['price']
            if side == 'buy':
                if best_bid is None or price > best_bid:
                    best_bid = price
            elif side == 'sell':
                if best_sell is None or price < best_sell:
                    best_sell = price
       
        return best_bid, best_sell
    

    def select_order_id_closest_to_best_price(self, stock_id):
        best_bid, best_sell = self.get_best_bid_and_sell_prices(stock_id)
        if stock_id == 0:
            order_book = self.order_book_0
        elif stock_id == 1:
            order_book = self.order_book_1
        elif stock_id == 2:
            order_book = self.order_book_2
        elif stock_id == 3:
            order_book = self.order_book_3
        else:
            raise ValueError(f"Unexpected stock_id value: {stock_id}, expected values between 0-3")

        weights = {}
        
        for order_id, order in order_book.items():
            price = order['price']
            side = order['side']
            
            if side == 'buy':
                distance = abs(best_bid - price) if best_bid is not None else float('inf')
            elif side == 'sell':
                distance = abs(best_sell - price) if best_sell is not None else float('inf')
            else:
                continue
            
            weight = 1 / (5 + distance)  # Adding 1 to avoid division by zero
            weights[order_id] = weight
        
        order_ids = list(weights.keys())
        weight_values = list(weights.values())

        if not order_ids or not weight_values:
            raise ValueError("No valid orders found or weights are empty.")
        else:
            selected_order_id = random.choices(order_ids, weights=weight_values, k=1)[0]
            return selected_order_id
            
    

    def insert_into_exchange(self, order_information):
        # Need to know what format the order is going to be received in
        # afaik it order information needs to have the following in a list
        stock_id = order_information[0] 
        timestamp = generate_timestamp()
        order_id = order_information[1] 
        order_price = order_information[3] 
        order_quantity = order_information[2] 
        order_side = order_information[4]
        # print(f"Arguments received: order_id={order_id}, order_price={order_price}, order_quantity={order_quantity}, order_side={order_side}")
        if stock_id == 0:
            self.order_book_0[order_id] = {
                'side' : order_side,
                'price' : order_price,
                'quantity' : order_quantity,
                'time' : timestamp
            }
        elif stock_id == 1:
            self.order_book_1[order_id] = {
                'side' : order_side,
                'price' : order_price,
                'quantity' : order_quantity,
                'time' : timestamp
            }
        elif stock_id == 2:
            self.order_book_2[order_id] = {
                'side' : order_side,
                'price' : order_price,
                'quantity' : order_quantity,
                'time' : timestamp
            }
        elif stock_id == 3:
            self.order_book_3[order_id] = {
                'side' : order_side,
                'price' : order_price,
                'quantity' : order_quantity,
                'time' : timestamp
            }
        else:
            raise ValueError(f"Invalid stock id: {stock_id}, expected 0-3")
        # print("i am in intertechange")
        self.generate_ITCH_order(stock_id=stock_id, order_id=order_information[1], order_price=order_price, order_quantity=order_quantity, order_side=order_side, printing=False)
        # tracking_numbers[order_id] = generate_tracking_number()
        # print("after")
        return timestamp, order_id, order_price, order_quantity, order_side
        # pass