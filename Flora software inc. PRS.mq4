//+------------------------------------------------------------------+
//|                                           HarmonicPatterns_1.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

enum type
{
  cypher,
  bat,
  gartley 
};

input bool plot_D_MidCandle=true;
input color target_color=clrLightGreen;
input color target_line_color=clrYellow;
input bool fill_triangles=true;
input type pattern=cypher;
input int recalculate_timeout_second=60;
input int how_big_first_leg_bars=250;
input int bars_back_check=3000;
input string c1="-------- Cypher --------";
input double cypher_B_leg_from=0.382;
input double cypher_B_leg_to=0.618;
input double cypher_C_leg_from=1.272;
input double cypher_C_leg_to=1.414;
input double cypher_D_leg=0.786;
input double cypher_target1=0.382;
input double cypher_target2=0.618;
input color cypher_color_up=clrLightSkyBlue;
input color cypher_color_dn=clrBlue;
input string c2="-------- Bat --------";
input double bat_B_leg_from=0.5;
input double bat_B_leg_to=0.618;
input double bat_C_leg_from=0.382;
input double bat_C_leg_to=0.886;
input double bat_D_leg=0.886;
input double bat_target1=0.382;
input double bat_target2=0.618;
input color bat_color_up=clrLightSalmon;
input color bat_color_dn=clrOrange;
input string c3="-------- Gartley --------";
input double gartley_B_leg_from=0.618;
input double gartley_B_leg_to=0.786;
input double gartley_C_leg_from=0.382   ;
input double gartley_C_leg_to=0.886;
input double gartley_D_leg=0.786;
input double gartley_target1=0.382;
input double gartley_target2=0.618;
input color gartley_color_up=clrPlum;
input color gartley_color_dn=clrMediumPurple;


double arrow[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   last_run_time=0;
//--- indicator buffers mapping
   ChartSetInteger(0,CHART_SHOW_OBJECT_DESCR,true);
//---
   return(INIT_SUCCEEDED);
  }
  void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();
  }
  datetime last_run_time=0;
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
  static int debug=0;
//---
   if(TimeCurrent()-last_run_time<recalculate_timeout_second) return rates_total;
   last_run_time=TimeCurrent();
   ObjectsDeleteAll();
   
   int i,x,a,b,c,d=0;
   int limit=MathMin(rates_total-2,bars_back_check);
