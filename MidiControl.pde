//MIDIコンのイベントハンドラはDraw関数内のどこで呼び出されるかわからないのでプログラムを書くときは注意
//
//


//ライブラリをインポート
import themidibus.*; //Import the library

//MidiControlクラスの宣言
public class MidiControl{
   
  MidiBus myBus; // The MidiBus//MidiBusクラスの変数「myBus」を作成。複数MIDIコンを使いたい場合には、myBus1,myBus2等、複数作れば良い…はず。
  
  //定数

  
  //ボタン判定用のコンストラクタ。直前のvalueの値を対応する変数に格納することでシュミットトリガ回路のように扱う
  //-1を初期値に設定した場合、ボタンを使用不可にする（ようにしたいな）
  
  private int pre43 = 0;//巻き戻し（冒頭にjump）
  private int pre44 = 0;//早送り（10秒ずつjump）
  private int pre42 = 0;//停止ボタン
  private int pre41 = 0;//再生ボタン
  private int pre45 = 0;//録音ボタン
  private int pre58 = 0;//prev trackボタン
  private int pre59 = 0;//next trackボタン
  
  private int preCycle = 0;//46 cycleとset同時押しでexit()
  private int preSet = 0;//60
  
  private int pre32 = 0;//左端のS
  private int pre48 = 0;//左端のM
  private int pre64 = 0;//左端のR
  
  private int pre33 = 0;//左端から2番目のS
  private int pre49 = 0;//左端から2番目のM
  private int pre62 = 0;//marker left
  private int pre65 = 0;//左端から2番目のR
  
  private int pre39 = 0;//右端のS
  private int pre55 = 0;//右端のM
  private int pre71 = 0;//右端のR
  
  
  
  MidiControl(){
    //つながっているMIDI関係機器を表示。このリストの番号で、後ほどのIn Outの設定をする。
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

//
  // Either you can
  //                   Parent In Out
  //                     |    |  |
  //myBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.

  // or you can ...
  //                   Parent         In                   Out
  //                     |            |                     |
  //myBus = new MidiBus(this, "IncomingDeviceName", "OutgoingDeviceName"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.

//先ほど表示したリストから番号か、もしくは名前で指定。毎回同じ機材を使うのであれば名前で指定したほうがいいのか？
//In Outのうち使わないところには-1を指定すれば良い模様。

  // or for testing you could ...
  //                 Parent  In        Out
  //                   |     |          |
  myBus = new MidiBus(this, "nanoKONTROL2", "nanoKONTROL2"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.

    
  }
  
  void midiDraw() {
    int channel = 0;
    int pitch = 64;
    int velocity = 127;
  
  //ノートを送る。
    myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
    delay(200);
    myBus.sendNoteOff(channel, pitch, velocity); // Send a Midi nodeOff
  
    int number = 0;
    int value = 90;
    
  
  //コントロールチェンジを送る
    myBus.sendControllerChange(channel, number, value); // Send a controllerChange
    delay(2000);
    
    
  }
  
  //ノートオンが来たときに起きる関数
  void noteOn(int channel, int pitch, int velocity) {
    // Receive a noteOn
    println();
    println("Note On:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);
  }
  
  //ノートオフが来たときに起きる関数
  void noteOff(int channel, int pitch, int velocity) {
    // Receive a noteOff
    println();
    println("Note Off:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);
  }
  
  //コントロールチェンジが来たときに起きる関数
  void controllerChange(int channel, int number, int value) {
    // Receive a controllerChange
    
    //MIDIの入力メッセージ見たくないときはこの関数をコメントアウト
    //keyMessage(channel, number, value);
    

    
    if(number == 41){//再生ボタンが押されたなら

      if(pre41 == 0 && value > 0){
        keyControl.playKey();
      }else{
        pre41 = value;
      }
    }else if(number == 42){//停止ボタン
      if(pre42 == 0 && value > 0){
        keyControl.cutoutKey();
      }else{
        pre42 = value;
      }
    }else if(number == 43){//巻き戻しボタン
      if(pre43 == 0 && value > 0){
        keyControl.restartKey();
      }else{
        pre43 = value;
      }
    }else if(number == 44){//早送りボタン
      if(pre44 == 0 && value > 0){
        keyControl.jumpKey();
      }else{
        pre44 = value;
      }
    }else if(number == 45){//録音ボタン
      if(pre45 == 0 && value > 0){
        keyControl.fadeoutKey();
      }
    }else if(number == 58){//prevボタン
      if(pre58 == 0 && value > 0){
        keyControl.prevKey();
      }
    }else if(number == 59){//nextボタン
      if(pre59 == 0 && value > 0){
        keyControl.nextKey();
      }
    }else if(number == 0){//左から1番目（画面のフェーダー）のフェーダーが操作されたなら
      fader0 = value;
    }else if(number == 1){//左から2番目（音量）のフェーダーが操作されたなら
      whichMov().volume(map(value,0,127,0,1.0));//valueを0～1.0の範囲に収める
    }else if(number == 7){//右端のフェーダーが操作されたら //39,45,71
      if(pre39 > 0){
        mopti.set(0,(int)map(value,0,127,255,0));
      }else if(pre45 > 0){
        mopti.set(1,(int)map(value,0,127,255,0));
      }else if(pre71 > 0){
        mopti.set(2,(int)map(value,0,127,255,0));
      }
    }else if(number == 16){//左端のつまみを操作したら
      //selectMov(index).speed(map(value,0,127,1.0,MAX_SPEED));  
    }else if(number == 62){
      if(pre62 == 0 && value > 0){
        keyControl.nextTrackKey();
      }
    }else if(number == 39){
      pre39 = value;
    }else if(number == 55){
      pre55 = value;
    }else if(number == 71){
      pre71 = value;
    }else if(number == 46){
      preCycle = value;
    }else if(number == 60){
      preSet = value;
      if(value==0){
        b_key=false;
      }else{
        b_key=true;
      }
      
    }else if(number == 32){//左端の"S" 
      if(pre32 == 0 && value > 0){
        keyControl.speedChangeKey(MAX_SPEED);
      //}else{
      //  pre32 = value;
      }
    }else if(number == 48){//左端の"M"
      if(pre48 == 0 && value > 0){
        //keyControl.speedChangeKey(1.0);
      }else{
        pre48 = value;
      }
    }else if(number == 64){//左端の"R"
      if(pre64 == 0 && value > 0){
        keyControl.speedChangeKey(1.0);
      //}else{
      //  pre64 = value;
      }
    }
    else if(number == 33){//左端から2番目の"S"
      if(pre33 == 0 && value > 0){
        //keyControl.speedChangeKey(MAX_SPEED/2);
      }else{
        pre33 = value;
      }
    }else if(number == 49){//左端から2番目の"M"
      if(pre49 == 0 && value > 0){
        //keyControl.speedChangeKey(MAX_SPEED/3);
      }else{
        pre49 = value;
      }
    }else if(number == 65){//左端から2番目の"R"
      if(pre65 == 0 && value > 0){
        //keyControl.speedChangeKey(MAX_SPEED/4);
      }else{
        pre65 = value;
      }
    }
    if(preSet == 127 && preCycle == 127){
      exit();
    }
  }
  
  void keyMessage(int channel, int number, int value){
    println();
    println("Controller Change:");
    println("--------");
    println("Channel:"+channel);
    println("Number:"+number);
    println("Value:"+value);
  }
  
  void delay(int time) {
    int current = millis();
    while (millis () < current+time) Thread.yield();
  }
}