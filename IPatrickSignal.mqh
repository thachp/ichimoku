//+------------------------------------------------------------------+
//|                                               iPatrickSignal.mq5 |
//|                                                       GPL License|
//|                            Use at your own risk! Not a holy grail|
//+------------------------------------------------------------------+
#property copyright "GPL License"

enum ICHI_TREND {TREND_BULL, TREND_BEAR, TREND_CONSOLIDATE};
enum ICHI_KUMO_TREND {KUMO_BULL, KUMO_BEAR, KUMO_CONSOLIDATE};


/**
* Get Price vs Tenkan relationship.
* @param price - current price.
* @param tenkan - current tenkan.
* @return trend enumeration.
*/

ICHI_TREND getPriceCurrentTenkan(const double price, const double tenkan)
{   
   ICHI_TREND pricetenkan_trend = TREND_BULL;
   
   if (price > tenkan) {
      pricetenkan_trend = TREND_BULL;    
   }
   else if (price < tenkan){
      pricetenkan_trend = TREND_BEAR;
   }
   else if (price == tenkan) {
      pricetenkan_trend = TREND_CONSOLIDATE;
   }                
   return pricetenkan_trend;         
}

/**
* Get Price vs Kijun relationship.
* @param price - current price.
* @param kijun - current kijun.
* @return trend enumeration.
*/
ICHI_TREND getPriceCurrentKijun(const double price, const double kijun)
{
   
   ICHI_TREND pricekijun_trend = TREND_BULL;
   
   if (price > kijun) {
      pricekijun_trend = TREND_BULL;    
   }
   else if (price < kijun){
      pricekijun_trend = TREND_BEAR;
   }
   else if (price == kijun) {
      pricekijun_trend = TREND_CONSOLIDATE;
   }   
   return pricekijun_trend;         
}
 
/*
* Get Tenkan vs Kumo relationship.
* @param tenkan - current tenkan line.
* @param senkoua - current senkou A.
* @param senkoub - current senkou b.
* @return trend enumeration.
*/

ICHI_TREND getTenkanCurrentKumoRelationship(const double tenkan, const double senkoua, const double senkoub)
{
   ICHI_TREND tenkan_trend = TREND_BULL;
   
   if (tenkan > senkoua && tenkan > senkoub)
   {
      tenkan_trend = TREND_BULL;
   }
   else if (tenkan < senkoua && tenkan < senkoub)
   {
      tenkan_trend = TREND_BEAR;
   }
   else if (tenkan > senkoua && tenkan < senkoub)
   {
      tenkan_trend = TREND_CONSOLIDATE;
   }
   else if (tenkan > senkoub && tenkan < senkoua)
   {
      tenkan_trend = TREND_CONSOLIDATE;
   }   
   
   return tenkan_trend;
}

/*
* Get Kijun vs Kumo relationship.
* @param kijun - current kijun line.
* @param senkoua - current senkou A.
* @param senkoub - current senkou b.
* @return trend enumeration.
*/

ICHI_TREND getKijunCurrentKumoRelationship(const double kijun, const double senkoua, const double senkoub)
{
   ICHI_TREND kijun_trend = TREND_BULL;
   
   if (kijun > senkoua && kijun > senkoub)
   {
      kijun_trend = TREND_BULL;
   }
   else if (kijun < senkoua && kijun < senkoub)
   {
      kijun_trend = TREND_BEAR;
   }
   else if (kijun > senkoua && kijun < senkoub)
   {
      kijun_trend = TREND_CONSOLIDATE;
   }
   else if (kijun > senkoub && kijun < senkoua)
   {
      kijun_trend = TREND_CONSOLIDATE;
   }   
     
   return kijun_trend;
}

/*
* Get Price vs Kumo relationship.
* @param price - current kijun line.
* @param senkoua - current senkou A.
* @param senkoub - current senkou b.
* @return trend enumeration.
*/

ICHI_TREND getPricecurrentKumoRelationship(const double price, const double senkoua, const double senkoub)
{
   ICHI_TREND price_trend = TREND_BULL;
      
   if (price > senkoua && price > senkoub)
   {
      price_trend = TREND_BULL;
   }
   else if (price < senkoua && price < senkoub)
   {
      price_trend = TREND_BEAR;
   }
   else if (price > senkoua && price < senkoub)
   {
      price_trend = TREND_CONSOLIDATE;
   }
   else if (price > senkoub && price < senkoua)
   {
      price_trend = TREND_CONSOLIDATE;
   }      
   return price_trend;
}

