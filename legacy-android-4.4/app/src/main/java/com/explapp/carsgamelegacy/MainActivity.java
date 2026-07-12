package com.explapp.carsgamelegacy;
import android.app.*;import android.os.*;import android.graphics.Color;import android.view.*;import android.widget.*;import java.util.*;
public class MainActivity extends Activity{
 LinearLayout b;TextView q,s;int score;Random r=new Random();String ans;
 public void onCreate(Bundle x){super.onCreate(x);game();}
 TextView t(String x,int z){TextView v=new TextView(this);v.setText(x);v.setTextSize(z);v.setGravity(17);v.setPadding(10,12,10,12);return v;}
 Button bt(String x){Button v=new Button(this);v.setText(x);v.setTextSize(20);v.setAllCaps(false);return v;}
 void game(){ScrollView sc=new ScrollView(this);b=new LinearLayout(this);b.setOrientation(1);b.setPadding(22,18,22,18);b.setBackgroundColor(Color.rgb(225,245,254));sc.addView(b);b.addView(t("🏁 سباق السيارات 🏁",30));s=t("النقاط: "+score,18);b.addView(s);q=t("",27);b.addView(q);round();setContentView(sc);}
 void round(){String[] a={"🚗 سيارة","🚌 حافلة","🚑 إسعاف","🚒 إطفاء"};ans=a[r.nextInt(a.length)];q.setText("اختر: "+ans);for(int i=0;i<a.length;i++){final String z=a[i];Button v=bt(z);v.setOnClickListener(new View.OnClickListener(){public void onClick(View x){if(z.equals(ans)){score++;Toast.makeText(MainActivity.this,"أحسنت!",0).show();}else Toast.makeText(MainActivity.this,"حاول من جديد",0).show();game();}});b.addView(v);}}
}