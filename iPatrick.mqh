//+------------------------------------------------------------------+
//|                                                     iPatrick.mqh |
//|                                                       GPL License|
//|                   I take donation via Paypal at paypal@ethach.com|
//|                    Use at your own risk! Not a holy grail project|
//+------------------------------------------------------------------+
#property copyright "GPL License"

#include "iPatrickSignal.mqh"
#include "iPatrickDraw.mqh"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
 
//+------------------------------------------------------------------+
//| CLASS DECLARATION                                                |
//+------------------------------------------------------------------+
class IPatrick
{
   //--- private members
private:
   int               Magic_No;   //Expert Magic Number
   int               Chk_Margin; //Margin Check before placing trade? (1 or 0)
   int               Ichimoku_handle;   
   int               IPriceAction_handle;   
   int               IATR_handle;
   int               Iband_handle;
         
   int               Ichimoku_val[];      
   
   int               start_from;
   int               number_copy;   
   
   double            LOTS;       //Lots or volume to Trade   
   double            TradePct;   //Percentage of Account Free Margin to trade
            
   double            ichiTenkan[]; 
   double            ichiKijun[];
   double            ichiSenkouA[];
   double            ichiSenkouB[];
   double            ichiChikou[];
   double            ipriceAction[];   
   double            iatr_val[];
   
   double            iband_upper[]; 
   double            iband_middle[];   
   double            iband_lower[];        
                  
   double            close_price; //variable to hold the previous bar closed price 
   double            current_price; //variable to hold the previous bar closed price 
   double            point;
      
   CTrade            my_trade;        
   CPositionInfo     my_position;
      
   MqlTradeRequest   trequest;   //MQL5 trade request structure to be used for sending our trade requests
   MqlTradeResult    tresult;    //MQL5 trade result structure to be used to get our trade results
   MqlRates          mratesLowerRange[]; 
   MqlRates          mratesHigherRange[]; 
   
   string            symbol;     //variable to hold the current symbol name
   ENUM_TIMEFRAMES   period;     //variable to hold the current timeframe value
   
   ICHI_TREND        price_kumo, tenkan_kijun,chikou_price, tenkan_kumo, kijun_kumo, price_tenkan, price_kijun, action_trend, band_trend;
   ICHI_KUMO_TREND   future_kumo;
   
   string            debugMessage[20];   
   
   string            my_export_data;      // export trades to file
      
   
   string            Errormsg;   //variable to hold our error messages
   int               Errcode;    //variable to hold our error codes
      
   //--- Public member/functions
public:
   void              IPatrick();                                  //Class Constructor
   void              setSymbol(string syb){symbol = syb;}         //function to set current symbol
   void              setPeriod(ENUM_TIMEFRAMES prd){period = prd;}//function to set current symbol timeframe/period
   void              setCloseprice(double prc){close_price=prc;}  //function to set prev bar closed price
   void              setCurrentprice(double prc){current_price=prc;}  //function to set prev bar current price  
   void              setchkMAG(int mag){Chk_Margin=mag;}          //function to set Margin Check value
   void              setLOTS(double lot){LOTS=lot;}               //function to set The Lot size to trade
   void              setTRpct(double trpct){TradePct=trpct/100;}  //function to set Percentage of Free margin to use for trading
   void              setMagic(int magic){Magic_No=magic;}         //function to set Expert Magic number
   void              setStartFrom(int start){start_from=start;}   //function to set Expert Magic number
   void              setNumberCopy(int number){number_copy=number;}         //function to set Expert Magic number
   void              setPoint(double pt) {point = pt;}
   void              setExport(string data) { my_export_data = data; }

   void              doInit(int entry_tenkan, int entry_kijun, int entry_senkou);    //function to be used at our EA intialization
   void              doUninit();                                  //function to be used at EA de-initialization

   bool              checkBuy();                                  //function to check for Buy conditions
   bool              checkSell();                                 //function to check for Sell conditions
   bool              checkModify();
   bool              checkClose();
   
   void              openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,
                             double TP,int dev,string comment=""); //function to open Buy positions
   void              openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,
                              double TP,int dev,string comment=""); //function to open Sell positions                              
                              
   void              openModify(double stoploss, double takeprofit);                                                            
   void              openClose();

   //--- Protected members
