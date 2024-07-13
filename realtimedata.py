import numpy as np
import pandas as pd
import yfinance as yf
import time

while True:
    
    data = yf.download(tickers='BTC-USD', period='1d', interval='1m')
    latest_entry = data.tail(1)
    print(latest_entry)
    time.sleep(1)
