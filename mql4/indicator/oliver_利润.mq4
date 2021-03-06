//+------------------------------------------------------------------+
//|                                                         账户利润.mq4 |
//|                                                        oliverlee |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "oliverlee"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window // 定义为显示在主图

//定义参数
extern color  InpColor=White;
extern color  EquityColor=Blue;
extern int    fontSize=14;
extern int    equitySize=20;
extern int    maxOrders=10;

//extern int    x=800;
//extern int    y=0;

#define SYMBOLS_MAX 1024
#define DEALS          0
#define BUY_LOTS       1
#define BUY_PRICE      2
#define SELL_LOTS      3
#define SELL_PRICE     4
#define NET_LOTS       5
#define PROFIT         6

// 各列的偏移量
int ExtShifts[8]={10,110,180,270,350,420,540,630 };

// 二维数组，每一种订单类型是个数组
double ExtSymbolsSummaries[SYMBOLS_MAX][7];

int    ExtSymbolsTotal=0;// 商品类型的总数
string ExtSymbols[SYMBOLS_MAX]; // 商品类型的数组
                                //string labelarray[10][8];

int    ExtLines=-1;
int    ExtVertShift=23; // 每次下移的幅度

string ExtCols[8]=
  {
   "商品",
   "编号",
   "买入",
   "价格",
   "卖出",
   "价格",
   "净持仓",
   "利润"
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
// ObjectDelete("Account_Profit_Label"); 
/*
  if(ObjectCreate("equity",OBJ_LABEL,0,0,0))
  {
   ObjectSet("equity",OBJPROP_XDISTANCE,200);
   ObjectSet("equity",OBJPROP_YDISTANCE,200);
  }
 ObjectSetText("equity",DoubleToStr(AccountEquity(),2),equitySize,"Arial",EquityColor);
 

   double profit;

   int i,type,total=OrdersTotal();

   for(i=0; i<total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      type=OrderType();
      if(type!=OP_BUY && type!=OP_SELL) continue;
      
      //打印商品种类名称 OrderSymbol()
      profit=OrderProfit()+OrderCommission()+OrderSwap();// 佣金
      Print(DoubleToStr(OrderProfit(),2));
     }
 */
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   string name;
   int    i,col,line;// 找到窗口

   ArrayInitialize(ExtSymbolsSummaries,0.0);// 初始化数组

                                            // 创建列头                                         
   if(ExtLines<0)
     {
      for(col=0; col<8; col++)
        {
         name="Head_"+string(col);
         if(ObjectCreate(name,OBJ_LABEL,0,0,0))
           {
            ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[col]);
            ObjectSet(name,OBJPROP_YDISTANCE,ExtVertShift);
            ObjectSetText(name,ExtCols[col],fontSize,"Arial",InpColor);
           }
        }
      ExtLines=0;
     }

   int total=Analyze();

// 如果有未平仓订单
   if(total>0)
     {
      line=0;
      // 遍历所有的品种
      for(i=0; i<ExtSymbolsTotal; i++)
        {
         // 如果这个商品的订单数量是0
         if(ExtSymbolsSummaries[i][DEALS]<=0) continue;
         // 新加一行
         line++;
         //---- add line
         if(line>ExtLines)
           {
            Print("start create...");
            int y_dist=ExtVertShift*(line+1)+1;

            // 在各个列上创建各个标签对象
            for(col=0; col<8; col++)
              {
               name="Line_"+string(line)+"_"+string(col);
               if(ObjectCreate(name,OBJ_LABEL,0,0,0))
                 {
                  ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[col]);
                  ObjectSet(name,OBJPROP_YDISTANCE,y_dist);
                 }
              }
            ExtLines++;
           }
         //---- 设置各个Label的内容
         int    digits=(int)MarketInfo(ExtSymbols[i],MODE_DIGITS);
         double buy_lots=ExtSymbolsSummaries[i][BUY_LOTS];// 买单手数
         double sell_lots=ExtSymbolsSummaries[i][SELL_LOTS];// 卖单手数
         double buy_price=0.0;
         double sell_price=0.0;

         if(buy_lots!=0) buy_price=ExtSymbolsSummaries[i][BUY_PRICE]/buy_lots;
         if(sell_lots!=0) sell_price=ExtSymbolsSummaries[i][SELL_PRICE]/sell_lots;
         name="Line_"+string(line)+"_0";
         Print("start set...");
         //labelarray[i][0]=name;

         ObjectSetText(name,ExtSymbols[i],fontSize,"Arial",InpColor);
         name="Line_"+string(line)+"_1";
         //labelarray[i][1]=name;
         ObjectSetText(name,DoubleToStr(ExtSymbolsSummaries[i][DEALS],0),fontSize,"Arial",InpColor);// 序号
         name="Line_"+string(line)+"_2";
         //labelarray[i][2]=name;
         ObjectSetText(name,DoubleToStr(buy_lots,2),fontSize,"Arial",InpColor);// 买单手数
         name="Line_"+string(line)+"_3";
         // labelarray[i][3]=name;
         ObjectSetText(name,DoubleToStr(buy_price,digits),fontSize,"Arial",InpColor);// 买单价格
         name="Line_"+string(line)+"_4";
         //labelarray[i][4]=name;
         ObjectSetText(name,DoubleToStr(sell_lots,2),fontSize,"Arial",InpColor);// 卖单手数
         name="Line_"+string(line)+"_5";
         // labelarray[i][5]=name;
         ObjectSetText(name,DoubleToStr(sell_price,digits),fontSize,"Arial",InpColor);// 卖单价格
         name="Line_"+string(line)+"_6";
         //labelarray[i][6]=name;
         ObjectSetText(name,DoubleToStr(buy_lots-sell_lots,2),fontSize,"Arial",InpColor);
         name="Line_"+string(line)+"_7";
         // labelarray[i][7]=name;
         ObjectSetText(name,DoubleToStr(ExtSymbolsSummaries[i][PROFIT],2),fontSize,"Arial",InpColor);// 利润
        }

        }
       
        else{
      // 清屏不能删除，删除了，然后再下单就不能显示了，只能设置空白
      for(int k=0;k<2;k++)
        {
         ObjectSetText("Line_"+string(k)+"_0","",fontSize,"Arial",InpColor);
         ObjectSetText("Line_"+string(k)+"_1","",fontSize,"Arial",InpColor);
         ObjectSetText("Line_"+string(k)+"_2","",fontSize,"Arial",InpColor);
         ObjectSetText("Line_"+string(k)+"_3","",fontSize,"Arial",InpColor);
         ObjectSetText("Line_"+string(k)+"_4","",fontSize,"Arial",InpColor);
         ObjectSetText("Line_"+string(k)+"_5","",fontSize,"Arial",InpColor);
         ObjectSetText("Line_"+string(k)+"_6","",fontSize,"Arial",InpColor);
         ObjectSetText("Line_"+string(k)+"_7","",fontSize,"Arial",InpColor);
        }

      // ArrayInitialize(labelarray,"");
     }