protected:   
   void              showError(string msg, int ercode);           //function for use to display error messages
   bool              getBuffers();                                //function for getting Indicator buffers
   bool              MarginOK();                                  //function to check if margin required for lots is OK
   bool              CopyBufferAsSeries(int handle, int bufer, int start, int number, bool asSeries, double &M[]);                          
   void              calculateTrend();
   datetime          current_time; 
   double            get_stoploss(const ENUM_POSITION_TYPE order_type, const double current_sl, const double senkoua, const double senkoub);   
   void              exportTrade(double str);
      
   }; // end of class declaration
       
//+------------------------------------------------------------------+
//| Definition of our Class/member functions                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  This CLASS CONSTRUCTOR                                          |
//|  *Does not have any input parameters                             |
//|  *Initilizes all the necessary variables                         |                 
//+------------------------------------------------------------------+
void IPatrick::IPatrick()
  {
   //---initialize all necessary variables
   ZeroMemory(trequest);
   ZeroMemory(tresult);
      
   ZeroMemory(ichiTenkan);
   ZeroMemory(ichiKijun);
   ZeroMemory(ichiSenkouA);
   ZeroMemory(ichiSenkouB);
   ZeroMemory(ichiChikou);   
   
   ZeroMemory(ipriceAction);
   ZeroMemory(iatr_val);
   ZeroMemory(iband_middle);
   ZeroMemory(iband_lower);
   ZeroMemory(iband_upper);
     
   ZeroMemory(mratesLowerRange);
   ZeroMemory(mratesHigherRange);
      
   Errormsg="";
   Errcode=0;
  }
  
//+------------------------------------------------------------------+
//|  SHOWERROR FUNCTION                                              |
//|  *Input Parameters - Error Message, Error Code                   |
//+------------------------------------------------------------------+
void IPatrick::showError(string msg,int ercode)
  {
   Alert(msg,"-error:",ercode,"!!"); // display error
  }
  
//+------------------------------------------------------------------+
//|  GETBUFFERS FUNCTION                                             |                   
//|  *No input parameters                                            |
//|  *Uses the class data members to get indicator's buffers         |
//+------------------------------------------------------------------+

bool IPatrick::getBuffers()
  {
    
   //--- Filling the array Tenkansen with the current values of TENKANSEN_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,0,start_from,number_copy,true,ichiTenkan)) return(false);

   //--- Filling the array Kijunsen with the current values of KIJUNSEN_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,1,start_from,number_copy,true,ichiKijun)) return(false);

   //--- Filling the array SenkouspanA with the current values of SENKOUSPANA_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,2,start_from,number_copy,true,ichiSenkouA)) return(false);

   //--- Filling the array SenkouspanB with the current values of SENKOUSPANB_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,3,start_from,number_copy,true,ichiSenkouB)) return(false);

   //--- Filling the array Chinkouspan with the current values of CHINKOUSPAN_LINE
   if(!CopyBufferAsSeries(Ichimoku_handle,4,start_from,number_copy,true,ichiChikou)) return(false);

   if(!CopyBufferAsSeries(IPriceAction_handle,2,start_from,number_copy,true,ipriceAction)) return(false);
      
   if(!CopyBufferAsSeries(IATR_handle,0,start_from,number_copy,true,iatr_val)) return(false);
   
   //-- Get band --//
   if(!CopyBufferAsSeries(Iband_handle,0,start_from,number_copy,true,iband_middle)) return(false);
   if(!CopyBufferAsSeries(Iband_handle,1,start_from,number_copy,true,iband_upper)) return(false);
   if(!CopyBufferAsSeries(Iband_handle,2,start_from,number_copy,true,iband_lower)) return(false);
   
   if(CopyRates(symbol,period,0,26,mratesLowerRange)<0) return false;   
   if(CopyRates(symbol,period,0,52,mratesHigherRange)<0) return false;   
   
   
   ArraySetAsSeries(mratesLowerRange, false);
   ArraySetAsSeries(mratesHigherRange, false);   
                     
   return true;        
  }
  
