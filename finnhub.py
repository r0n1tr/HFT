import requests
import time
from datetime import datetime, timezone

API_KEY = 'cq97oh1r01qlu7f1t64gcq97oh1r01qlu7f1t650'
symbol = 'BINANCE:BTCUSDT'

while True:
    url = f'https://finnhub.io/api/v1/quote?symbol={symbol}&token={API_KEY}'
    response = requests.get(url)
    data = response.json()
    
    latest_price = data['c']  # Current price
    latest_time = data['t']  # Unix timestamp
    latest_time_formatted = datetime.fromtimestamp(latest_time, tz=timezone.utc).strftime('%H:%M:%S %d-%m-%Y')
    print(f"{symbol} - Time: {latest_time}, Latest Price: {latest_time_formatted}")

    time.sleep(1)
