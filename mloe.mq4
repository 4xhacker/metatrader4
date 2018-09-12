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
input int      TAKE_PROFIT=40;
input int      STOP_LOSS=40;
input int      STOCHASTIC_SLOW=21;
input int      STOCHASTIC_FAST=5;
input int      MAX_OPEN_TRADE=1;
input int      TREND_MOVING_AVERAGE=200;
input double   OVERBOUGHT_LEVEL=80;
input double   OVERSOLD_LEVEL=20;
input double   LOT_SIZE=0.01;

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
      double stochastictSlow = iStochastic(Symbol(),0,STOCHASTIC_SLOW,3,1,MODE_SMA,0,MODE_MAIN,1);
      double stochastictFast =iStochastic(Symbol(),0,STOCHASTIC_FAST,3,1,MODE_SMA,0,MODE_MAIN,1);
      double iMA1 = iMA(Symbol(),0,STOCHASTIC_FAST,0,MODE_SMMA,PRICE_MEDIAN,1);
      double iMA2 = iMA(Symbol(),0,STOCHASTIC_FAST,0,MODE_SMMA,PRICE_MEDIAN,2);
      double slope= iMA1-iMA2;

      if((stochastictFast>OVERBOUGHT_LEVEL && stochastictSlow>OVERBOUGHT_LEVEL) && slope>0 && IsAllowedToTrade())
        {
         double mystoploss=Bid+(STOP_LOSS*RealPoint);
         double mytakeprofit=Bid-(TAKE_PROFIT*RealPoint);
         Print("stochastictFast["+stochastictFast+"] stochastictSlow["+stochastictSlow+"] Slope["+slope+"]");
         OrderSend(Symbol(),OP_SELL,LOT_SIZE,Bid,0,mystoploss,mytakeprofit,"",MAGICMA,0,Blue);
        }

      if((stochastictFast<OVERSOLD_LEVEL && stochastictSlow<OVERSOLD_LEVEL) && slope>0 && IsAllowedToTrade())
        {
         double mystoploss=Ask-(STOP_LOSS*RealPoint);
         double mytakeprofit=Ask+(TAKE_PROFIT*RealPoint);
         Print("stochastictFast["+stochastictFast+"] stochastictSlow["+stochastictSlow+"] Slope["+slope+"]");
         OrderSend(Symbol(),OP_BUY,LOT_SIZE,Ask,0,mystoploss,mytakeprofit,"",MAGICMA,0,Blue);
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
