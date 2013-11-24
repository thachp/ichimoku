//+------------------------------------------------------------------+
//|                                                 iPatrickDraw.mq5 |
//|                                                       GPL License|
//|                   I take donation via Paypal at paypal@ethach.com|
//|                    Use at your own risk! Not a holy grail project|
//+------------------------------------------------------------------+
#property copyright "GPL License"

/*
* Draw a line.
* @param name - name for the object.
* @param price - price line to create the object.
*/

void drawLine(const string name, const double price, const datetime time, const color line_color = clrRed)
{
  ObjectCreate(0,name,OBJ_HLINE,0,time,price);           
  ObjectSetInteger(0,name,OBJPROP_COLOR,line_color);
  ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
  ObjectSetInteger(0,name,OBJPROP_WIDTH,1);  
}

/*
* Draw an object.
* @param name - name for the object.
* @param price - price line to create the object.
*/

void drawObject(const string name, const double price, const datetime time,
                const ENUM_OBJECT objectType)
{
  ObjectCreate(0,name,objectType,0,time,price);           
  ObjectSetInteger(0,name,OBJPROP_COLOR,clrGreen);
}


/*
* Move an object.
* @param name - name for the object.
* @param price - price line to create the object.
*/

void moveObject(const string name, const double price, const datetime time,
                const ENUM_OBJECT objectType)
{
  ObjectCreate(0,name,objectType,0,time,price);           
  ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);
  ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
}


/*
* Draw a buy / sell icon on the chart.
* @param name - name for the object.
* @param price - price line to create the object.
* @param orderTime - date to place this object.
* @param orderType - buy or sell icon for this object.
*/

void drawPurchase(const string name, const double price, const datetime orderTime, 
                  const ENUM_ORDER_TYPE orderType)
{
   color arrow_color = clrRed;
   
   ENUM_OBJECT orderObject = OBJ_ARROW_BUY;   
   if (orderType == ORDER_TYPE_BUY)
   {
      orderObject = OBJ_ARROW_UP;
      arrow_color = clrLightYellow;
   }
   else if (orderType == ORDER_TYPE_SELL)
   {
      orderObject = OBJ_ARROW_DOWN; 
   }
      
  ObjectCreate(0,name,orderObject,0,orderTime,price);
  ObjectSetInteger(0,name,OBJPROP_COLOR,arrow_color);
}

/*
* Draw a buy / sell icon on the chart.
* @param name - name for the object.
* @param price - price line to create the object.
* @param orderTime - date to place this object.
* @param orderType - buy or sell icon for this object.
*/

void drawBanner(const string label_name, const ENUM_ORDER_TYPE orderType)
{   
   int height= (int) ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   int width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

   ObjectCreate(0,label_name,OBJ_LABEL,0,0,0);           
   //--- set X coordinate
   ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,width-160);
   //--- set Y coordinate
   ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,10);
   //--- define text string
   ObjectSetString(0,label_name,OBJPROP_TEXT, label_name);
   //--- define font
   ObjectSetString(0,label_name,OBJPROP_FONT,"Arial");   
   //--- define font size
   ObjectSetInteger(0,label_name,OBJPROP_FONTSIZE,40);
   //--- draw it on the chart
   
   if(orderType == ORDER_TYPE_BUY)
   {
   //--- define text color
   ObjectSetInteger(0,label_name,OBJPROP_COLOR,clrGreen);      
   }
   else if(orderType == ORDER_TYPE_BUY)
   {
   //--- define text color
   ObjectSetInteger(0,label_name,OBJPROP_COLOR,clrRed);
   }      
   ChartRedraw(0);                                      
}

/*
* Draw label at x, y coordinate.
* @param label_name
* @param info
* @param x
* @param y
*/

void drawText(const string label_name, const string info, const int x, const int y)
{  
   ObjectCreate(0,label_name,OBJ_TEXT,0,0,0);  
   ObjectSetString(0,label_name,OBJPROP_TEXT, info);   
   //--- set X coordinate
   ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,x);
   //--- set Y coordinate
   ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,y);
   
   ChartRedraw(0);
}  // end function


void drawMark(const string name, const datetime time, const double price, const string shortname)
{

   if(ObjectFind(0,name)< 0)   
   {
   ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
   ObjectSetString(0, name, OBJPROP_TEXT, shortname);
	ObjectSetString(0, name, OBJPROP_FONT, "Times New Roman");   
   }   

}

/*
* Display comments and print string.
* @param msg
*/
void debug(const string &msg[])
{
   string message = "";
         
   for(int i=0;i<ArraySize(msg);i++)
   {
    message = message + msg[i] +"\n";   
   }     
   Comment(message);
}


string getName(string aName, datetime timeshift)
{
  return(aName + DoubleToString(timeshift, 0));
}
