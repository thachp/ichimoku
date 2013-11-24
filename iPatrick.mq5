//+------------------------------------------------------------------+
//|                                                     iPatrick.mq5 |
//|                                                       GPL License|
//|                   I take donation via Paypal at paypal@ethach.com|
//|                    Use at your own risk! Not a holy grail project|
//+------------------------------------------------------------------+
#property copyright "GPL License"
#property version   "1.00"

#include "iPatrick.mqh"

//--- input parameters
input int      StopLoss=3500;
input int      TakeProfit=400;
input int      Entry_Tenkan=9;
input int      Entry_Kijun=26;
input int      Entry_Senkou=52;
input int      EA_Magic=4564894;   // EA Magic Number

input double   Lot= 1.0;          // Lots to Trade
input int      Margin_Chk=0;     // Check Margin before placing trade(0=No, 1=Yes)
input double   Trd_percent=15.0; // Percentage of Free Margin To use for Trading

int STP,TKP;   // To be used for Stop Loss & Take Profit values
IPatrick Cexpert;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- run Initialize function
   Cexpert.doInit(Entry_Tenkan, Entry_Kijun, Entry_Senkou);
   
//--- set all other necessary variables for our class object
   Cexpert.setPeriod(_Period);    // sets the chart period/timeframe
   Cexpert.setSymbol(_Symbol);    // sets the chart symbol/currency-pair   
   Cexpert.setPoint(_Point);
   Cexpert.setMagic(EA_Magic);    // sets the Magic Number
   Cexpert.setLOTS(Lot);          // set the Lots value
   Cexpert.setchkMAG(Margin_Chk); // set the margin check variable
   Cexpert.setTRpct(Trd_percent); // set the percentage of Free Margin for trade
   Cexpert.setStartFrom(0);
   Cexpert.setNumberCopy(Entry_Kijun);
   Cexpert.setExport("data.csv");
   
//--- let us handle brokers that offers 5 digit prices instead of 4
   STP = StopLoss;
   TKP = TakeProfit;
   
   if(_Digits==5)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
//---
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Run UnIntilialize function
   Cexpert.doUninit();   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
     ChartRedraw();   
//--- do we have enough bars to work with
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<60) // if total bars is less than 60 bars
     {
      Alert("We have less than 60 bars, EA will now exit!!");
      return;
     }

//--- define some MQL5 Structures we will use for our trade
   MqlTick latest_price;      // To be used for getting recent/latest price quotes
   MqlRates mrate[];          // To be used to store the prices, volumes and spread of each bar
/*
     Let's make sure our arrays values for the Rates
     is store serially similar to the timeseries array
*/
//--- the rates arrays
   ArraySetAsSeries(mrate,true);

//--- Get the last price quote using the MQL5 MqlTick Structure
   if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
     }

//--- get the details of the latest 3 bars
   if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
     {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      return;
     }

//--- EA should only check for new trade if we have a new bar
//--- lets declare a static datetime variable
   static datetime Prev_time;
//--- lets declare a datetmie variable to hold the start time for the current bar (Bar 0)
   datetime Bar_time[1];

//--- copy the start time of the new bar to the variable
   Bar_time[0]=mrate[0].time;
//--- we don't have a new bar when both times are the same
   if(Prev_time==Bar_time[0])
     {
      return;
     }
//--- copy time to static value, save
   Prev_time=Bar_time[0];

//--- we have no errors, so continue
//--- do we have positions opened already?
   bool Buy_opened=false, Sell_opened=false; // variables to hold the result of the opened position

   if(PositionSelect(_Symbol)==true) // we have an opened position
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  //It is a Buy
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; // It is a Sell
        }
     }
     
   Cexpert.setCloseprice(mrate[1].close);  // bar 1 close price   
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);            
   Cexpert.setCurrentprice(current_price);

   // check buy
   checkBuy(Buy_opened, latest_price);
   checkSell(Sell_opened, latest_price);
//   Cexpert.checkModify();
   checkClose();      
   return;
  }

