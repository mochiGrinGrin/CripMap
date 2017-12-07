import controlP5.*;


  
public class GUIControl{

  
  
  

  
  //コンストラクタ
  GUIControl(){

  }
  
  void setupGUI(){
      
  //controlP5 = new ControlP5(this);
  Group g1 = controlP5.addGroup("myGroup1")
          .setBackgroundColor(color(90,200)) //color(色,不透明度)
          .setBackgroundHeight(400)
          .setSize(800,400)
          ; 
  
  guiLabel(g1);

     
  //controlP5オブジェクトにチェックボックス追加
  checkbox = controlP5.addCheckBox("checkbox",285,40);
  //配置方法決定　横に1つ並べる
  checkbox.setItemsPerRow(1);
  //横の配置は30あける
  checkbox.setSpacingColumn(10);
  //縦の配置は10空ける
  checkbox.setSpacingRow(10);
  checkbox.setGroup(g1);
  checkbox.setSize(20,20);
  //フェードイン、フェードアウトの切り替えを行うチェックボックスの配置。getStateで
  //チェックの有無を取得するので２個目の引数は意味がない
  checkbox.addItem("",0);  
  checkbox.addItem(" ",1);
  checkbox.addItem("  ",2);
  checkbox.addItem("   ",3);
  checkbox.addItem("    ",4);
  checkbox.addItem("     ",5);
  checkbox.addItem("      ",6);
  checkbox.addItem("       ",7);
  checkbox.addItem("        ",8);
  checkbox.addItem("         ",9);
  ;

//  guiMaskButton(g1);
  
  //ループの有無を決めるチェックボックス
  //controlP5オブジェクトにチェックボックス追加
  checkbox2 = controlP5.addCheckBox("checkbox2",345,40);
  //配置方法決定　横に1つ並べる
  checkbox2.setItemsPerRow(1);
  //横の配置は30あける
  checkbox2.setSpacingColumn(10);
  //縦の配置は10空ける
  checkbox2.setSpacingRow(10);
  checkbox2.setGroup(g1);
  checkbox2.setSize(20,20);
  //フェードイン、フェードアウトの切り替えを行うチェックボックスの配置。getStateで
  //チェックの有無を取得するので２個目の引数は意味がない
  checkbox2.addItem("          ",0);  
  checkbox2.addItem("           ",1);
  checkbox2.addItem("            ",2);
  checkbox2.addItem("             ",3);
  checkbox2.addItem("              ",4);
  checkbox2.addItem("               ",5);
  checkbox2.addItem("                ",6);
  checkbox2.addItem("                 ",7);
  checkbox2.addItem("                  ",8);
  checkbox2.addItem("                   ",9);
  
  //結局マスクの有無もチェックボックスで管理します
  checkbox3 = controlP5.addCheckBox("checkbox3",405,40);
  //配置方法決定　横に3つ並べる
  checkbox3.setItemsPerRow(1);
  //横の配置は30あける
  checkbox3.setSpacingColumn(10);
  //縦の配置は10空ける
  checkbox3.setSpacingRow(10);
  checkbox3.setGroup(g1);
  checkbox3.setSize(20,20);
  //フェードイン、フェードアウトの切り替えを行うチェックボックスの配置。getStateで
  //チェックの有無を取得するので２個目の引数は意味がない
  checkbox3.addItem("mask11_switch",1);  
  checkbox3.addItem("mask12_switch",2);
  checkbox3.addItem("mask13_switch",3);
  checkbox3.addItem("mask21_switch",4);
  checkbox3.addItem("mask22_switch",5);
  checkbox3.addItem("mask23_switch",6);
  checkbox3.addItem("mask31_switch",7);
  checkbox3.addItem("mask32_switch",8);
  checkbox3.addItem("mask33_switch",9);
  checkbox3.addItem("mask41_switch",0);
/*    checkbox3.addItem("mask42_switch",1);  
  checkbox3.addItem("mask43_switch",2);
  checkbox3.addItem("mask51_switch",3);
  checkbox3.addItem("mask52_switch",4);
  checkbox3.addItem("mask53_switch",5);
  checkbox3.addItem("mask61_switch",6);
  checkbox3.addItem("mask62_switch",7);
  checkbox3.addItem("mask63_switch",8);
  checkbox3.addItem("mask71_switch",9);
  checkbox3.addItem("mask72_switch",0);
    checkbox3.addItem("mask73_switch",1);  
  checkbox3.addItem("mask81_switch",2);
  checkbox3.addItem("mask82_switch",3);
  checkbox3.addItem("mask83_switch",4);
  checkbox3.addItem("mask91_switch",5);
  checkbox3.addItem("mask92_switch",6);
  checkbox3.addItem("mask93_switch",7);
  checkbox3.addItem("mask01_switch",8);
  checkbox3.addItem("mask02_switch",9);
  checkbox3.addItem("mask03_switch",0);
  *///マスクを最大3つまで表示できるようにしてたけどGUIの実装がややこしすぎて挫折しました...
  checkbox3.hideLabels();
  
  fix = controlP5.addCheckBox("fix",285,350);
  fix.addItem("fix1",1)
     .setSize(30,30)
     .setGroup(g1)
     .setColorBackground(#228B22) //通常時のボタンの色
     .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
     .setColorActive(#00FF7F) //ボタンを押したときの色
     ;

    loadProperty();//プロパティを読み込む。チェックボックス生成後に実行すること


//フェードイン、フェードアウト時間を決めるスライダー

  slider.addSlider("fade_in_time",0.1,5.0,fade_in_time_slider   ,20,340,  150,20)
        .setGroup(g1)
        .setLabel("Fade in time");
  slider.addSlider("fade_out_time",0.1,5.0,fade_out_time_slider   ,20,370,  150,20)
        .setGroup(g1)
        .setLabel("Fade out time");

//セーブボタン　このボタンが押されたら今入力されているプロパティを記録する  
  controlP5.addButton("saveProperty")
           .setPosition(345,340)
           .setSize(80,20)
           .setGroup(g1)
           .setLabel("save")
           ;

//キャンセルボタン　このボタンが押されたら入力されているプロパティを破棄する(すでに記憶されているプロパティファイルをロードする。）
  controlP5.addButton("cancelProperty")
           .setPosition(345,370)
           .setSize(80,20)
           .setGroup(g1)
           .setLabel("cancel")
           ;   
      

//アコーディオンの中にグループg1を設置する。アコーディオンなくても表示できる気はする
  accordion = controlP5.addAccordion("panel")
                       .setPosition(40+SHIFT_WINDOW_X,40+SHIFT_WINDOW_Y)
                       .setWidth(450)
                       .addItem(g1)
                     ;
  accordion.open();
  accordion.hide(); //起動時は非表示に

  //accordion.show(); //デバッグに便利なので 
  }
    
    
  //Labelに関する記述はこちらに
  void guiLabel(Group g1){
          label1 = controlP5.addTextlabel("label")
                      .setText("Num. File name             FI   Loop  Mask")
                      .setPosition(10,10)
                      .setColorValue(color(#FFFF00))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
       label_file0 = controlP5.addTextlabel("file0")
                      .setText(" 0   "+file0)
                      .setPosition(10,35)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
      
      
       label_file1 = controlP5.addTextlabel("file1")
                      .setText(" 1   "+file1)
                      .setPosition(10,65)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                      
       label_file2 = controlP5.addTextlabel("file2")
                      .setText(" 2   "+file2)
                      .setPosition(10,95)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                      
        label_file3 = controlP5.addTextlabel("file3")
                      .setText(" 3   "+file3)
                      .setPosition(10,125)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                      
        label_file4 = controlP5.addTextlabel("file4")
                      .setText(" 4   "+file4)
                      .setPosition(10,155)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                      
        label_file5 = controlP5.addTextlabel("file5")
                      .setText(" 5   "+file5)
                      .setPosition(10,185)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                      
        label_file6 = controlP5.addTextlabel("file6")
                      .setText(" 6   "+file6)
                      .setPosition(10,215)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                     
        label_file7 = controlP5.addTextlabel("file7")
                      .setText(" 7   "+file7)
                      .setPosition(10,245)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                      
        label_file8 = controlP5.addTextlabel("file8")
                      .setText(" 3   "+file8)
                      .setPosition(10,275)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                      
        label_file9 = controlP5.addTextlabel("file9")
                      .setText(" 9   "+file9)
                      .setPosition(10,305)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                      
  
                     
                     
  /*     label_mask1 = new Textlabel(controlP5,""+mask_switch[1],470,35);
       label_mask1.setGroup(g1);*/
       /* controlP5.addTextlabel("label_mask1")
                      .setText(""+mask_switch[1])
                      .setPosition(470,35)
                      .setColorValue(color(#FFFFFF))
                      .setFont(createFont("MS Gothic",20))
                      .setGroup(g1);
                      ;
                      */
  }
  
  void guiMaskButton(Group g1){
  /*
    controlP5.addButton("mask1")
             .setPosition(440,40)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(1)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             .updateSize()
             ;
             
      controlP5.addButton("mask2") //ボタン名を取得して、イベントリスナーで処理を行う
             .setPosition(440,70)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(2)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             ;
             
      controlP5.addButton("mask3") //ボタン名を取得して、イベントリスナーで処理を行う
             .setPosition(440,100)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(3)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             ;
             
                 controlP5.addButton("mask4") //ボタン名を取得して、イベントリスナーで処理を行う
             .setPosition(440,130)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(4)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             ;
             
                 controlP5.addButton("mask5") //ボタン名を取得して、イベントリスナーで処理を行う
             .setPosition(440,160)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(5)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             ;
             
                 controlP5.addButton("mask6") //ボタン名を取得して、イベントリスナーで処理を行う
             .setPosition(440,190)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(6)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             ;
             
                 controlP5.addButton("mask7") //ボタン名を取得して、イベントリスナーで処理を行う
             .setPosition(440,220)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(7)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             ;
             
                 controlP5.addButton("mask8") //ボタン名を取得して、イベントリスナーで処理を行う
             .setPosition(440,250)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(8)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             ;
             
                 controlP5.addButton("mask9") //ボタン名を取得して、イベントリスナーで処理を行う
             .setPosition(440,280)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(9)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             ;
             
                 controlP5.addButton("mask0") //ボタン名を取得して、イベントリスナーで処理を行う
             .setPosition(440,310)
             .setSize(20,20)
             .setGroup(g1)
             .setValue(0)//ボタンを押したときに呼び出される関数の引数？
             .setLabel("")
             .setColorBackground(#228B22) //通常時のボタンの色
             .setColorForeground(#3CB371) //ボタンの上にカーソルを置いた時の色
             .setColorActive(#00FF7F) //ボタンを押したときの色
             ;
  */
  }
    

  
  public void loopSwitch(){
    for(int i = 0 ;i<10;i++){
      if(loop_switch[i]==1){
        selectMov(i).loop();
      }else{
        selectMov(i).noLoop();
      }
      selectMov(i).pause();
      selectMov(i).jump(0);
      playing=-1;
    }
  }
  
   private void saveProperty(){
    println("Call saveProperty");
    for(int i=0;i<10;i++){
      if(checkbox.getState(i)){//チェックされていたらtrueが返る
        fadein_switch[i]=1;
      }else{
        fadein_switch[i]=0;
      }
    }
    for(int i=0;i<10;i++){
      if(checkbox2.getState(i)){//チェックされていたらtrueが返る
        loop_switch[i]=1;
      }else{
        loop_switch[i]=0;
      }
    }
    for(int i=0;i<10;i++){
      if(checkbox3.getState(i)){//チェックされていたらtrueが返る
        mask_switch[i]=MAX_MASK; //2017/07/04
      }else{
        mask_switch[i]=0;
      }
    }
    //fade_in_timeとfade_out_timeは自動的に代入されているのでここでは記述しない
    PrintWriter output;
    output=createWriter(property_file_name);
    for(int i=0;i<10;i++){
      output.print(fadein_switch[i]+",");//フェードインの有無を記録
    }
    output.println();//改行を挿入
    for(int i=0;i<10;i++){
      output.print(loop_switch[i]+",");//ループの有無を記憶
    }
    output.println();//改行を挿入
    for(int i=0;i<10;i++){
      output.print(mask_switch[i]+",");//マスクの有無を記憶
    }
    output.println();//改行を挿入
    output.println(fade_in_time);
    output.println(fade_out_time);
    if(fix_flag){
      output.println("1");
    }else{
      output.println("0");
    }
    fade_in_time_slider=fade_in_time;
    fade_out_time_slider=fade_out_time;
    output.flush();   
    
    loopSwitch();//ループの有無をここで更新
    println("Save Property.txt");
  }
  
  public void loadProperty(){ //起動するときにpropertyファイルを読み込む
      String[] lines=loadStrings(property_file_name);
      for(int i=0;i<10;i++){
        int[] data=int(split(lines[0],','));
        fadein_switch[i] = data[i];
        if(fadein_switch[i]==1){
          checkbox.activate(i);
        }else{
          checkbox.deactivate(i);
        }
      }
      for(int i=0;i<10;i++){
        int[] data=int(split(lines[1],','));
        loop_switch[i] = data[i];
        if(loop_switch[i]==1){
          checkbox2.activate(i);
        }else{
          checkbox2.deactivate(i);
        }
      }
      for(int i=0;i<10;i++){
        int[] data=int(split(lines[2],','));
        mask_switch[i] = data[i];
        if(mask_switch[i]>=1){
          checkbox3.activate(i);
        }else{
          checkbox3.deactivate(i);
        }
      }
      fade_in_time = float(lines[3]);
      fade_out_time = float(lines[4]);
      if(int(lines[5])==1){
        fix.activate(0);
        fix_flag=true;
      }else{
        fix.deactivate(0);
        fix_flag=false;
      }
      fade_in_time_slider=fade_in_time;
      fade_out_time_slider=fade_out_time;
      loopSwitch();//ループかそうでないかの切り替え
      println("loadProperty");
  }
  
  
  public void cancelProperty(){
    loadProperty();//セーブする前のプロパティファイルを読み込む
  }
  
  public void maskSwitchReflection(int i){
    if(mask_switch[i]>=1){
      checkbox3.activate(i);
    }else{
      checkbox3.deactivate(i);
    }
  }

  
  void accordionHide(){
    accordion.hide();
  }
  
  void accordionShow(){
    accordion.show();
  }

}