import random
import datetime
import time

order_ids = []

def generate_order_id():
    while True:
        number = random.randint(1, 4294967295)
        if number not in order_ids:
            order_ids.append(number)
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
        return round(random.normalvariate(1000000, 5000))
    elif stock_id == 1:
        return round(random.normalvariate(2000000, 7500))
    elif stock_id == 2:
        return round(random.normalvariate(3000000, 10000))
    elif stock_id == 3:
        return round(random.normalvariate(4000000, 12500))
    else:
        raise ValueError(f"Unexpected stock_id valud: {stock_id}, expected values between 0-3")


def generate_order_quantity():
    return random.randint(100, 200)


class Exchange:
    NUM_STOCKS = 4

    def __init__(self):
        self.order_book_0 = {}
        self.order_book_1 = {}
        self.order_book_2 = {}
        self.order_book_3 = {}
    

    def generate_ITCH_order(self, stock_id):
        order_type = self.generate_order_type(stock_id)
        if order_type == "ADD":
            timestamp, order_id, order_price, order_quantity, order_side = self.create_add_order(stock_id)
        elif order_type == "CANCEL":
            timestamp, order_id, order_price, order_quantity, order_side = self.create_cancel_order(stock_id)
        elif order_type == "EXECUTE":
            timestamp, order_id, order_price, order_quantity, order_side = self.create_execute_order(stock_id)
        else:
            raise ValueError(f"Invalid order_type: {order_type}. Expected: 'ADD', 'CANCEL' or 'EXECUTE'")
       
        print([order_type, timestamp, order_id, order_side, order_quantity, stock_id, order_price])
        return order_type, timestamp, order_id, order_side, order_quantity, stock_id, order_price
    

    # TODO: def insert_order_to_exchange(self, stock_id):


    def generate_order_type(self, stock_id):
        order_types = ["ADD", "EXECUTE", "CANCEL"]
        if stock_id == 0:
            if(len(self.order_book_0) == 0):
                return "ADD"
            else:
                return random.choice(order_types)
        elif stock_id == 1:
            if(len(self.order_book_1) == 0):
                return "ADD"
            else:
                return random.choice(order_types)
        elif stock_id == 2:
            if(len(self.order_book_2) == 0):
                return "ADD"
            else:
                return random.choice(order_types)
        elif stock_id == 3:
            if(len(self.order_book_3) == 0):
                return "ADD"
            else:
                return random.choice(order_types)
        else:
            raise ValueError(f"Unexpected stock_id valud: {stock_id}, expected values between 0-3")
        

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
            
            weight = 1 / (1 + distance)  # Adding 1 to avoid division by zero
            weights[order_id] = weight
        
        order_ids = list(weights.keys())
        weight_values = list(weights.values())
        
        selected_order_id = random.choices(order_ids, weights=weight_values, k=1)[0]
        return selected_order_id