/*
* Get Tenkan vs Kijun relationship.
* @param tekan - current tekan line.
* @param kijun - current kijun line.
* @return trend enumeration.
*/

ICHI_TREND getTenkanKijunRelationship(const double tenkan, const double kijun)
{   
   ICHI_TREND tenkankijun_trend = TREND_BULL;
   
   if (tenkan > kijun) {
      tenkankijun_trend = TREND_BULL;    
   }
   else if (tenkan < kijun){
      tenkankijun_trend = TREND_BEAR;
   }
   else if (tenkan == kijun) {
      tenkankijun_trend = TREND_CONSOLIDATE;
   }   
   return tenkankijun_trend;   
}

/*
* Get chikou and price at 26 period relationship.
* @param chikou - current chikou line.
* @param price - current price line.
* @return trend enumeration.
*/

ICHI_TREND getChikouPreviousPriceRelationship(const double chikou, const MqlRates &price)
{

//   string test = "Time " + TimeToString(price.time) + " Chikou: " + DoubleToString(chikou,6) + " High: " + DoubleToString(price.high,6) + " Open: " + DoubleToString(price.low,6) + " Close: " + DoubleToString(price.close,6) + " Low: " + DoubleToString(price.low,6);
//   Print(test);
   
   ICHI_TREND chikou_trend = TREND_BULL;
      
   if(chikou > price.high)
   {
      chikou_trend = TREND_BULL;     
   }
   
   else if(chikou < price.low)
   {
      chikou_trend = TREND_BEAR;      
   }
   
   else if (chikou > price.low && chikou < price.high)
   {
      chikou_trend = TREND_CONSOLIDATE;
   }
   
   return chikou_trend;
}


/**
* Check for Chikou and Kumo at 26 periods ago relationship.
* @param chikou
* @param senkou a
* @param senkou b
* @return What is the trend?
*/

ICHI_TREND getChikouKumoRelationship(const double chikou, const double senkoua, const double senkoub)
{
   ICHI_TREND chikou_trend = TREND_BULL;
   
   if(chikou > senkoua && chikou > senkoub)
   {
      chikou_trend = TREND_BULL;      
   }
   
   else if(chikou < senkoua && chikou < senkoub)
   {
      chikou_trend = TREND_BEAR;      
   }
   
   else if (chikou > senkoua && chikou < senkoub)
   {
      chikou_trend = TREND_CONSOLIDATE;
   }
   else if (chikou > senkoub && chikou < senkoua)
   {
      chikou_trend = TREND_CONSOLIDATE;
   }
         
   return chikou_trend;  // What is the trend?
      
} //end function

/**
* Check for Tenkan and Kijun cross relationship.
* @param tenkan
* @param kijun
* @return What is the trend?
*/
ICHI_TREND getTenkanKijunCrossRelationship(const double tenkan, const double kijun)
{
   ICHI_TREND cross_trend =  TREND_BULL;
   
   if(tenkan < kijun)
   {
      cross_trend = TREND_BEAR;
   }     
   return cross_trend;
} // end function


/**
* Get the difference value of the current price vs current Senkou A. 
* @param  price
* @param current senkouA
* @return What is the value?
*/

double getPriceCurrentSenkouA( const double price, const double senkoua)
{
   // 
   double price_senkoua = 0.0;
   price_senkoua =  (price - senkoua) / _Point;
   
   // what is the current price
   return MathAbs(price_senkoua);      
} // end function

/**
* Get the difference value of the current price vs current Senkou B. 
* @param  price
* @param current senkouB
* @return What is the value?
*/

double getPriceCurrentSenkouB( const double price, const double senkoub)
{
   // 
   double price_senkoub = 0.0;
   price_senkoub = (price - senkoub) / _Point;
   
   // what is the current price
   return MathAbs(price_senkoub);      
   
} // end function


