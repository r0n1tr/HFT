import random
import time
import struct
import argparse
import datetime

# Define stock symbols
stocks = ['AAPL', 'GOOGL', 'AMZN', 'MSFT']

# Define order types
order_types = ['ADD', 'EXECUTE', 'CANCEL']

# Define buy/sell indicators
buy_sell_indicators = ['B', 'S']

# Order book to keep track of orders
order_book = {}

# Function to generate a unique order id
def generate_order_id():
    return random.randint(1, 4294967295)

# Function to generate a random price
def generate_price():
    return round(random.uniform(100, 1500), 2)

# Function to generate a random quantity
def generate_quantity():
    return random.randint(1, 1000)

# Function to generate a timestamp in microseconds since epoch - want to conver this to time in seconds of current day
def generate_timestamp():
    current_time = time.time()
    now = datetime.datetime.now()

    # start of trading day
    nine_thirty_am = datetime.datetime(now.year, now.month, now.day, 9, 30)
    nine_thirty_am_timestamp = time.mktime(nine_thirty_am.timetuple())

    # Calculate the seconds since 9:30 AM today
    seconds_since_nine_thirty = current_time - nine_thirty_am_timestamp

    return round(seconds_since_nine_thirty)
# Function to convert string to fixed-length bytes, padded with spaces
def str_to_fixed_bytes(s, length):
    return s.ljust(length).encode('ascii')

# Function to create an ADD order
def create_add_order(print_structure=False):
    timestamp = generate_timestamp()
    stock = random.choice(stocks)
    order_id = generate_order_id()
    price = generate_price()
    quantity = generate_quantity()
    side = random.choice(buy_sell_indicators)
    order_book[order_id] = {
        'stock': stock,
        'price': price,
        'quantity': quantity,
        'side': side
    }
    
    # Construct the message
    message_type = b'A'  # 1 byte
    timestamp_bytes = struct.pack('>I', timestamp)  # 4 bytes
    order_id_bytes = struct.pack('>I', order_id)  # 4 bytes
    side_byte = b'\x01' if side == 'B' else b'\x00'  # 1 byte
    quantity_bytes = struct.pack('>I', quantity)  # 4 bytes
    stock_bytes = str_to_fixed_bytes(stock, 8)  # 8 bytes
    price_bytes = struct.pack('>I', int(price * 10000))  # 4 bytes
    
    message = (
        message_type +
        timestamp_bytes +
        order_id_bytes +
        side_byte +
        quantity_bytes +
        stock_bytes +
        price_bytes
    )
    
    hex_message = format_hex_message(message.hex(), 56)
    
    if print_structure:
        # Print the order structure and message
        print(f"ADD Order:")
        print(f"  Order Type: ADD (1 byte)")
        print(f"  Timestamp: {timestamp} ({timestamp_bytes.hex()})")
        print(f"  Order ID: {order_id} ({order_id_bytes.hex()})")
        print(f"  Side: {side} ({side_byte.hex()})")
        print(f"  Quantity: {quantity} ({quantity_bytes.hex()})")
        print(f"  Stock Symbol: {stock} ({stock_bytes.decode().strip()})")
        print(f"  Price: {price} ({price_bytes.hex()})")
        print(f"  Hex Message: {hex_message}")
    else:
        print(hex_message)
    
    return hex_message

# Function to create an EXECUTE order
def create_execute_order(print_structure=False):
    if not order_book:
        return None
    timestamp = generate_timestamp()
    order_id = random.choice(list(order_book.keys()))
    order = order_book[order_id]
    quantity = generate_quantity()
    # Make sure we don't execute more than the remaining quantity
    quantity = min(quantity, order['quantity'])
    order['quantity'] -= quantity
    if order['quantity'] == 0:
        del order_book[order_id]
    
    # Construct the message
    message_type = b'E'  # 1 byte
    timestamp_bytes = struct.pack('>I', timestamp)  # 4 bytes
    order_id_bytes = struct.pack('>I', order_id)  # 4 bytes
    quantity_bytes = struct.pack('>I', quantity)  # 4 bytes
    
    message = (
        message_type +
        timestamp_bytes +
        order_id_bytes +
        quantity_bytes
    )
    
    hex_message = format_hex_message(message.hex(), 56)
    
    if print_structure:
        # Print the order structure and message
        print(f"EXECUTE Order:")
        print(f"  Order Type: EXECUTE (1 byte)")
        print(f"  Timestamp: {timestamp} ({timestamp_bytes.hex()})")
        print(f"  Order ID: {order_id} ({order_id_bytes.hex()})")
        print(f"  Quantity: {quantity} ({quantity_bytes.hex()})")
        print(f"  Hex Message: {hex_message}")
    else:
        print(hex_message)
    
    return hex_message

# Function to create a CANCEL order
def create_cancel_order(print_structure=False):
    if not order_book:
        return None
    timestamp = generate_timestamp()
    order_id = random.choice(list(order_book.keys()))
    order = order_book.pop(order_id)
    
    # Construct the message
    message_type = b'X'  # 1 byte
    timestamp_bytes = struct.pack('>I', timestamp)  # 4 bytes
    order_id_bytes = struct.pack('>I', order_id)  # 4 bytes
    
    message = (
        message_type +
        timestamp_bytes +
        order_id_bytes
    )
    
    hex_message = format_hex_message(message.hex(), 56)
    
    if print_structure:
        # Print the order structure and message
        print(f"CANCEL Order:")
        print(f"  Order Type: CANCEL (1 byte)")
        print(f"  Timestamp: {timestamp} ({timestamp_bytes.hex()})")
        print(f"  Order ID: {order_id} ({order_id_bytes.hex()})")
        print(f"  Hex Message: {hex_message}")
    else:
        print(hex_message)
    
    return hex_message

# Function to convert byte data to a formatted hex string with groups of 8
def format_hex_message(hex_message, length):
    # Pad the hex_message with zeroes to ensure it's the desired length
    padded_length = length
    padded_hex_message = hex_message.ljust(padded_length, '0')

    # Format the padded hex_message in groups of 8 characters
    return ' '.join(padded_hex_message[i:i+8] for i in range(0, len(padded_hex_message), 8))

# Function to generate a stream of ITCH messages
def generate_itch_stream(num_messages=100, print_structure=False):
    for _ in range(num_messages):
        order_type = random.choice(order_types)
        if order_type == 'ADD':
            create_add_order(print_structure)
        elif order_type == 'EXECUTE':
            create_execute_order(print_structure)
        elif order_type == 'CANCEL':
            create_cancel_order(print_structure)
        # Sleep to simulate time delay between messages
        time.sleep(random.uniform(0.01, 0.1))

# Main function to parse arguments and generate ITCH messages
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate ITCH messages.")
    parser.add_argument('--print_structure', action='store_true', help="Print the structure of the orders.")
    args = parser.parse_args()
    
    generate_itch_stream(100, args.print_structure)