//+------------------------------------------------------------------+
//| CHECKBUY FUNCTION                                                |
//| *Returns TRUE if Buy conditions are met or FALSE if not met      |
//+------------------------------------------------------------------+

void checkBuy(bool Buy_opened, MqlTick & latest_price)
{
//--- check for Buy position
   if(Cexpert.checkBuy()==true)
     {
      //--- do we already have an opened buy position      
      if(Buy_opened)
        {
//         Alert("We already have a Buy Position!!!");
         return;    // Don't open a new Buy Position
        }
      double aprice = NormalizeDouble(latest_price.ask,_Digits);              // current Ask price
      double stl    = NormalizeDouble(latest_price.ask - STP*_Point,_Digits); // Stop Loss
      double tkp    = NormalizeDouble(latest_price.ask + TKP*_Point,_Digits); // Take profit
      int    mdev   = 100;                                                    // Maximum deviation
                                                                                    // place order
      Cexpert.openBuy(ORDER_TYPE_BUY,aprice,stl,tkp,mdev);
     }
}

//+------------------------------------------------------------------+
//| CHECKSELL FUNCTION                                                |
//| *Returns TRUE if Sell conditions are met or FALSE if not met      |
//+------------------------------------------------------------------+

void checkSell(bool Sell_opened, MqlTick &latest_price)
{
//--- check for any Sell position
   if(Cexpert.checkSell()==true)
     {
      //--- do we already have an opened Sell position
      if(Sell_opened)
        {
//         Alert("We already have a Sell position!!!");
         return;    // Don't open a new Sell Position
        }
      double bprice=NormalizeDouble(latest_price.bid,_Digits);                 // Current Bid price
      double bstl    = NormalizeDouble(latest_price.bid + STP*_Point,_Digits); // Stop Loss
      double btkp    = NormalizeDouble(latest_price.bid - TKP*_Point,_Digits); // Take Profit
      int    bdev=100;                                                         // Maximum deviation
                                                                               // place order
      Cexpert.openSell(ORDER_TYPE_SELL,bprice,bstl,btkp,bdev);
     }
}

//+------------------------------------------------------------------+
//| CHECKCLOSE FUNCTION                                                |
//| *Returns TRUE if Sell conditions are met or FALSE if not met      |
//+------------------------------------------------------------------+
void checkClose()
{
   if(Cexpert.checkClose()==true)
   {
      Cexpert.openClose();
   }
}

/*
* Check ad optimized trading lots.
* @param max_risk Maximum Risk in percentage
* @param decrease_factor Descrease factor
* @return What is the optimized trade lots?
*/
double TradeSizeOptimized(const double max_risk, const double decrease_factor)
  {
   double price=0.0;
   double margin=0.0;
//--- select lot size
   if(!SymbolInfoDouble(_Symbol,SYMBOL_ASK,price))               return(0.0);
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,1.0,price,margin)) return(0.0);
   if(margin<=0.0)                                               return(0.0);

   double lot=NormalizeDouble(AccountInfoDouble(ACCOUNT_FREEMARGIN)*max_risk/margin,2);
//--- calculate number of losses orders without a break
   if(decrease_factor>0)
     {
      //--- select history for access
      HistorySelect(0,TimeCurrent());
      //---
      int    orders=HistoryDealsTotal();  // total history deals
      int    losses=0;                    // number of losses orders without a break

      for(int i=orders-1;i>=0;i--)
        {
         ulong ticket=HistoryDealGetTicket(i);
         if(ticket==0)
           {
            Print("HistoryDealGetTicket failed, no trade history");
            break;
           }
         //--- check symbol
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;
         //--- check profit
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         if(profit>0.0) break;
         if(profit<0.0) losses++;
        }
      //---
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/decrease_factor,1);
     }
//--- normalize and check limits
   double stepvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   lot=stepvol*NormalizeDouble(lot/stepvol,0);

   double minvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   if(lot<minvol) lot=minvol;

   double maxvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   if(lot>maxvol) lot=maxvol;
//--- return trading volume
   return(lot);
  }  // end function