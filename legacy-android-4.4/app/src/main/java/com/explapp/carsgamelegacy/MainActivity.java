package com.explapp.carsgamelegacy;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Shader;
import android.graphics.Typeface;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.os.Bundle;
import android.os.Handler;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Random;

/**
 * Professional low-memory native arcade for Android 4.4.
 * Two complete games: Endurance Road and Fuel Plane.
 */
public final class MainActivity extends Activity {
    private ArcadeView arcade;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        arcade = new ArcadeView(this);
        setContentView(arcade);
    }

    @Override protected void onResume() { super.onResume(); arcade.resume(); }
    @Override protected void onPause() { arcade.pause(); super.onPause(); }
    @Override public void onBackPressed() { if (arcade.isHome()) super.onBackPressed(); else arcade.showHome(); }

    private static final class Falling {
        float x, y, speed;
        int type, lane, color;
        Falling(float px, float py, float velocity, int kind) {
            x=px; y=py; speed=velocity; type=kind;
        }
    }

    private static final class Bullet {
        float x, y;
        Bullet(float px, float py) { x=px; y=py; }
    }

    private static final class ArcadeView extends View implements Runnable {
        private static final int HOME=0, ROAD=1, PLANE=2;
        private static final int SKY=0xff07172d, CYAN=0xff28c7d9, ORANGE=0xffff7a32;
        private final Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
        private final Path path = new Path();
        private final Handler handler = new Handler();
        private final Random random = new Random();
        private final ArrayList<Falling> objects = new ArrayList<Falling>();
        private final ArrayList<Bullet> bullets = new ArrayList<Bullet>();
        private final SharedPreferences prefs;
        private final ToneGenerator tones;

        private int mode=HOME, score, bestRoad, bestPlane, level, tick, lives;
        private int lane=2, passed, target, weather, crashFlash;
        private float playerX=.5f, playerY=.79f, roadOffset, fuel=100, throttle=.56f;
        private boolean running, gameOver, attached, stopped, soundOn=true, lowFuelWarned;

        ArcadeView(Context context) {
            super(context);
            setFocusable(true);
            setKeepScreenOn(false);
            prefs=context.getSharedPreferences("retro_arcade_v3",0);
            bestRoad=prefs.getInt("road",0);
            bestPlane=prefs.getInt("plane",0);
            soundOn=prefs.getBoolean("sound",true);
            tones=new ToneGenerator(AudioManager.STREAM_MUSIC,26);
            setContentDescription("ألعاب زمان: طريق التحمل وطائرة الوقود");
        }

        boolean isHome(){return mode==HOME;}

        void resume() {
            attached=true;
            if(mode!=HOME&&!gameOver&&!stopped)running=true;
            schedule();
        }

        void pause() {
            attached=false;
            running=false;
            handler.removeCallbacks(this);
        }

        void showHome() {
            mode=HOME; running=false; gameOver=false; stopped=false;
            objects.clear(); bullets.clear(); handler.removeCallbacks(this);
            ((Activity)getContext()).getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            invalidate();
        }

        private void startGame(int selected) {
            mode=selected; score=0; level=1; tick=0; lives=3; passed=0; target=40;
            lane=2; playerX=.5f; playerY=.79f; roadOffset=0; fuel=100; throttle=.56f;
            weather=0; crashFlash=0; lowFuelWarned=false;
            objects.clear(); bullets.clear(); gameOver=false; stopped=false; running=true;
            ((Activity)getContext()).getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            beep(true); schedule(); invalidate();
        }

        private void schedule() {
            handler.removeCallbacks(this);
            if(attached&&running)handler.postDelayed(this,33);
        }

        @Override public void run() {
            if(attached&&running){tick();invalidate();}
            schedule();
        }

        private void tick() {
            tick++;
            roadOffset=(roadOffset+.012f+throttle*.012f)%1f;
            if(crashFlash>0)crashFlash--;
            if(mode==ROAD)tickRoad();else if(mode==PLANE)tickPlane();
        }

        private void tickRoad() {
            int gap=Math.max(18,48-level*2-(int)(throttle*8));
            if(tick%gap==0&&objects.size()<7){
                Falling car=new Falling(0,-.08f,.0044f+level*.00035f+throttle*.0036f,0);
                car.lane=random.nextInt(5);
                car.color=roadColor(random.nextInt(5));
                boolean blocked=false;
                for(Falling o:objects)if(o.lane==car.lane&&o.y<.22f)blocked=true;
                if(!blocked)objects.add(car);
            }
            if(tick%8==0)score+=1+(int)(throttle*2);
            Iterator<Falling> it=objects.iterator();
            while(it.hasNext()){
                Falling o=it.next();o.y+=o.speed;
                if(o.y>1.09f){it.remove();passed++;score+=80+(int)(throttle*45);beep(false);}
                else if(o.lane==lane&&o.y>.72f&&o.y<.94f){it.remove();crash();return;}
            }
            if(passed>=target){
                passed=0;level++;target=Math.min(90,target+10);weather=(weather+1)%6;
                objects.clear();score+=700;success();
            }
        }

        private void tickPlane() {
            level=1+tick/1200;
            fuel-=.019f+throttle*.029f;
            if(fuel<23&&!lowFuelWarned){lowFuelWarned=true;warning();}
            if(fuel>30)lowFuelWarned=false;
            if(fuel<=0){fuel=0;crashFinal();return;}

            if(tick%10==0)bullets.add(new Bullet(playerX,playerY-.075f));
            Iterator<Bullet> bit=bullets.iterator();
            while(bit.hasNext()){Bullet b=bit.next();b.y-=.035f+throttle*.012f;if(b.y<-.06f)bit.remove();}

            int gap=Math.max(14,32-level-(int)(throttle*5));
            if(tick%gap==0&&objects.size()<11){
                float roll=random.nextFloat();
                int type=roll<.12f?1:roll<.72f?2:roll<.88f?3:4;
                objects.add(new Falling(.08f+random.nextFloat()*.84f,-.08f,.0045f+random.nextFloat()*.0025f+throttle*.0032f,type));
            }

            Iterator<Falling> it=objects.iterator();
            while(it.hasNext()){
                Falling o=it.next();o.y+=o.speed;
                if(o.y>1.10f){it.remove();continue;}
                boolean shot=false;
                if(o.type==2){
                    Iterator<Bullet> shots=bullets.iterator();
                    while(shots.hasNext()){
                        Bullet b=shots.next();
                        if(Math.abs(b.x-o.x)<.045f&&Math.abs(b.y-o.y)<.055f){
                            shots.remove();shot=true;score+=75;success();break;
                        }
                    }
                }
                if(shot){it.remove();continue;}
                if(Math.abs(o.x-playerX)<.062f&&Math.abs(o.y-playerY)<.075f){
                    if(o.type==1){fuel=Math.min(100,fuel+25);score+=130;it.remove();success();}
                    else if(o.type==4){score+=180;it.remove();success();}
                    else if(o.type==3){it.remove();}
                    else{it.remove();crash();return;}
                }
            }
            if(tick%8==0)score+=1+(int)(throttle*2);
        }

        private void crash() {
            crashFlash=14;running=false;
            if(lives>1){
                lives--;stopped=true;throttle=Math.max(.32f,throttle-.16f);
                if(mode==PLANE)fuel=Math.max(25,fuel);
                warning();
            }else crashFinal();
            saveBest();
        }

        private void crashFinal() {
            lives=0;running=false;stopped=false;gameOver=true;crashFlash=16;
            warning();saveBest();
        }

        private void continueGame() {
            stopped=false;running=true;objects.clear();bullets.clear();crashFlash=0;
            schedule();beep(true);invalidate();
        }

        private void saveBest() {
            if(mode==ROAD&&score>bestRoad){bestRoad=score;prefs.edit().putInt("road",bestRoad).apply();}
            if(mode==PLANE&&score>bestPlane){bestPlane=score;prefs.edit().putInt("plane",bestPlane).apply();}
        }

        private int roadColor(int index) {
            int[] colors={0xffef4444,0xffffca3a,0xff22c55e,0xffa78bfa,0xffff7a32};
            return colors[index%colors.length];
        }

        private void beep(boolean start) {
            if(soundOn)tones.startTone(start?ToneGenerator.TONE_PROP_ACK:ToneGenerator.TONE_PROP_BEEP,start?110:35);
        }
        private void success(){if(soundOn)tones.startTone(ToneGenerator.TONE_PROP_BEEP2,55);}
        private void warning(){if(soundOn)tones.startTone(ToneGenerator.TONE_PROP_NACK,120);}

        @Override protected void onDetachedFromWindow() {
            handler.removeCallbacks(this);tones.release();super.onDetachedFromWindow();
        }

        @Override protected void onDraw(Canvas c) {
            super.onDraw(c);
            if(mode==HOME)drawHome(c);else if(mode==ROAD)drawRoad(c);else drawPlane(c);
            if(stopped)drawPauseCard(c);else if(gameOver)drawGameOver(c);
        }

        private void drawHome(Canvas c) {
            float w=getWidth(),h=getHeight();
            p.setShader(new LinearGradient(0,0,w,h,0xff020617,0xff0b3654,Shader.TileMode.CLAMP));
            c.drawRect(0,0,w,h,p);p.setShader(null);
            p.setColor(0x2238bdf8);c.drawCircle(w*.08f,h*.18f,h*.28f,p);
            p.setColor(0x22f97316);c.drawCircle(w*.94f,h*.86f,h*.38f,p);

            label(c,"ألعاب زمان",w*.5f,h*.13f,h*.085f,Color.WHITE,true);
            label(c,"تحديات أركيد كاملة وخفيفة — تعمل دون إنترنت",w*.5f,h*.205f,h*.036f,0xffb9d9eb,false);

            RectF road=new RectF(w*.055f,h*.27f,w*.485f,h*.82f);
            RectF plane=new RectF(w*.515f,h*.27f,w*.945f,h*.82f);
            homeCard(c,road,ORANGE,0xff9a3412);
            homeCard(c,plane,0xff1687c3,0xff075985);
            drawRoadPreview(c,road);
            drawPlanePreview(c,plane);

            label(c,"طريق التحمل",road.centerX(),road.top+road.height()*.72f,h*.055f,Color.WHITE,true);
            label(c,"5 مسارات • مراحل وطقس • 3 أرواح",road.centerX(),road.top+road.height()*.82f,h*.030f,0xffffe4cf,false);
            label(c,"الأفضل  "+bestRoad,road.centerX(),road.top+road.height()*.92f,h*.032f,0xffffd27a,true);

            label(c,"طائرة الوقود",plane.centerX(),plane.top+plane.height()*.72f,h*.055f,Color.WHITE,true);
            label(c,"إطلاق تلقائي • وقود ومكافآت • 3 أرواح",plane.centerX(),plane.top+plane.height()*.82f,h*.030f,0xffd7f5ff,false);
            label(c,"الأفضل  "+bestPlane,plane.centerX(),plane.top+plane.height()*.92f,h*.032f,0xff9de9ff,true);

            p.setColor(0x44ffffff);c.drawRoundRect(new RectF(w*.40f,h*.875f,w*.60f,h*.96f),h*.025f,h*.025f,p);
            label(c,soundOn?"الصوت يعمل":"الصوت متوقف",w*.5f,h*.93f,h*.030f,Color.WHITE,true);
        }

        private void homeCard(Canvas c,RectF r,int top,int bottom) {
            p.setColor(0x55000000);c.drawRoundRect(new RectF(r.left,r.top+8,r.right,r.bottom+8),hRadius(r),hRadius(r),p);
            p.setShader(new LinearGradient(r.left,r.top,r.right,r.bottom,top,bottom,Shader.TileMode.CLAMP));
            c.drawRoundRect(r,hRadius(r),hRadius(r),p);p.setShader(null);
            p.setStyle(Paint.Style.STROKE);p.setStrokeWidth(2);p.setColor(0x55ffffff);c.drawRoundRect(r,hRadius(r),hRadius(r),p);p.setStyle(Paint.Style.FILL);
        }

        private float hRadius(RectF r){return Math.min(r.width(),r.height())*.08f;}

        private void drawRoadPreview(Canvas c,RectF r) {
            float top=r.top+r.height()*.10f,bottom=r.top+r.height()*.60f,cx=r.centerX();
            p.setColor(0xff27303b);path.reset();path.moveTo(cx-r.width()*.10f,top);path.lineTo(cx+r.width()*.10f,top);path.lineTo(cx+r.width()*.38f,bottom);path.lineTo(cx-r.width()*.38f,bottom);path.close();c.drawPath(path,p);
            p.setColor(0xfffff3a8);p.setStrokeWidth(3);
            for(int i=-1;i<=1;i++){float x=cx+i*r.width()*.12f;c.drawLine(x,top+10,x,bottom-8,p);}
            drawCar(c,cx,bottom-r.height()*.06f,r.height()*.20f,0xffffd43b,false);
        }

        private void drawPlanePreview(Canvas c,RectF r) {
            for(int i=0;i<4;i++){p.setColor(0x28ffffff);c.drawCircle(r.left+r.width()*(.2f+i*.2f),r.top+r.height()*(.2f+(i%2)*.13f),r.height()*.06f,p);}
            drawJet(c,r.centerX(),r.top+r.height()*.43f,r.height()*.27f,0xffffd43b);
        }

        private void drawRoad(Canvas c) {
            float w=getWidth(),h=getHeight();
            drawWeatherSky(c,w,h);
            p.setColor(weather==4?0xffe8eef5:weather==5?0xff0f3b25:0xff2e8c4b);c.drawRect(0,h*.34f,w,h,p);
            drawMountains(c,w,h);

            path.reset();path.moveTo(w*.465f,h*.33f);path.lineTo(w*.535f,h*.33f);path.lineTo(w*1.03f,h);path.lineTo(-w*.03f,h);path.close();
            p.setShader(new LinearGradient(0,h*.33f,0,h,weather==2?0xff181b24:0xff50545b,0xff14171c,Shader.TileMode.CLAMP));
            c.drawPath(path,p);p.setShader(null);

            for(int i=0;i<16;i++){
                float d=((i/16f+roadOffset)%1f);float y=h*(.34f+.69f*d*d);float rw=w*(.04f+.98f*d*d);
                p.setColor((i%2==0)?0xffffffff:0xffef4444);
                c.drawRect(w*.5f-rw*.51f,y,w*.5f-rw*.47f,y+3+d*8,p);
                c.drawRect(w*.5f+rw*.47f,y,w*.5f+rw*.51f,y+3+d*8,p);
                if(i%2==0){p.setColor(0xccffffff);c.drawRect(w*.5f-2-d*3,y,w*.5f+2+d*3,y+8+d*30,p);}
            }

            for(Falling o:objects){
                float d=Math.max(0,o.y),y=h*(.34f+.60f*d),x=laneX(w,o.lane,d);
                drawCar(c,x,y,h*(.045f+.10f*d),o.color,true);
            }
            drawCar(c,laneX(w,lane,.9f),h*.84f,h*.17f,0xff38bdf8,false);
            drawRoadHud(c,w,h);
            drawWeatherFx(c,w,h);
            drawControls(c,w,h);
            drawCrashFx(c,w,h,laneX(w,lane,.9f),h*.82f);
        }

        private float laneX(float w,int laneValue,float depth) {
            float roadWidth=w*(.08f+.86f*depth);
            return w*.5f-roadWidth*.5f+roadWidth*((laneValue+.5f)/5f);
        }

        private void drawWeatherSky(Canvas c,float w,float h) {
            int top,bottom;
            if(weather==1){top=0xff3b0b5b;bottom=0xffff7a32;}
            else if(weather==2){top=0xff020617;bottom=0xff172033;}
            else if(weather==3){top=0xff657687;bottom=0xffcbd5e1;}
            else if(weather==4){top=0xff8fc7ef;bottom=0xffe7f5ff;}
            else if(weather==5){top=0xff07111f;bottom=0xff465a68;}
            else{top=0xff0284c7;bottom=0xff8ce0f2;}
            p.setShader(new LinearGradient(0,0,0,h*.45f,top,bottom,Shader.TileMode.CLAMP));c.drawRect(0,0,w,h*.45f,p);p.setShader(null);
            if(weather==2){p.setColor(0xfff6f2d0);c.drawCircle(w*.80f,h*.13f,h*.055f,p);}
            else{p.setColor(0xfffff2a6);c.drawCircle(w*.80f,h*.15f,h*.065f,p);}
        }

        private void drawMountains(Canvas c,float w,float h) {
            p.setColor(weather==2?0xff10192b:0x55334e68);
            path.reset();path.moveTo(0,h*.35f);path.lineTo(w*.14f,h*.21f);path.lineTo(w*.31f,h*.35f);path.lineTo(w*.51f,h*.19f);path.lineTo(w*.72f,h*.35f);path.lineTo(w*.90f,h*.23f);path.lineTo(w,h*.35f);path.close();c.drawPath(path,p);
        }

        private void drawRoadHud(Canvas c,float w,float h) {
            p.setColor(0xcc020617);c.drawRoundRect(new RectF(w*.02f,h*.025f,w*.98f,h*.155f),h*.035f,h*.035f,p);
            hudCell(c,"النقاط",String.valueOf(score),w*.12f,h);
            hudCell(c,"السرعة",String.valueOf(70+(int)(throttle*170)),w*.31f,h);
            hudCell(c,"الأرواح",String.valueOf(lives),w*.50f,h);
            hudCell(c,"المرحلة",String.valueOf(level),w*.69f,h);
            hudCell(c,"التجاوز",passed+"/"+target,w*.88f,h);
            p.setColor(0xff1f2937);c.drawRoundRect(new RectF(w*.38f,h*.18f,w*.62f,h*.205f),8,8,p);
            p.setColor(CYAN);c.drawRoundRect(new RectF(w*.38f,h*.18f,w*(.38f+.24f*passed/Math.max(1,target)),h*.205f),8,8,p);
        }

        private void drawPlane(Canvas c) {
            float w=getWidth(),h=getHeight();
            p.setShader(new LinearGradient(0,0,0,h,0xff020617,0xff087ca0,Shader.TileMode.CLAMP));c.drawRect(0,0,w,h,p);p.setShader(null);
            drawRiver(c,w,h);
            for(int i=0;i<20;i++){float x=((i*.17f+roadOffset)%1f)*w;float y=((i*.11f+roadOffset*2)%1f)*h;p.setColor(0x24ffffff);c.drawLine(x,y,x,y+h*.07f,p);}

            for(Bullet b:bullets){p.setColor(0xfffff176);c.drawCircle(b.x*w,b.y*h,h*.009f,p);}
            for(Falling o:objects){
                float x=o.x*w,y=o.y*h,s=h*.10f;
                if(o.type==1)drawFuel(c,x,y,s);
                else if(o.type==2)drawEnemy(c,x,y,s);
                else if(o.type==3)drawCloud(c,x,y,s);
                else drawBonus(c,x,y,s);
            }
            drawJet(c,playerX*w,playerY*h,h*.17f,0xff38bdf8);
            drawPlaneHud(c,w,h);drawControls(c,w,h);drawCrashFx(c,w,h,playerX*w,playerY*h);
        }

        private void drawRiver(Canvas c,float w,float h) {
            p.setColor(0xff14532d);c.drawRect(0,0,w,h,p);
            path.reset();path.moveTo(w*.28f,0);path.cubicTo(w*.08f,h*.25f,w*.42f,h*.46f,w*.20f,h*.70f);path.lineTo(w*.08f,h);path.lineTo(w*.92f,h);path.cubicTo(w*.82f,h*.74f,w*.94f,h*.55f,w*.74f,h*.36f);path.lineTo(w*.72f,0);path.close();
            p.setShader(new LinearGradient(0,0,0,h,0xff155e75,0xff0891b2,Shader.TileMode.CLAMP));c.drawPath(path,p);p.setShader(null);
            for(int i=0;i<12;i++){float y=((i*.13f+roadOffset)%1f)*h;p.setColor(0xff226b3b);c.drawRoundRect(new RectF(0,y,w*.12f,y+h*.035f),8,8,p);c.drawRoundRect(new RectF(w*.88f,y+h*.05f,w,y+h*.085f),8,8,p);}
        }

        private void drawPlaneHud(Canvas c,float w,float h) {
            p.setColor(0xcc020617);c.drawRoundRect(new RectF(w*.02f,h*.025f,w*.98f,h*.155f),h*.035f,h*.035f,p);
            hudCell(c,"النقاط",String.valueOf(score),w*.12f,h);
            hudCell(c,"السرعة",String.valueOf(70+(int)(throttle*170)),w*.31f,h);
            hudCell(c,"الأرواح",String.valueOf(lives),w*.50f,h);
            hudCell(c,"المرحلة",String.valueOf(level),w*.69f,h);
            hudCell(c,"الوقود",(int)fuel+"%",w*.88f,h);
            p.setColor(0xff273647);c.drawRoundRect(new RectF(w*.78f,h*.18f,w*.96f,h*.205f),8,8,p);
            p.setColor(fuel<25?0xffef4444:0xff34d16f);c.drawRoundRect(new RectF(w*.78f,h*.18f,w*(.78f+.18f*fuel/100f),h*.205f),8,8,p);
        }

        private void hudCell(Canvas c,String name,String value,float x,float h) {
            label(c,name,x,h*.072f,h*.027f,0xff9fb8c8,false);
            label(c,value,x,h*.127f,h*.042f,Color.WHITE,true);
        }

        private void drawControls(Canvas c,float w,float h) {
            p.setColor(0x99020717);c.drawRoundRect(new RectF(w*.87f,h*.38f,w*.98f,h*.72f),h*.025f,h*.025f,p);
            label(c,"+",w*.925f,h*.47f,h*.060f,CYAN,true);
            p.setColor(0xff26394a);c.drawRoundRect(new RectF(w*.91f,h*.50f,w*.94f,h*.64f),8,8,p);
            p.setColor(CYAN);float fill=h*.14f*throttle;c.drawRoundRect(new RectF(w*.91f,h*.64f-fill,w*.94f,h*.64f),8,8,p);
            label(c,"−",w*.925f,h*.70f,h*.060f,ORANGE,true);
        }

        private void drawWeatherFx(Canvas c,float w,float h) {
            if(weather==3){p.setColor(0x88ffffff);c.drawRect(0,0,w,h,p);}
            else if(weather==4){for(int i=0;i<55;i++){float x=(i*67+tick)%Math.max(1,(int)w);float y=(i*43+tick*2)%Math.max(1,(int)h);p.setColor(0xddffffff);c.drawCircle(x,y,2+(i%2),p);}}
            else if(weather==5){for(int i=0;i<65;i++){float x=(i*61+tick*2)%Math.max(1,(int)w);float y=(i*47+tick*5)%Math.max(1,(int)h);p.setColor(0xaa9bd6ff);p.setStrokeWidth(2);c.drawLine(x,y,x-7,y+18,p);}}
            else if(weather==2){p.setColor(0x44000000);c.drawRect(0,0,w,h,p);}
        }

        private void drawCrashFx(Canvas c,float w,float h,float x,float y) {
            if(crashFlash<=0)return;
            float alpha=crashFlash/16f;p.setColor((int)(0x55*alpha)<<24|0x00ff3300);c.drawRect(0,0,w,h,p);
            p.setColor(0xffffb020);p.setStrokeWidth(3);
            for(int i=0;i<12;i++){double a=i*Math.PI/6;c.drawLine(x,y,x+(float)Math.cos(a)*h*.10f,y+(float)Math.sin(a)*h*.10f,p);}
        }

        private void drawPauseCard(Canvas c) {
            float w=getWidth(),h=getHeight();p.setColor(0xdd020617);c.drawRoundRect(new RectF(w*.27f,h*.22f,w*.73f,h*.82f),h*.06f,h*.06f,p);
            p.setStyle(Paint.Style.STROKE);p.setStrokeWidth(2);p.setColor(0x88ff7a32);c.drawRoundRect(new RectF(w*.27f,h*.22f,w*.73f,h*.82f),h*.06f,h*.06f,p);p.setStyle(Paint.Style.FILL);
            label(c,"اصطدام",w*.5f,h*.39f,h*.078f,0xffff8a5b,true);
            label(c,"تبقى لديك "+lives+" أرواح",w*.5f,h*.51f,h*.044f,Color.WHITE,true);
            p.setColor(CYAN);c.drawRoundRect(new RectF(w*.37f,h*.61f,w*.63f,h*.75f),h*.025f,h*.025f,p);
            label(c,"متابعة",w*.5f,h*.70f,h*.045f,Color.WHITE,true);
        }

        private void drawGameOver(Canvas c) {
            float w=getWidth(),h=getHeight();p.setColor(0xe8020617);c.drawRoundRect(new RectF(w*.24f,h*.18f,w*.76f,h*.86f),h*.06f,h*.06f,p);
            label(c,"انتهت الجولة",w*.5f,h*.36f,h*.082f,0xffff6b6b,true);
            label(c,"النتيجة  "+score,w*.5f,h*.49f,h*.052f,0xffffd65c,true);
            p.setColor(0xff1687c3);c.drawRoundRect(new RectF(w*.28f,h*.64f,w*.48f,h*.79f),20,20,p);
            p.setColor(ORANGE);c.drawRoundRect(new RectF(w*.52f,h*.64f,w*.72f,h*.79f),20,20,p);
            label(c,"الرئيسية",w*.38f,h*.74f,h*.038f,Color.WHITE,true);
            label(c,"إعادة",w*.62f,h*.74f,h*.038f,Color.WHITE,true);
        }

        private void drawCar(Canvas c,float x,float y,float size,int color,boolean opponent) {
            p.setColor(0x55000000);c.drawRoundRect(new RectF(x-size*.54f,y-size*.35f+7,x+size*.54f,y+size*.42f+7),size*.18f,size*.18f,p);
            p.setColor(color);path.reset();path.moveTo(x-size*.52f,y+size*.28f);path.quadTo(x-size*.46f,y-size*.22f,x-size*.22f,y-size*.39f);path.quadTo(x,y-size*.50f,x+size*.22f,y-size*.39f);path.quadTo(x+size*.46f,y-size*.22f,x+size*.52f,y+size*.28f);path.lineTo(x+size*.40f,y+size*.42f);path.lineTo(x-size*.40f,y+size*.42f);path.close();c.drawPath(path,p);
            p.setColor(0xffcceeff);c.drawRoundRect(new RectF(x-size*.22f,y-size*.31f,x+size*.22f,y-size*.05f),size*.08f,size*.08f,p);
            p.setColor(0xff070b12);c.drawRoundRect(new RectF(x-size*.62f,y-size*.10f,x-size*.47f,y+size*.30f),4,4,p);c.drawRoundRect(new RectF(x+size*.47f,y-size*.10f,x+size*.62f,y+size*.30f),4,4,p);
            p.setColor(opponent?0xfffff176:0xffef4444);c.drawRect(x-size*.35f,y+size*.28f,x-size*.12f,y+size*.36f,p);c.drawRect(x+size*.12f,y+size*.28f,x+size*.35f,y+size*.36f,p);
        }

        private void drawJet(Canvas c,float x,float y,float size,int color) {
            p.setColor(0x44000000);c.drawOval(new RectF(x-size*.55f,y+size*.28f,x+size*.55f,y+size*.55f),p);
            p.setColor(color);path.reset();path.moveTo(x,y-size*.62f);path.lineTo(x-size*.18f,y+size*.42f);path.lineTo(x+size*.18f,y+size*.42f);path.close();c.drawPath(path,p);
            p.setColor(0xff2563eb);path.reset();path.moveTo(x-size*.15f,y);path.lineTo(x-size*.78f,y+size*.28f);path.lineTo(x-size*.10f,y+size*.31f);path.close();c.drawPath(path,p);path.reset();path.moveTo(x+size*.15f,y);path.lineTo(x+size*.78f,y+size*.28f);path.lineTo(x+size*.10f,y+size*.31f);path.close();c.drawPath(path,p);
            p.setColor(0xffdff5ff);c.drawCircle(x,y-size*.38f,size*.10f,p);
        }

        private void drawFuel(Canvas c,float x,float y,float s) {
            p.setColor(0xffffc93b);c.drawRoundRect(new RectF(x-s*.32f,y-s*.43f,x+s*.32f,y+s*.43f),s*.10f,s*.10f,p);
            p.setColor(0xffe84b4b);c.drawRect(x-s*.10f,y-s*.24f,x+s*.10f,y+s*.24f,p);
            label(c,"GAS",x,y+s*.10f,s*.22f,Color.WHITE,true);
        }

        private void drawEnemy(Canvas c,float x,float y,float s) {
            p.setColor(0xff94a3b8);path.reset();path.moveTo(x,y+s*.48f);path.lineTo(x-s*.18f,y-s*.38f);path.lineTo(x+s*.18f,y-s*.38f);path.close();c.drawPath(path,p);
            p.setColor(0xff334155);c.drawRect(x-s*.48f,y-s*.05f,x+s*.48f,y+s*.17f,p);
            p.setColor(0xffef4444);c.drawCircle(x,y+s*.26f,s*.06f,p);
        }

        private void drawCloud(Canvas c,float x,float y,float s){p.setColor(0x99ffffff);c.drawCircle(x-s*.22f,y,s*.22f,p);c.drawCircle(x,y-s*.10f,s*.29f,p);c.drawCircle(x+s*.25f,y+s*.02f,s*.20f,p);}
        private void drawBonus(Canvas c,float x,float y,float s){p.setColor(0xffffd43b);c.drawCircle(x,y,s*.25f,p);p.setColor(0xffff8a00);c.drawCircle(x,y,s*.13f,p);}

        private void label(Canvas c,String value,float x,float y,float size,int color,boolean bold) {
            p.setTextAlign(Paint.Align.CENTER);p.setTextSize(size);p.setColor(color);p.setTypeface(bold?Typeface.DEFAULT_BOLD:Typeface.DEFAULT);c.drawText(value,x,y,p);
        }

        @Override public boolean onTouchEvent(MotionEvent e) {
            float x=e.getX()/Math.max(1,getWidth()),y=e.getY()/Math.max(1,getHeight());
            if(e.getAction()==MotionEvent.ACTION_DOWN){
                if(mode==HOME){
                    if(y>.84f&&x>.38f&&x<.62f){soundOn=!soundOn;prefs.edit().putBoolean("sound",soundOn).apply();beep(true);invalidate();}
                    else if(y>.25f&&y<.84f)startGame(x<.5f?ROAD:PLANE);
                    return true;
                }
                if(stopped){continueGame();return true;}
                if(gameOver&&y>.60f){if(x<.5f)showHome();else startGame(mode);return true;}
                if(x>.86f&&y>.34f&&y<.52f){throttle=Math.min(1f,throttle+.08f);beep(false);invalidate();return true;}
                if(x>.86f&&y>.58f&&y<.76f){throttle=Math.max(.2f,throttle-.08f);beep(false);invalidate();return true;}
            }
            if(running&&(e.getAction()==MotionEvent.ACTION_DOWN||e.getAction()==MotionEvent.ACTION_MOVE)){
                if(mode==ROAD){
                    if(x<.86f){lane=Math.max(0,Math.min(4,(int)(x*5)));playerX=(lane+.5f)/5f;}
                }else{
                    if(x<.86f){playerX=Math.max(.07f,Math.min(.93f,x));playerY=Math.max(.22f,Math.min(.88f,y));}
                }
                invalidate();
            }
            return true;
        }
    }
}
