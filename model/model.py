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

        # load it into the order book
        if order_type.upper() == "ADD":
            self.ob.add_order(stock_id, order_id, trade_type, quantity, price)
        elif order_type.upper() == "CANCEL":
            self.order_book.cancel_order(stock_id, trade_type, order_id)
        elif order_type.upper() == "EXECUTE":
            self.order_book.execute_order(stock_id, quantity, order_id)
        else:
             raise ValueError("Invalid order type")

        best_bid = self.order_book.return_best_bid(stock_id)
        best_ask = self.order_book.return_best_ask(stock_id)

        # inventory stuff - need to pass in order id too to check if the order from the exchange is one of ours that has been executed.

        # trading logic stuff

        # order size 

        # output orders
    
    def update_inventory(self, order_id, stock_id, quantity):
         
    