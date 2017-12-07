//キー操作関連のメソッドをまとめるためだけのクラス
import java.awt.event.*;
import javax.swing.*;

public class KeyControl/* implements ActionListener*/{
  
  Timer play_timer;
 // 2016/08/25 消しました
 // private boolean playkey_permission = true;
  
  
  void playKey(){
    /*
    if(playing == -1 || playing==0){
      if(playkey_permission==false)return;//不許可なら何もしない
      play_timer = new Timer(1000 ,this);
      play_timer.start();
      playkey_permission = false; //1秒経過するまで不許可にする
    }
    */
    
    println("'p' pressed. playing = "+playing);
    //if(_mov_width==0)_mov_width=selectMov(index).width;
    //if(_mov_height==0)_mov_height=selectMov(index).height;
    /*playing = -1...黒画面で停止の状態
      playing =  0...一時停止状態
      playing =  1...再生中*/
    if(playing == -1){
      selectMov(index).play();
      playing = 1;
      fadein = 1; //fadeinの有無の判定はメインクラスで行う
    }else if(playing == 0){
      selectMov(index).play();
      playing = 1;
    }else if(playing == 1 && fadeout == -1){
      selectMov(index).pause();
      playing = 0;
    }else{
      println("playing変数に正しい値が入っていません");
    }
  }

  void pauseKey(){
    whichMov().pause();
    playing = 0;
/*    fadeout = -1;    //フェードアウト中ならキャンセルする
    c = 0.0;
    playing = -1;    //映像を切り替えたらplayingを-1にする
    */
  }
  
  void restartKey(){
    selectMov(index).jump(0);
    //再生ボタン押下時にfadeinを1にしないと黒画面表示中に勝手にフェードインする
    //fadein = 1;
    if(playing==0){ 
      playing = -1; 
//    }else if(playing==1 && fadeout == -1 && fadein_switch[index]==1){
    }
  }
  
  void jumpKey(){
    float t = selectMov(index).time() + 10;    
    if(t < selectMov(index).duration()){
      selectMov(index).jump(t);
    }
    //selectMov(index).play();
    //selectMov(index).pause();
  }
  
  void fadeoutKey(){
    fadeout = 1;
  }
  
  void cutoutKey(){
    fadeout = -1;
    selectMov(index).pause();
    playing = -1;
  }
  
  void prevKey(){
    int temp_index = index -1;
    if(temp_index<0){
      temp_index = MAX_INDEX;
    }
    changeMovie(temp_index);
  }
  
  void nextKey(){
    int temp_index = index + 1;

    /*
    if(temp_index == 10){
      if(selectMov(index).time()<7.95){
        selectMov(index).jump(7.95);
        return;
      }else{
        temp_index++;
      }
    }
    */
    
    //final
    /*
    if(temp_index == 21){
      if(selectMov(index).time()<9.95){
        selectMov(index).jump(9.95);
        return;
      }else if(selectMov(index).time()<29.95){
        selectMov(index).jump(29.95);
        return;
      }else{
        temp_index=23;
      }
    }
    */
    
    
    //ここまで
    if(temp_index>MAX_INDEX){
      temp_index=0;
    }
    changeMovie(temp_index);
  }
  
  //本当にプログラムが動いているのか不安になったとき
  void checkKey(){
    fill(255,255,255);
    text(index,CHECK_POINT_X,CHECK_POINT_Y);
    if(frameRate < FRAME_RATE-1)fill(255,255,0);//規定のフレームレートより1以上小さくなっていれば黄色文字にする
    text(frameRate,CHECK_POINT_X+25,CHECK_POINT_Y);
    fill(255,255,255);
    text(filemap.get(index),CHECK_POINT_X,CHECK_POINT_Y+15);
   if(playing ==1)text("playing now",CHECK_POINT_X,CHECK_POINT_Y-15);
    else if(playing==0) text("pause",CHECK_POINT_X,CHECK_POINT_Y-15);
    else text("stop",CHECK_POINT_X,CHECK_POINT_Y-15);//playing == -1
    text("location of playback = "+selectMov(index).time(),CHECK_POINT_X,CHECK_POINT_Y-30);
    if(fader0<125)fill(255,255,0); //fader0の値が127近くでなければエラーを出す
    text("Fader : "+fader0,CHECK_POINT_X,CHECK_POINT_Y-45);
    fill(255,255,255);
    text("BUG_SHIFT : "+BUG_SHIFT_X+", "+BUG_SHIFT_Y,CHECK_POINT_X,CHECK_POINT_Y-60);
  }
  
