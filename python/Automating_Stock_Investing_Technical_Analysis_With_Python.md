# Automating Stock Investing Technical Analysis With Python
source: https://medium.com/fintechexplained/automating-stock-investing-technical-analysis-with-python-81c669e360b2

## RSI Technical Indicator

We are going to analyze RSI now. RSI stands for Relative Strength Index. It’s a widely used technical indicator and this is mainly due to its simplicity. It relies on the market and we can use the indicator to determine when to buy or sell a stock.

RSI requires us to compute the recent gains and losses. The recent specified time period is subjective in nature. We use the RSI indicator to measure the speed and change of price movements.

RSI is an oscillating indicator. It can help us understand the momentum better. Note, momentum is the change of price and size. Therefore, the RSI indicator can help us understand when the stock price will change its trend.

The key to using this indicator is to understand whether a stock is overbought or oversold.
Calculation

The calculation is extremely simple.

    Firstly, we have to determine the time period. Usually, a 14 day time period is chosen but it could depend on the investor’s own view of the market and the stock.
    Secondly, we have to compute the relative strength which is known as RS. RS is the average gain over the average loss. To explain it further, RS is the average gain when the price was moving up over the average loss when the price change was negative.
    Calculate RSI as 100 — (100/(1+RS))

The RSI value is between 0–100

## Strategy:

Overbought: When the RSI is above 70%. Essentially, overbought is when the price of a stock has increased quickly over a small period of time, implying that it is overbought.

The price of an overbought stock usually decreases in price.

Oversold: When the RSI is below 30%. Essentially, oversold is when the price of a stock has decreased quickly over a small period of time, implying that it is oversold. The price of an oversold stock usually increases in price.

There are way too many strategies that are dependent on the RSI indicator.

A simple strategy is to use the RSI such that:

Sell: When RSI increases above 70%

Buy: When RSI decreases below 30%.

We might decide to use different parameters. The point is that we can optimize the parameters that meet our trading style, the market and the stock we are interested in.
RSI Example For TWTR

## Key Points

The signals are not always accurate. The RSI signals are dependent on the price of the stock only and this is not the only factor that can change the price of a stock. Plus it’s highly subjective.

As an instance, a company can launch a product when a stock is oversold and that could further increase the price of the stock.

Therefore, always consider the market factors and also use the short and long term price trend when buying or selling a stock.

## Code

I recently came across a Technical Analysis library named ta

It uses the financial time series datasets (open, close, high, low, volume) and is built on the Python Pandas library.

It provides a large number of technical indicators that are grouped into Momentum Indicators, Volume Indicators, Volatility Indicators, Trend Indicators, and Others Indicators categories.

Further documentation can be found here: https://technical-analysis-library-in-python.readthedocs.io/en/latest/

### Install ```ta```

We are going to use the ta library to compute the technical indicators.
```shell
pip install ta
```
### Create a file and name it: ```technical_indicators_calculator.py``` file

Add the following code:
```python
from ta.momentum import RSIIndicator

import numpy as np
import pandas

class Company:
    def __init__(self, symbol):
        self.symbol = symbol
        self.technical_indicators = None
        self.prices = None


def generate_buy_sell_signals(condition_buy, condition_sell, dataframe, strategy):
    last_signal = None
    indicators = []
    buy = []
    sell = []
    for i in range(0, len(dataframe)):
        # if buy condition is true and last signal was not Buy
        if condition_buy(i, dataframe) and last_signal != 'Buy':
            last_signal = 'Buy'
            indicators.append(last_signal)
            buy.append(dataframe['Close'].iloc[i])
            sell.append(np.nan)
        # if sell condition is true and last signal was Buy
        elif condition_sell(i, dataframe)  and last_signal == 'Buy':
            last_signal = 'Sell'
            indicators.append(last_signal)
            buy.append(np.nan)
            sell.append(dataframe['Close'].iloc[i])
        else:
            indicators.append(last_signal)
            buy.append(np.nan)
            sell.append(np.nan)

    dataframe[f'{strategy}_Last_Signal'] = np.array(last_signal)
    dataframe[f'{strategy}_Indicator'] = np.array(indicators)
    dataframe[f'{strategy}_Buy'] = np.array(buy)
    dataframe[f'{strategy}_Sell'] = np.array(sell)



def set_technical_indicators(config, company):
    company.technical_indicators = pandas.DataFrame()
    company.technical_indicators['Close'] = company.prices

    get_rsi(config, company)


def get_rsi(config, company):
    close_prices = company.prices
    dataframe = company.technical_indicators
    rsi_time_period = 20

    rsi_indicator = RSIIndicator(close_prices, rsi_time_period)
    dataframe['RSI'] = rsi_indicator.rsi()

    low_rsi = 40
    high_rsi = 70

    generate_buy_sell_signals(
        lambda x, dataframe: dataframe['RSI'].values[x] < low_rsi,
        lambda x, dataframe: dataframe['RSI'].values[x] > high_rsi,
    dataframe, 'RSI')

    return dataframe
```
### Create a file and name it: ```technical_indicators_chart_plotting.py```

