from exchange import Exchange
import random

my_exchange = Exchange()

for _ in range(1000):
    num = random.randint(0,3)
    my_exchange.generate_ITCH_order(num)