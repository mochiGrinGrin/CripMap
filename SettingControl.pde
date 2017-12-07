//映像を切り取る際に使用するメソッドたちをまとめるためのクラス


public class SettingControl{
  private int mouseX_start=-1,mouseY_start=-1; //ドラッグを開始したときの座標を記憶
  //private boolean click_flag = false; //mouseClickedの際にmouseReleasedが呼び出されることを防ぐ
  private boolean drag_flag = false; //mouseDragged()が「マウスボタンを押しながら移動しているときのみ呼び出される」という仕様なのでドラッグはフラグで管理
  //private boolean release_flag = false;
  private int select_area=-1; //右クリックしたとき、マウスカーソルがあった座標を含んでいる四角形の左上頂点のインデックスを記憶
  
  //コンストラクタ
  SettingControl(){

  }
  
  //描画系の処理をまとめた
  void settingDraw(){
    //動画の範囲外に出ないようにする
    if(mouseX > selectMov(index).width){
      mouseX = selectMov(index).width;
    }
    if(mouseY > selectMov(index).height){
      mouseY = selectMov(index).height;
    }
    for(int j=0;j<select.size();j++){//頂点が選択されているときカーソルがその直線に吸着されるようにする
      fill(0,200,200);
      stroke(0,200,200);
      strokeWeight(3);
      line(svList.get(0).get(select.get(j)),0,svList.get(0).get(select.get(j)),displayHeight);
      line(0,svList.get(1).get(select.get(j)),displayWidth,svList.get(1).get(select.get(j)));
      noStroke();
      if(mouseX >= svList.get(0).get(select.get(j)) - 10 && mouseX <= svList.get(0).get(select.get(j)) + 10){
        mouseX = svList.get(0).get(select.get(j));
      }
      if(mouseY >= svList.get(1).get(select.get(j)) - 10 && mouseY <= svList.get(1).get(select.get(j)) + 10){
        mouseY = svList.get(1).get(select.get(j));
      }
    }
    //頂点付近にカーソルがあるとき、その頂点に吸着されるようにする
    //for(int i=0; i<svx.size(); i++) {
    //  float distance = dist(mouseX, mouseY, svList.get(0).get(i),svList.get(1).get(i) );
    //  if(distance < ADSORPTION){
    //     mouseX = svList.get(0).get(i);
    //     mouseY = svList.get(1).get(i);
    //  }
    //}
    //頂点によって四角形が構成されているのであれば辺を表示する
    for(int i=0;i<svx.size();i=i+4){
      int a=i+0;int b=i+1;int c=i+2;int d=i+3;
      stroke(255,255,0);//黄色になるといいな
      strokeWeight(1);
      line(svList.get(0).get(a),svList.get(1).get(a),svList.get(0).get(b),svList.get(1).get(b));
      line(svList.get(0).get(a),svList.get(1).get(a),svList.get(0).get(d),svList.get(1).get(d));
      line(svList.get(0).get(d),svList.get(1).get(d),svList.get(0).get(c),svList.get(1).get(c));
      line(svList.get(0).get(b),svList.get(1).get(b),svList.get(0).get(c),svList.get(1).get(c));
      noStroke();
    }
    //選択されている頂点なら塗りつぶす
    for(int i=0;i<select.size();i++){
      fill(0,200,200);
      for(int k = 0;k<co_point.size();k++){
        if(select.get(i)==co_point.get(k)){
          fill(200,0,0);//co_pointは色を変更する
        }
      }
       ellipse(svx.get(select.get(i)),svy.get(select.get(i)),20, 20);
    }
    
    //ドラッグ中なら四角形を表示する
    if(drag_flag){
      stroke(255,255,0);//黄色になるといいな
      fill(255,255,0,60);
      strokeWeight(1);
      int minX,maxX,minY,maxY;
      if(mouseX_start < mouseX){
        minX = mouseX_start; maxX = mouseX;
      }else{
        maxX = mouseX_start; minX = mouseX;
      }
      if(mouseY_start < mouseY){
        minY = mouseY_start; maxY = mouseY;
      }else{
        maxY = mouseY_start; minY = mouseY;
      }
      quad(minX,minY,maxX,minY,maxX,maxY,minX,maxY);
      noStroke();
    }
    //選択している四角形に色を付ける
    if(select_area != -1){
      int a = select_area; int c = select_area + 2;
      int minX = svx.get(a); int minY = svy.get(a); int maxX = svx.get(c); int maxY = svy.get(c); 
      stroke(255,165,0);//オレンジ色にする
      fill(255,165,0,60);
      strokeWeight(1);
      quad(minX,minY,maxX,minY,maxX,maxY,minX,maxY);
      noStroke();
    }

    //マウスポインタの左下に座標を表示する
    fill(255,255,255);
  
    int dis = 60;//マウスカーソルの位置が画面端からどの程度離れたら座標の表示位置を変更するか決める関数
    if(mouseX >= width-dis && mouseY >=height-dis){
      text(mouseX+","+mouseY,mouseX-60,mouseY-20);
    }else if(mouseX  >= width-dis && mouseY < height-dis){
      text(mouseX+","+mouseY,mouseX-60,mouseY+20);
    }else if(mouseX  < width-dis && mouseY >= height-dis){
      text(mouseX+","+mouseY,mouseX+20,mouseY-20);
    }else{
      text(mouseX+","+mouseY,mouseX+20,mouseY+20);
    }
  }
  
  
  void setFixVertex(){
    for(int i=0;i<svx.size();i++){
      svx.set(i,fix_svx.get(i));
      svy.set(i,fix_svy.get(i));
    }
  }
  
