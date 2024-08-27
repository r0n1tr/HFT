class OrderBook:
    BUFFER_SIZE = 10
    NUM_STOCKS = 4
    NUM_REGISTERS = 5
    
    #REGISTER_MAP:
    #  [stock_id, order_type, order_quantity, order_price, order_id]
    STOCK_ID_REG = 0
    ORDER_TYPE_REG = 1
    ORDER_QUANTITY_REG = 2
    ORDER_PRICE_REG = 3
    ORDER_ID_REG = 4

    def __init__(self):
        self.buy_orders = [[0] * OrderBook.NUM_REGISTERS * OrderBook.BUFFER_SIZE for _ in range(OrderBook.NUM_STOCKS)]
        self.sell_orders = [[0] * OrderBook.NUM_REGISTERS * OrderBook.BUFFER_SIZE for _ in range(OrderBook.NUM_STOCKS)]
        self.buy_write_addresses = [[0] for _ in range(OrderBook.NUM_STOCKS)]
        self.sell_write_addresses = [[0] for _ in range(OrderBook.NUM_STOCKS)]
        self.buy_cache = [[0] * OrderBook.NUM_REGISTERS for _ in range(OrderBook.NUM_STOCKS)]
        self.sell_cache = [[0] * OrderBook.NUM_REGISTERS for _ in range(OrderBook.NUM_STOCKS)]

    def generate_address(self, stock_id, order_side):
        if order_side == "buy":
            tmp = self.buy_write_addresses[stock_id]
            self.buy_write_addresses[stock_id] += OrderBook.NUM_REGISTERS 
            if self.buy_write_addresses[stock_id] >= OrderBook.BUFFER_SIZE * OrderBook.NUM_REGISTERS:
                self.buy_write_addresses[stock_id] = 0
            return tmp
        elif order_side == "sell":
            tmp = self.sell_write_addresses[stock_id]
            self.sell_write_addresses[stock_id] += OrderBook.NUM_REGISTERS 
            if self.sell_write_addresses[stock_id] >= OrderBook.BUFFER_SIZE * OrderBook.NUM_REGISTERS:
                self.sell_write_addresses[stock_id] = 0
            return tmp
        else:
            raise ValueError(f"Invalid order_side: {order_side}. Expected 'buy' or 'sell'.")

    def add_order(self, stock_id, order_id, order_side, order_quantity, order_price, order_type="add"):
        write_address = self.generate_address(stock_id, order_side)
        order_data = [stock_id, order_type, order_quantity, order_price, order_id]
        if order_side == "buy":
            self.buy_orders[stock_id][write_address:write_address+OrderBook.NUM_REGISTERS] = order_data
            self.update_cache(stock_id, order_id, "buy", order_quantity, order_price, order_type)
        elif order_side == "sell":
            self.sell_orders[stock_id][write_address:write_address+OrderBook.NUM_REGISTERS] = order_data
        else:
            raise ValueError(f"Invalid order_side: {order_side}. Expected 'buy' or 'sell'.")
        
    def execute_order(self, stock_id, order_side, order_quantity, order_id, order_type = "execute"):
        # find the corresponding order id 
        execute_address = 0
        book_side = 0
        found = False
        for i in range(OrderBook.BUFFER_SIZE):
            if (self.buy_orders[stock_id][(i*OrderBook.NUM_REGISTERS) + OrderBook.ORDER_ID_REG] == order_id):
                execute_address = (i*OrderBook.NUM_REGISTERS)
                book_side = 0
                found = True
                break
            elif (self.sell_orders[stock_id][(i*OrderBook.NUM_REGISTERS) + OrderBook.ORDER_ID_REG] == order_id):
                execute_address = (i*OrderBook.NUM_REGISTERS) 
                book_side = 1
                found = True
                break
            else:
                pass
        
        if (not found):
            return
        else:
            if (book_side == 0):
                self.buy_orders[stock_id][execute_address + OrderBook.ORDER_QUANTITY_REG] -= order_quantity
                if (self.buy_orders[stock_id][execute_address + OrderBook.ORDER_QUANTITY_REG] == order_quantity):
                    self.shift_book(stock_id, "buy", execute_address)
            else:
                self.sell_orders[stock_id][execute_address + OrderBook.ORDER_QUANTITY_REG] -= order_quantity
                if (self.sell_orders[stock_id][execute_address + OrderBook.ORDER_QUANTITY_REG] == order_quantity):
                    self.shift_book(stock_id, "sell", execute_address)
            return

    def cancel_order(self, stock_id, order_side, order_id, order_type = "cancel"):


    def shift_book(self, stock_id, order_side, execute_address):
        if (order_side == "buy"):
            if 0 <= execute_address < len(self.buy_orders[stock_id]):
                arr = self.buy_orders[stock_id]
                arr.pop(execute_address + OrderBook.STOCK_ID_REG)
                arr.pop(execute_address + OrderBook.ORDER_TYPE_REG)
                arr.pop(execute_address + OrderBook.ORDER_QUANTITY_REG)
                arr.pop(execute_address + OrderBook.ORDER_PRICE_REG)
                arr.pop(execute_address + OrderBook.ORDER_ID_REG)
                for _ in range(OrderBook.NUM_REGISTERS):
                    arr.append(0)
            else:
                raise ValueError("Execute address out of range for shift book")

        elif(order_side == "sell"):
            if 0 <= execute_address < len(self.sell_orders[stock_id]):
                arr = self.sell_orders[stock_id]
                arr.pop(execute_address + OrderBook.STOCK_ID_REG)
                arr.pop(execute_address + OrderBook.ORDER_TYPE_REG)
                arr.pop(execute_address + OrderBook.ORDER_QUANTITY_REG)
                arr.pop(execute_address + OrderBook.ORDER_PRICE_REG)
                arr.pop(execute_address + OrderBook.ORDER_ID_REG)
                for _ in range(OrderBook.NUM_REGISTERS):
                    arr.append(0)
            else:
                raise ValueError("Execute address out of range for shift book")

        else:
            raise ValueError(f"Invalid order_side: {order_side}. Expected 'buy' or 'sell'.")

    def return_best_ask(self, stock_id):
        return self.buy_cache[stock_id][OrderBook.ORDER_PRICE_REG]

    def return_best_bid(self, stock_id):
        return self.sell_cache[stock_id][OrderBook.ORDER_PRICE_REG]

    def update_cache(self, stock_id, order_id, order_side, order_quantity, order_price, order_type):
        if(order_type == "add"):
            if (order_side == "buy"):
                if (self.buy_cache[OrderBook.ORDER_PRICE_REG] < order_price):
                    order_data = [stock_id, order_type, order_quantity, order_price, order_id]
                    self.buy_cache[stock_id][0:OrderBook.NUM_REGISTERS] = order_data
                else:
                    return
            elif(order_side == "sell"):
                if (self.sell_cache[OrderBook.ORDER_PRICE_REG] > order_price):
                    order_data = [stock_id, order_type, order_quantity, order_price, order_id]
                    self.sell_cache[stock_id][0:OrderBook.NUM_REGISTERS] = order_data
                else:
                    return
            else:
                raise ValueError(f"Invalid order_side: {order_side}. Expected 'buy' or 'sell'.")
        elif(order_type == "cancel"):
            if (order_side == "buy"):
            
            elif(order_side == "sell"):

            else:
                raise ValueError(f"Invalid order_side: {order_side}. Expected 'buy' or 'sell'.")
        else:
            raise ValueError(f"Invalid order_type: {order_type}. Expected 'add', or 'cancel'")