//+------------------------------------------------------------------+
//|  CopyBufferAsSeries FUNCTION                                     |                   
//|  *No input parameters                                            |
//|  *Uses the class data members to get indicator's buffers         |
//+------------------------------------------------------------------+    
bool IPatrick::CopyBufferAsSeries(
                        int handle,      // handle
                        int bufer,       // buffer number
                        int start,       // start from
                        int number,      // number of elements to copy
                        bool asSeries,   // is as series
                        double &M[]      // target array for data
                        )
  {  
//--- filling M with current values of the indicator
   if(CopyBuffer(handle,bufer,start,number,M)<=0)return(false);   
   ArraySetAsSeries(M,asSeries);   
   return(true);
  }
        
//+------------------------------------------------------------------+
//| MARGINOK FUNCTION                                                |
//| *No input parameters                                             |
//| *Uses the Class data members to check margin required to place   |
//| a trade with the lot size is ok                                  |
//| *Returns TRUE on success and FALSE on failure                    |
//+------------------------------------------------------------------+
bool IPatrick::MarginOK()
  {
   double one_lot_price;                                                        //Margin required for one lot
   double act_f_mag     = AccountInfoDouble(ACCOUNT_FREEMARGIN);                //Account free margin
   long   levrage       = AccountInfoInteger(ACCOUNT_LEVERAGE);                 //Leverage for this account
   double contract_size = SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);  //Total units for one lot
   string base_currency = SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);        //Base currency for currency pair
                                                                                //
   if(base_currency=="USD")
     {
      one_lot_price=contract_size/levrage;
     }
   else
     {
      double bprice= SymbolInfoDouble(symbol,SYMBOL_BID);
      one_lot_price=bprice*contract_size/levrage;
     }
// Check if margin required is okay based on setting
   if(MathFloor(LOTS*one_lot_price)>MathFloor(act_f_mag*TradePct))
     {
      return(false);
     }
   else
     {
      return(true);
     }
  }
  
//+------------------------------------------------------------------+
//| DOINIT FUNCTION                                                  |
//| *Takes the ADX indicator's Period and Moving Average indicator's |
//| period as input parameters                                       |
//| *To be used in the OnInit() function of our EA                   |                                            
//+------------------------------------------------------------------+
void IPatrick::doInit(int entry_tenkan, int entry_kijun, int entry_senkou)
  {  
  
   Ichimoku_handle = iIchimoku(symbol,period,entry_tenkan,entry_kijun,entry_senkou);
   IPriceAction_handle = iCustom(symbol,period,"iPatrickAction");
   IATR_handle = iATR(NULL,period,24);   
      
   Iband_handle = iBands(symbol,period,20,0,2.0,PRICE_CLOSE);

   //--- what if handle returns Invalid Handle
   if(Ichimoku_handle<0 || IPriceAction_handle < 0)
     {
      Errormsg="Error Creating Handles for indicators";
      Errcode=GetLastError();
      showError(Errormsg,Errcode);
     }          
     
   ArraySetAsSeries(Ichimoku_val,true);         
  }
  
//+------------------------------------------------------------------+
//|  DOUNINIT FUNCTION                                               |
//|  *No input parameters                                            |
//|  *Used to release ADX and MA indicators handles                  |
//+------------------------------------------------------------------+
void IPatrick::doUninit()
  {
   //--- release our indicator handles
   IndicatorRelease(Ichimoku_handle);
   IndicatorRelease(IPriceAction_handle);
   IndicatorRelease(IATR_handle);
   IndicatorRelease(Iband_handle);   
  }
  

