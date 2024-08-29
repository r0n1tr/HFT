from order_book import OrderBook
import string

def parse(ITCH_data):
        # return a list of the parsed data
        reg_0 = ITCH_data[0]
        reg_1 = ITCH_data[1]
        reg_2 = ITCH_data[2]
        reg_3 = ITCH_data[3]
        reg_4 = ITCH_data[4]
        reg_5 = ITCH_data[5]
        reg_6 = ITCH_data[6]
        reg_7 = ITCH_data[7]
        reg_8 = ITCH_data[8]

        # TODO need to complete

class Model:

    def __init__(self):
        self.ob = OrderBook()
        self.inventory = [0, 0, 0, 0]

    
    def quote_orders(self, ITCH_data):
        # parse the order
        order_book_inputs = parse(ITCH_data)
        # TODO: not complete
        stock_id = order_book_inputs[0]
        order_id = order_book_inputs[0]
        trade_type = order_book_inputs[0]
        quantity = order_book_inputs[0]
        price = order_book_inputs[0]
        order_type = order_book_inputs[0]
        timestamp = order_book_inputs[0]

        # load it into the order book
        if order_type.upper() == "ADD":
            self.ob.add_order(stock_id, order_id, trade_type, quantity, price)
        elif order_type.upper() == "CANCEL":
            self.order_book.cancel_order(stock_id, trade_type, order_id)
        elif order_type.upper() == "EXECUTE":
            self.order_book.execute_order(stock_id, quantity, order_id)

            # in the order book, we need to see what side the execute trade is.
            # inventory stuff - need to pass in order id too to check if the order from the exchange is one of ours that has been executed.
            trade_type = self.ob.execute_order_side
            self.update_inventory(order_id, stock_id, quantity, trade_type)
        else:
             raise ValueError("Invalid order type")

        best_bid = self.order_book.return_best_bid(stock_id)
        best_ask = self.order_book.return_best_ask(stock_id)


        # trading logic stuff
        quote_bid, quote_ask = self.calculate_bid_and_ask_prices(timestamp, best_bid, best_ask)


        # order size 
            

        # output orders
    
    def calculate_bid_and_ask_prices(self, timestamp, best_bid, best_ask):
        # volatility + is full logic
        # zero protection logic
        # spread
        # ref price
        # maths
        return quote_bid, quote_ask

    
    def update_inventory(self, order_id, stock_id, quantity, order_side):
        MAX_INVENTORY_SIZE = 10000
        if(order_id >= 536870912):
            return
        else:
            if order_side.upper() == "BUY":
                multiplier = 1
            elif order_side.upper() == "SELL":
                multiplier = -1
            else:
                # didn't find the order - do nothing to inventory
                multiplier = 0

            self.inventory[stock_id] = self.inventory[stock_id] + (multiplier*quantity)/MAX_INVENTORY_SIZE

    