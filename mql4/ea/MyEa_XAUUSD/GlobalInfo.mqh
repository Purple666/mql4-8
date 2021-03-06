//+------------------------------------------------------------------+
//|                                                   GlobalInfo.mqh |
//|                                                        oliverlee |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "oliverlee"
#property link      "http://www.mql5.com"
#property strict
#include <KeyPrice.mqh>

const int UPCROSS = 1;
const int DOWNCROSS = 2;
const int FLAT = 3;
const int UPRUNNING = 4;
const int DOWNRUNNING = 5;
const int UNKNOWN = 0;

class GlobalInfo{

private:

 datetime lastRangeStart; /* 上一次震荡结束的坐标*/
 datetime lastRangeEnd;
 
 double lastRangeHigh;
 double lastRangeLow;
 
 datetime lastCalculateBankPos;
 
public:

 // 0.外部参数
 int mainTF;
 int largeTF;
 
 int condition1;
 double lot1;
 int condition2;
 double lot2;
 int condition3;
 double lot3;
 int conditionOut;
 int lsDeviation200;
 
 int mainMAFast;// 12
 int mainMASLow;// 50
 int crossEffectPeriod;
 
 int slowMAFast;// 200
 int slowMASlow;//377
 
 int stoplose;
 int takeprofile;
 
 double MaximumRisk;
 double DecreaseFactor;
 int MovingShift;
 
 
 
 // 0.状态
 int currentStatus; /*当前行情是单边还是震荡*/

 double rangeHigh; /* 当前行情的震荡区间*/
 double rangeLow;
  
 datetime rangeStart;
 datetime rangeEnd;
 
 bool breakLastRange;
 
 int mMaStatus;
 int sMaStatus;
 
 bool mainUpSlow;
 bool mainBelowSlow;
 
 datetime lastmMaCrossTime;
 
 bool mMaCrossEffect;
 
 double distanceSMaFast; // 价格到P200的价差
 double distanceMS; // 377 和 200的价差
 
 int dis_betweenMMA; // ma12和ma50的点数差
 int dis_betweenMMA_before; // N根前ma12和ma50的点数差
 
 int dis_sMAFastToSlow;
 
 bool nearSMaFast;
 bool nearSmaSlow;
 bool farSMaFast;
 
 double rsi;
 double rsi_day;
 double rsi_4h;
  
 KeyPrice *kps[]; /*银行位*/
 
 //double distanceToSMaFast;
 //double distanceTOSMaSlow;
 


 int backPeriod; // 当前行情持续的K线个数
 bool break50ma;


 // 2.
 void GlobalInfo(){
   
      breakLastRange=false;
 }
 