void IPatrick::calculateTrend()
{
   price_tenkan = getPriceCurrentTenkan(current_price, ichiTenkan[0]);
   price_kijun = getPriceCurrentKijun(current_price, ichiKijun[0]);      
   price_kumo = getPricecurrentKumoRelationship(close_price, ichiSenkouA[0], ichiSenkouB[0]);

   tenkan_kijun = getTenkanKijunRelationship(ichiTenkan[0], ichiKijun[0]);
   chikou_price = getChikouPreviousPriceRelationship(current_price, mratesLowerRange[0]);
   future_kumo = getFutureKumoTrend(ichiTenkan[0], ichiKijun[0], mratesHigherRange); 
   tenkan_kumo = getTenkanCurrentKumoRelationship(ichiTenkan[0], ichiSenkouA[0], ichiSenkouB[0]);
   kijun_kumo = getKijunCurrentKumoRelationship(ichiKijun[0], ichiSenkouA[0], ichiSenkouB[0]);
   action_trend = get_price_action_trend(ipriceAction);   
                                   
   debugMessage[1]= "price kumo : Trend "+get_trend_string(price_kumo);  //+" : " + DoubleToString(ichiSenkouA[0],6) + " : " + DoubleToString(ichiSenkouB[0],6);
   debugMessage[2]= "tenkan kijun : Trend "+get_trend_string(tenkan_kijun); //+" : " + DoubleToString(ichiTenkan[0],6) + " : " + DoubleToString(ichiKijun[0],6);
   debugMessage[3]= "chikou price : Trend "+get_trend_string(chikou_price);      
   debugMessage[4]= "future kumo : Trend "+get_kumo_trend_string(future_kumo);
   debugMessage[5]= "tenkan kumo : Trend "+get_trend_string(tenkan_kumo); // + " : " + DoubleToString(ichiSenkouA[0],6) + " : " + DoubleToString(ichiSenkouB[0],6);      
   debugMessage[6]= "kijun kumo : Trend "+get_trend_string(kijun_kumo); // + " : " + DoubleToString(ichiSenkouA[0],6) + " : " + DoubleToString(ichiSenkouB[0],6);

   debugMessage[7]= "price tenkan : Trend "+get_trend_string(price_tenkan);     
   debugMessage[8]= "price kijun  : Trend "+get_trend_string(price_kijun);         

   debugMessage[9]= "price action trend  : Trend "+get_trend_string(action_trend);         


   if(current_price >  iband_middle[0])
   {
      band_trend = TREND_BULL;
   } 
   else if(current_price < iband_middle[0])
   {
      band_trend = TREND_BEAR;   
   }
   else {
      band_trend =  TREND_CONSOLIDATE;
   }
           
   debugMessage[10]="bollinger band: Trend " + get_trend_string(band_trend); // + " Upper " + DoubleToString(iband_upper[0]) + " , Middle " + DoubleToString(iband_middle[0]) + ", Close " + DoubleToString(iband_lower[0]);   

   //for(int i = 0; i < 5; i++)
   //{
   //debugMessage[i+13] = "  price action : " + get_price_action((int) ipriceAction[i]);         
   //}         
      
   if(ipriceAction[0] > 0.0 && ipriceAction[0] <= 7.0)
   {
      drawPurchase(get_price_action((int) ipriceAction[0]),current_price, current_time, ORDER_TYPE_SELL);                  
   } else if(ipriceAction[0] > 7.0 && ipriceAction[0] <= 15.0) {
      drawPurchase(get_price_action((int) ipriceAction[0]),current_price, current_time, ORDER_TYPE_BUY);                     
   }
   debug(debugMessage);   
   
}    
    
//+------------------------------------------------------------------+
//| CHECKBUY FUNCTION                                                |
//| *No input parameters                                             |
//| *Uses the class data members to check for Buy setup              |
//| based on the defined trade strategy                              |
//| *Returns TRUE if Buy conditions are met or FALSE if not met      |
//+------------------------------------------------------------------+
bool IPatrick::checkBuy()
  {
  
   getBuffers();
   calculateTrend(); 
                    
   // price > cloud     
   bool Buy_Condition_1 = (price_kumo == TREND_BULL);      
      
   // tenkan > kijun   
   bool Buy_Condition_2 = (tenkan_kijun == TREND_BULL); 
   
   // chikou > price (26 days ago)
   bool Buy_Condition_3 = (chikou_price == TREND_BULL);
   
   // senkou A > senkou B
   bool Buy_Condition_4 = (future_kumo == KUMO_BULL);   
   
   // tenkan > current kumo
   bool Buy_Condition_5 = (tenkan_kumo == TREND_BULL);   
   
   // kijun > current kumo   
   bool Buy_Condition_6 = (kijun_kumo == TREND_BULL);   
   
   // price action
   bool Buy_Condition_7 = true; //( ipriceAction[0] == 10.0 || ipriceAction[0] == 8.0 || ipriceAction[0] == 9.0 || ipriceAction[0] == 11.0 || ipriceAction[0] == 12.0);    
   
   // price tenkan
   bool Buy_Condition_8 = (price_tenkan == TREND_BULL);
   
   // price kijun
   bool Buy_Condition_9 = (price_kijun == TREND_BULL);
   
   // price action trend is bull
   bool Buy_Condition_10 = (action_trend == TREND_BULL || action_trend == TREND_CONSOLIDATE);
   
   // price action > iband_middle
   bool Buy_Condition_11 = (band_trend == TREND_BULL);
   
               
//--- Putting all together   
   if(Buy_Condition_1 && Buy_Condition_2 && Buy_Condition_3 && Buy_Condition_4 && Buy_Condition_5 && Buy_Condition_6  && Buy_Condition_7  
     && Buy_Condition_8 && Buy_Condition_9  && Buy_Condition_10 && Buy_Condition_11)
     {
      current_time = (datetime) SymbolInfoInteger(symbol, SYMBOL_TIME);     
      drawPurchase("Long " + DoubleToString(current_price),current_price, current_time, ORDER_TYPE_BUY);               
      return(true);
     }
   else
     {
      return(false);
     }
  }
    