  void setSvVertex(){
    loadData();
  }
  
  void deleteArea(){
   if(select_area!=-1){
     println("delete");//try 
     //頂点を削除するとき、共有点をすべてリセットする
     //頂点を削除することでco_pointに記憶させた頂点番号と実際の頂点番号に齟齬を生じさせるため
     co_point.clear();
     for(int i=0;i<4;i++){
        svx.remove(select_area);
        svy.remove(select_area);
        fix_svx.remove(select_area);
        fix_svy.remove(select_area);
      }
      select_area=-1;//select_area 初期化
      select.clear();
    }
  }
  
  //セッティングモード時のマウスクリック処理
  void setMouseClicked(){
     //println("Call mouseClicked");
 
    //左クリックしたとき、その位置に頂点があればその頂点を選択する
    if(mouseButton == LEFT){
      //println("Call mouseClicked(LEFT)");//try
      if(ctrl==false)select.clear();//ctrlが押されていなければセレクトされている要素を全消去
      float min_distance = 2000;//最大値を記憶する一時変数
      int min_number = -1;
      for(int i=0; i<svx.size(); i++) {
        float distance = dist(mouseX, mouseY, svList.get(0).get(i),svList.get(1).get(i) );
        if(distance < min_distance ){
          min_distance = distance;
          min_number = i;
          println(min_number+","+min_distance);//try
        }
      }
      //頂点が選択されたと判定されたなら
      if(min_distance < ADSORPTION && min_number != -1){
        if(select.contains(min_number)==false){
          select.add(min_number);
        }else{//すでに登録済みであれば解除する
          select.remove(select.indexOf(min_number));
        }
        return;
      }
      println("Call mouseClicked(LEFT and except for points)");//try
      int prev_select_area = select_area;//クリックしたときのエリアがどこに該当するのか判定する前に、今まで選択していたエリアを記憶する
      for(int i=0;i<svx.size();i=i+4){
        int a=i+0; int c=i+2;
        if(mouseX >= svList.get(0).get(a) && mouseY >= svList.get(1).get(a) && mouseX <= svList.get(0).get(c) && mouseY <= svList.get(1).get(c) && mouseX < _movie_w && mouseY < _movie_h){
          select_area = a;
        }
      }
        //select_areaに変化がなければ選択を解除する
        if(prev_select_area == select_area)select_area = -1;
    }else if(mouseButton == RIGHT){ //右クリックを押したとき、頂点上であれば共有点に登録する
      println("Call mouseClicked(RIGHT)");
      for(int i=0; i<svx.size(); i++) {
        float distance = dist(mouseX, mouseY, svList.get(0).get(i),svList.get(1).get(i) );
        if(distance < ADSORPTION){
          //ここから頂点をクリックしたときの処理。iにはその頂点番号が格納されている
          int x = svx.get(i); int y = svy.get(i);
          int count = 0;
          ArrayList<Integer> temp_co_point =new ArrayList<Integer>();;
          for(int j=0;j<svx.size();j++){
            if(x == svx.get(j) && y == svy.get(j)){ //共有したい座標と同じ頂点を持ち、かつその頂点番号が登録されていないとき
              if(co_point.contains(j)==false){
                co_point.add(j); //頂点番号を記憶させる。仕様上昇順に格納される
                count++;
              }else{//登録済みの頂点の場合
                temp_co_point.add(j);
              }
            }
          }
          if(count == 1){ //countが1、つまり1頂点しか記憶されていなかったら
            co_point.remove(co_point.size()-1); //登録した番号を消す
          }else if(count > 1){
            co_point.add(-1); //切れ目を表す-1を挿入する
          }
          //すでに登録済みの共有点と全く同じ組み合わせを登録しようとしていた場合、登録済みの共有点を削除する
          if(temp_co_point.size() > 0){ //共有点削除に判定される可能性の場合だけ実行する
            temp_co_point.add(-1);//ループ判定の際に-1も追加しておいた方が都合がいいため
            for(int k = 0; k<co_point.size();k++){
              if(k == 0 || co_point.get(k-1)==-1){//co_pointで注目している頂点が-1もしくはインデックスが0のとき
                for(int t=k;t-k<temp_co_point.size() ; t++){
                  if(co_point.get(t) == -1){//一致したとき
                    for(int s=t-k+1;s>0;s--)co_point.remove(k);//kからtまでの要素を削除
                    temp_co_point.clear();
                    return; //削除したら用無しなのでリターン
                  }
                  if(co_point.get(t) != temp_co_point.get(t-k)){
                    break;
                  }
                }
              }
            }
            temp_co_point.clear();
          }
          break;
        }
      }
    } 
    
  }
  
