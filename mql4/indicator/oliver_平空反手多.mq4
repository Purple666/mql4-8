//+------------------------------------------------------------------+
//|                                          deadswan_平空反手多.mq4 |
//|                                      淘宝旺旺 liuxiaoqian2525400 |
//|                                             http://www.waihui.ru |
//+------------------------------------------------------------------+
#property copyright "淘宝旺旺 liuxiaoqian2525400"
#property link      "http://www.waihui.ru"
//double 下单手数=1;
double 止损点数=600;
double 止盈点数=1000;
string 注释="赢家外汇论坛 www.yingjia.im QQ:29996044";
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
  if (TimeCurrent()>D'2014.02.10') //这里设定过期时间

   { 

      Alert("软件过期!请联系淘宝旺旺liuxiouqian2525400"); 

      return(0); 

   } 
double 下单手数=最大手数();   
平卖仓();   
int Ticket;
double zhisun=Ask-止损点数*Point;
double zhiying=Ask+止盈点数*Point;
if(止损点数==0)zhisun=0;
if(止盈点数==0)zhiying=0;
Ticket=OrderSend(Symbol(),OP_BUY,下单手数,Ask,30,zhisun,zhiying,注释,0,0,0);
      if(Ticket<0)
      {
      Print("多单入场失败"+GetLastError()); 
      }
      if(Ticket>0)
      {
      Print("多单入场成功"); 
      }

//----
   return(0);
  }
//+------------------------------------------------------------------+
void 平卖仓()
{
 int total = OrdersTotal();
 for(int i=total-1;i>=0;i--)
 {
  if( OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
   if(OrderSymbol()==Symbol()&&OrderType()==OP_SELL){
   bool result = false;
   result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 300, Red );
   if(result)  Print(Symbol()+"平空单成功！！");

   if(result == false)
   {
     Print("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
   }
 }}}
}
double 最大手数()
{
double s;
 for(int i=OrdersTotal()-1;i>=0;i--)
 {
  OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
  if(OrderSymbol()==Symbol()&&OrderType()==OP_SELL)
    {     
    if(s<OrderLots())s=OrderLots();
     
    }
 } return(s);

}