//+------------------------------------------------------------------+
//| CHECKSELL FUNCTION                                               |
//| *No input parameters                                             |
//| *Uses the class data members to check for Sell setup             |
//|  based on the defined trade strategy                             |
//| *Returns TRUE if Sell conditions are met or FALSE if not met     |
//+------------------------------------------------------------------+
bool IPatrick::checkSell()
  {
   getBuffers();
   calculateTrend(); 
   
   // price < cloud          
   bool Sell_Condition_1 = (price_kumo == TREND_BEAR);
   
   // tenkan < kijun
   bool Sell_Condition_2 = (tenkan_kijun == TREND_BEAR);
   
   // chikou < price (26 days ago)
   bool Sell_Condition_3 = (chikou_price == TREND_BEAR);
   
   // senkou A < senko B
   bool Sell_Condition_4 = (future_kumo == KUMO_BEAR);
   
   // tenkan < current kumo
   bool Sell_Condition_5 = (tenkan_kumo == TREND_BEAR);   
   
   // kijun < current kumo   
   bool Sell_Condition_6 = (kijun_kumo == TREND_BEAR);     
   
   // price action
   bool Sell_Condition_7 = true; //(ipriceAction[0] == 1.0 || ipriceAction[0] == 2.0 || ipriceAction[0] == 3.0 || ipriceAction[0] == 4.0 || ipriceAction[0] == 5.0);    

   bool Sell_Condition_8 = (price_tenkan == TREND_BEAR);
   
   bool Sell_Condition_9 = (price_kijun == TREND_BEAR);   

   bool Sell_Condition_10 = (action_trend == TREND_BEAR || action_trend == TREND_CONSOLIDATE);  
   
   // price action > iband_middle
   bool Sell_Condition_11 = (band_trend == TREND_BEAR);
         
   //--- putting all together
   if(Sell_Condition_1 && Sell_Condition_2 && Sell_Condition_3 && Sell_Condition_4 && Sell_Condition_5 && Sell_Condition_6  && Sell_Condition_7  
                       && Sell_Condition_8  && Sell_Condition_9  && Sell_Condition_10  && Sell_Condition_11)
     {         
      current_time = (datetime) SymbolInfoInteger(symbol, SYMBOL_TIME);          
      drawPurchase("Sell " + DoubleToString(current_price), current_price, current_time, ORDER_TYPE_SELL);
      return(true);
     }
   else
     {
      return(false);
     }
  }

//+------------------------------------------------------------------+
//| CHECKCLOSE FUNCTION                                              |
//+------------------------------------------------------------------+