  void setMouseDragged(){
    if(mouseButton == LEFT){
      println("Call mouseDragged(LEFT)");
      if(mouseX_start==-1 && mouseY_start==-1){
        int memoryX=mouseX; int memoryY=mouseY;
        if(memoryX > selectMov(index).width)memoryX=selectMov(index).width;
        if(memoryY > selectMov(index).height)memoryY=selectMov(index).height;
        mouseX_start=memoryX; mouseY_start=memoryY;//ドラッグし始めた時の開始点をここで記憶
        for(int i=0; i<svx.size(); i++) {
          float distance = dist(mouseX, mouseY, svList.get(0).get(i),svList.get(1).get(i) );
          if(distance < ADSORPTION){
            if(select.contains(i)==true){
              mouseX_start=svx.get(i); mouseY_start=svy.get(i);
            }
          }
        }
        drag_flag = true;//ドラッグ中はtrue
      }
    }
  }
  
  void setMouseReleased(){
   
    //println("Call mouseReleased");//try
    if(mouseButton==LEFT){
          //mouseClickedの後に呼び出されることを防ぐ
      if(mouseX_start == -1 || mouseY_start == -1){
        return;
      }
      //ドラッグしたとき四角形を構成していなければ頂点追加処理を行わない
      int mouseX_end = mouseX; int mouseY_end = mouseY; //ドラッグ終了時のマウスカーソルの座標を記憶
      //マウスクリック時の座標と指を離したときの座標が同一なら処理を終了する
      if(mouseX_start == mouseX_end || mouseX_start == mouseY_end){ 
        return;
      }
      //println("Call mouseReleased(LEFT)");//try
      //今後の処理がしやすいように登録する頂点のX、Y座標の大小関係をはっきりさせる
      int minX,maxX,minY,maxY;
      if(mouseX_start < mouseX_end){
        minX = mouseX_start; maxX = mouseX_end;
      }else{
        maxX = mouseX_start; minX = mouseX_end;
      }
      if(mouseY_start < mouseY_end){
        minY = mouseY_start; maxY = mouseY_end;
      }else{
        maxY = mouseY_start; minY = mouseY_end;
      }
      
      //頂点の登録処理
      svx.add(minX); svy.add(minY); //a
      svx.add(maxX); svy.add(minY); //b
      svx.add(maxX); svy.add(maxY); //c
      svx.add(minX); svy.add(maxY); //d
      fix_svx.add(minX); fix_svy.add(minY); //a
      fix_svx.add(maxX); fix_svy.add(minY); //b
      fix_svx.add(maxX); fix_svy.add(maxY); //c
      fix_svx.add(minX); fix_svy.add(maxY); //d
      
      mouseX_start=-1;mouseY_start=-1; //初期化
      drag_flag = false;

    } 
  }
}