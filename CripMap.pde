//ver2.0...起動しっぱなしにしているとメモリリークを起こす不具合を修正できたのかな
//ver1.8...マルチスクリーン（マルチプロジェクタ投影）に対応．shiftキーを押さずに実行してください．輝度調整による疑似エッジブレンディングも可能．
//ver1.7...矩形ごとに移動させる機能を追加。"<",">",で選択中の矩形or全ての矩形の大きさを比を保ったまま大きさを変える
//ver1.6...映像を切り取る機能を同じプログラムで実装。xキーで投影&シュートモード、カッティングモードを切り替える
//ver1.5...頂点の管理方法を動的配列に変更し、dataファイルから映像のサイズ、各頂点の座標を取得する

//サブスクリーンを表示しているときにフルスクリーンにしたいならばfullScreen(P2D)とfullScreen(SPAN)を両方とも実行すればよい


//*****シュートモード*******

//Shift押しながら実行 ...フルスクリーンモード
//頂点付近で右ドラッグ...頂点を移動してゆがませる
//左ドラッグ..映像を移動させる
//Shift押しながら左ドラッグ...マスクを移動させる
//'p'...再生ボタン。再生中にもう一度押すと映像が停止する
//'s'...現在の座標を外部データに保存。ファイルはdataフォルダ内に保存している。マスクの座標も保存
//'l'...保存していた外部データを読み込む。
//'f'...プログラム実行時の位置に映像を移動させ、さらにサイズを動画ファイルそのものの値に変更する
//'o'...フェードアウト開始。フェードアウト中は'p'キーは無効。
//'m'...黒色マスクの表示。mキーを押すたびに表示・非表示が切り替わる
//'c'...マウスカーソルの表示・非表示切り替え(初期状態は表示)
//'b'...映像のインデックスを指定した座標に表示する。同時にフレームレートも出力する。
//'r'...映像を頭に巻き戻す
//'u'...再生速度UP（誤操作防止のためコメントアウトしてます）再生速度変更使うならkeyControlの該当関数のコメントを外せばok
//'d'...再生速度DOWN（誤操作防止のためコメントアウトしてます）
//'n'..再生速度を通常に戻す
//'j'..一回押すごとに10秒早送りする。それ以上早送りできないときは何もしない。
//'w'..プロパティ設定パネルを表示する。表示中にもう一度入力すると消える。
//'x'..ver1.6より追加．映像の位置を調整するシュートモードと，映像の切り取り位置を決めるカッティングモードを切り替える
//'/'..ver1.7より追加．シュート時に使用．切り取った映像を選択する．選択された矩形は枠が青くなり，このキーを押すたびに選択対象が切り替わる．
//'<'..ver1.7より追加．選択している矩形（映像）を拡大する．比を出来るだけ保って拡大する．
//'>'..ver1.7より追加．〃縮小する
//1～9の数字キー...各番号に登録した映像を選択する。その状態でpキーを押せば再生される

//*******カッティングモード*********
//頂点付近で左クリック　頂点を選択します
//頂点以外で左クリック　矩形を選択します
//頂点付近で右クリック　共有点を設定を切り替えます．
//頂点付近で左ドラッグ　矩形を作成し，範囲内の映像を切り取ります．
//'d'..選択している矩形を削除します．
//'s'..切り取った状態を保存します．シュートした座標は全て初期状態に戻るので注意！
//'l'..ファイルを読み込み，元の切り取り型に戻します．
//'f'..初期状態にリセットします．

//デバッグメモ↓
//1440*900だと緑の線が映像の下端に表示された
//1280*800なら緑の線が表示されなかった
//FADE_TIME = 0.5ならフリーズは確認されていない  
//2016/09/06 mov.width,mov.heightはplay()実行後、数フレーム経過後しか使えない

import processing.video.*;
import controlP5.*;
import processing.awt.PSurfaceAWT;
import java.io.File;
//import gab.opencv.*;

//import java.awt.Frame;
//import java.awt.Insets;


//FADE_TIME...フェードアウトする時間、単位は秒
//MAX_MASK...表示するマスクの個数
//MAX_SCREEN...同時に再生する映像の数     
float FADE_TIME = 0.5;  
float FADE_IN_TIME = 0.5;
int MAX_MASK = 1; //表示するマスクの最大数。
int MAX_INDEX =10; //indexの最大値
public float MAX_SPEED = 1.7;//左端のつまみを動かしたときに変化させる再生速度の最大値
public int ADSORPTION = 20; //頂点への吸着度
int CHECK_POINT_X=100;    //確認用文字を表示する左上座標
int CHECK_POINT_Y=100;   // 
String TEXT_PATH = "data/_txt/";//テキストデータを記憶するパス
int SMALL_BIG = 100;//拡大、縮小時にsizeの何分の1だけ動かすか決定する定数

int BUG_SHIFT_X= 0;//ネオン街で確認されたバグ（プロジェクタの不具合？）　この定数の値だけファイルロード時にx軸をシフトする。ファイルを書き換えるわけではない（重要）
int BUG_SHIFT_Y = 0;

//2017/07/04追加　設定ウインドウの表示位置をずらすための変数
int SHIFT_WINDOW_X = 0;
int SHIFT_WINDOW_Y = 0;


//_MODE...モードを切り替える。
//0...通常時、1...映像切り取り時
public int _MODE = 0; 