bool IPatrick::checkModify()
{
   my_position.Select(symbol); 
   ENUM_POSITION_TYPE open_position = my_position.PositionType();      
   double current_stoploss = my_position.StopLoss();  
   double current_takeprofit = my_position.TakeProfit();
         
//   current_stoploss = get_stoploss(open_position, current_stoploss, ichiSenkouA[0], ichiSenkouB[0]);
   
   if(open_position == POSITION_TYPE_BUY)
   {
   
      if(ichiKijun[0] > current_stoploss)
      {
         current_stoploss = ichiKijun[0] + iatr_val[0];         
      }
      current_takeprofit = iband_upper[0]; // + (2 * iatr_val[0]);
   }
   else if(open_position == POSITION_TYPE_SELL)
   {
      if(ichiKijun[0] < current_stoploss)
      {
         current_stoploss = ichiKijun[0] - iatr_val[0];         
      }
      current_takeprofit = iband_lower[0];// - (2 * iatr_val[0]);     
   }
            
   openModify(current_stoploss, current_takeprofit);
         
   return false;                    
}


//+------------------------------------------------------------------+
//| CHECKCLOSE FUNCTION                                               |
//| *No input parameters                                             |
//| *Uses the class data members to check for Sell setup             |
//|  based on the defined trade strategy                             |
//| *Returns TRUE if Sell conditions are met or FALSE if not met     |
//+------------------------------------------------------------------+
bool IPatrick::checkClose()
   {
      
      my_position.Select(symbol); 
      ENUM_POSITION_TYPE open_position = my_position.PositionType();

      bool Close_Condition_1 = false;
      bool Close_Condition_2 = false;
      bool Close_Condition_3 = false;
      bool Close_Condition_4 = false;   
      bool Close_Condition_5 = false;         
            
      if(open_position == POSITION_TYPE_BUY)
      {
         Close_Condition_1 = (current_price < ichiKijun[0]);
//         Close_Condition_2 = (current_price < ichiSenkouA[0]);         
//         Close_Condition_3 = (current_price < ichiSenkouB[0]);                          
         //Close_Condition_4 = (ipriceAction[0] == 3.0);      
 //        Close_Condition_5 = (current_price < iband_middle[0]);
                
      }
      else if(open_position == POSITION_TYPE_SELL)
      {
         Close_Condition_1 = (current_price > ichiKijun[0]);
//         Close_Condition_2 = (current_price > ichiSenkouA[0]);         
//         Close_Condition_3 = (current_price > ichiSenkouB[0]);         
         //Close_Condition_4 = (ipriceAction[0] == 10.0);             
//         Close_Condition_5 = (current_price > iband_middle[0]);         
      }          
                              
      if(Close_Condition_1  || Close_Condition_2 || Close_Condition_3 || Close_Condition_4 || Close_Condition_5)
      {                   
        return true;     
      } 
                      
     // return false     
     return false;           
   }
                 
