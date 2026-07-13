package com.explapp.carsgamelegacy;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.os.Bundle;
import android.os.Handler;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Random;

/** Two original low-memory arcade games rendered entirely with Android Canvas. */
public final class MainActivity extends Activity {
    private ArcadeView arcade;
    @Override public void onCreate(Bundle state){super.onCreate(state);arcade=new ArcadeView(this);setContentView(arcade);}
    @Override protected void onResume(){super.onResume();arcade.resume();}
    @Override protected void onPause(){arcade.pause();super.onPause();}
    @Override public void onBackPressed(){if(arcade.isHome())super.onBackPressed();else arcade.showHome();}

    private static final class Falling {
        float x,y,speed;int type;
        Falling(float px,float py,float v,int kind){x=px;y=py;speed=v;type=kind;}
    }

    private static final class ArcadeView extends View implements Runnable {
        private static final int HOME=0,ROAD=1,PLANE=2;
        private final Paint p=new Paint(Paint.ANTI_ALIAS_FLAG);
        private final Path path=new Path();
        private final Handler handler=new Handler();
        private final Random random=new Random();
        private final ArrayList<Falling> objects=new ArrayList<Falling>();
        private final SharedPreferences prefs;
        private int mode=HOME,score,bestRoad,bestPlane,level,spawnTick;
        private float playerX=.5f,roadOffset,fuel=100;
        private boolean running,gameOver,attached;

