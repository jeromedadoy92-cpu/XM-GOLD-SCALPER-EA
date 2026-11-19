
#include <Trade/Trade.mqh>

CTrade trade;

input double LotSize = 0.01;
input int StopLoss = 300;
input int TakeProfit = 600;
input int FastEMA = 20;
input int SlowEMA = 50;
input int RSIPeriod = 14;

int ema20Handle, ema50Handle, rsiHandle;
datetime lastBar = 0;

int OnInit()
{
   ema20Handle = iMA(_Symbol, PERIOD_M5, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   ema50Handle = iMA(_Symbol, PERIOD_M5, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   rsiHandle = iRSI(_Symbol, PERIOD_M5, RSIPeriod, PRICE_CLOSE);

   if(ema20Handle == INVALID_HANDLE ||
      ema50Handle == INVALID_HANDLE ||
      rsiHandle == INVALID_HANDLE)
      return INIT_FAILED;

   trade.SetExpertMagicNumber(20261119);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(ema20Handle);
   IndicatorRelease(ema50Handle);
   IndicatorRelease(rsiHandle);
}

void OnTick()
{
   datetime currentBar = iTime(_Symbol, PERIOD_M5, 0);

   if(currentBar == lastBar)
      return;

   lastBar = currentBar;

   if(PositionSelect(_Symbol))
      return;

   double fast[], slow[], rsi[];
   MqlRates candles[];

   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(candles, true);

   if(CopyBuffer(ema20Handle, 0, 0, 3, fast) < 3) return;
   if(CopyBuffer(ema50Handle, 0, 0, 3, slow) < 3) return;
   if(CopyBuffer(rsiHandle, 0, 0, 3, rsi) < 3) return;
   if(CopyRates(_Symbol, PERIOD_M5, 0, 3, candles) < 3) return;

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   if(fast[1] > slow[1] && rsi[1] > 55 &&
      candles[1].close > fast[1])
   {
      double sl = NormalizeDouble(
         candles[1].close - StopLoss * point, digits);
      double tp = NormalizeDouble(
         candles[1].close + TakeProfit * point, digits);

      trade.Buy(LotSize, _Symbol, 0.0, sl, tp, "Gold BUY");
   }
   else if(fast[1] < slow[1] && rsi[1] < 45 &&
           candles[1].close < fast[1])
   {
      double sl = NormalizeDouble(
         candles[1].close + StopLoss * point, digits);
      double tp = NormalizeDouble(
         candles[1].close - TakeProfit * point, digits);

      trade.Sell(LotSize, _Symbol, 0.0, sl, tp, "Gold SELL");
   }
}