// 账户利润
   if(ObjectCreate("equity",OBJ_LABEL,0,0,0))
     {
      ObjectSet("equity",OBJPROP_XDISTANCE,200);
      ObjectSet("equity",OBJPROP_YDISTANCE,200);
     }
   ObjectSetText("equity",DoubleToStr(AccountEquity(),2),equitySize,"Arial",EquityColor);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Analyze()
  {
   double profit;
   int    i,index,type,total=OrdersTotal();
//----
// 遍历所有的订单
   for(i=0; i<total; i++)
     {
      // 过滤
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      type=OrderType();
      if(type!=OP_BUY && type!=OP_SELL) continue;

      index=SymbolsIndex(OrderSymbol());// 商品的序号

      if(index<0 || index>=SYMBOLS_MAX) continue;

      //----
      ExtSymbolsSummaries[index][DEALS]++;// 改商品类型的订单序号加1

      profit=OrderProfit()+OrderCommission()+OrderSwap();
      ExtSymbolsSummaries[index][PROFIT]+=profit;// 利润
      if(type==OP_BUY)
        {
         ExtSymbolsSummaries[index][BUY_LOTS]+=OrderLots();
         ExtSymbolsSummaries[index][BUY_PRICE]+=OrderOpenPrice()*OrderLots();
        }
      else
        {
         ExtSymbolsSummaries[index][SELL_LOTS]+=OrderLots();
         ExtSymbolsSummaries[index][SELL_PRICE]+=OrderOpenPrice()*OrderLots();
        }
     }
//----
// 计算所有的订单数
   total=0;
   for(i=0; i<ExtSymbolsTotal; i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(ExtSymbolsSummaries[i][DEALS]>0) total++;
     }
//----
   return(total);
  }
// 返回商品类型的序号
int SymbolsIndex(string SymbolName)
  {

   bool found=false;
   int  i;
//----
   for(i=0; i<ExtSymbolsTotal; i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(SymbolName==ExtSymbols[i])
        {
         found=true;
         break;
        }
     }
//----
   if(found)
      return(i);// 如果找到了就返回序号
   if(ExtSymbolsTotal>=SYMBOLS_MAX)
      return(-1);
//----

// 如果没找到
   i=ExtSymbolsTotal;
   ExtSymbolsTotal++;

// 保存到下一个元素
   ExtSymbols[i]=SymbolName;
// 初始化数组的值
   ExtSymbolsSummaries[i][DEALS]=0;
   ExtSymbolsSummaries[i][BUY_LOTS]=0;
   ExtSymbolsSummaries[i][BUY_PRICE]=0;
   ExtSymbolsSummaries[i][SELL_LOTS]=0;
   ExtSymbolsSummaries[i][SELL_PRICE]=0;
   ExtSymbolsSummaries[i][NET_LOTS]=0;
   ExtSymbolsSummaries[i][PROFIT]=0;
//----
   return(i);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete("Account_Profit_Label");

//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
