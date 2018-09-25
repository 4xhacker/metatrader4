//+------------------------------------------------------------------+
//|                                                         mloe.mq4 |
//|                        Copyright 2018,               onsentrade. |
//|                https://www.facebook.com/groups/1798369970423556/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, onsentrade"
#property link      "https://www.facebook.com/groups/1798369970423556/"
#property version   "1.00"
#property strict

#define MAGICMA  1

//--- input parameters
input int      STOCHASTIC_SLOW=21;
input int      STOCHASTIC_FAST=5;
input int      MAX_OPEN_TRADE=1;
input int      TREND_MOVING_AVERAGE=200;
input int      BOLINGER_PERIOD=20;
input int      BOLINGER_DEVIATION=2;
input double   OVERBOUGHT_LEVEL=80;
input double   OVERSOLD_LEVEL=20;
input double   LOT_SIZE=0.1;
input double   LOT_MULTIPLICATOR=1.5;
input double   PROFIT_LOSS_RATIO=0.5;

// Global variables
double RealPoint;
datetime LastCandleOpenTime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   RealPoint=RealPipPoint(Symbol());

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   
   if(IsNewBar())
     {
      Print("===== NEW BAR ======");
      double bolMiddleLine = iBands(Symbol(),0,BOLINGER_PERIOD,2,0,0,MODE_MAIN,1);
      double bolBottomLine = iBands(Symbol(),0,BOLINGER_PERIOD,2,0,0,MODE_LOWER,1);
      double bolUpperLine=iBands(Symbol(),0,BOLINGER_PERIOD,2,0,0,MODE_UPPER,1);

      //Print("Bolinger middle line["+bolMiddleLine+"] bottom line["+bolBottomLine+"] upper line["+bolUpperLine +"]");
      int bolLenghInPip=(bolUpperLine-bolBottomLine)/RealPoint;
      int stopLossSize = bolLenghInPip/4;

      Print("Bolinger length in pips["+bolLenghInPip+"] stop loss distance in pips ["+stopLossSize+"]");

      //--- conditions to go long
      if(IsOverSold() && IsBullTrend() && IsAllowedToTrade())
        {
         Print("GOING LONG");
         double mystoploss=Ask-(bolLenghInPip*RealPoint);
         double mytakeprofit=Ask+(bolLenghInPip*RealPoint*PROFIT_LOSS_RATIO);
         double mystoploss2=Ask-(2*stopLossSize*RealPoint);
         double mystoploss3=Ask-(3*stopLossSize*RealPoint);
         double mystoploss4=Ask-(4*stopLossSize*RealPoint);
         int orderTicket = OrderSend(Symbol(),OP_BUY,LOT_SIZE,Ask,0,mystoploss,mytakeprofit,"",MAGICMA,0,Blue);
         Print("OrderTicket["+orderTicket+"]");
         OrderSend(Symbol(),OP_BUYLIMIT,LOT_SIZE*LOT_MULTIPLICATOR,mystoploss,100,mystoploss2,mytakeprofit,"",MAGICMA,0,Blue);
         OrderSend(Symbol(),OP_BUYLIMIT,LOT_SIZE*2*LOT_MULTIPLICATOR,mystoploss2,100,mystoploss3,mytakeprofit,"",MAGICMA,0,Blue);
         OrderSend(Symbol(),OP_BUYLIMIT,LOT_SIZE*3*LOT_MULTIPLICATOR,mystoploss3,100,mystoploss4,mytakeprofit,"",MAGICMA,0,Blue);
        }

      //--- conditions to go short
      if(IsOverBought() && IsBearTrend() && IsAllowedToTrade())
        {
         Print("GOING SHORT");
         double mystoploss=Bid+(stopLossSize*RealPoint);
         double mytakeprofit=Bid-(bolLenghInPip*RealPoint*PROFIT_LOSS_RATIO);
         double mystoploss2=Bid+(2*stopLossSize*RealPoint);
         double mystoploss3=Bid+(3*stopLossSize*RealPoint);
         double mystoploss4=Bid+(4*stopLossSize*RealPoint);
         int orderTicket = 
OrderSend(Symbol(),OP_SELL,LOT_SIZE,Bid,100,mystoploss,mytakeprofit,"",MAGICMA,0,Blue);
         Print("OrderTicket["+orderTicket+"]");
         OrderSend(Symbol(),OP_SELLLIMIT,LOT_SIZE*LOT_MULTIPLICATOR,mystoploss,100,mystoploss2,mytakeprofit,"",MAGICMA,0,Blue);
         OrderSend(Symbol(),OP_SELLLIMIT,LOT_SIZE*2*LOT_MULTIPLICATOR,mystoploss2,100,mystoploss3,mytakeprofit,"",MAGICMA,0,Blue);
         OrderSend(Symbol(),OP_SELLLIMIT,LOT_SIZE*3*LOT_MULTIPLICATOR,mystoploss3,100,mystoploss4,mytakeprofit,"",MAGICMA,0,Blue);
        }
     }
  }