double lowest,highest;  
double target1,target2; 
double priceD=0;
bool isTemp;
bool wasTemp;
bool found;
int prevx;
int prevd;
if(pattern==cypher)
{     
   wasTemp=false;
   prevx=0;
   prevd=0;
   for(i=limit;i>=1;i--)
   {
      if(high[i]<high[i+1] || high[i]<high[i-1]) continue;
      x=i;
      found=false;
      lowest=low[x-1];
      isTemp=false;
      for(a=x-1;a>=x-how_big_first_leg_bars && a>=1;a--)
      {
         double xa=high[x]-low[a];
         if(high[a]>high[x]) break;
         if(low[a]>lowest || low[a]>low[a-1]) continue;
         lowest=low[a];
         for(b=a-1;b>=0;b--)
         {
            double ab=high[b]-low[a];
            if(low[b]<low[a] || ab>cypher_B_leg_to*xa)
            {
               break;
            }
            if(ab>cypher_B_leg_from*xa)
            {
               for(c=b-1;c>=1;c--)
               {
                  double cb=high[b]-low[c];
                  if(high[c]>high[b] || cb>cypher_C_leg_to*xa)
                  {
                     break;
                  }
                  if(low[c]>low[c-1] || low[c]>low[c+1]) continue;
                  if(cb>cypher_C_leg_from*xa)
                  {
                     double xc=high[x]-low[c];
                     for(d=c-1;d>=1;d--)
                     {
                        if(low[d]<low[c])
                        {
                           break;
                        }
                        if(high[d]<high[d-1]) continue;
                        double cd=high[d]-low[c];
                        if(cd>cypher_D_leg*xc)
                        {
                           priceD=high[d];
                           if(plot_D_MidCandle)
                           priceD=low[c]+cypher_D_leg*xc;
                           found=true;
                           break;
                        }
                        if(d==1)
                        {
                           priceD=low[c]+cypher_D_leg*xc;
                           found=true;
                           isTemp=true;
                           break;
                        }
                     }
                  }
                  if(found) break;
               }
            }
            if(found) break;
         }
         if(found) break;
      }
     if(isTemp)
     {
         wasTemp=true;
         TriangleCreate(0,"1_temp",0,time[x],high[x],time[b],high[b],time[a],low[a],cypher_color_dn);
         TriangleCreate(0,"1_1temp",0,time[b],high[b],time[d],priceD,time[c],low[c],cypher_color_dn);
         target1=priceD-(priceD-low[c])*cypher_target1;
         target2=priceD-(priceD-low[c])*cypher_target2;
         TrendCreate(0,"1_target1temp",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,"1_target2temp",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,"1_target_linetemp",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,"1_target1temp",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,"1_target2temp",OBJPROP_TEXT,DoubleToString(target2,_Digits));
     }
     if(!wasTemp)
     {
      ObjectDelete("1_temp");
      ObjectDelete("1_1temp");
      ObjectDelete("1_target1temp");
      ObjectDelete("1_target2temp");
      ObjectDelete("1_target_linetemp");
     }
     if(found && !isTemp)
     {   
     
      if(x>prevd)
      {
         if(x-d>prevx-prevd)
         {
            TriangleCreate(0,(string)time[x],0,time[x],high[x],time[b],high[b],time[a],low[a],cypher_color_dn);
            TriangleCreate(0,(string)time[x]+"1",0,time[b],high[b],time[d],priceD,time[c],low[c],cypher_color_dn);  
            target1=priceD-(priceD-low[c])*cypher_target1;
            target2=priceD-(priceD-low[c])*cypher_target2;
            TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
            ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
            ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
            ObjectDelete((string)time[prevx]);
            ObjectDelete((string)time[prevx]+"1");
            ObjectDelete((string)time[prevx]+"target1");
            ObjectDelete((string)time[prevx]+"target2");
            ObjectDelete((string)time[prevx]+"target_line");
            prevx=x;
            prevd=d;
         }
      }
      else
      {
         TriangleCreate(0,(string)time[x],0,time[x],high[x],time[b],high[b],time[a],low[a],cypher_color_dn);
         TriangleCreate(0,(string)time[x]+"1",0,time[b],high[b],time[d],priceD,time[c],low[c],cypher_color_dn);
         target1=priceD-(priceD-low[c])*cypher_target1;
         target2=priceD-(priceD-low[c])*cypher_target2;
         TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
         prevx=x;
         prevd=d;
      }
   }

}
   wasTemp=false;
   prevx=0;
   prevd=0;
   for(i=limit;i>=1;i--)
   {
      if(low[i]>low[i+1] || low[i]>low[i-1]) continue;
      x=i;
      found=false;
      highest=high[x-1];
      isTemp=false;
      for(a=x-1;a>=x-how_big_first_leg_bars && a>=1;a--)
      {
         double xa=high[a]-low[x];
         if(low[a]<low[x]) break;
         if(high[a]<highest || high[a]<high[a-1]) continue;
         highest=high[a];
         for(b=a-1;b>=0;b--)
         {
            double ab=high[a]-low[b];
            if(high[b]>high[a] || ab>cypher_B_leg_to*xa)
            {
               break;
            }
            if(ab>cypher_B_leg_from*xa)
            {
               for(c=b-1;c>=1;c--)
               {
                  double cb=high[c]-low[b];
                  if(low[c]<low[b] || cb>cypher_C_leg_to*xa)
                  {
                     break;
                  }
                  if(high[c]<high[c-1] || high[c]<high[c+1]) continue;
                  if(cb>cypher_C_leg_from*xa)
                  {
                     double xc=high[c]-low[x];
                     for(d=c-1;d>=1;d--)
                     {
                        if(high[d]>high[c])
                        {
                           break;
                        }
                        if(low[d]>low[d-1]) continue;
                        double cd=high[c]-low[d];
                        if(cd>cypher_D_leg*xc)
                        {
                           found=true;
                           priceD=low[d];
                           if(plot_D_MidCandle)
                           priceD=high[c]-cypher_D_leg*xc;
                           break;
                        }
                        if(d==1)
                        {
                           priceD=high[c]-cypher_D_leg*xc;
                           found=true;
                           isTemp=true;
                           break;
                        }
                     }
                  }
                  if(found) break;
               }
            }
            if(found) break;
         }
         if(found) break;
      }
      
     if(isTemp)
     {
         wasTemp=true;
         TriangleCreate(0,"2_0temp",0,time[x],low[x],time[b],low[b],time[a],high[a],cypher_color_up);
         TriangleCreate(0,"2_01temp",0,time[b],low[b],time[d],priceD,time[c],high[c],cypher_color_up);
         target1=priceD+(high[c]-priceD)*cypher_target1;
         target2=priceD+(high[c]-priceD)*cypher_target2;
         TrendCreate(0,"2_target1temp",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,"2_target2temp",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,"2_target_linetemp",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,"2_target1temp",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,"2_target2temp",OBJPROP_TEXT,DoubleToString(target2,_Digits));
     }
     if(!wasTemp)
     {
      ObjectDelete("2_0temp");
      ObjectDelete("2_01temp");
      ObjectDelete("2_target1temp");
      ObjectDelete("2_target2temp");
      ObjectDelete("2_target_linetemp");
     }
     if(found && !isTemp)
     {   
      if(x>prevd)
      {
         if(x-d>prevx-prevd)
         {
            TriangleCreate(0,(string)time[x]+"0",0,time[x],low[x],time[b],low[b],time[a],high[a],cypher_color_up);
            TriangleCreate(0,(string)time[x]+"01",0,time[b],low[b],time[d],priceD,time[c],high[c],cypher_color_up);  
            target1=priceD+(high[c]-priceD)*cypher_target1;
            target2=priceD+(high[c]-priceD)*cypher_target2;
            TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
            ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
            ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
            ObjectDelete((string)time[prevx]+"0");
            ObjectDelete((string)time[prevx]+"01");
            ObjectDelete((string)time[prevx]+"target1");
            ObjectDelete((string)time[prevx]+"target2");
            ObjectDelete((string)time[prevx]+"target_line");
            prevx=x;
            prevd=d;
         }
      }
      else
      {
         TriangleCreate(0,(string)time[x]+"0",0,time[x],low[x],time[b],low[b],time[a],high[a],cypher_color_up);
         TriangleCreate(0,(string)time[x]+"01",0,time[b],low[b],time[d],priceD,time[c],high[c],cypher_color_up);
         target1=priceD+(high[c]-priceD)*cypher_target1;
         target2=priceD+(high[c]-priceD)*cypher_target2;
         TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
         prevx=x;
         prevd=d;
      }
     }
   }
}
else if(pattern==bat)
{
   wasTemp=false;
   prevx=0;
   prevd=0;
   for(i=limit;i>=1;i--)
   {
      if(high[i]<high[i+1] || high[i]<high[i-1]) continue;
      x=i;
      found=false;
      lowest=low[x-1];
      isTemp=false;
      for(a=x-1;a>=x-how_big_first_leg_bars && a>=1;a--)
      {
         double xa=high[x]-low[a];
         if(high[a]>high[x]) break;
         if(low[a]>lowest || low[a]>low[a-1]) continue;
         lowest=low[a];
         for(b=a-1;b>=0;b--)
         {
            double ab=high[b]-low[a];
            if(low[b]<low[a] || ab>bat_B_leg_to*xa)
            {
               break;
            }
            if(ab>bat_B_leg_from*xa)
            {
               for(c=b-1;c>=1;c--)
               {
                  double cb=high[b]-low[c];
                  //double ab=high[b]-low[a];
                  if(high[c]>high[b] || cb>bat_C_leg_to*ab)
                  {
                     break;
                  }
                  if(low[c]>low[c-1] || low[c]>low[c+1]) continue;
                  if(cb>bat_C_leg_from*ab)
                  {
                     double xc=high[x]-low[c];
                     for(d=c-1;d>=1;d--)
                     {
                        if(low[d]<low[c])
                        {
                           break;
                        }
                        if(high[d]<high[d-1]) continue;
                        double cd=high[d]-low[c];
                        if(cd>bat_D_leg*xc)
                        {
                           priceD=high[d];
                           if(plot_D_MidCandle)
                           priceD=low[c]+bat_D_leg*xc;
                           found=true;
                           break;
                        }
                        if(d==1)
                        {
                           priceD=low[c]+bat_D_leg*xc;
                           found=true;
                           isTemp=true;
                           break;
                        }
                     }
                  }
                  if(found) break;
               }
            }
            if(found) break;
         }
         if(found) break;
      }
     if(isTemp)
     {
         wasTemp=true;
         TriangleCreate(0,"1_temp",0,time[x],high[x],time[b],high[b],time[a],low[a],bat_color_dn);
         TriangleCreate(0,"1_1temp",0,time[b],high[b],time[d],priceD,time[c],low[c],bat_color_dn);
         target1=priceD-(priceD-low[c])*bat_target1;
         target2=priceD-(priceD-low[c])*bat_target2;
         TrendCreate(0,"1_target1temp",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,"1_target2temp",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,"1_target_linetemp",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,"1_target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,"1_target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
     }
     if(!wasTemp)
     {
      ObjectDelete("1_temp");
      ObjectDelete("1_1temp");
      ObjectDelete("1_target1temp");
      ObjectDelete("1_target2temp");
      ObjectDelete("1_target_linetemp");
     }
     if(found && !isTemp)
     {   
      if(x>prevd)
      {
         if(x-d>prevx-prevd)
         {
            TriangleCreate(0,(string)time[x],0,time[x],high[x],time[b],high[b],time[a],low[a],bat_color_dn);
            TriangleCreate(0,(string)time[x]+"1",0,time[b],high[b],time[d],priceD,time[c],low[c],bat_color_dn);  
            target1=priceD-(priceD-low[c])*bat_target1;
            target2=priceD-(priceD-low[c])*bat_target2;
            TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
            ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
            ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
            ObjectDelete((string)time[prevx]);
            ObjectDelete((string)time[prevx]+"1");
            ObjectDelete((string)time[prevx]+"target1");
            ObjectDelete((string)time[prevx]+"target2");
            ObjectDelete((string)time[prevx]+"target_line");
            prevx=x;
            prevd=d;
         }
      }
      else
      {
         TriangleCreate(0,(string)time[x],0,time[x],high[x],time[b],high[b],time[a],low[a],bat_color_dn);
         TriangleCreate(0,(string)time[x]+"1",0,time[b],high[b],time[d],priceD,time[c],low[c],bat_color_dn);
         target1=priceD-(priceD-low[c])*bat_target1;
         target2=priceD-(priceD-low[c])*bat_target2;
         TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
         prevx=x; 
         prevd=d;
      }
     }
   }
   wasTemp=false;
   prevx=0;
   prevd=0;
   for(i=limit;i>=1;i--)
   {
      if(low[i]>low[i+1] || low[i]>low[i-1]) continue;
      x=i;
      found=false;
      highest=high[x-1];
      isTemp=false;
      for(a=x-1;a>=x-how_big_first_leg_bars && a>=1;a--)
      {
         double xa=high[a]-low[x];
         if(low[a]<low[x]) break;
         if(high[a]<highest || high[a]<high[a-1]) continue;
         highest=high[a];
         for(b=a-1;b>=0;b--)
         {
            double ab=high[a]-low[b];
            if(high[b]>high[a] || ab>bat_B_leg_to*xa)
            {
               break;
            }
            if(ab>bat_B_leg_from*xa)
            {
               for(c=b-1;c>=1;c--)
               {
                  double cb=high[c]-low[b];
                  //double ab=high[a]-low[b];
                  if(low[c]<low[b] || cb>bat_C_leg_to*ab)
                  {
                     break;
                  }
                  if(high[c]<high[c-1] || high[c]<high[c+1]) continue;
                  if(cb>bat_C_leg_from*ab)
                  {
                     double xc=high[c]-low[x];
                     for(d=c-1;d>=1;d--)
                     {
                        if(high[d]>high[c])
                        {
                           break;
                        }
                        if(low[d]>low[d-1]) continue;
                        double cd=high[c]-low[d];
                        if(cd>bat_D_leg*xc)
                        {
                           priceD=low[d];
                           if(plot_D_MidCandle)
                           priceD=high[c]-bat_D_leg*xc;
                           found=true;
                           break;
                        }
                        if(d==1)
                        {
                           priceD=high[c]-bat_D_leg*xc;
                           found=true;
                           isTemp=true;
                           break;
                        }
                     }
                  }
                  if(found) break;
               }
            }
            if(found) break;
         }
         if(found) break;
      }
      
     if(isTemp)
     {
         wasTemp=true;
         TriangleCreate(0,"2_0temp",0,time[x],low[x],time[b],low[b],time[a],high[a],bat_color_up);
         TriangleCreate(0,"2_01temp",0,time[b],low[b],time[d],priceD,time[c],high[c],bat_color_up);
         target1=priceD+(high[c]-priceD)*bat_target1;
         target2=priceD+(high[c]-priceD)*bat_target2;
         TrendCreate(0,"2_target1temp",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,"2_target2temp",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,"2_target_linetemp",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,"2_target1temp",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,"2_target2temp",OBJPROP_TEXT,DoubleToString(target2,_Digits));
     }
     if(!wasTemp)
     {
      ObjectDelete("2_0temp");
      ObjectDelete("2_01temp");
      ObjectDelete("2_target1temp");
      ObjectDelete("2_target2temp");
      ObjectDelete("2_target_linetemp");
      
     }
     if(found && !isTemp)
     {   
      if(x>prevd)
      {
         if(x-d>prevx-prevd)
         {
            TriangleCreate(0,(string)time[x]+"0",0,time[x],low[x],time[b],low[b],time[a],high[a],bat_color_up);
            TriangleCreate(0,(string)time[x]+"01",0,time[b],low[b],time[d],priceD,time[c],high[c],bat_color_up);  
            target1=priceD+(high[c]-priceD)*bat_target1;
            target2=priceD+(high[c]-priceD)*bat_target2;
            TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
            ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
            ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
            ObjectDelete((string)time[prevx]+"0");
            ObjectDelete((string)time[prevx]+"01");
            ObjectDelete((string)time[prevx]+"target1");
            ObjectDelete((string)time[prevx]+"target2");
            ObjectDelete((string)time[prevx]+"target_line");
            prevx=x;
            prevd=d;
         }
      }
      else
      {
         TriangleCreate(0,(string)time[x]+"0",0,time[x],low[x],time[b],low[b],time[a],high[a],bat_color_up);
         TriangleCreate(0,(string)time[x]+"01",0,time[b],low[b],time[d],priceD,time[c],high[c],bat_color_up);
         target1=priceD+(high[c]-priceD)*bat_target1;
         target2=priceD+(high[c]-priceD)*bat_target2;
         TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
         prevx=x;
         prevd=d;
      }
     }
   }
}
else if(pattern==gartley)
{
   wasTemp=false;
   prevx=0;
   prevd=0;
   for(i=limit;i>=1;i--)
   {
      if(high[i]<high[i+1] || high[i]<high[i-1]) continue;
      x=i;
      found=false;
      lowest=low[x-1];
      isTemp=false;
      for(a=x-1;a>=x-how_big_first_leg_bars && a>=1;a--)
      {
         double xa=high[x]-low[a];
         if(high[a]>high[x]) break;
         if(low[a]>lowest || low[a]>low[a-1]) continue;
         lowest=low[a];
         for(b=a-1;b>=0;b--)
         {
            double ab=high[b]-low[a];
            if(low[b]<low[a] || ab>gartley_B_leg_to*xa)
            {
               break;
            }
            if(ab>gartley_B_leg_from*xa)
            {
               for(c=b-1;c>=1;c--)
               {
                  double cb=high[b]-low[c];
                  //double ab=high[b]-low[a];
                  if(high[c]>high[b] || cb>gartley_C_leg_to*ab)
                  {
                     break;
                  }
                  if(low[c]>low[c-1] || low[c]>low[c+1]) continue;
                  if(cb>gartley_C_leg_from*ab)
                  {
                     double xc=high[x]-low[c];
                     for(d=c-1;d>=1;d--)
                     {
                        if(low[d]<low[c])
                        {
                           break;
                        }
                        if(high[d]<high[d-1]) continue;
                        double cd=high[d]-low[c];
                        if(cd>gartley_D_leg*xc)
                        {
                           priceD=high[d];
                           if(plot_D_MidCandle)
                           priceD=low[c]+gartley_D_leg*xc;
                           found=true;
                           break;
                        }
                        if(d==1)
                        {
                           priceD=low[c]+gartley_D_leg*xc;
                           found=true;
                           isTemp=true;
                           break;
                        }
                        
                     }
                  }
                  if(found) break;
               }
            }
            if(found) break;
         }
         if(found) break;
      }
      if(isTemp)
      {
         wasTemp=true;
         TriangleCreate(0,"1_temp",0,time[x],high[x],time[b],high[b],time[a],low[a],gartley_color_dn);
         TriangleCreate(0,"1_1temp",0,time[b],high[b],time[d],priceD,time[c],low[c],gartley_color_dn);
         target1=priceD-(priceD-low[c])*gartley_target1;
         target2=priceD-(priceD-low[c])*gartley_target2;
         TrendCreate(0,"1_target1temp",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,"1_target2temp",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,"1_target_linetemp",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,"1_target1temp",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,"1_target2temp",OBJPROP_TEXT,DoubleToString(target2,_Digits));
      }
      if(!wasTemp)
      {
         ObjectDelete("1_temp");
         ObjectDelete("1_1temp");
         ObjectDelete("1_target1temp");
         ObjectDelete("1_target2temp");
         ObjectDelete("1_target_linetemp");
         
      }
     if(found && !isTemp)
     {   
      if(x>prevd)
      {
         if(x-d>prevx-prevd)
         {
            TriangleCreate(0,(string)time[x],0,time[x],high[x],time[b],high[b],time[a],low[a],gartley_color_dn);
            TriangleCreate(0,(string)time[x]+"1",0,time[b],high[b],time[d],priceD,time[c],low[c],gartley_color_dn);  
            target1=priceD-(priceD-low[c])*gartley_target1;
            target2=priceD-(priceD-low[c])*gartley_target2;
            TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
            ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
            ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
            ObjectDelete((string)time[prevx]);
            ObjectDelete((string)time[prevx]+"1");
            ObjectDelete((string)time[prevx]+"target1");
            ObjectDelete((string)time[prevx]+"target2");
            ObjectDelete((string)time[prevx]+"target_line");
            prevx=x;
            prevd=d;
         }
      }
      else
      {
         TriangleCreate(0,(string)time[x],0,time[x],high[x],time[b],high[b],time[a],low[a],gartley_color_dn);
         TriangleCreate(0,(string)time[x]+"1",0,time[b],high[b],time[d],priceD,time[c],low[c],gartley_color_dn);
         target1=priceD-(priceD-low[c])*gartley_target1;
         target2=priceD-(priceD-low[c])*gartley_target2;
         TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
         prevx=x;
         prevd=d;
      }
     }
   }
   wasTemp=false;
   prevx=0;
   prevd=0;
   for(i=limit;i>=1;i--)
   {
      if(low[i]>low[i+1] || low[i]>low[i-1]) continue;
      x=i;
     found=false;
      highest=high[x-1];
      isTemp=false;
      for(a=x-1;a>=x-how_big_first_leg_bars && a>=1;a--)
      {
         double xa=high[a]-low[x];
         if(low[a]<low[x]) break;
         if(high[a]<highest || high[a]<high[a-1]) continue;
         highest=high[a];
         for(b=a-1;b>=0;b--)
         {
            double ab=high[a]-low[b];
            if(high[b]>high[a] || ab>gartley_B_leg_to*xa)
            {
               break;
            }
            if(ab>gartley_B_leg_from*xa)
            {
               for(c=b-1;c>=1;c--)
               {
                  double cb=high[c]-low[b];
                  //double ab=high[a]-low[b];
                  if(low[c]<low[b] || cb>gartley_C_leg_to*ab)
                  {
                     break;
                  }
                  if(high[c]<high[c-1] || high[c]<high[c+1]) continue;
                  if(cb>gartley_C_leg_from*ab)
                  {
                     double xc=high[c]-low[x];
                     for(d=c-1;d>=1;d--)
                     {
                        if(high[d]>high[c])
                        {
                           break;
                        }
                        if(low[d]>low[d-1]) continue;
                        double cd=high[c]-low[d];
                        if(cd>gartley_D_leg*xc)
                        {
                           priceD=low[d];
                           if(plot_D_MidCandle)
                           priceD=high[c]-gartley_D_leg*xc;
                           found=true;
                           break;
                        }
                        if(d==1)
                        {
                           priceD=high[c]-gartley_D_leg*xc;
                           found=true;
                           isTemp=true;
                           break;
                        }
                     }
                  }
                  if(found) break;
               }
            }
            if(found) break;
         }
         if(found) break;
      }
      if(isTemp)
      {
         wasTemp=true;
         Comment(b);
         TriangleCreate(0,"2_0temp",0,time[x],low[x],time[b],low[b],time[a],high[a],gartley_color_up);
         TriangleCreate(0,"2_01temp",0,time[b],low[b],time[d],priceD,time[c],high[c],gartley_color_up);
         target1=priceD+(high[c]-priceD)*gartley_target1;
         target2=priceD+(high[c]-priceD)*gartley_target2;
         TrendCreate(0,"2_target1temp",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,"2_target2temp",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,"2_target_linetemp",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,"2_target1temp",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,"2_target2temp",OBJPROP_TEXT,DoubleToString(target2,_Digits));
      }
      if(!wasTemp)
      {
         ObjectDelete("2_0temp");
         ObjectDelete("2_01temp");
         ObjectDelete("2_target1temp");
         ObjectDelete("2_target2temp");
         ObjectDelete("2_target_linetemp");
      }
     if(found && !isTemp)
     {   
      if(x>prevd)
      {
         if(x-d>prevx-prevd)
         {
            TriangleCreate(0,(string)time[x]+"0",0,time[x],low[x],time[b],low[b],time[a],high[a],gartley_color_up);
            TriangleCreate(0,(string)time[x]+"01",0,time[b],low[b],time[d],priceD,time[c],high[c],gartley_color_up); 
            target1=priceD+(high[c]-priceD)*gartley_target1;
            target2=priceD+(high[c]-priceD)*gartley_target2;
            TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
            TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
            ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
            ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits)); 
            ObjectDelete((string)time[prevx]+"0");
            ObjectDelete((string)time[prevx]+"01");
            ObjectDelete((string)time[prevx]+"target1");
            ObjectDelete((string)time[prevx]+"target2");
            ObjectDelete((string)time[prevx]+"target_line");
            prevx=x;
            prevd=d;
         }
      }
      else
      {
         TriangleCreate(0,(string)time[x]+"0",0,time[x],low[x],time[b],low[b],time[a],high[a],gartley_color_up);
         TriangleCreate(0,(string)time[x]+"01",0,time[b],low[b],time[d],priceD,time[c],high[c],gartley_color_up);
         target1=priceD+(high[c]-priceD)*gartley_target1;
         target2=priceD+(high[c]-priceD)*gartley_target2;
         TrendCreate(0,(string)time[x]+"target1",0,time[d],target1,time[d]+_Period*60*5,target1,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target2",0,time[d],target2,time[d]+_Period*60*5,target2,target_color,STYLE_SOLID,2);
         TrendCreate(0,(string)time[x]+"target_line",0,time[d],priceD,time[d],target2,target_line_color,STYLE_SOLID,2);
         ObjectSetString(0,(string)time[x]+"target1",OBJPROP_TEXT,DoubleToString(target1,_Digits));
         ObjectSetString(0,(string)time[x]+"target2",OBJPROP_TEXT,DoubleToString(target2,_Digits));
         prevx=x;
         prevd=d;
      }
     }
   }
}
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
bool TriangleCreate(const long            chart_ID=0,        // chart's ID 
                    const string          name="Triangle",   // triangle name 
                    const int             sub_window=0,      // subwindow index  
                    datetime              time1=0,           // first point time 
                    double                price1=0,          // first point price 
                    datetime              time2=0,           // second point time 
                    double                price2=0,          // second point price 
                    datetime              time3=0,           // third point time 
                    double                price3=0,          // third point price 
                    const color           clr=clrRed,        // triangle color 
                    const ENUM_LINE_STYLE style=STYLE_SOLID, // style of triangle lines 
                    const int             width=2,           // width of triangle lines 
                    const bool            fill=true,        // filling triangle with color 
                    const bool            back=false,        // in the background 
                    const bool            selection=false,    // highlight to move 
                    const bool            hidden=false,       // hidden in the object list 
                    const long            z_order=0)         // priority for mouse click 
  { 
//--- set anchor points' coordinates if they are not set 
  // ChangeTriangleEmptyPoints(time1,price1,time2,price2,time3,price3); 
//--- reset the error value 
   ResetLastError(); 
//--- create triangle by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_TRIANGLE,sub_window,time1,price1,time2,price2,time3,price3)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a triangle! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set triangle color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,clr);
//--- set style of triangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set width of triangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of highlighting the triangle for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill_triangles);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 


bool TrendCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="TrendLine",  // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time1=0,           // first point time 
                 double                price1=0,          // first point price 
                 datetime              time2=0,           // second point time 
                 double                price2=0,          // second point price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=false,    // highlight to move 
                 const bool            ray_right=false,   // line's continuation to the right 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  { 
//--- set anchor points' coordinates if they are not set 
   //ChangeTrendEmptyPoints(time1,price1,time2,price2); 
//--- reset the error value 
   ResetLastError(); 
//--- create a trend line by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a trend line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 