import random
import time
from datetime import datetime

stocks = ['AAPL', 'GOOGL', 'AMZN', 'MSFT']

order_types = ['ADD', 'EXECUTE', 'CANCEL']

order_book = {}

def generate_order_id():
    return f"{random.randint(100000, 999999)}"

def generate_price():
    return round(random.uniform(100, 1500), 2)

def generate_quantity():
    return random.randint(1, 1000)

def generate_timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")

def create_add_order():
    stock = random.choice(stocks)
    order_id = generate_order_id()
    price = generate_price()
    quantity = generate_quantity()
    order_book[order_id] = {
        'stock': stock,
        'price': price,
        'quantity': quantity
    }
    return f"{generate_timestamp()} ADD {order_id} {stock} {price} {quantity}"

def create_execute_order():
    if not order_book:
        return None
    order_id = random.choice(list(order_book.keys()))
    order = order_book[order_id]
    quantity = generate_quantity()
    # Make sure we don't execute more than the remaining quantity
    quantity = min(quantity, order['quantity'])
    order['quantity'] -= quantity
    if order['quantity'] == 0:
        del order_book[order_id]
    return f"{generate_timestamp()} EXECUTE {order_id} {order['stock']} {order['price']} {quantity}"

def create_cancel_order():
    if not order_book:
        return None
    order_id = random.choice(list(order_book.keys()))
    order = order_book.pop(order_id)
    return f"{generate_timestamp()} CANCEL {order_id} {order['stock']}"

def generate_itch_stream(num_messages=1000):
    for _ in range(num_messages):
        order_type = random.choice(order_types)
        if order_type == 'ADD':
            message = create_add_order()
        elif order_type == 'EXECUTE':
            message = create_execute_order()
        elif order_type == 'CANCEL':
            message = create_cancel_order()
        if message:
            print(message)
        time.sleep(random.uniform(0.01, 0.1))

if __name__ == "__main__":
    generate_itch_stream(1000)