//////////////////////////////////
//変更する項目
//////////////////////////////////
//再生するファイル名　必ず何かしらの映像ファイルを登録しておくこと。重複して選択することはできない
// 2017/07/07 ９番ループしてます
//movだけでなくmp4も対応しています．
String file0 = "kata.mp4"; //0にはテストパターンを登録しておくとシュートの時便利
String file1 = "sample1.mov";
String file2 = "sample2.mov";
String file3 = "sample3.mov";
String file4 = "sample4.mov";
String file5 = "sample5.mov";
String file6 = "sample6.mov";
String file7 = "sample7.mov";
String file8 = "sample8.mov";
String file9 = "sample9.mov";

//座標を記憶するファイル名　特定の映像だけ異なる座標に表示させたい場合適宜変更すること
//2017/02/05 存在しないファイル名を指定した場合，映像の解像度に合わせて初期値を設定し新しくファイルを作成する
String data0 = "data.txt";
String data1 = "data.txt";
String data2 = "data.txt";
String data3 = "data.txt";
String data4 = "data.txt";
String data5 = "data.txt";
String data6 = "data.txt";
String data7 = "data.txt";
String data8 = "data.txt";
String data9 = "data.txt";

//遅延が発生する場合、フレームレートを下げれば改善する場合がある。デフォルトは29
int FRAME_RATE = 29;

int DIV_X = 4;
int DIV_Y = 3;

//////////////////////////////////
//変更する項目 終了
//////////////////////////////////

HashMap<Integer,String> datamap = new HashMap<Integer,String>();
HashMap<Integer,String> filemap = new HashMap<Integer,String>();


PGraphics mainScreen;                 // メイン画面(これを変形描画する)
PGraphics g_main;
//PGraphics secondScreen;
//PGraphics mask;                 // マスク画面(これを変形描画する)
ArrayList<PGraphics> mask =new ArrayList<PGraphics>();//PGraphics型マスク変数をarrayListに格納
PGraphics m0,m1,m2;

Movie mov0,mov1,mov2,mov3,mov4,mov5,mov6,mov7,mov8,mov9;            // movie
int selected = -1;  // selected point
int over = -1;           // over = 1 when mouse point exist on the movie