Add the following code:

```python
import os

from matplotlib import pyplot as plt
import numpy as np


class TechnicalIndicatorsChartPlotter:
    def plot_price_and_signals(self, fig, company, data, strategy, axs):
        last_signal_val = data[f'{strategy}_Last_Signal'].values[-1]
        last_signal = 'Unknown' if not last_signal_val else last_signal_val
        title = f'Close Price Buy/Sell Signals using {strategy}.  Last Signal: {last_signal}'
        fig.suptitle(f'Top: {company.symbol} Stock Price. Bottom: {strategy}')

        if not data[f'{strategy}_Buy'].isnull().all():
            axs[0].scatter(data.index, data[f'{strategy}_Buy'], color='green', label='Buy Signal', marker='^', alpha=1)
        if not data[f'{strategy}_Sell'].isnull().all():
            axs[0].scatter(data.index, data[f'{strategy}_Sell'], color='red', label='Sell Signal', marker='v', alpha=1)
        axs[0].plot(company.prices, label='Close Price', color='blue', alpha=0.35)

        plt.xticks(rotation=45)
        axs[0].set_title(title)
        axs[0].set_xlabel('Date', fontsize=18)
        axs[0].set_ylabel('Close Price', fontsize=18)
        axs[0].legend(loc='upper left')
        axs[0].grid()

    def plot_macd(self, company):
        image = f'images/{company.symbol}_macd.png'
        macd = company.technical_indicators

        # Create and plot the graph
        fig, axs = plt.subplots(2, sharex=True, figsize=(13,9))
        self.plot_price_and_signals(fig, company, macd, 'MACD', axs)

        axs[1].plot(macd['MACD'], label=company.symbol+' MACD', color = 'green')
        axs[1].plot(macd['MACD_Signal'], label='Signal Line', color='orange')        positive = macd['MACD_Histogram'][(macd['MACD_Histogram'] >= 0)]
        negative = macd['MACD_Histogram'][(macd['MACD_Histogram'] < 0)]
        axs[1].bar(positive.index, positive, color='green')
        axs[1].bar(negative.index, negative, color='red')    
        axs[1].legend(loc='upper left')
        axs[1].grid()
        print(os.path.abspath(image))
        plt.show()

    def plot_rsi(self, company):
        image = f'images/{company.symbol}_rsi.png'
        rsi = company.technical_indicators
        low_rsi = 40
        high_rsi = 70

        #plt.style.use('default')
        fig, axs = plt.subplots(2, sharex=True, figsize=(13, 9))
        self.plot_price_and_signals(fig, company, rsi, 'RSI', axs)
        axs[1].fill_between(rsi.index, y1=low_rsi, y2=high_rsi, color='#adccff', alpha=0.3)
        axs[1].plot(rsi['RSI'], label='RSI', color='blue', alpha=0.35)
        axs[1].legend(loc='upper left')
        axs[1].grid()
        plt.show()

    def plot_bollinger_bands(self, company):
        image = f'images/{company.symbol}_bb.png'
        bollinger_bands = company.technical_indicators

        fig, axs = plt.subplots(2, sharex=True, figsize=(13, 9))

        self.plot_price_and_signals(fig, company, bollinger_bands, 'Bollinger_Bands', axs)

        axs[1].plot(bollinger_bands['Bollinger_Bands_Middle'], label='Middle', color='blue', alpha=0.35)
        axs[1].plot(bollinger_bands['Bollinger_Bands_Upper'], label='Upper', color='green', alpha=0.35)
        axs[1].plot(bollinger_bands['Bollinger_Bands_Lower'], label='Lower', color='red', alpha=0.35)
        axs[1].fill_between(bollinger_bands.index, bollinger_bands['Bollinger_Bands_Lower'], bollinger_bands['Bollinger_Bands_Upper'], alpha=0.1)
        axs[1].legend(loc='upper left')
        axs[1].grid()

        plt.show()
```
### Running the code

Create a file and name it: ```test_runner.py```

```python
from unittest import TestCase

from technical_indicators_calculator import set_technical_indicators, Company
from technical_indicators_chart_plotting import TechnicalIndicatorsChartPlotter
import yfinance as yf

class TestTechnicalIndicator(TestCase):

    def test_tech_indicator(self):
        company = Company(’TWTR’)
        config = {}
        company.prices = yf.Ticker(company.symbol).history(period=’1y’)[’Close’]
        set_technical_indicators(config, company)

        tacp = TechnicalIndicatorsChartPlotter()
        tacp.plot_rsi(company)
```

Run the code and it will produce the following results:
![1*Pi2lBCCxbCCdWrhTSoeJSQ](https://user-images.githubusercontent.com/12711066/134187826-9888422b-64ea-43a3-94b1-b67e9fdaec25.png)

