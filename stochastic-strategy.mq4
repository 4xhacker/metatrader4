//+------------------------------------------------------------------+
//|                                                  fxeabuilder.mq4 |
//|                                                      fxeabuilder |
//|                                       http://www.fxeabuilder.com |
//+------------------------------------------------------------------+

#property copyright "fxeabuilder.com"
#property link "www.fxeabuilder.com"

// External variables
extern double LotSize=0.1;
extern double StopLoss=50;
extern double TakeProfit=0;
extern double TrailingStopLimit= 0;
extern double TrailingStopStop = 0;
extern int MagicNumber=23310;

// Global variables
int LongTicket;
int ShortTicket;
double RealPoint;
// Init function
int init()
  {
   RealPoint=RealPipPoint(Symbol());

  }
// Start function
int start()
  {
//--- LONG
   OrderSelect(LongTicket,SELECT_BY_TICKET);
   if(OrderCloseTime()!=0 || LongTicket==0)
     {

      bool buy_condition_1 = iStochastic(NULL, 0, 14, 3, 1, MODE_SMA, 0, MODE_MAIN, 1)  <  20;
      bool buy_condition_2 = iStochastic(NULL, 0, 14, 3, 1, MODE_SMA, 0, MODE_MAIN, 0)  >  20;



      if(buy_condition_1 && buy_condition_2)
        {

         OrderSelect(ShortTicket,SELECT_BY_TICKET);

         if(OrderCloseTime()==0 && ShortTicket>0)
           {

            bool Closed=OrderClose(ShortTicket,OrderLots(),Ask,0,Red);
           }

         LongTicket=OrderSend(Symbol(),OP_BUY,LotSize,Ask,0,0,0,"Buy Order",MagicNumber,0,Green);

         OrderSelect(LongTicket,SELECT_BY_TICKET);
         double OpenPrice=OrderOpenPrice();

         if(StopLoss>0) double LongStopLoss=OpenPrice -(StopLoss*RealPoint);
         if(TakeProfit>0) double LongTakeProfit=OpenPrice+(TakeProfit*RealPoint);

         if(LongStopLoss>0 || LongTakeProfit>0)
           {
            bool LongMod=OrderModify(LongTicket,OpenPrice,LongStopLoss,LongTakeProfit,0);
           }

         ShortTicket=0;
        }

     }

//Close long
   if(OrdersTotal()>0)
     {

      bool close_buy_condition_1=iStochastic(NULL,0,14,3,1,MODE_SMA,0,MODE_MAIN,0)>80;

      if(close_buy_condition_1)
        {
         OrderSelect(LongTicket,SELECT_BY_TICKET);

         if(OrderCloseTime()==0 && LongTicket>0)
           {

            Closed=OrderClose(LongTicket,OrderLots(),Bid,0,Red);

            LongTicket=0;
           }
        }
     }

// Short

   OrderSelect(ShortTicket,SELECT_BY_TICKET);
   if(OrderCloseTime()!=0 || ShortTicket==0)
     {

      bool sell_condition_1 = iStochastic(NULL, 0, 14, 3, 1, MODE_SMA, 0, MODE_MAIN, 1)  >  80;
      bool sell_condition_2 = iStochastic(NULL, 0, 14, 3, 1, MODE_SMA, 0, MODE_MAIN, 0)  <  80;


      if(sell_condition_1 && sell_condition_2)
        {


         ShortTicket=OrderSend(Symbol(),OP_SELL,LotSize,Bid,0,0,0,"Sell Order",MagicNumber,0,Red);

         OrderSelect(ShortTicket,SELECT_BY_TICKET);
         OpenPrice=OrderOpenPrice();

         if(StopLoss>0) double ShortStopLoss=OpenPrice+(StopLoss*RealPoint);
         if(TakeProfit>0) double ShortTakeProfit=OpenPrice -(TakeProfit*RealPoint);

         if(ShortStopLoss>0 || ShortTakeProfit>0)
           {
            bool ShortMod=OrderModify(ShortTicket,OpenPrice,ShortStopLoss,ShortTakeProfit,0);
           }

         LongTicket=0;
        }

     }

//Close Short
   if(OrdersTotal()>0)
     {

      bool close_sell_condition_1=iStochastic(NULL,0,14,3,1,MODE_SMA,0,MODE_MAIN,0)<20;

      if(close_sell_condition_1)
        {
         OrderSelect(ShortTicket,SELECT_BY_TICKET);

         if(OrderCloseTime()==0 && ShortTicket>0)
           {

            Closed=OrderClose(ShortTicket,OrderLots(),Ask,0,Red);

            ShortTicket=0;
           }
        }
     }

   return(0);
  }
// Pip Point Function
double RealPipPoint(string Currency)
  {
   int CalcDigits= MarketInfo(Currency,MODE_DIGITS);
   if(CalcDigits == 2|| CalcDigits == 3) double CalcPoint = 0.01;
   else if(CalcDigits==4 || CalcDigits==5) CalcPoint=0.0001;
   return(CalcPoint);
  }
//+------------------------------------------------------------------+