/**
* Get the current senkou spread
* @param senkou a
* @param senkou b
* @return What is the spread between senkou a and senkou b?
*/
double getCurrentSenkouSpread(const double senkoua, const double senkoub)
{
   double difference = 0.0;
   difference = (senkoua - senkoub) / _Point;
   
   return MathAbs(difference);
} // end function

/**
* Get the future senkou spread
* @param senkou a
* @param senkou b
* @return What is the spread between senkou a and senkou b?
*/
double getFutureSenkouSpread(const double senkoua, const double senkoub)
{
   double difference = 0.0;
   difference = (senkoua - senkoub) / _Point;
   
   return MathAbs(difference);
} // end function



/*
* Get future Kumo trend.
* @param chikou - current chikou line.
* @param tenkan - current tenkan line.
* @param kijun - current kijun line.
* @param mrates52 - current mrates w/ 52 periods.
* @return trend enumeration.
*/

ICHI_KUMO_TREND getFutureKumoTrend(const double tenkan, const double kijun, const MqlRates &rates52[])
{
   ICHI_KUMO_TREND future_trend = KUMO_BULL;
      
   double fSenkouA = getFutureCloudVal("SenkouA", tenkan, kijun, rates52);
   double fSenkouB = getFutureCloudVal("SenkouB", tenkan, kijun, rates52);
   
//   Print("fSenkouA" + DoubleToString(fSenkouA) + " : fSenkouB" + DoubleToString(fSenkouB));   
   
   if (fSenkouA > fSenkouB) {
      future_trend = KUMO_BULL;      
   }
      
   else if (fSenkouB > fSenkouA) {
      future_trend = KUMO_BEAR;      
   }
   else if (fSenkouA == fSenkouB) {
      future_trend = KUMO_CONSOLIDATE;  
   }
   return future_trend;
}

/*
* Get entry price vs tenkan relationship.
* @param price - current price.
* @param tenkan - current tenkan line.
* @return points What is the difference?
*/

double getEntryPriceTenkanRelationship(const double price, const double tenkan)
{
   double points = 0.0;
   
   points = (price - tenkan) / _Point;
   
   return MathAbs(points);
}

/*
* How is the tenkan sentiment?
* @param tenkana - current tenkan
* @param tenkanb - previous tenkan
* @return points What is the trend?
*/

ICHI_TREND getTenkanSentiment(const double tenkana, const double tenkanb)
{
   ICHI_TREND tenkan_trend = TREND_BULL;
   
   if (tenkana > tenkanb)
   {
      tenkan_trend = TREND_BULL;
   }
   else if (tenkana < tenkanb)
   {
      tenkan_trend = TREND_BEAR;
   }
   else if(tenkana == tenkanb)
   {
      tenkan_trend = TREND_CONSOLIDATE;
   }
   
   return tenkan_trend;
}

/*
* How is the kijun sentiment?
* @param kijuna - current kijun
* @param kijunb - previous kijun
* @return points What is the trend?
*/

ICHI_TREND getKijunSentiment(const double kijuna, const double kijunb)
{
   ICHI_TREND trend = TREND_BULL;
   
   if (kijuna > kijunb)
   {
      trend = TREND_BULL;
   }
   else if (kijuna < kijunb)
   {
      trend = TREND_BEAR;
   }
   else if(kijuna == kijunb)
   {
      trend = TREND_CONSOLIDATE;
   }
   
   return trend;
}

/*
* How is the senkou A sentiment?
* @param senkoua_a - current senkoua
* @param senkoub_b - previous senkoua
* @return points What is the trend?
*/

ICHI_TREND getSenkouASentiment(const double senkoua_a, const double senkoua_b)
{
   ICHI_TREND trend = TREND_BULL;
   
   if (senkoua_a > senkoua_b)
   {
      trend = TREND_BULL;
   }
   else if (senkoua_a < senkoua_b)
   {
      trend = TREND_BEAR;
   }
   else if(senkoua_a == senkoua_b)
   {
      trend = TREND_CONSOLIDATE;
   }   
   return trend;
}  // end function


/*
* How is the senkou B sentiment?
* @param senkoub_a - current senkoua
* @param senkoub_b - previous senkoua
* @return points What is the trend?
*/

