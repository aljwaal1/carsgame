package com.explapp.carsgamelegacy;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Shader;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.os.Bundle;
import android.os.Handler;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Random;

public final class MainActivity extends Activity {
    private static final int MODE_MENU = 0;
    private static final int MODE_RACE = 1;
    private static final int MODE_PLANE = 2;

    private SharedPreferences prefs;
    private ToneGenerator tones;
    private GameView activeGame;
    private int mode = MODE_MENU;
    private boolean soundEnabled;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        prefs = getSharedPreferences("retro_arcade_v2", MODE_PRIVATE);
        soundEnabled = prefs.getBoolean("sound", true);
        tones = new ToneGenerator(AudioManager.STREAM_MUSIC, 82);
        showMenu();
    }

    private void showMenu() {
        stopActiveGame();
        mode = MODE_MENU;
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER_HORIZONTAL);
        root.setPadding(dp(18), dp(18), dp(18), dp(18));
        root.setBackground(gradient(0xff061326, 0xff0a2846, 0xff020814));

        TextView title = label("ألعاب زمان", 34, Color.rgb(255, 195, 38), true);
        title.setShadowLayer(8f, 0, 3, 0xff000000);
        root.addView(title, match());
        TextView subtitle = label("لعبتان في تطبيق واحد — خفيفة وسريعة", 15, 0xffd7e9ff, false);
        root.addView(subtitle, match());

        ArcadePreview preview = new ArcadePreview(this);
        LinearLayout.LayoutParams previewParams = new LinearLayout.LayoutParams(-1, 0, 1f);
        previewParams.setMargins(0, dp(12), 0, dp(12));
        root.addView(preview, previewParams);

        Button race = menuButton("🚗  طريق التحمل", "تجاوز السيارات واجمع العملات", 0xffd9472c);
        race.setOnClickListener(new View.OnClickListener() { @Override public void onClick(View v) { play(ToneGenerator.TONE_PROP_ACK, 130); startRace(); } });
        root.addView(race, matchHeight(72));

        Button plane = menuButton("✈  طائرة الوقود", "اجمع الوقود وتجنب الطائرات", 0xff167bc0);
        LinearLayout.LayoutParams planeParams = matchHeight(72); planeParams.topMargin = dp(10);
        plane.setOnClickListener(new View.OnClickListener() { @Override public void onClick(View v) { play(ToneGenerator.TONE_PROP_ACK, 130); startPlane(); } });
        root.addView(plane, planeParams);

        Button sound = simpleButton(soundEnabled ? "🔊 الصوت يعمل" : "🔇 الصوت مكتوم", soundEnabled ? 0xff147d55 : 0xff4d5b69);
        LinearLayout.LayoutParams soundParams = matchHeight(52); soundParams.topMargin = dp(12);
        sound.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                soundEnabled = !soundEnabled;
                prefs.edit().putBoolean("sound", soundEnabled).apply();
                if (soundEnabled) play(ToneGenerator.TONE_CDMA_CONFIRM, 150);
                showMenu();
            }
        });
        root.addView(sound, soundParams);
        setContentView(root);
    }

    private void startRace() {
        mode = MODE_RACE;
        RaceView game = new RaceView(this);
        showGame(game, "طريق التحمل");
    }

    private void startPlane() {
        mode = MODE_PLANE;
        PlaneView game = new PlaneView(this);
        showGame(game, "طائرة الوقود");
    }

    private void showGame(final GameView game, String title) {
        stopActiveGame();
        activeGame = game;
        FrameLayout frame = new FrameLayout(this);
        frame.addView(game, new FrameLayout.LayoutParams(-1, -1));

        LinearLayout top = new LinearLayout(this);
        top.setGravity(Gravity.CENTER_VERTICAL);
        top.setPadding(dp(8), dp(5), dp(8), dp(5));
        top.setBackgroundColor(0xc9000b18);
        TextView name = label(title, 18, Color.WHITE, true);
        name.setGravity(Gravity.CENTER_VERTICAL);
        top.addView(name, new LinearLayout.LayoutParams(0, dp(46), 1f));
        Button pause = simpleButton("Ⅱ", 0xff174d77);
        pause.setTextSize(22);
        pause.setOnClickListener(new View.OnClickListener() { @Override public void onClick(View v) { game.togglePause(); } });
        top.addView(pause, new LinearLayout.LayoutParams(dp(58), dp(46)));
        frame.addView(top, new FrameLayout.LayoutParams(-1, dp(58), Gravity.TOP));

        setContentView(frame);
        game.start();
    }

    private void stopActiveGame() {
        if (activeGame != null) {
            activeGame.stop();
            activeGame = null;
        }
    }

    private void showEnd(final GameView game, String title, String details) {
        play(ToneGenerator.TONE_PROP_NACK, 260);
        new AlertDialog.Builder(this)
                .setTitle(title)
                .setMessage(details)
                .setCancelable(false)
                .setPositiveButton("إعادة اللعب", new DialogInterface.OnClickListener() {
                    @Override public void onClick(DialogInterface dialog, int which) {
                        if (mode == MODE_RACE) startRace(); else startPlane();
                    }
                })
                .setNegativeButton("القائمة الرئيسية", new DialogInterface.OnClickListener() {
                    @Override public void onClick(DialogInterface dialog, int which) { showMenu(); }
                }).show();
    }

    private void play(int tone, int duration) {
        if (soundEnabled && tones != null) tones.startTone(tone, duration);
    }

    private Button menuButton(String title, String subtitle, int color) {
        Button button = simpleButton(title + "\n" + subtitle, color);
        button.setTextSize(18);
        button.setGravity(Gravity.CENTER);
        return button;
    }

    private Button simpleButton(String text, int color) {
        Button button = new Button(this);
        button.setText(text);
        button.setTextColor(Color.WHITE);
        button.setTextSize(16);
        button.setAllCaps(false);
        button.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        GradientDrawable drawable = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{lighten(color, 22), color, darken(color, 28)});
        drawable.setCornerRadius(dp(14));
        drawable.setStroke(dp(1), 0x66ffffff);
        button.setBackground(drawable);
        return button;
    }

    private TextView label(String text, int size, int color, boolean bold) {
        TextView view = new TextView(this);
        view.setText(text);
        view.setTextSize(size);
        view.setTextColor(color);
        view.setGravity(Gravity.CENTER);
        view.setTypeface(Typeface.DEFAULT, bold ? Typeface.BOLD : Typeface.NORMAL);
        view.setPadding(dp(4), dp(4), dp(4), dp(4));
        return view;
    }

    private GradientDrawable gradient(int top, int middle, int bottom) {
        GradientDrawable drawable = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{top, middle, bottom});
        return drawable;
    }

    private int lighten(int color, int amount) {
        return Color.rgb(Math.min(255, Color.red(color) + amount), Math.min(255, Color.green(color) + amount), Math.min(255, Color.blue(color) + amount));
    }

    private int darken(int color, int amount) {
        return Color.rgb(Math.max(0, Color.red(color) - amount), Math.max(0, Color.green(color) - amount), Math.max(0, Color.blue(color) - amount));
    }

    private LinearLayout.LayoutParams match() { return new LinearLayout.LayoutParams(-1, -2); }
    private LinearLayout.LayoutParams matchHeight(int height) { return new LinearLayout.LayoutParams(-1, dp(height)); }
    private int dp(int value) { return (int) (value * getResources().getDisplayMetrics().density + .5f); }

    @Override public void onBackPressed() {
        if (mode != MODE_MENU) showMenu(); else super.onBackPressed();
    }

    @Override protected void onDestroy() {
        stopActiveGame();
        if (tones != null) { tones.release(); tones = null; }
        super.onDestroy();
    }

    private abstract class GameView extends View {
        final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        final Handler handler = new Handler();
        final Random random = new Random();
        boolean running;
        boolean paused;
        float downX;
        int score;
        int lives = 3;

        GameView(Context context) { super(context); setLayerType(View.LAYER_TYPE_SOFTWARE, null); }
        abstract void step();
        abstract void resetGame();

        final Runnable loop = new Runnable() {
            @Override public void run() {
                if (!running) return;
                if (!paused) step();
                invalidate();
                handler.postDelayed(this, 32L);
            }
        };

        void start() { resetGame(); running = true; handler.post(loop); }
        void stop() { running = false; handler.removeCallbacksAndMessages(null); }
        void togglePause() { paused = !paused; play(paused ? ToneGenerator.TONE_PROP_BEEP2 : ToneGenerator.TONE_PROP_ACK, 100); invalidate(); }

        @Override public boolean onTouchEvent(MotionEvent event) {
            if (event.getAction() == MotionEvent.ACTION_DOWN) downX = event.getX();
            if (event.getAction() == MotionEvent.ACTION_UP && !paused) {
                float dx = event.getX() - downX;
                if (Math.abs(dx) > dp(20)) movePlayer(dx > 0 ? 1 : -1);
            }
            return true;
        }

        abstract void movePlayer(int direction);

        void drawHud(Canvas canvas, int extraValue, String extraLabel) {
            float top = dp(66);
            drawHudBox(canvas, dp(8), top, dp(105), dp(58), "النقاط", String.valueOf(score));
            drawHudBox(canvas, getWidth() - dp(113), top, dp(105), dp(58), "الأرواح", hearts());
            drawHudBox(canvas, getWidth()/2f - dp(53), top, dp(106), dp(58), extraLabel, String.valueOf(extraValue));
        }

        private void drawHudBox(Canvas c, float x, float y, float w, float h, String title, String value) {
            paint.setColor(0xd8071525);
            c.drawRoundRect(new RectF(x, y, x+w, y+h), dp(9), dp(9), paint);
            paint.setStyle(Paint.Style.STROKE); paint.setStrokeWidth(dp(1)); paint.setColor(0x668bdcff);
            c.drawRoundRect(new RectF(x, y, x+w, y+h), dp(9), dp(9), paint); paint.setStyle(Paint.Style.FILL);
            paint.setTextAlign(Paint.Align.CENTER); paint.setTypeface(Typeface.DEFAULT_BOLD);
            paint.setColor(0xffd3e9ff); paint.setTextSize(dp(11)); c.drawText(title, x+w/2, y+dp(18), paint);
            paint.setColor(Color.WHITE); paint.setTextSize(dp(18)); c.drawText(value, x+w/2, y+dp(44), paint);
        }

        String hearts() { return lives == 3 ? "♥♥♥" : lives == 2 ? "♥♥♡" : lives == 1 ? "♥♡♡" : "♡♡♡"; }

        void drawPause(Canvas canvas) {
            if (!paused) return;
            paint.setColor(0xc9000000); canvas.drawRect(0, 0, getWidth(), getHeight(), paint);
            paint.setTextAlign(Paint.Align.CENTER); paint.setTypeface(Typeface.DEFAULT_BOLD); paint.setColor(0xffffd33d); paint.setTextSize(dp(30));
            canvas.drawText("إيقاف مؤقت", getWidth()/2f, getHeight()/2f, paint);
            paint.setColor(Color.WHITE); paint.setTextSize(dp(15)); canvas.drawText("اضغط زر الإيقاف للمتابعة", getWidth()/2f, getHeight()/2f + dp(34), paint);
        }
    }

    private final class RaceView extends GameView {
        final ArrayList<CarObject> objects = new ArrayList<CarObject>();
        int lane = 1;
        float roadOffset;
        float speed;
        int distance;

        RaceView(Context context) { super(context); }
        @Override void resetGame() { score=0; lives=3; lane=1; roadOffset=0; speed=8; distance=0; paused=false; objects.clear(); for(int i=0;i<4;i++) spawn(i*220-dp(200)); }
        void spawn(float y) { CarObject o=new CarObject(); o.lane=random.nextInt(3); o.y=y; o.kind=random.nextInt(5)==0?1:0; objects.add(o); }
        @Override void step() {
            roadOffset=(roadOffset+speed)%dp(110); distance++;
            for(int i=0;i<objects.size();i++) {
                CarObject o=objects.get(i); o.y+=speed;
                if(o.y>getHeight()+dp(100)) { o.y=-dp(120)-random.nextInt(dp(260)); o.lane=random.nextInt(3); o.kind=random.nextInt(6)==0?1:0; score+=10; if(score%100==0) play(ToneGenerator.TONE_PROP_ACK,90); }
                float playerY=getHeight()-dp(150);
                if(o.lane==lane && o.y+dp(75)>playerY && o.y<playerY+dp(85)) {
                    if(o.kind==1){ score+=50; play(ToneGenerator.TONE_CDMA_CONFIRM,120); o.y=-dp(160); }
                    else { lives--; play(ToneGenerator.TONE_PROP_NACK,180); o.y=-dp(180); if(lives<=0){ running=false; showEnd(this,"انتهت اللعبة","النقاط: "+score+"\nالمسافة: "+distance+" م"); } }
                }
            }
            speed=Math.min(18f,8f+score/250f);
        }
        @Override void movePlayer(int direction){ lane=Math.max(0,Math.min(2,lane+direction)); play(direction>0?ToneGenerator.TONE_DTMF_6:ToneGenerator.TONE_DTMF_4,65); }

        @Override protected void onDraw(Canvas c) {
            float w=getWidth(), h=getHeight();
            paint.setShader(new LinearGradient(0,0,0,h*.45f,new int[]{0xff1b7bb5,0xff89d5ef,0xffffd184},null,Shader.TileMode.CLAMP)); c.drawRect(0,0,w,h*.45f,paint); paint.setShader(null);
            drawMountains(c,w,h);
            float topY=h*.27f, roadLTop=w*.43f, roadRTop=w*.57f, roadLBottom=w*.04f, roadRBottom=w*.96f;
            Path road=new Path(); road.moveTo(roadLTop,topY); road.lineTo(roadRTop,topY); road.lineTo(roadRBottom,h); road.lineTo(roadLBottom,h); road.close();
            paint.setShader(new LinearGradient(0,topY,0,h,0xff4b5058,0xff171b20,Shader.TileMode.CLAMP)); c.drawPath(road,paint); paint.setShader(null);
            paint.setColor(0xfff4f4e8); paint.setStrokeWidth(dp(5)); c.drawLine(roadLTop,topY,roadLBottom,h,paint); c.drawLine(roadRTop,topY,roadRBottom,h,paint);
            for(int l=1;l<3;l++) for(float y=topY+roadOffset;y<h;y+=dp(110)) {
                float t=(y-topY)/(h-topY); float left=roadLTop+(roadLBottom-roadLTop)*t; float right=roadRTop+(roadRBottom-roadRTop)*t; float x=left+(right-left)*l/3f;
                paint.setColor(0xffffd34f); paint.setStrokeWidth(dp(3)+t*dp(4)); c.drawLine(x,y,x,y+dp(46)*(0.35f+t),paint);
            }
            for(CarObject o:objects){ float t=Math.max(.05f,(o.y-topY)/(h-topY)); float left=roadLTop+(roadLBottom-roadLTop)*t; float right=roadRTop+(roadRBottom-roadRTop)*t; float x=left+(right-left)*(o.lane+.5f)/3f; if(o.kind==1) drawCoin(c,x,o.y,dp(12)+t*dp(8)); else drawCar(c,x,o.y,dp(34)+t*dp(24),0xffe14731,false); }
            float playerY=h-dp(145); float playerX=roadLBottom+(roadRBottom-roadLBottom)*(lane+.5f)/3f; drawCar(c,playerX,playerY,dp(62),0xffe31d26,true);
            drawHud(c,Math.round(speed*8),"السرعة"); drawPause(c);
        }

        void drawMountains(Canvas c,float w,float h){ paint.setColor(0xff7f593d); Path p=new Path(); p.moveTo(0,h*.34f); p.lineTo(w*.16f,h*.19f); p.lineTo(w*.28f,h*.34f); p.lineTo(w*.45f,h*.23f); p.lineTo(w*.62f,h*.35f); p.lineTo(w*.82f,h*.17f); p.lineTo(w,h*.34f); p.close(); c.drawPath(p,paint); paint.setColor(0xff3e8b46); c.drawRect(0,h*.34f,w,h*.49f,paint); }
        void drawCoin(Canvas c,float x,float y,float r){ paint.setColor(0xffffc928); c.drawCircle(x,y,r,paint); paint.setStyle(Paint.Style.STROKE); paint.setStrokeWidth(dp(3)); paint.setColor(0xfffff0a0); c.drawCircle(x,y,r*.72f,paint); paint.setStyle(Paint.Style.FILL); }
        void drawCar(Canvas c,float x,float y,float size,int color,boolean player){ float h=size*1.45f; paint.setShadowLayer(player?12:5,0,5,0xaa000000); paint.setColor(0xff111820); c.drawRoundRect(new RectF(x-size*.55f,y+h*.18f,x+size*.55f,y+h*.92f),size*.16f,size*.16f,paint); paint.setColor(color); c.drawRoundRect(new RectF(x-size*.46f,y,x+size*.46f,y+h),size*.2f,size*.2f,paint); paint.setColor(0xffb8e9ff); c.drawRoundRect(new RectF(x-size*.31f,y+h*.16f,x+size*.31f,y+h*.43f),size*.1f,size*.1f,paint); paint.setColor(0xfffff0a8); c.drawCircle(x-size*.3f,y+h*.84f,size*.08f,paint); c.drawCircle(x+size*.3f,y+h*.84f,size*.08f,paint); paint.clearShadowLayer(); }
        final class CarObject { int lane,kind; float y; }
    }

    private final class PlaneView extends GameView {
        final ArrayList<AirObject> objects=new ArrayList<AirObject>();
        float playerX=.5f;
        int fuel;
        int distance;
        PlaneView(Context context){ super(context); }
        @Override void resetGame(){ score=0;lives=3;fuel=100;distance=0;playerX=.5f;paused=false;objects.clear();for(int i=0;i<7;i++)spawn(-i*dp(125)-dp(120)); }
        void spawn(float y){ AirObject o=new AirObject();o.x=.1f+random.nextFloat()*.8f;o.y=y;o.kind=random.nextInt(4)==0?1:0;objects.add(o); }
        @Override void step(){ distance++; if(distance%18==0)fuel--; for(AirObject o:objects){o.y+=dp(5.5f);if(o.y>getHeight()+dp(60)){o.y=-dp(100)-random.nextInt(dp(350));o.x=.1f+random.nextFloat()*.8f;o.kind=random.nextInt(4)==0?1:0;score+=5;} float px=getWidth()*playerX, py=getHeight()-dp(145);if(Math.abs(getWidth()*o.x-px)<dp(42)&&Math.abs(o.y-py)<dp(58)){if(o.kind==1){fuel=Math.min(100,fuel+28);score+=30;play(ToneGenerator.TONE_CDMA_CONFIRM,120);}else{lives--;play(ToneGenerator.TONE_PROP_NACK,170);}o.y=-dp(140);if(lives<=0||fuel<=0){running=false;showEnd(this,fuel<=0?"نفد الوقود":"سقطت الطائرة","النقاط: "+score+"\nالوقود المجموع: "+Math.max(0,fuel));}}} if(fuel<=0&&running){running=false;showEnd(this,"نفد الوقود","النقاط: "+score);} }
        @Override void movePlayer(int direction){playerX=Math.max(.14f,Math.min(.86f,playerX+direction*.18f));play(direction>0?ToneGenerator.TONE_DTMF_6:ToneGenerator.TONE_DTMF_4,65);}
        @Override protected void onDraw(Canvas c){float w=getWidth(),h=getHeight();paint.setShader(new LinearGradient(0,0,0,h,new int[]{0xff0b66a7,0xff3ca7d7,0xff9ee8f5,0xff0b6f8d},null,Shader.TileMode.CLAMP));c.drawRect(0,0,w,h,paint);paint.setShader(null);drawIslands(c,w,h);for(AirObject o:objects){if(o.kind==1)drawFuel(c,w*o.x,o.y);else drawPlane(c,w*o.x,o.y,dp(40),0xff4b5968,false);}drawPlane(c,w*playerX,h-dp(145),dp(58),0xffe14731,true);drawFuelBar(c);drawHud(c,fuel,"الوقود");drawPause(c);}
        void drawIslands(Canvas c,float w,float h){paint.setColor(0x8842a95d);Path a=new Path();a.moveTo(0,h*.72f);a.cubicTo(w*.2f,h*.58f,w*.3f,h*.9f,w*.5f,h*.78f);a.cubicTo(w*.68f,h*.68f,w*.8f,h*.86f,w,h*.64f);a.lineTo(w,h);a.lineTo(0,h);a.close();c.drawPath(a,paint);paint.setColor(0x447be7ee);for(int i=0;i<8;i++)c.drawOval(new RectF(i*w/7f-dp(20),h*.45f+i%2*dp(40),i*w/7f+dp(55),h*.45f+i%2*dp(40)+dp(8)),paint);}
        void drawFuelBar(Canvas c){float x=dp(14),y=getHeight()-dp(255),bw=dp(24),bh=dp(130);paint.setColor(0xcc051523);c.drawRoundRect(new RectF(x,y,x+bw,y+bh),dp(8),dp(8),paint);float fill=bh*fuel/100f;paint.setColor(fuel>35?0xff23c55e:0xffef3d36);c.drawRoundRect(new RectF(x+dp(4),y+bh-fill+dp(4),x+bw-dp(4),y+bh-dp(4)),dp(5),dp(5),paint);}
        void drawFuel(Canvas c,float x,float y){paint.setColor(0xffef4035);c.drawRoundRect(new RectF(x-dp(15),y-dp(20),x+dp(15),y+dp(22)),dp(5),dp(5),paint);paint.setColor(0xffffc928);paint.setTextAlign(Paint.Align.CENTER);paint.setTextSize(dp(11));paint.setTypeface(Typeface.DEFAULT_BOLD);c.drawText("GAS",x,y+dp(5),paint);}
        void drawPlane(Canvas c,float x,float y,float size,int color,boolean player){paint.setShadowLayer(player?12:5,0,5,0xaa000000);paint.setColor(color);Path body=new Path();body.moveTo(x,y-size*.72f);body.lineTo(x+size*.18f,y+size*.5f);body.lineTo(x,y+size*.7f);body.lineTo(x-size*.18f,y+size*.5f);body.close();c.drawPath(body,paint);Path wings=new Path();wings.moveTo(x-size*.65f,y+size*.18f);wings.lineTo(x,y-size*.06f);wings.lineTo(x+size*.65f,y+size*.18f);wings.lineTo(x+size*.48f,y+size*.42f);wings.lineTo(x,y+size*.26f);wings.lineTo(x-size*.48f,y+size*.42f);wings.close();c.drawPath(wings,paint);paint.setColor(0xffd8f4ff);c.drawOval(new RectF(x-size*.11f,y-size*.34f,x+size*.11f,y-size*.03f),paint);paint.clearShadowLayer();}
        final class AirObject{float x,y;int kind;}
    }

    private final class ArcadePreview extends View {
        private final Paint p=new Paint(Paint.ANTI_ALIAS_FLAG);
        ArcadePreview(Context c){super(c);setLayerType(View.LAYER_TYPE_SOFTWARE,null);}
        @Override protected void onDraw(Canvas c){float w=getWidth(),h=getHeight();p.setShader(new LinearGradient(0,0,w,h,0xff102e50,0xff04111f,Shader.TileMode.CLAMP));c.drawRoundRect(new RectF(0,0,w,h),dp(20),dp(20),p);p.setShader(null);p.setColor(0x55ffffff);for(int i=0;i<16;i++){float x=(i*73)%Math.max(1,(int)w);float y=(i*47)%Math.max(1,(int)h);c.drawCircle(x,y,dp(2),p);}p.setColor(0xffffc928);p.setTextAlign(Paint.Align.CENTER);p.setTypeface(Typeface.DEFAULT_BOLD);p.setTextSize(dp(24));c.drawText("سباق • طيران • تحدّي",w/2,h*.16f,p);drawPreviewCar(c,w*.3f,h*.62f);drawPreviewPlane(c,w*.72f,h*.55f);}
        void drawPreviewCar(Canvas c,float x,float y){p.setShadowLayer(15,0,8,0xaa000000);p.setColor(0xffe52d2d);c.drawRoundRect(new RectF(x-dp(55),y-dp(42),x+dp(55),y+dp(50)),dp(18),dp(18),p);p.setColor(0xffbdeaff);c.drawRoundRect(new RectF(x-dp(34),y-dp(26),x+dp(34),y-dp(2)),dp(8),dp(8),p);p.clearShadowLayer();}
        void drawPreviewPlane(Canvas c,float x,float y){p.setColor(0xffe15b32);Path q=new Path();q.moveTo(x,y-dp(62));q.lineTo(x+dp(18),y+dp(42));q.lineTo(x,y+dp(62));q.lineTo(x-dp(18),y+dp(42));q.close();c.drawPath(q,p);p.setColor(0xffffb22c);c.drawOval(new RectF(x-dp(72),y-dp(8),x+dp(72),y+dp(22)),p);}
    }
}