  //引数に指定した速度に変化させる
  void speedChangeKey(float s){
    //誤操作の原因となるため使わないときはコメントアウト
    //selectMov(index).speed(s);
  }
  
  void smallKey(){
    //各矩形の大きさを元の大きさよりも50分の1小さくする
    if(kukei_select==0){
      for(int i = 1; i<svx.size();i+=4){
        //iが1から始まることに注意
        int w = fix_svx.get(i)-fix_svx.get(i-1);
        int h = fix_svy.get(i+2)-fix_svy.get(i-1);
        svx.set(i,svx.get(i)-w/SMALL_BIG);
        //svy.set(i,svy.get(i)-h/SMALL_BIG);
        svx.set(i+1,svx.get(i+1)-w/SMALL_BIG);
        svy.set(i+1,svy.get(i+1)-h/SMALL_BIG);
        //svx.set(i+2,svx.get(i+2)-w/SMALL_BIG);
        svy.set(i+2,svy.get(i+2)-h/SMALL_BIG);
      }
    }else{
      int i = (kukei_select -1)*4+1;
      int w = fix_svx.get(i)-fix_svx.get(i-1);
      int h = fix_svy.get(i+2)-fix_svy.get(i-1);
      svx.set(i,svx.get(i)-w/SMALL_BIG);
      //svy.set(i,svy.get(i)-h/SMALL_BIG);
      svx.set(i+1,svx.get(i+1)-w/SMALL_BIG);
      svy.set(i+1,svy.get(i+1)-h/SMALL_BIG);
      //svx.set(i+2,svx.get(i+2)-w/SMALL_BIG);
      svy.set(i+2,svy.get(i+2)-h/SMALL_BIG);
    }
  }
  
  void bigKey(){
    //各矩形の大きさを元の大きさよりも50分の1大きくする
    if(kukei_select==0){
      for(int i = 1; i<svx.size();i+=4){
        int w = fix_svx.get(i)-fix_svx.get(i-1);
        int h = fix_svy.get(i+2)-fix_svy.get(i-1);
        svx.set(i,svx.get(i)+w/SMALL_BIG);
       //svy.set(i,svy.get(i)+fix_svy.get(i)/SMALL_BIG);
        svx.set(i+1,svx.get(i+1)+w/SMALL_BIG);
        svy.set(i+1,svy.get(i+1)+h/SMALL_BIG);
        //svx.set(i+2,svx.get(i+2)+fix_svx.get(i+2)/SMALL_BIG);
        svy.set(i+2,svy.get(i+2)+h/SMALL_BIG);
      }
    }else{
      int i = (kukei_select -1)*4+1;
        int w = fix_svx.get(i)-fix_svx.get(i-1);
        int h = fix_svy.get(i+2)-fix_svy.get(i-1);
        svx.set(i,svx.get(i)+w/SMALL_BIG);
       //svy.set(i,svy.get(i)+fix_svy.get(i)/SMALL_BIG);
        svx.set(i+1,svx.get(i+1)+w/SMALL_BIG);
        svy.set(i+1,svy.get(i+1)+h/SMALL_BIG);
        //svx.set(i+2,svx.get(i+2)+fix_svx.get(i+2)/SMALL_BIG);
        svy.set(i+2,svy.get(i+2)+h/SMALL_BIG);
    }
  }
  
  void rightShiftKey(){
    BUG_SHIFT_X++;
  }
  
  void leftShiftKey(){
    
  }
  
  void upShiftKey(){
    
  }
  
  void downShiftKey(){
    
  }
  
  //next Trackボタンを押すと変化起こす
  void nextTrackKey(){
    if(index==1){//OP
      selectMov(index).jump(5.03);
    }
  }
}