ICHI_TREND getSenkouBSentiment(const double senkoub_a, const double senkoub_b)
{
   ICHI_TREND trend = TREND_BULL;
   
   if (senkoub_a > senkoub_b)
   {
      trend = TREND_BULL;
   }
   else if (senkoub_a < senkoub_b)
   {
      trend = TREND_BEAR;
   }
   else if(senkoub_a == senkoub_b)
   {
      trend = TREND_CONSOLIDATE;
   }   
   return trend;
}  // end function

/*
* Get high vortex.
* @param span_array - an array of the span.
* @return points What is the highest point?
*/

double getHighVortex(const double &span_array[])
{
   double vortex = 0.0;
   int fsHighestHi = ArrayMaximum(span_array,0);
   vortex = span_array[fsHighestHi];
       
   return vortex;
   
} // end function

double getVortexPoints(const double price, const double vortex)
{

   double point = 0.0;
   point = (price - vortex) / _Point;
   
   return point;
}

/*
* Get low vortex.
* @param span_array - an array of the span.
* @return points What is the lowest point?
*/

double getLowVortex(const double &span_array[])
{
   double vortex = 0.0;
   int fsLowestHi = ArrayMinimum(span_array,0);
   vortex = span_array[fsLowestHi];
       
   return vortex;
   
} // end function



/*
* Get entry price future sekou a relationship.
* @param price - current price.
* @param senkoua - current senkoua line.
* @return points What is the difference?
*/

double getEntryPriceFutureSenkouARelationship(const double price, const double future_senkoua)
{
   double points = 0.0;
   points = (price - future_senkoua) / _Point;
   
   return MathAbs(points);
} // end function


/*
* Get entry price future senkou b relationship.
* @param price - current price.
* @param senkoub - current senkoub line.
* @return points What is the difference?
*/

double getEntryPriceFutureSenkouBRelationship(const double price, const double senkoub)
{
   double points = 0.0;
   
   points = (price - senkoub) / _Point;
   
   return MathAbs(points);
} // end function


/*
* Get entry price vs kijun relationship.
* @param price - current price.
* @param tenkan - current tenkan line.
* @return points What is the difference?
*/

double getEntryPriceKijunRelationship(const double price, const double kijun)
{
   double points = 0.0;
   
   points = (price - kijun) / _Point;
   
   return MathAbs(points);
} // end function

/*
* Get the difference between tenkan and kijun
* @param tenkan
* @param kijun
* @return difference - What is the difference between tenkan and kijun in points?
*/
double getDifferenceTenkanKijunRelationship(const double tenkan, const double kijun)
{
   double difference = 0.0;   
   double absTenkan = MathAbs(tenkan);
   double absKijun = MathAbs(kijun);
   difference = (absTenkan - absKijun) / _Point;         
   return MathAbs(difference);
   
}  // end function

/*
* Get future Kumo trend val.
* @param cloudType - senkou A or senkou B.
* @param chikou - current chikou line.
* @param tenkan - current tenkan line.
* @param kijun - current kijun line.
* @param mrates52 - current mrates w/ 52 periods.
* @return trend enumeration.
*/

double getFutureCloudVal(const string cloudType, const double tenkan, const double kijun, const MqlRates &rates[], const int limit = 52)
{
   double cloudVal = 0.0;
   double fSenkouBTotal = 0.00;  
   double fsHHArray[];
   double fsLLArray[]; 
   
   if(ArraySize(fsHHArray) < 2)
   {
      ArrayResize(fsHHArray,limit);
      ArrayResize(fsLLArray,limit);
   }
   
   for(int i=0;i<limit;i++)
   {
      fsHHArray[i] = rates[i].high;
      fsLLArray[i] = rates[i].low;      
   }
      
   int fsHighestHi = ArrayMaximum(fsHHArray,0);
   int fsLowestLow = ArrayMinimum(fsLLArray,0);   
   
   double fSenkouA = (tenkan + kijun) / 2; 
   double fSenkouB = (fsHHArray[fsHighestHi] + fsLLArray[fsLowestLow]) / 2;
   
   if (cloudType == "SenkouA")
   {
      cloudVal = fSenkouA;
   }
   else if (cloudType == "SenkouB")
   {
      cloudVal = fSenkouB;
   }     
   return cloudVal;     
}