int playing = -1;
int fadeout = -1;        //フェードアウト中は1になり、その間画面を黒くする
int fadein = -1;         //フェードイン中は1になり、その間画面を明るくする。　フェードイン終了後は-1を代入し、映像を切り替える or Restart時に1を代入する
boolean mouse = true;    //trueなら表示
int mask_switch[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};  //1以上ならその個数だけマスク表示。'm'キーを押すたびにマスクの数が増える
int fadein_switch[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; //1ならフェードインさせる。0ならしない。
int loop_switch[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};//1ならループさせる。0ならしない。テストデータは常にループ

int   index = 1;      //現在再生している映像の番号  
int   sv[][] = {{0,0},{960,0},{960,720},{0,720}}; // プロジェクションするスクリーンの変形描画用頂点
//int   mpos[][] = {{0,0},{200,0},{200,200},{0,200},{300,0},{500,0},{500,200},{300,200},{600,0},{800,0},{800,200},{600,200}};
PrintWriter writer; 
                       
int editSvNo = -1;                    // ドラッグ移動中のスクリーン頂点番号
int editMposNo = -1;                  //ドラッグ移動中のマスクの頂点番号
boolean main_w_now = false;                  //メインスクリーンがワープ中はtrue
boolean mask_w_now = false;

float c = 0.0;                                //フェードアウト時の黒色の濃度を決める一時変数
float c_in = 255.0;                                //フェードイン時の黒色の濃度を決める一時変数
float f1,f2,rate,f1_in,f2_in,rate_in;

boolean ctrl = false;
boolean q_key = false;
boolean b_key = false;
boolean shift = false;
boolean alt = false;

ArrayList<Integer> svx =new ArrayList<Integer>(); //sv(頂点)のX座標を格納する動的配列ArrayList
ArrayList<Integer> svy =new ArrayList<Integer>(); //sv(頂点)のY座標を格納する動的配列ArrayList
ArrayList<Integer> o_svx =new ArrayList<Integer>(); //sv(頂点)のX座標を格納する動的配列ArrayList
ArrayList<Integer> o_svy =new ArrayList<Integer>(); //sv(頂点)のY座標を格納する動的配列ArrayList
ArrayList<Integer> fix_svx =new ArrayList<Integer>(); //描画時の計算に使用するsv(頂点)のX座標を格納する動的配列ArrayList
ArrayList<Integer> fix_svy =new ArrayList<Integer>(); //描画時の計算に使用するsv(頂点)のY座標を格納する動的配列ArrayList
ArrayList<ArrayList<Integer>> svList=new ArrayList<ArrayList<Integer>>(); //svを2次元配列に
//svList.get(0).get(3); というようにして要素を取り出す 

ArrayList<Integer> mposx =new ArrayList<Integer>();//マスクの頂点のx軸を管理するArrayList
ArrayList<Integer> mposy =new ArrayList<Integer>();//マスクの頂点のy軸を管理するArrayList
ArrayList<Integer> mopti =new ArrayList<Integer>();//マスクの不透明度を管理するArrayList


ArrayList<Integer> select =new ArrayList<Integer>();//現在選択している頂点番号を記憶する。何も選択されていないなら-1を格納する。

ArrayList<Integer> co_point =new ArrayList<Integer>(); //頂点座標を共有する頂点番号を格納する動的配列ArrayList


ArrayList<Integer> areaA =new ArrayList<Integer>();
ArrayList<Integer> areaB =new ArrayList<Integer>();
ArrayList<Integer> areaC =new ArrayList<Integer>();
ArrayList<Integer> areaD =new ArrayList<Integer>();

//midiControlクラスのオブジェクト
public MidiControl midi = new MidiControl();
public KeyControl keyControl = new KeyControl();
//public SubFullScreen sub = new SubFullScreen();
public int fader0 = 127; //フェードイン、アウトに使用するフェーダーの値を格納するグローバル変数 初期値は透明(フェーダーが上がりきった状態)にしておく

ControlP5 controlP5,slider,save_button,cancel_button;
//checkboxオブジェクト作成
CheckBox checkbox,checkbox2,checkbox3,fix;
//controlP5内でテキストを記述する場合はTextlabelを使用する
Textlabel label1,label_file1,label_file2,label_file3,label_file4,label_file5;
Textlabel label_file6,label_file7,label_file8,label_file9,label_file0;
Textlabel label_mask1;
//マスクの個数はボタンで調整
//ControlP5 maskbutton;

//アコーディオンでウインドウみたく出来た
Accordion accordion;

public float fade_in_time = 0.5;
public float fade_out_time = 0.5;
public float  fade_in_time_slider=0.2, fade_out_time_slider=0.4; //スライダーの値。saveボタンを押してから反応するように

public String property_file_name = "data/_txt/property.txt"; //パスも含める

public boolean accordion_flag = false;//hideされている間はfalse
public boolean fix_flag = false;

int _movie_w;
int _movie_h;

GUIControl gui;
SettingControl set;

int kukei_select = 0; //平行移動させる矩形を選択する。0が通常時（全体を動かす）１以上なら各矩形を順に選択していく

void settings(){
  //マルチディスプレイ時はfullScreen(SPAN)も実行
  fullScreen(SPAN);
  fullScreen(P2D);
  // size(displayWidth,displayHeight,P2D);     // ここでdisplayWidthとdisplayHeightを指定しないとフルスクリーンにならない
}

void setup() {
  //dataファイルをハッシュテーブルに登録
  //パスもここで追加する
  datamap.put(0,TEXT_PATH+data0);
  datamap.put(1,TEXT_PATH+data1);
  datamap.put(2,TEXT_PATH+data2);
  datamap.put(3,TEXT_PATH+data3);
  datamap.put(4,TEXT_PATH+data4);
  datamap.put(5,TEXT_PATH+data5);
  datamap.put(6,TEXT_PATH+data6);
  datamap.put(7,TEXT_PATH+data7);
  datamap.put(8,TEXT_PATH+data8);
  datamap.put(9,TEXT_PATH+data9);

  filemap.put(0,file0);
  filemap.put(1,file1);
  filemap.put(2,file2);
  filemap.put(3,file3);
  filemap.put(4,file4);
  filemap.put(5,file5);
  filemap.put(6,file6);
  filemap.put(7,file7);
  filemap.put(8,file8);
  filemap.put(9,file9);
 
  surface.setResizable(true);
  
///////////////////////////////////////////////////////////////////////
//
//再生するファイル名を指定する。同じファイルを指定することはできない
//
///////////////////////////////////////////////////////////////////////

  mov0 = new Movie(this,file0);
  mov1 = new Movie(this,file1);
  mov2 = new Movie(this,file2);
  mov3 = new Movie(this,file3);
  mov4 = new Movie(this,file4);
  mov5 = new Movie(this,file5);
  mov6 = new Movie(this,file6);
  mov7 = new Movie(this,file7);
  mov8 = new Movie(this,file8);
  mov9 = new Movie(this,file9);
 
  println("Start firstLoadData");
  //firstLoadData();
  loadData();
  println("Finish firstLoadData");
  //ぶっちゃけsvList必要ないからsvx,svyの2つのArrayList使う形式に統一したい...
  svList.add(svx);//2次元配列に追加
  svList.add(svy);
  for(int i = 0;i<svx.size();i++){
    println("vertexs "+i+" = "+svx.get(i)+","+svy.get(i));  
  }
  for(int i = 0;i<mposx.size();i++){
    println("mask vertexs "+i+" = "+mposx.get(i)+","+mposy.get(i));  
  }
  
  mov0.pause();
  mov0.jump(0);
  mov1.pause();
  mov1.jump(0);
  mov2.pause();
  mov2.jump(0);
  mov3.pause();
  mov3.jump(0);
  mov4.pause();
  mov4.jump(0);
  mov5.pause();
  mov5.jump(0);
  mov6.pause();
  mov6.jump(0);
  mov7.pause();
  mov7.jump(0);
  mov8.pause();
  mov8.jump(0);
  mov9.pause();
  mov9.jump(0);

  mainScreen = createGraphics(1280, 960, P2D);
  g_main = mainScreen; //2017/11/15 g_mainの定義をdraw内でしたくないため
  m0 =  createGraphics(400, 300, P2D);
  m1 =  createGraphics(400, 300, P2D);
  m2 =  createGraphics(400, 300, P2D);
  mask.add(m0);
  mask.add(m1);
  mask.add(m2);
  mopti.add(255);mopti.add(255);mopti.add(255); //mopti初期化。不透明度maxに。いずれはdataファイルに格納したいね
  noStroke();

  frameRate(FRAME_RATE); //映像ファイルは1秒あたり29.97フレームで構成されているため



//mouseの初期値に応じてカーソルの表示を切り替える
  if(mouse)cursor();
  else noCursor();

  //ここからGUIの実装
  controlP5 = new ControlP5(this);
  slider= new ControlP5(this);
  gui = new GUIControl();//guiを生成するクラスを作成
  gui.setupGUI();
  
  //setting用
  set = new SettingControl();
  
  playing = -1;
  //起動後すぐ再生するなら
  //whichMov().play();
  
}


////////////////
/////draw()/////
////////////////
void draw() {
  
  //ここにループ判定を記述してみる
  //loopCheck();
  
  renderScreen();
  drawScreen();
  if(ctrl == true && q_key == true){
    exit();
  }

  if(alt==true || _MODE==1){ //alt押しながらまたはセッティングモードのとき
    for(int i=0;i<svx.size();i++){
      drawVertex(svx.get(i),svy.get(i),i);//指定された座標に頂点マークを表示する関数
    }
    if(mask_switch[index]>0 && _MODE==0){//セッティングモードのときはマスクの頂点を表示する必要なし
     for(int i=0; i<mposx.size(); i++){
        if(i==editMposNo)fill(#00FA9A); //MediumSpringGreen
        else fill(200,0,200);
        ellipse(mposx.get(i),mposy.get(i),5, 5);
        if(i==editMposNo)stroke(#00FA9A);
        else stroke(200,0,200);
        strokeWeight(3);
        noFill();
        ellipse(mposx.get(i),mposy.get(i),20, 20);
        noStroke();
     }
    }
  }else if(mouseButton==RIGHT && _MODE==0 && mousePressed){ //マウスを表示し頂点を選択中にも頂点を表示する
    if(editSvNo>-1){
      drawVertex(svx.get(editSvNo),svy.get(editSvNo),editSvNo); //選択されている頂点に頂点マークを表示
    }else if(editMposNo>-1){
      drawVertex(svx.get(editMposNo),svy.get(editMposNo),editMposNo); 
    }else{
      //なにもなし
    }
  }
  
  //シュート中に矩形が選択されているならば縁取る
  if(_MODE==0 && kukei_select > 0 ){
    stroke(0,200,200);
    strokeWeight(3);
    int i=(kukei_select-1)*4;
    line(svx.get(i),svy.get(i),svx.get(i+1),svy.get(i+1));
    line(svx.get(i+1),svy.get(i+1),svx.get(i+2),svy.get(i+2));
    line(svx.get(i+2),svy.get(i+2),svx.get(i+3),svy.get(i+3));
    line(svx.get(i+3),svy.get(i+3),svx.get(i),svy.get(i));
    strokeWeight(1);
    noStroke();
  }
  
  if(b_key==true)keyControl.checkKey(); //デバッグ用メッセージ表示
  if(_MODE==1)set.settingDraw(); //セッティングモード時の描画を実行
}





void drawScreen(){
    background(0);
    
 int divX = DIV_X, divY = DIV_Y;  //処理が重ければ分割数を減らそう
// int pA,pB,pC,pD;
 float kX,kY,keikaX,keikaY;
 
 //描画する四角形の頂点の番号をpA～pDに代入する
 //位置関係は以下の通り
 //pA------------pB
 // |            |
 // |            |
 //pD------------pC
// pA=0;pB=1;pC=2;pD=3;
 kX=1;kY=1;keikaX=0;keikaY=0;

 
    
   
   for(int i=0;i<svx.size();i=i+4){
     //preが頭に付く変数は計算用の一時変数
     float preBx = float(fix_svx.get(i+1));
     float preAx = float(fix_svx.get(i));
     float preDy = float(fix_svy.get(i+3));
     float preAy = float(fix_svy.get(i));
     float preW = float(_movie_w);
     float preH = float(_movie_h);
      kX = (preBx - preAx) / preW;
      kY = (preDy - preAy) / preH;
      keikaX = preAx / preW;
      keikaY = preAy / preH;
//      println("kX,kY,keikaX,keikaY = "+kX,kY,keikaX,keikaY,preAx,preBx,preW,preH);//try
      for(int iy=0; iy<divY; iy++) { 
        beginShape(QUAD_STRIP);
        texture(mainScreen);
        textureMode(NORMAL);
        float ay = float(iy) / divY;
        float vy1 = lerp(svy.get(i), svy.get(i+3), ay);
        float vy2 = lerp(svy.get(i+1), svy.get(i+2), ay);
        float ay_next = float(iy+1) / divY;
        float vy1_next = lerp(svy.get(i), svy.get(i+3), ay_next);
        float vy2_next = lerp(svy.get(i+1), svy.get(i+2), ay_next);
        for(int ix=0; ix<=divX; ix++) {
          float ax = float(ix) / divX;
          float vx1 = lerp(svx.get(i), svx.get(i+1), ax);
          float vx2 = lerp(svx.get(i+3), svx.get(i+2), ax);
          float vx = lerp(vx1, vx2, ay);
          float vx_next = lerp(vx1, vx2, ay_next);
          float vy = lerp(vy1, vy2, ax);
          float vy_next = lerp(vy1_next, vy2_next, ax);
          vertex(vx, vy, ax*kX+keikaX, ay*kY+keikaY);
          vertex(vx_next, vy_next, ax*kX+keikaX, ay_next*kY+keikaY);
        }
        endShape();
      }
   }
   

  if(mask_switch[index]>=1 && _MODE==0){    //マスクを表示させる場合。セッティングモードの場合はマスク表示させない
  int mp=0;
  for(int i=0;i<mask_switch[index];i++){ 
      beginShape();
        texture(mask.get(i));
        textureMode(NORMAL);
        vertex(mposx.get(mp), mposy.get(mp), 0, 0);
        vertex(mposx.get(mp+1), mposy.get(mp+1), 400, 0);
        vertex(mposx.get(mp+2), mposy.get(mp+2), 400, 300);
        vertex(mposx.get(mp+3), mposy.get(mp+3), 0, 300);
      endShape(CLOSE);
      mp=mp+4;
    }
  }

  //右クリックしたとき、頂点付近ならドラッグを開始する
  if(fix_flag == false && _MODE == 0){ //fixボタンにチェックが入ってなくてかつモードが0のとき頂点の移動を許可する
    if(mouseButton==RIGHT && mousePressed && editSvNo >= 0) {
      if(mask_w_now ==false){
        main_w_now = true;
        screenWarpTrue(svx,svy,editSvNo);
        coPoint();
      }
    } else {
      main_w_now = false;
      editSvNo = screenWarpFalse(svx,svy,editSvNo);
    }
  
    if(mouseButton==RIGHT && mousePressed && editMposNo >= 0 && mask_switch[index] > 0){
      if(main_w_now == false){
        mask_w_now = true;
        screenWarpTrue(mposx,mposy,editMposNo);
      }
    }else {
      mask_w_now = false;
      editMposNo = screenWarpFalse(mposx,mposy,editMposNo);
    }
    
    if(mouseButton == LEFT && mousePressed && keyPressed && keyCode == SHIFT && mask_switch[index] > 0){
      screenMove(mposx,mposy,0,mposx.size());
    }else if(mouseButton == LEFT && mousePressed){
      if(kukei_select==0){
        screenMove(svx,svy,0,svx.size());
      }else{ //kukei_select>0
        screenMove(svx,svy,(kukei_select-1)*4,kukei_select*4);
      }
    }
  }
}

void renderScreen(){
  //
  g_main.beginDraw();
  //g.noLights();
  g_main.background(0);
  if(playing == -1){
    
  }else{
    if(whichMov().time()>0){
      if(c+rate<255) g_main.image(whichMov(),0,0,g_main.width,g_main.height);    //フェードアウト中にフレームレートが下がったとき用に不透明度が255に近づいて来たら映像流さない
    }else{
      g_main.background(0);
    }
  }
  if(fadeout == 1){
      
    f1 = 1.0 / FRAME_RATE;
    f2 = 1.0 / fade_out_time;
    rate = 255 * f1 * f2;

    c = c + rate;
    print(frameRate);
    if(c > 255){    //不透明度の値が255を超えたら、fadeoutを終了させ映像も停止させる  
      println("  c(>255) = ",c);
      fadeout = -1;
      playing = -1;
      c = 0.0;
      whichMov().pause();      //黒四辺形の描画をやめているので、映像の再生は一時停止
      println("フェードアウト完了");
    }else{
      println("  c(<=255) = ",c);
      g_main.fill(0,c);    //0は完全に透明、255は完全に不透明
      g_main.rect(0,0,g_main.width,g_main.height);
    }
  }

  
  if(fadein_switch[index] == 1 && fadein == 1){

    f1_in = 1.0 / FRAME_RATE;
    f2_in = 1.0 / fade_in_time;
    rate_in = 255 * f1_in * f2_in;  
  
    c_in = c_in - rate_in;
    print(frameRate);
    if(c_in < 0){    //不透明度の値が0を下回ったら、fadeinを終了させる  
      println("  c_in( < 0) = ",c_in);
      fadein = -1;
      c_in = 255.0;
      println("フェードイン完了");
    }else{
      println("  c_in( >= 0) = ",c_in);
      g_main.fill(0,c_in);    //0は完全に透明、255は完全に不透明
      g_main.rect(0,0,g_main.width,g_main.height);
    }
  }
  g_main.endDraw();  
  
  //PGraphicsのキャッシュを消去する処理を追加すると異様に処理が重くなる上に表示されない
  //PGraphicsやMovieはPImageを継承しているらしいので，removeCacheの引数には指定できる
  //movファイルを指定しても同様でした．表示はされる．
  //g.removeCache(g_main);
  //g.removeCache(whichMov());
  //System.gc();
  //whichMov().dispose();
    //フェーダーを利用してフェードイン・アウトする場合　フェーダーが完全に下(上)がっても映像が止まったりはしない
  
  PGraphics g_fader = mainScreen;
  g_fader.beginDraw();
 // g_fader.noLights();
  g_fader.fill(0,map(fader0,0,127,255,0));
  g_fader.rect(0,0,g_fader.width,g_fader.height);
  g_fader.endDraw();
  
  for(int i=0;i<mask.size();i++){
    PGraphics m = mask.get(i);
    m.beginDraw();   
    if(shift){
      //m.fill(80,200);
      m.background(80,255);
    }else{
      //m.fill(0,mopti.get(i));
      m.background(0,mopti.get(i));
    }
//    m.rect(0,0,g.width,g.height);
    m.endDraw();
  }
}


void screenWarpTrue(ArrayList<Integer> px,ArrayList<Integer>py,int n){
  px.set(n,mouseX);
  py.set(n,mouseY);
  //drawVertex(mouseX,mouseY,n,true); //頂点をドラッグしているとき、マウスの頂点に
  //fill(0, 200, 200);
  //ellipse(mouseX, mouseY, 20, 20);
}


//引数で受け取った2次元配列のうち、マウスによってどの頂点が指定されているか検出する関数
//0=左上、1=右上、2=右下、3=左下　添え字の一番目を返す
int screenWarpFalse(ArrayList<Integer> px,ArrayList<Integer>py,int n){
    n = -1;
    for(int i=0; i<px.size(); i++) {
      float distance = dist(mouseX, mouseY, px.get(i), py.get(i));
      if(distance < ADSORPTION) n = i;
    }
    return n;
}

void screenMove(ArrayList<Integer> px,ArrayList<Integer>py,int start,int max){
//2016/10/19 追記　各矩形ごとに平行移動できるようにする
  
  if(accordion_flag == false){ //誤操作防止のため、アコーディオンが開いている間映像が動かないようにする
    for(int i=start;i<max;i++){
        px.set(i,px.get(i) + mouseX - pmouseX);
        py.set(i,py.get(i) + mouseY - pmouseY);
    }
  }
}

// コード化されたキー(Ctrl等)が押されたときは反応しない
void keyTyped(){
  if(key == 's' && fix_flag == false){
    saveData(datamap.get(index));
    println("data saved");
  }else if(key == 'l' && fix_flag == false){
    loadData();
    println("data loaded");
  }else if(key == 'n'){
    keyControl.nextKey();
    //keyControl.speedChangeKey(1.0);
  }else if(key == 'p'){
    keyControl.playKey();
  }else if(key == 'o'){
    keyControl.fadeoutKey();
  }else if(key == 'c'&& _MODE==0){
    if(mouse){
      noCursor();
      mouse = false;
    }else{
      cursor();
      mouse = true;
    }
  }else if(key == 'm'  && fix_flag == false){
    if(mask_switch[index] < MAX_MASK){
      mask_switch[index]++;
    }else{
      mask_switch[index]=0;
    }
    gui.maskSwitchReflection(index);
  }else if(key == 'r'){    //ReStart
    keyControl.restartKey();
  }else if(key == '0'){
    changeMovie(0);  
  }else if(key == '1'){
    changeMovie(1);
  } else if(key == '2'){ 
    changeMovie(2);
  }else if(key == '3'){
    changeMovie(3);
  }else if(key == '4'){
    changeMovie(4);
  }else if(key == '5'){
    changeMovie(5);
  }else if(key == '6'){
    changeMovie(6);
  }else if(key == '7'){
    changeMovie(7);
  }else if(key == '8'){
    changeMovie(8);
  }else if(key == '9'){
    changeMovie(9);
  }else if(key == 'u' && fix_flag == false){ 
    print("u pressed");
    whichMov().speed(1.0);
  } else if(key == 'd' && fix_flag == false){ 
    print("d pressed");
    if(_MODE==1)set.deleteArea(); //エリアの消去
    else whichMov().speed(0.3);
//      println("ctrl+d");//try
  } else if(key == 'w'){ //GUIの表示
    if(accordion_flag){
      gui.accordionHide();
      accordion_flag = false;
    }else{
      gui.accordionShow();
      accordion_flag = true;
    }
  }else if(key == 'f'  && fix_flag == false){
    if(_MODE==0){
      for(int i=0;i<svx.size();i++){
        svx.set(i,fix_svx.get(i));
        svy.set(i,fix_svy.get(i));
      }
    }else if(_MODE==1){ //セッティングモードのときはsvx,svyをクリアしてもとの映像をそのまま投影するようにする
      svx.clear();svy.clear();
      svx.add(0);svy.add(0);
      svx.add(whichMov().width);svy.add(0);
      svx.add(whichMov().width);svy.add(whichMov().height);
      svx.add(0);svy.add(whichMov().height);
      fix_svx.clear();fix_svy.clear();
      fix_svx.add(0);fix_svy.add(0);
      fix_svx.add(whichMov().width);fix_svy.add(0);
      fix_svx.add(whichMov().width);fix_svy.add(whichMov().height);
      fix_svx.add(0);fix_svy.add(whichMov().height);
      co_point.clear();
    }
  }else if(key == 'j' && fix_flag == false){//jキーを押すたびに10秒ずつ進む
    keyControl.jumpKey();
  }else if(key == 'q'){
    frame.setLocation(0,0);
  }else if(key == 't'){
    keyControl.nextTrackKey();
  }else if(key == ','&&fix_flag == false){
    //小さくする
    println("small");
    keyControl.smallKey();
  }else if(key == '.'&&fix_flag == false){
    //大きくする
    keyControl.bigKey();
  }else if(key == '/'&&fix_flag == false){
    //選択している矩形のインデックスをインクリメントする
    kukei_select++;
    println("kukei_select = "+kukei_select);
    if(kukei_select > svx.size()/4 ){//インクリメントした後、矩形の数よりも多かったら0に戻す
      kukei_select = 0;
    }
  }else if(key == 'x' && fix_flag == false){ //ver1.6から　モード切替
    if(_MODE==0){
      _MODE=1;
      mouse=true;
      editSvNo = -1;
      editMposNo = -1;
      set.setFixVertex();//切り取るために、svにfixVertexの値を代入する
    }else{
      _MODE=0;
      mouse=false;
      set.setSvVertex();//通常モードに切り替えるために、svにsvの値を代入する
    }
  }
}

void keyPressed(){
  switch(keyCode){
    case CONTROL:
      ctrl = true;
      println("ctrl Press");
      break;
    case 66:  // 'b'
      b_key = true;
      println("b Pressed");
      break;
    case 81: // 'q'
      q_key = true;
      println("q Press");
      break;
    case SHIFT:
      shift = true;
      println("shift Pressed");
      break;
    case ALT:
      if(alt){
        alt = false;
      }else{
        alt = true;
      }  
      //alt = true;
      break;
  }
}

void keyReleased(){
  switch(keyCode){
    case CONTROL:
      ctrl = false;
      println("ctrl Release");
      break;
    case 66:  // 'b'
      b_key = false;
      println("b Release");
      break;
    case 81:  // 'q'
      q_key = false;
      println("q Release");
      break;
    case SHIFT:  // 'shift'
      shift = false;
      println("shift Release");
      break;
//    case ALT:
//      alt = false;
//      break;
  }
}

void mouseClicked(){
  //println("[main] Call mouseClicked");
  if(_MODE==1)set.setMouseClicked();
}

void mouseDragged(){
  //println("[main] Call mouseDragged");
  if(_MODE==1)set.setMouseDragged();
}

void mouseReleased(){
  //println("[main] Call mouseReleased");
  if(_MODE==1)set.setMouseReleased();
}

///////ここまでProcessingで用意されているイベントハンドラ//////
///////ここからメソッド////////////////////////////////////////


void saveData(String savePath){
    if(savePath != null){
      PrintWriter output;
      output=createWriter(savePath);
      output.println("<<size>>");
      //映像ファイルのサイズを定義
      //output.println(0+","+0);
      //output.println(whichMov().width+","+0);
      output.println(whichMov().width+","+whichMov().height);
      //output.println(0+","+whichMov().height);
      
      output.println("<<fix_vertex>>");
      for(int i=0;i<fix_svx.size();i++){
        output.println(fix_svx.get(i)+","+fix_svy.get(i));//X座標+コンマ+Y座標+改行
      }
      
      output.println("<<vertex>>");
      for(int i=0;i<svx.size();i++){
        output.println(svList.get(0).get(i)+","+svList.get(1).get(i));//X座標+コンマ+Y座標+改行
      }
      
      output.println("<<mask>>");
      int i2=0;
      for(int i=0;i<mposx.size();i++){
        if(i % 4 == 0){
          output.println("[opacity]");
          output.println(mopti.get(i2));
          i2++;
        }
        output.println(mposx.get(i)+","+mposy.get(i));//X座標+コンマ+Y座標+改行 マスクの座標も保存

      }
      
      output.println("<<co_point>>");
      //int prior = -1;
      for(int i=0;i<co_point.size();i++){
        output.print(co_point.get(i)+",");
      }
      output.flush();
    }
}

//プログラム起動時に実行するロード関数
//setの代わりにaddを使用する

void loadData(){
    if(datamap.get(index) != null){
            
      String[] lines=loadStrings(datamap.get(index));
      if (lines!=null){
        println("ファイルは存在します");
      }else{
        println("ファイルは存在しません");
        makingDefaultData(datamap.get(index));
        loadData();//loadData再実行
        return;
      }
      
      //各リストをクリアしてから頂点を突っ込んでいく
      //o_svx.clear();    o_svy.clear();
      fix_svx.clear();  fix_svy.clear();
      svx.clear();      svy.clear();  
      mposx.clear();    mposy.clear();
      co_point.clear();
      
      if("<<size>>".equals(lines[0])==false){//<<size>>の記述がなければエラー
        println("error <<size>> is nothing");
        return;
      }
      
      int j=1;//dataファイル読み込み時の行数を表す変数。1行目は<<size>>なのでインデックスは1からスタートする

      int[] data_size=int(split(lines[j],','));
      _movie_w = data_size[0]; _movie_h = data_size[1];
      j++;

      
      if("<<fix_vertex>>".equals(lines[j])==false){//<<fix_vertex>>の記述がなければエラー
       println("error <<fix_vertex>> is nothing");
       return;
      }
      j++;
      
      while(true){
        if("<<vertex>>".equals(lines[j])){//<<vertex>>の記述があれば次の処理に移行する
          println(" <<vertex>> is loaded");
          j++;
          break;
        }
        int[] data=int(split(lines[j],','));
        fix_svx.add(data[0]); fix_svy.add(data[1]);
        j++;
      }
      
      
      while(true){
        if("<<mask>>".equals(lines[j])){//<<mask>>の記述があれば次の処理に移行する
          println(" <<mask>> is loaded");
          j++;
          break;
        }
        int[] data=int(split(lines[j],','));
        svx.add(data[0]); svy.add(data[1]);
        j++;
      }
      
      println("lines.length = "+lines.length);
      while(true){
        if("<<co_point>>".equals(lines[j])){//<<co_point>>の記述があれば次の処理に移行する
          println(" <<co_point>> is loaded");
          j++;
          break;
        }else if("[opacity]".equals(lines[j])){//[opacity]の記述があればそれはマスクの不透明度を表す
          j++;
          mopti.add(int(lines[j])); //次の行を不透明度として追加
          j++;
        }
        int[] data=int(split(lines[j],','));
        println(data[0],data[1]);
        mposx.add(data[0]); mposy.add(data[1]);
        j++;
      }
      
      //co_pointが記録されていたら
      if(j < lines.length){
        int[] data=int(split(lines[j],','));
        for(int i=0;i<data.length-1;i++){ //なぜか0が最後に格納されてしまうため-1している
          co_point.add(data[i]);
          print(data[i]+",");
        }
      }
      
      //2016/10/18追記
      //全体をシフトしたいときに用いる
      for(int i=0;i<svx.size();i++){
        svx.set(i,svx.get(i)+BUG_SHIFT_X);
        svy.set(i,svy.get(i)+BUG_SHIFT_Y);
      }
      for(int i=0;i<mposx.size();i++){
        mposx.set(i,mposx.get(i)+BUG_SHIFT_X);
        mposy.set(i,mposy.get(i)+BUG_SHIFT_Y);
      }
      //2016/10/18ここまで
    }

}
//
//ファイルが存在しない場合、基本となるファイルを自動作成する
//
void makingDefaultData(String str){
   PrintWriter output;
   output=createWriter(str);
   whichMov().play();
   whichMov().volume(0);
   delay(200); //動画のサイズを取得するためにplay後少し待つ
   int w = whichMov().width;
   int h = whichMov().height;
   whichMov().pause();
   whichMov().jump(0);
   
   output.println("<<size>>");
   output.println(w+","+h);
   
   output.println("<<fix_vertex>>");
   output.println(0+","+0);//X座標+コンマ+Y座標+改行
   output.println(w+","+0);
   output.println(w+","+h);
   output.println(0+","+h);
    
   output.println("<<vertex>>");
   output.println(0+","+0);//X座標+コンマ+Y座標+改行
   output.println(w+","+0);
   output.println(w+","+h);
   output.println(0+","+h);
    
   output.println("<<mask>>");
   output.println("[opacity]");
   output.println(255);
   output.println(0+","+400);//X座標+コンマ+Y座標+改行
   output.println(400+","+0);
   output.println(400+","+300);
   output.println(0+","+300);
    
   output.println("<<co_point>>");
   output.flush();
}  



Movie whichMov(){
  switch(index){
     case 0:
      return mov0;
     case 1:
      return mov1;
    case 2:
      return mov2; 
    case 3:
      return mov3;
    case 4:
      return mov4;
    case 5:
      return mov5;
    case 6:
      return mov6; 
    case 7:
      return mov7;
    case 8:
      return mov8; 
    case 9:
      return mov9;
    default:
    return mov1;
  }
}

// 引数が必要な場合にwhichMov()の代わりに利用する関数
Movie selectMov(int i){
  switch(i){
     case 0:
      return mov0;
     case 1:
      return mov1;
    case 2:
      return mov2; 
    case 3:
      return mov3;
    case 4:
      return mov4;
    case 5:
      return mov5;
    case 6:
      return mov6; 
    case 7:
      return mov7;
    case 8:
      return mov8; 
    case 9:
      return mov9;
    default:
    return mov1;
  }
}
// 動画のフレームが読み込まれたときにそれを取得するイベント
void movieEvent(Movie m) {
  //g.removeCache(whichMov());
  m.read();
}


//映像切り替えを行う関数
//引数に指定した整数に対応した映像をセット
void changeMovie(int number){
  
  //時間を飛ばして任意のタイミングで映像を切り替える
  //変化後のインデックスを引数として受け取っている
  //nextキーで遷移する前提
    

    whichMov().jump(0);
    whichMov().pause();
   
    whichMov().speed(1.0);
    index = number;
    loadData();
    fadein = 1; //fadeinの有無は描画時に行う
    fadeout = -1;    //フェードアウト中ならキャンセルする
    c = 0.0;
    //チェリボ終わったらここでplaying変数のコメントアウト外して
    playing = -1;    //映像を切り替えたらplayingを-1にする
    editSvNo = -1;
    editMposNo = -1;
    if(_MODE==1)set.setFixVertex();//切り取るために、svにfixVertexの値を代入する
    kukei_select = 0; //選択されている矩形をリセット
    
    // 2017/07/05 音声を出したくない動画をミュートさせる
    //switch(index){
    //case 4:whichMov().volume(0);break;
    //case 5:whichMov().volume(0);break;
    //case 6:whichMov().volume(0);break;
    //default:break;
    //}
    //

    //スピードを変えたいときはここでインデックス指定する
   //if(index==12){
   //  whichMov().speed(0.9);
   //}
    
   // //すぐに再生してほしい映像はインデックス指定でここで処理する
   //if(index!=0 && index!=6 && index != 23){
   //  whichMov().play(); playing=1;
   //}else{
   //  playing = -1;
   //}
   
   /*
    switch(index){
    case 2:whichMov().play(); playing=1;break;
    case 3:whichMov().play(); playing=1;break;
    case 4:whichMov().play(); playing=1;break;
    case 5:whichMov().play(); playing=1;break;
    case 7:whichMov().play(); playing=1;break;
    case 8:whichMov().play(); playing=1;break;
    default:break;
    }
    */
    //ここまで
}


public void loopCheck(){
  
  //if(index == 9)//炎上
  //  if(playing == 1){ //再生中はplaying=1 のはず
  //    if(/*whichMov().time() <= 5.0 && */whichMov().time()>=169.999){
  //      whichMov().jump(0.05); //最初に戻る（ループ）
  //    }
  //  }
 

}

public void loopOut(){
  
}


public void coPoint(){
  ArrayList<Integer> temp =new ArrayList<Integer>();
  for(int i=0;i<co_point.size();i++){
    if(co_point.get(i)!=-1){
      temp.add(co_point.get(i));
    }else{//-1を読み込んだら
      int max = co_point.get(i-1);//一番大きい頂点座標
      for(int j=0;j<temp.size()-1;j++){//最大の頂点番号には代入を行わないから
        svx.set(temp.get(j),svx.get(max));
        svy.set(temp.get(j),svy.get(max));
      }
      temp.clear();
    }
  }
}

public void drawVertex(int x, int y, int i){ //iは頂点番号
  fill(0, 200, 200);
  if(i==editSvNo){
    fill(255,255,0);//移動中の頂点は黄色
  }else{
    for(int k = 0;k<co_point.size();k++){
     if(i==co_point.get(k)){
       fill(200,0,0);//co_pointは色を変更する
     }
    }
  }
  ellipse(x,y,5, 5);
  stroke(0,200,200);
  if(i==editSvNo){
    stroke(255,255,0);//移動中の頂点は黄色
  }else{
    for(int k = 0;k<co_point.size();k++){
      if(i==co_point.get(k)){
        stroke(200,0,0);//co_pointは色を変更する
      }
    }
  }
  strokeWeight(3);
  noFill();
  ellipse(x,y,20, 20);
  noStroke();
}





//ボタンによるイベントはメインクラスに記述しなければならない
void saveProperty(){gui.saveProperty();}
void cancelProperty(){gui.cancelProperty();}
public void controlEvent(ControlEvent theEvent) {
/*
  String name = theEvent.getController().getName();
  float i = theEvent.getController().getValue();
  println(name);
  if(name.startsWith("mask")){
    if(mask_switch[index] < MAX_MASK){
      mask_switch[(int)i]++;
     }else{
       mask_switch[(int)i]=0;
     }
  }
  */
  if (theEvent.isFrom(fix)) {
    if(fix.getState(0)){
      fix_flag = true;
    }else{
      fix_flag = false; 
    }
  }
}