//+------------------------------------------------------------------+
//| OPENBUY FUNCTION                                                 |
//| *Has Input parameters - order type, Current ASK price,           |
//|  Stop Loss, Take Profit, deviation, comment                      |
//| *Checks account free margin before pacing trade if trader chooses|
//| *Alerts of a success if position is opened or shows error        |
//+------------------------------------------------------------------+
void IPatrick::openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,double TP,int dev,string comment="")
  {
//--- do check Margin if enabled
   if(Chk_Margin==1)
     {
      if(MarginOK()==false)
        {
         Errormsg= "You do not have enough money to open this Position!!!";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
      else
        {
         trequest.action=TRADE_ACTION_DEAL;
         trequest.type=otype;
         trequest.volume=LOTS;
         trequest.price=askprice;
         trequest.sl=SL;
         trequest.tp=TP;
         trequest.deviation=dev;
         trequest.magic=Magic_No;
         trequest.symbol=symbol;
         trequest.type_filling=ORDER_FILLING_FOK;
         //--- send
         OrderSend(trequest,tresult);
         //--- check result
         if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed 
           {
            
            Print("A Buy order has been successfully placed with Ticket#:",tresult.order,"!!");
           }
         else
           {
            Errormsg= "The Buy order request could not be completed";
            Errcode =GetLastError();
            showError(Errormsg,Errcode);
           }
        }
     }
   else
     {
      trequest.action=TRADE_ACTION_DEAL;
      trequest.type=otype;
      trequest.volume=LOTS;
      trequest.price=askprice;
      trequest.sl=SL;
      trequest.tp=TP;
      trequest.deviation=dev;
      trequest.magic=Magic_No;
      trequest.symbol=symbol;
      trequest.type_filling=ORDER_FILLING_FOK;
      //--- send
      OrderSend(trequest,tresult);
      //--- check result
      if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed 
        {
         Print("A Buy order has been successfully placed with Ticket#:",tresult.order,"!!");
        }
      else
        {
         Errormsg= "The Buy order request could not be completed";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
     }
  }
  
//+------------------------------------------------------------------+
//| OPENSELL FUNCTION                                                |
//| *Has Input parameters - order type, Current BID price, Stop Loss,|
//|  Take Profit, deviation, comment                                 |
//| *Checks account free margin before pacing trade if trader chooses|
//| *Alerts of a success if position is opened or shows error        |
//+------------------------------------------------------------------+
void IPatrick::openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,double TP,int dev,string comment="")
  {
//--- do check Margin if enabled
   if(Chk_Margin==1)
     {
      if(MarginOK()==false)
        {
         Errormsg= "You do not have enough money to open this Position!!!";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
      else
        {
         trequest.action=TRADE_ACTION_DEAL;
         trequest.type=otype;
         trequest.volume=LOTS;
         trequest.price=bidprice;
         trequest.sl=SL;
         trequest.tp=TP;
         trequest.deviation=dev;
         trequest.magic=Magic_No;
         trequest.symbol=symbol;
         trequest.type_filling=ORDER_FILLING_FOK;
         //--- send
         OrderSend(trequest,tresult);
         //--- check result
         if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed 
           {
            Print("A Sell order has been successfully placed with Ticket#:",tresult.order,"!!");
           }
         else
           {
            Errormsg= "The Sell order request could not be completed";
            Errcode =GetLastError();
            showError(Errormsg,Errcode);
           }
        }
     }
   else
     {
      trequest.action=TRADE_ACTION_DEAL;
      trequest.type=otype;
      trequest.volume=LOTS;
      trequest.price=bidprice;
      trequest.sl=SL;
      trequest.tp=TP;
      trequest.deviation=dev;
      trequest.magic=Magic_No;
      trequest.symbol=symbol;
      trequest.type_filling=ORDER_FILLING_FOK;
      //--- send
      OrderSend(trequest,tresult);
      //--- check result
      if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed 
        {
         Print("A Sell order has been successfully placed with Ticket#:",tresult.order,"!!");
        }
      else
        {
         Errormsg= "The Sell order request could not be completed";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
     }
  }


//+------------------------------------------------------------------+
//| MODIFYPOSITION FUNCTION                                           |
//+------------------------------------------------------------------+      
void IPatrick::openModify(double stoploss, double takeprofit)
{
   if (my_position.Select(symbol))
   {
    //close the open position for this symbol
    my_trade.PositionModify(symbol, stoploss, takeprofit);  
    
   }   
}

//+------------------------------------------------------------------+
//| CLOSEPOSITION FUNCTION                                           |
//+------------------------------------------------------------------+      
void IPatrick::openClose()
{
   if (my_position.Select(symbol))
   {
    //close the open position for this symbol
    my_trade.PositionClose(symbol);  
   }   
}

void IPatrick::exportTrade(double str)
{
   int file_handle=FileOpen("exports.csv",FILE_READ|FILE_WRITE|FILE_CSV);
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is available for writing",my_export_data);
      //--- first, write the number of signals
      FileWrite(file_handle,str);
      //--- close the file
      FileClose(file_handle);
      PrintFormat("Data is written, %s file is closed",my_export_data);
     }
   else {
      PrintFormat("Failed to open %s file, Error code = %d",my_export_data,GetLastError());
  }
}

double IPatrick::get_stoploss(const ENUM_POSITION_TYPE order_type, const double current_sl, const double senkoua, const double senkoub)
{
      
   double stopL = senkoub;   
   if(order_type == POSITION_TYPE_BUY)
      if (senkoub > senkoua)
      {
         stopL = senkoua;
      }                  
               
   else if(order_type == POSITION_TYPE_SELL)
   {
      if (senkoua > senkoub)
      {
         stopL = senkoua;
      }
      else
      {
         stopL = senkoub;     
      }                 
   }         
            
   // What is the stop loss level?
   return stopL;   
} // end function 