//+------------------------------------------------------------------+
//|                                            deadswan-画线指标.mq4 |
//|                                      淘宝旺旺 liuxiouqian2525400 |
//|                                             http://www.waihui.ru |
//+------------------------------------------------------------------+
#property copyright "QQ：29996044 淘宝旺旺 liuxiouqian2525400 网址 www.yingjia.im"
#property link      "http://www.yingjia.im"

int 画线宽度K数=30;
extern color 画线颜色=Red;
extern int 画线类型=0;
extern int 画线粗度=2;
extern int 画线数量=6;
//extern int 文字位置=30;
extern color 文字颜色=Lime;
extern int 文字大小=14;

int 画线距离=80;
int s,x;
int sj;
int px;
double pxjg;
datetime sjbj,xjbj,jcbj,scbj;
int bj;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- indicators
double jg=Bid+(画线数量/2)*画线距离*Point;
   for (int i = 1; i <=画线数量; i++) {
画线("xian"+i,画线颜色,画线类型,画线粗度,Time[画线宽度K数],Time[0],jg-i*画线距离*Point,jg-i*画线距离*Point);

}
计算();

//----
 EventSetMillisecondTimer(10);     
//---
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
ObjectsDeleteAll();

   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void OnTimer()
  {
   
计算();

//----
  }
//+------------------------------------------------------------------+
void 画线(string 画线名称,color 颜色,int 类型,int cu,datetime 时间1,datetime 时间2,double 价格1,double 价格2)
{
if(价格1!=0&&ObjectFind(画线名称)==-1)
{
   ObjectCreate(画线名称,OBJ_TREND,0,时间1,价格1,时间2,价格2);
   ObjectSet(画线名称,OBJPROP_COLOR,颜色);
   ObjectSet(画线名称,OBJPROP_STYLE,类型);
   ObjectSet(画线名称,OBJPROP_WIDTH,cu);
   ObjectSet(画线名称,OBJPROP_RAY,false);
   
   
}
if(价格1!=0&&ObjectFind(画线名称)!=-1)
{
ObjectSet(画线名称,OBJPROP_PRICE1,价格1);
ObjectSet(画线名称,OBJPROP_PRICE2,价格1);
}

}

void 写字(string 字名称,string 字内容,datetime 字位置,double 字价格,int 字大小,string 字颜色)
{
if(ObjectFind(字名称)==-1)
{
ObjectCreate(字名称, OBJ_TEXT, 0, 字位置, 字价格);
ObjectSetText(字名称, 字内容, 字大小, "Arial", 字颜色);
}
else
{
ObjectSet(字名称,OBJPROP_PRICE1,字价格);
ObjectSet(字名称,OBJPROP_TIME1,字位置);
ObjectSetText(字名称, 字内容, 字大小, "Arial", EMPTY);
}

}
void 计算()
{

     for (int k = 1; k <画线数量; k++) {
double jg1=ObjectGet("xian"+k, OBJPROP_PRICE1);
double jg2=ObjectGet("xian"+(k+1), OBJPROP_PRICE1);
datetime sj6=ObjectGet("xian"+k, OBJPROP_TIME1);
   Print(jg2);
写字("zi"+k,DoubleToStr(MathAbs((jg1-jg2)/Point),2),sj6,jg1-(MathAbs(jg1-jg2)/3),文字大小,文字颜色);   
   
   }
}