/*
* Get trend string
* @param trendType - trend enumeration
* @return string
*/

string get_trend_string(ICHI_TREND trendType)
{
   string trend = "";
   
   switch (trendType) {
      case TREND_BULL:
         trend = "Bull";
         break;
      case TREND_BEAR:
         trend = "Bear";
         break;
      case TREND_CONSOLIDATE:
         trend = "Consolidate";  
         break; 
   }   
   return trend;
} // end function


/*
* Get kumo trend string
* @param trendType - kumo enumeration
* @return string
*/

string get_kumo_trend_string(ICHI_KUMO_TREND trendType)
{
   
   string trend = "";
   
   switch (trendType) {
      case KUMO_BULL:
         trend = "Bull"; break;
      case KUMO_BEAR:
         trend = "Bear"; break;
      case KUMO_CONSOLIDATE:
         trend = "Consolidate"; break;   
   }   
   return trend;
} // end function

/*
* Get spread for the current symbol.
* @return double What is the spread?
*/

double get_spread()
{
   double spread;   
   spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;    
   return spread;
} // end function

/*
* Get atr buffer for the current symbol to calculate entry / exit buffer.
* @return double What is the atr buffer?
*/

double get_atr_buffer(const double atr)
{
   double buffer;      
   buffer = atr / _Point;    
   return buffer;
} // end function


/*
* Calculate the buffer line for the current symbol to calculate entry / exit buffer.
* @param orderType
* @param price
* @Param atr
* @return double What is the atr buffer line?
*/

double get_atr_buffer_line(const ENUM_ORDER_TYPE orderType, const double price, const double atr)
{
   double buffer_line = 0.0;
   double buffer = get_atr_buffer(atr) * _Point;
   
   if (orderType == ORDER_TYPE_BUY)
   {
      buffer_line = price + buffer;
   }
   else if(orderType == ORDER_TYPE_SELL)
   {
      buffer_line = price - buffer;
   }
  
   // What is the buffer line?    
   return buffer_line;   
   
}  // end function



double get_breakeven_line(const ENUM_ORDER_TYPE orderType, const double price, const double spread)
{
   double break_line = 0.0;
   double buffer = spread * _Point;
   
   if (orderType == ORDER_TYPE_BUY)
   {
      break_line = price + buffer;
   }
   else if(orderType == ORDER_TYPE_SELL)
   {
      break_line = price - buffer;
   }
  
   // What is the breakeven line for this trade?    
   return break_line;   
   
}  // end function


/**
* Get last price action trend.
*/ 

ICHI_TREND get_price_action_trend(double &price_action[])
{
   int tmp_array[3];
         
   for(int i=0; i<3; i++){
      
      tmp_array[i] = (int) price_action[i];         
   }
      
   for(int i=3; i <= 5; i++)
   {
      if(in_array(tmp_array, i) > 0)
      {
         return TREND_BEAR;      
      }
   }
   
   for(int i=10; i <= 12; i++)
   {
      if(in_array(tmp_array, i)> 0)
      {
         return TREND_BULL;      
      }
   }         
   
   return TREND_CONSOLIDATE;
}


string get_price_action(int action_id)
{
   string action[15];

   if(action_id < 0 || action_id > 15)
   {
      action_id = 0;
   }
              
   action[0] = "N/A";      
   action[1]= "Bearish Shooting ShootStar 2";
   action[2]= "Bearish Shooting ShootStar 3";
   action[3]= "Bearish Shooting ShootStar 4";
   action[4]= "Evening Star";
   action[5]= "Evening Doji Star ";
   action[6]= "Dark Cloud Cover";
   action[7]= "Bearish Engulfing";   
   action[8]= "Bullish Hammer 2";
   action[9]= "Bullish Hammer 3";
   action[10]= "Bullish Hammer 4";
   action[11]= "Morning Star";
   action[12]= "Morning Doji";
   action[13]= "Piercing Line";
   action[14]= "Bullish Engulfing";   
                       
   return action[action_id];
}

/**
* Find an item in an array
*/
int in_array(int &Array[],int Value){
   int size=ArraySize(Array);
      for(int i=0; i<size; i++){
         if(Array[i]==Value){
            return(i);
         }
      }
   return(-1);
}
