from exchange import Exchange
import random

my_exchange = Exchange()

for _ in range(1):
    num = random.randint(0,3)
    # print(len(my_exchange.generate_ITCH_order(num, hex_output=True, printing=True)))
    for _ in range(20):
        (my_exchange.generate_ITCH_order(num, integer_output=True, printing=True))