 void prepare()
 {
 
   rsi = iRSI(NULL,mainTF,14,PRICE_CLOSE,0);
   rsi_day = iRSI(NULL,PERIOD_D1,14,PRICE_CLOSE,0);
   rsi_4h = iRSI(NULL,PERIOD_H4,14,PRICE_CLOSE,0);
   
   // 0.均线状态   
   mMaStatus = MaCompare(mainMAFast,mainMASLow,MovingShift,0,mainTF); 
   // 1.判断均线穿越是否生效
   if(mMaStatus == UPCROSS || mMaStatus == DOWNCROSS)
   {
      int crossshift = iBarShift(Symbol(),mainTF,lastmMaCrossTime);
      if(crossshift<crossEffectPeriod)
      {
         mMaCrossEffect = false;
      }else{
         mMaCrossEffect = true;
      }
      lastmMaCrossTime = iTime(Symbol(),mainTF,0);
   }
   sMaStatus = MaCompare(slowMAFast,slowMASlow,MovingShift,0,mainTF);
   
   // 2. 12均线是否在377上下
   double ma12 = iMA(Symbol(),mainTF,mainMAFast,0,MODE_EMA,PRICE_CLOSE,0);
   double p50 = iMA(Symbol(),mainTF,mainMASLow,0,MODE_EMA,PRICE_CLOSE,0);
   double ma377  = iMA(Symbol(),mainTF,slowMASlow,0,MODE_EMA,PRICE_CLOSE,0);
   double p200 = iMA(NULL,mainTF,200,0,MODE_EMA,PRICE_CLOSE,0);
   
   dis_sMAFastToSlow = (p200-ma377)/Point;
   
   if(ma12 > ma377)
   {
      mainUpSlow = true;
      mainBelowSlow = false;
   }else{
      mainUpSlow = false;
      mainBelowSlow = true;
   }
   
   // 3. ma12和ma50的距离
   dis_betweenMMA = (ma12-p50)/Point;
   double Pbefore12 = iMA(Symbol(),mainTF,mainMAFast,0,MODE_EMA,PRICE_CLOSE,8);
   double Pbefore50 = iMA(Symbol(),mainTF,mainMASLow,0,MODE_EMA,PRICE_CLOSE,8);
    
   dis_betweenMMA_before = (Pbefore12 - Pbefore50)/Point;
   
   
   // 4.价格状态
    
   distanceSMaFast = MathAbs(Bid - p200);
   nearSMaFast = distanceSMaFast<200*Point;
   nearSmaSlow = MathAbs(Bid - ma377)<200*Point;
   
   // 要超出377
   /*
   if(sMaStatus == UPRUNNING || sMaStatus == UPCROSS)
   {
      nearSmaSlow = 100*Point<MathAbs(Bid - p377)&&MathAbs(Bid - p377)<200*Point && Bid<p377;
   }else if(sMaStatus == DOWNRUNNING || sMaStatus == DOWNCROSS)
   {
      nearSmaSlow = 100*Point<MathAbs(Bid - p377)&&MathAbs(Bid - p377)<200*Point && Bid>p377;
   }*/
   
   farSMaFast = distanceSMaFast>500*Point;
   
   distanceMS = MathAbs(ma377-p200);
   
   // 2.银行位,每天计算一次 
   /*
   datetime currentDay = iTime(Symbol(),largeTF,0);
   
   if(currentDay!=lastCalculateBankPos)
   {
      lastCalculateBankPos = currentDay;
      
      // 重新计算
      // TODO 如何知道zz的长度
      int num = Bars(Symbol(), largeTF)/5;

      double data[];
      ArrayResize(data,num);
      ArrayInitialize(data,0.0);
      
   
      for(int i=0;i<num;i++)
      {
         data[i] = GetExtremumZZPrice(Symbol(), largeTF, i, 9, 5, 2); 
      }

      KeyPrice::findRepeat(data,1500*Point,kps);
      
     
      int size = ArraySize(kps);
      for(int j=0;j<size;j++)
      {
         HLineCreate(0,"MyHigh_"+DoubleToStr(kps[j].getPrice()),0,kps[j].getPrice(),clrRed,1,3);
      }
      
   }*/
   
 
   // 200在上方，下跌过程中如果到达200 就平仓，价格跌穿377 再进空单
   // 这样分段的话，如果达到1000点就平仓
   // 如果距离200近的话，就不进逆势单
   
   
   
   // 2.震荡区间
   
   // 1.银行线
   
   
    /*
    //int shift = 0;
    int shift = Bars-500;
    
    rangeStart = iTime(Symbol(),mainTF,shift+59);
    rangeEnd = iTime(Symbol(),mainTF,shift+51);
    rangeHigh = High[iHighest(Symbol(),mainTF,MODE_HIGH,9,shift+51)];
    rangeLow = Low[iLowest(Symbol(),mainTF,MODE_LOW,9,shift+51)];
    
    lastRangeStart = iTime(Symbol(),mainTF,shift+09);
    lastRangeEnd = iTime(Symbol(),mainTF,shift+01);
    lastRangeHigh =  High[iHighest(Symbol(),mainTF,MODE_HIGH,9,shift+51)];
    lastRangeLow  = Low[iLowest(Symbol(),mainTF,MODE_LOW,9,shift+51)];
    
    for(;shift>1;shift--)
    {
    
        double p377 = iMA(NULL,mainTF,377,shift,MODE_EMA,PRICE_CLOSE,0);
        double p200 = iMA(NULL,mainTF,200,shift,MODE_EMA,PRICE_CLOSE,0);
        double p210 = iMA(NULL,mainTF,200,shift,MODE_EMA,PRICE_CLOSE,10);
        
        double angle200 = get_MA_Window_Angle(200,shift+10,shift,PERIOD_H1,NULL);// 与前20，均线的角度
        
       
         
        double dev = p200 - p377;
        double dev2 = MathAbs(p200-p210);
        
        datetime currentTime =  iTime(Symbol(),mainTF,shift);

    // 均线走平
    if(-5<angle200&&angle200<5)//&&(currentTime != rangeEnd)
    {

         if(currentStatus!=FLAT)
         {
            currentStatus = FLAT;
            
            // 判断是否连接之前的区间
            int pos = iBarShift(Symbol(),mainTF,rangeEnd);
           
            if(pos-shift>40)
            {     
                 // 画之前的区间
                 RectangleCreate(0,""+rangeStart,0,rangeStart,rangeHigh,rangeEnd,rangeLow,clrBlue,0,2,true);
                 
                 lastRangeStart = rangeStart;
                 lastRangeEnd = rangeEnd;
                 lastRangeHigh = rangeHigh;
                 lastRangeLow = rangeLow;
                 
                 // 开启新的区间
                 rangeStart = currentTime;
                 rangeEnd = currentTime;
                  
                 rangeHigh = High[shift];
                 rangeLow = Low[shift];
                
            }
           else{
               // 延续之前的区间
               
               // 补充中间的高低价
               if(pos-shift>1)
               {
                  double p1 = High[iHighest(NULL,mainTF,MODE_HIGH,pos-shift+1,shift)];
                  if(p1>rangeHigh)
                  {
                     rangeHigh = p1;
                     
                  }
                  
                  double p2 = Low[iLowest(NULL,mainTF,MODE_LOW,pos-shift+1,shift)];
                  if(p2<rangeLow)
                  {
                     rangeLow = p2;
                     
                  } 
               }
               rangeEnd = currentTime;  
               
                      
            } 
  
         }else{// 本来就是在区间进行中
         
            bool re3 =ArrowBuyCreate(0,""+currentTime+"Arraw",0,currentTime,p200,clrAzure,1,2);
            Print("创建箭头:"+ re3);
            // 更新区间
            if(High[shift]>rangeHigh)
            {
               rangeHigh = High[shift];
            }
            if(Low[shift]<rangeLow)
            {
               rangeLow = Low[shift];
            }
            
            rangeEnd = currentTime;
         } 
    }
    // 角度不平
    else{
      
      
      currentStatus = UPRUNNING;
      /*
       int s1 = iBarShift(Symbol(),mainTF,rangeStart)-iBarShift(Symbol(),mainTF,rangeEnd);

      if(s1<10)
      {
         //取消上一次的区间
         rangeStart = lastRangeStart;
         rangeEnd = lastRangeEnd;
         rangeHigh = lastRangeHigh;
         rangeLow = lastRangeLow;
      }
      */
      /*
      // ma200在ma377上方
      if(dev>0)
      {
         
      }
      // ma200在
      else{
      }
      
      if(angle200>10)
      {
         // 正常上涨
         
         
         // 上穿
      }else if(angle200<-10)
      {
         // 正常下跌
         
         // 下穿
      }

    }
   }// end of shift loop
    
    
 */
    
    
 }// end of init

};


int MaCompare(int fast,int slow,int shift,int pos,int tf)
{
   double fastNow = iMA(Symbol(),tf,fast,shift,MODE_EMA,PRICE_CLOSE,pos);
   double fastBefore = iMA(Symbol(),tf,fast,shift,MODE_EMA,PRICE_CLOSE,pos+1);
   
   double slowNow = iMA(Symbol(),tf,slow,shift,MODE_EMA,PRICE_CLOSE,pos);
   
   if(fastNow > slowNow && fastBefore > slowNow)
   {
      return UPRUNNING;
   }else if(fastNow>slowNow && fastBefore<=slowNow)
   {
      return UPCROSS;
   }else if(fastNow<slowNow && fastBefore<slowNow)
   {
      return DOWNRUNNING;
   }else if(fastNow<slowNow && fastBefore>=slowNow)
   {
      return DOWNCROSS;
   }
   
   return UNKNOWN;
}