//+------------------------------------------------------------------+
//| All the rules to see if we are allowed to trade                  |
//| So far we check only for the maximum of trade open               |
//+------------------------------------------------------------------+
bool IsAllowedToTrade()
  {
   if(OrdersTotal()<MAX_OPEN_TRADE)
     {
      Print("IsAllowedToTrade[true]");
      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
// Check if we are on a new bar                                      |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   datetime currentCandleOpenTime=Time[0];
   if(LastCandleOpenTime!=currentCandleOpenTime)
     {
      LastCandleOpenTime=Time[0];
      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
//| Calculate the value of a pip.                                    |
//+------------------------------------------------------------------+
double RealPipPoint(string Currency)
  {
   double CalcPoint=0;
   double CalcDigits=MarketInfo(Currency,MODE_DIGITS);
   if(CalcDigits==2 || CalcDigits==3)
     {
      CalcPoint=0.01;
     }
   else if(CalcDigits==4 || CalcDigits==5)
     {
      CalcPoint=0.0001;
     }
   return(CalcPoint);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsOverBought()
  {
   double stochastictSlow = iStochastic(Symbol(),0,STOCHASTIC_SLOW,3,1,MODE_SMA,0,MODE_MAIN,1);
   double stochastictFast = iStochastic(Symbol(),0,STOCHASTIC_FAST,3,1,MODE_SMA,0,MODE_MAIN,1);

   if(stochastictFast>OVERBOUGHT_LEVEL && stochastictSlow>OVERBOUGHT_LEVEL)
     {
      Print("stochastiSlow["+stochastictSlow+"] stochasticFast["+stochastictFast+"]");
      Print("IsOverBought[true]");
      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsOverSold()
  {
   double stochastictSlow = iStochastic(Symbol(),0,STOCHASTIC_SLOW,3,1,MODE_SMA,0,MODE_MAIN,1);
   double stochastictFast =iStochastic(Symbol(),0,STOCHASTIC_FAST,3,1,MODE_SMA,0,MODE_MAIN,1);

   if(stochastictFast<OVERSOLD_LEVEL && stochastictSlow<OVERSOLD_LEVEL)
     {
      Print("stochastic values stochastiSlow["+stochastictSlow+"] stochasticFast["+stochastictFast+"]");
      Print("IsOverSold[true]");
      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBullTrend()
  {
   double iMA1=iMA(Symbol(),0,STOCHASTIC_FAST,0,MODE_SMMA,PRICE_MEDIAN,1);
   double iMA2=iMA(Symbol(),0,STOCHASTIC_FAST,0,MODE_SMMA,PRICE_MEDIAN,20);
   double slope=iMA1-iMA2;
   if(slope>0)
     {
      Print("Slope["+slope+"]");
      Print("Trend[Bull]");
      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBearTrend()
  {
   double iMA1=iMA(Symbol(),0,STOCHASTIC_FAST,0,MODE_SMMA,PRICE_MEDIAN,1);
   double iMA2=iMA(Symbol(),0,STOCHASTIC_FAST,0,MODE_SMMA,PRICE_MEDIAN,20);
   double slope=iMA1-iMA2;

   if(slope<0)
     {
      Print("Slope["+slope+"]");
      Print("Trend[Bear]");
      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