        ArcadeView(Context context){super(context);setFocusable(true);prefs=context.getSharedPreferences("retro_arcade_v2",0);bestRoad=prefs.getInt("road",0);bestPlane=prefs.getInt("plane",0);}
        boolean isHome(){return mode==HOME;}
        void resume(){attached=true;if(mode!=HOME&&!gameOver)running=true;schedule();}
        void pause(){attached=false;running=false;handler.removeCallbacks(this);}
        void showHome(){mode=HOME;running=false;gameOver=false;objects.clear();handler.removeCallbacks(this);((Activity)getContext()).getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);invalidate();}
        private void startGame(int selected){mode=selected;score=0;level=1;spawnTick=0;playerX=.5f;roadOffset=0;fuel=100;objects.clear();gameOver=false;running=true;((Activity)getContext()).getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);schedule();invalidate();}
        private void schedule(){handler.removeCallbacks(this);if(attached&&running)handler.postDelayed(this,16);}
        @Override public void run(){if(attached&&running){tick();invalidate();}schedule();}

        private void tick(){
            roadOffset=(roadOffset+.018f+Math.min(.018f,score/180000f))%1f;spawnTick++;level=1+score/120;
            if(mode==ROAD)tickRoad();else if(mode==PLANE)tickPlane();
        }
        private void tickRoad(){
            score++;int gap=Math.max(35,70-level*3);if(spawnTick>=gap){spawnTick=0;float[] lanes={.35f,.5f,.65f};objects.add(new Falling(lanes[random.nextInt(3)],-.12f,.007f+level*.00035f,0));}
            Iterator<Falling> it=objects.iterator();while(it.hasNext()){Falling o=it.next();o.y+=o.speed;if(o.y>1.12f){it.remove();score+=12;}else if(Math.abs(o.x-playerX)<.085f&&Math.abs(o.y-.79f)<.12f){finish();return;}}
        }
        private void tickPlane(){
            score++;fuel-=.026f+level*.0015f;if(fuel<=0){fuel=0;finish();return;}int gap=Math.max(28,58-level*2);if(spawnTick>=gap){spawnTick=0;int type=random.nextFloat()<.28f?1:2;objects.add(new Falling(.1f+random.nextFloat()*.8f,-.1f,.0065f+level*.0003f,type));}
            Iterator<Falling> it=objects.iterator();while(it.hasNext()){Falling o=it.next();o.y+=o.speed;if(o.y>1.12f)it.remove();else if(Math.abs(o.x-playerX)<.085f&&Math.abs(o.y-.76f)<.11f){if(o.type==1){fuel=Math.min(100,fuel+28);score+=45;it.remove();}else{finish();return;}}}
        }
        private void finish(){running=false;gameOver=true;if(mode==ROAD&&score>bestRoad){bestRoad=score;prefs.edit().putInt("road",bestRoad).apply();}if(mode==PLANE&&score>bestPlane){bestPlane=score;prefs.edit().putInt("plane",bestPlane).apply();}}

        @Override protected void onDraw(Canvas c){super.onDraw(c);if(mode==HOME)drawHome(c);else if(mode==ROAD)drawRoad(c);else drawPlane(c);if(gameOver)drawGameOver(c);}
        private void drawHome(Canvas c){
            float w=getWidth(),h=getHeight();c.drawColor(0xff07172d);p.setColor(0xff0c2c4e);c.drawCircle(w*.1f,h*.15f,h*.28f,p);c.drawCircle(w*.92f,h*.82f,h*.38f,p);
            label(c,"ألعاب زمان",w*.5f,h*.16f,h*.105f,Color.WHITE,true);label(c,"سيارات وطائرة بروح أركيد أصلية — تعمل دون إنترنت",w*.5f,h*.24f,h*.045f,0xffb8d8ee,false);
            RectF road=new RectF(w*.055f,h*.31f,w*.485f,h*.79f),plane=new RectF(w*.515f,h*.31f,w*.945f,h*.79f);card(c,road,0xffef6c25);card(c,plane,0xff1687c3);drawMiniCar(c,road.centerX(),road.top()+road.height()*.36f,road.height()*.23f,0xffffd34e);drawMiniPlane(c,plane.centerX(),plane.top()+plane.height()*.36f,plane.height()*.23f,0xffffffff);
            label(c,"طريق الريترو",road.centerX(),road.top()+road.height()*.72f,h*.067f,Color.WHITE,true);label(c,"الأفضل: "+bestRoad,road.centerX(),road.top()+road.height()*.88f,h*.044f,0xffffedc2,false);
            label(c,"طائرة الوقود",plane.centerX(),plane.top()+plane.height()*.72f,h*.067f,Color.WHITE,true);label(c,"الأفضل: "+bestPlane,plane.centerX(),plane.top()+plane.height()*.88f,h*.044f,0xffd9f6ff,false);
            label(c,"المس البطاقة للبدء  •  حرّك بإصبعك يميناً ويساراً",w*.5f,h*.93f,h*.043f,0xffd7e7f3,false);
        }
        private void drawRoad(Canvas c){
            float w=getWidth(),h=getHeight();c.drawColor(0xff74c8ef);p.setColor(0xff79ba62);c.drawRect(0,h*.16f,w,h,p);p.setColor(0xff30353d);path.reset();path.moveTo(w*.30f,h*.16f);path.lineTo(w*.76f,h);path.lineTo(w*.24f,h);path.lineTo(w*.70f,h*.16f);path.close();c.drawPath(path,p);
            p.setColor(0xfffff4b0);p.setStrokeWidth(Math.max(3,h*.018f));for(int lane=1;lane<=2;lane++)for(int i=-1;i<8;i++){float y=((i/7f+roadOffset)%1f)*h;float perspective=.18f+.82f*y/h;float x=w*.5f+(lane==1?-.105f:.105f)*w*perspective;c.drawLine(x,y,x,y+h*.055f*perspective,p);}
            for(Falling o:objects)drawRoadCar(c,o.x*w,o.y*h,h*.12f*(.45f+.7f*Math.max(0,o.y)),0xffe84b4b);drawRoadCar(c,playerX*w,h*.79f,h*.145f,0xffffc928);drawHud(c,"طريق الريترو",score,"اليوم "+level,-1);
        }
        private void drawPlane(Canvas c){
            float w=getWidth(),h=getHeight();c.drawColor(0xff0b5a8d);p.setColor(0x33ffffff);for(int i=0;i<5;i++){float x=((i*.23f+roadOffset)%1f)*w;c.drawOval(new RectF(x,h*(.16f+i%2*.23f),x+w*.13f,h*(.24f+i%2*.23f)),p);}p.setColor(0xff0b4269);c.drawRect(0,h*.9f,w,h,p);
            for(Falling o:objects){if(o.type==1)drawFuel(c,o.x*w,o.y*h,h*.12f);else drawHazard(c,o.x*w,o.y*h,h*.12f);}drawMiniPlane(c,playerX*w,h*.76f,h*.16f,0xffffd34e);drawHud(c,"طائرة الوقود",score,"المستوى "+level,fuel);
        }
        private void drawHud(Canvas c,String title,int points,String extra,float fuelValue){float w=getWidth(),h=getHeight();p.setColor(0xaa061a2c);c.drawRoundRect(new RectF(w*.02f,h*.025f,w*.98f,h*.14f),h*.035f,h*.035f,p);label(c,title,w*.16f,h*.105f,h*.055f,Color.WHITE,true);label(c,"النقاط "+points,w*.50f,h*.105f,h*.051f,0xffffd65c,true);label(c,extra,w*.82f,h*.105f,h*.047f,0xffd8ecf7,true);if(fuelValue>=0){p.setColor(0xff263b4c);c.drawRoundRect(new RectF(w*.72f,h*.16f,w*.96f,h*.205f),12,12,p);p.setColor(fuelValue<25?0xffef4444:0xff34d16f);c.drawRoundRect(new RectF(w*.72f,h*.16f,w*(.72f+.24f*fuelValue/100f),h*.205f),12,12,p);label(c,"وقود",w*.67f,h*.202f,h*.036f,Color.WHITE,true);}}
        private void drawGameOver(Canvas c){float w=getWidth(),h=getHeight();p.setColor(0xdd07172d);c.drawRoundRect(new RectF(w*.22f,h*.22f,w*.78f,h*.82f),h*.06f,h*.06f,p);label(c,"انتهت الجولة",w*.5f,h*.39f,h*.085f,Color.WHITE,true);label(c,"النتيجة: "+score,w*.5f,h*.52f,h*.061f,0xffffd65c,true);p.setColor(0xff1687c3);c.drawRoundRect(new RectF(w*.27f,h*.63f,w*.48f,h*.76f),20,20,p);p.setColor(0xffef6c25);c.drawRoundRect(new RectF(w*.52f,h*.63f,w*.73f,h*.76f),20,20,p);label(c,"الرئيسية",w*.375f,h*.72f,h*.047f,Color.WHITE,true);label(c,"إعادة",w*.625f,h*.72f,h*.047f,Color.WHITE,true);}

        private void card(Canvas c,RectF r,int color){p.setColor(0x44000000);c.drawRoundRect(new RectF(r.left,r.top+8,r.right,r.bottom+8),24,24,p);p.setColor(color);c.drawRoundRect(r,24,24,p);}
        private void drawRoadCar(Canvas c,float x,float y,float size,int color){p.setColor(0x55000000);c.drawRoundRect(new RectF(x-size*.38f,y-size*.43f+7,x+size*.38f,y+size*.43f+7),size*.1f,size*.1f,p);p.setColor(color);c.drawRoundRect(new RectF(x-size*.38f,y-size*.43f,x+size*.38f,y+size*.43f),size*.1f,size*.1f,p);p.setColor(0xffbfe9ff);c.drawRect(x-size*.25f,y-size*.26f,x+size*.25f,y-size*.02f,p);p.setColor(0xff20252b);c.drawRect(x-size*.46f,y-size*.28f,x-size*.36f,y+size*.27f,p);c.drawRect(x+size*.36f,y-size*.28f,x+size*.46f,y+size*.27f,p);}
        private void drawMiniCar(Canvas c,float x,float y,float size,int color){drawRoadCar(c,x,y,size,color);}
        private void drawMiniPlane(Canvas c,float x,float y,float size,int color){p.setColor(0x44000000);path.reset();path.moveTo(x,y-size*.52f+6);path.lineTo(x+size*.18f,y+size*.22f+6);path.lineTo(x+size*.52f,y+size*.42f+6);path.lineTo(x+size*.08f,y+size*.32f+6);path.lineTo(x,y+size*.52f+6);path.lineTo(x-size*.08f,y+size*.32f+6);path.lineTo(x-size*.52f,y+size*.42f+6);path.lineTo(x-size*.18f,y+size*.22f+6);path.close();c.drawPath(path,p);p.setColor(color);c.translate(0,-6);c.drawPath(path,p);c.translate(0,6);p.setColor(0xff1687c3);c.drawCircle(x,y-size*.13f,size*.09f,p);}
        private void drawFuel(Canvas c,float x,float y,float size){p.setColor(0xff34d16f);c.drawRoundRect(new RectF(x-size*.34f,y-size*.42f,x+size*.34f,y+size*.42f),size*.08f,size*.08f,p);label(c,"F",x,y+size*.18f,size*.48f,Color.WHITE,true);}
        private void drawHazard(Canvas c,float x,float y,float size){p.setColor(0xffe84b4b);path.reset();path.moveTo(x,y-size*.46f);path.lineTo(x+size*.46f,y+size*.4f);path.lineTo(x-size*.46f,y+size*.4f);path.close();c.drawPath(path,p);label(c,"!",x,y+size*.22f,size*.55f,Color.WHITE,true);}
        private void label(Canvas c,String value,float x,float y,float size,int color,boolean bold){p.setTextAlign(Paint.Align.CENTER);p.setTextSize(size);p.setColor(color);p.setFakeBoldText(bold);c.drawText(value,x,y,p);p.setFakeBoldText(false);}

        @Override public boolean onTouchEvent(MotionEvent e){
            if(e.getAction()!=MotionEvent.ACTION_DOWN&&e.getAction()!=MotionEvent.ACTION_MOVE)return true;float x=e.getX()/Math.max(1,getWidth()),y=e.getY()/Math.max(1,getHeight());
            if(mode==HOME&&e.getAction()==MotionEvent.ACTION_DOWN){if(y>.29f&&y<.82f)startGame(x<.5f?ROAD:PLANE);return true;}
            if(gameOver&&e.getAction()==MotionEvent.ACTION_DOWN){if(y>.58f){if(x<.5f)showHome();else startGame(mode);}return true;}
            if(running){playerX=Math.max(mode==ROAD?.29f:.07f,Math.min(mode==ROAD?.71f:.93f,x));invalidate();}return true;
        }
    }
}
