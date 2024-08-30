from exchange import Exchange
from market_maker import MarketMakingModel
import random


my_exchange = Exchange()
my_model = MarketMakingModel()

# for _ in range(20):
#     # print(len(my_exchange.generate_ITCH_order(num, hex_output=True, printing=True)))
#     num = random.randint(0,3)
#     (my_exchange.generate_ITCH_order(num, integer_output=True, printing=True))
for _ in range (100):
    num = random.randint(0,3)
    input_vector = my_exchange.generate_ITCH_order(num, printing=False, integer_output=True)
    sell_order, buy_order = my_model.quote_orders(input_vector)
    order_information_buy = buy_order
    order_information_buy.append(1)
    order_information_sell = sell_order
    order_information_sell.append(0)
    my_exchange.insert_into_exchange(order_information_buy)
    my_exchange.insert_into_exchange(order_information_sell)

    print(sell_order)
    print(buy_order)