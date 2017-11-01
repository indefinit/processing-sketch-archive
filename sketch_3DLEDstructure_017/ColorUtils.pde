// color lerpMultiColors(color[] colors, float t){
//   for (color col : colors) {
    
//   }
//   if( t == 0.0 ){ return colors[0]; }
//   else if( t == 1.0 ){ return colors[colors.length -1]; }
  
//   return color(
//     lerpWrapped( s_hsv.x, f_hsv.x, 1.0f, t )
//     , lerp( s_hsv.y, f_hsv.y, t )
//     , lerp( s_hsv.z, f_hsv.z, t )
//     , lerp( start.a, finish.a, t ) );
// }

// /////////////////////////////////////////////////////////
// //

// ////////////////////////////////////////////////////////////

//    color getColor(int _rib, int _strand, int _pcb){
//      return sceneColors[_rib][_strand][_pcb];
//    }
   
//    void setColor(color _color){
//      sceneColors[rib][strand][pcb] = _color;
//    }
   
//    void layer(color _newLayer){
//      color current = sceneColors[rib][strand][pcb];
//      float blendPercent = (brightness(_newLayer)/100);
//      float aR = (red(current)/360)*255;
//      float aG = (green(current)/100)*255;
//      float aB = (blue(current)/100)*255;
//      float bR = (red(_newLayer)/360)*255;
//      float bG = (green(_newLayer)/100)*255;
//      float bB = (blue(_newLayer)/100)*255;
//      colorMode(RGB,255,255,255);
//      color a = color(aR, aG, aB);
//      color b = color(bR, bG, bB);
//      //float pcent = (mouseX/float(width));
//      color blend = lerpColor(a,b,blendPercent);
//      float newHue = (hue(blend)/255)*360;
//      float newSaturation = (saturation(blend)/255)*100;
//      float newBrightness = (brightness(blend)/255)*100;
//      colorMode(HSB,360,100,100);
//      color composite =  color(newHue,newSaturation,newBrightness);
//      setColor(composite);
//    }
    color layerColor(color _previousColor, color _newLayer, float _pcent){
      color previousColor = _previousColor;
      //float blendPercent = (brightness(_newLayer)/100);
      float aR = (red(_previousColor)/360)*255;
      float aG = (green(_previousColor)/100)*255;
      float aB = (blue(_previousColor)/100)*255;
      float bR = (red(_newLayer)/360)*255;
      float bG = (green(_newLayer)/100)*255;
      float bB = (blue(_newLayer)/100)*255;
      colorMode(RGB,255,255,255);
      color a = color(aR, aG, aB);
      color b = color(bR, bG, bB);
      color blend = lerpColor(a,b,_pcent);
      float newHue = (hue(blend)/255)*360;
      float newSaturation = (saturation(blend)/255)*100;
      float newBrightness = (brightness(blend)/255)*100;
      colorMode(HSB,360,100,100);
      color composite =  color(newHue,newSaturation,newBrightness);
      return composite;
    }
    
    color addColor(color _previousColor, color _newLayer, float _pcent){
      color previousColor = _previousColor;
      //float blendPercent = (brightness(_newLayer)/100);
      float aR = (red(_previousColor)/360)*255;
      float aG = (green(_previousColor)/100)*255;
      float aB = (blue(_previousColor)/100)*255;
      float bR = (red(_newLayer)/360)*255;
      float bG = (green(_newLayer)/100)*255;
      float bB = (blue(_newLayer)/100)*255;
      colorMode(RGB,255,255,255);
      color a = color(aR, aG, aB);
      color b = color(bR, bG, bB);
      color blend = lerpColor(a,b,_pcent/100);
      float newHue = (hue(blend)/255)*360;
      float newSaturation = (saturation(blend)/255)*100;
      float newBrightness = (brightness(blend)/255)*100;
      colorMode(HSB,360,100,100);
      color composite =  color(newHue,newSaturation,newBrightness);
      return composite;
    }
   
//    color paletteWheel(color first, color second, color third, float index){
//      color wheel = color(0,0,0);
//      int stop = 360/3;
//      float aR = (red(first)/360)*255;
//      float aG = (green(first)/100)*255;
//      float aB = (blue(first)/100)*255;
//      float bR = (red(second)/360)*255;
//      float bG = (green(second)/100)*255;
//      float bB = (blue(second)/100)*255;
//      float cR = (red(third)/360)*255;
//      float cG = (green(third)/100)*255;
//      float cB = (blue(third)/100)*255;
//      colorMode(RGB,255,255,255);
//      color a = color(aR, aG, aB);
//      color b = color(bR, bG, bB);
//      color c = color(cR, cG, cB);
//        if(index < stop){
//          wheel = lerpColor(a,b,(index/(float)stop));
//        } else if(index < stop*2){
//          wheel = lerpColor(b,c,((index-stop)/((float)stop)));
//        } else if(index < stop*3){
//          wheel = lerpColor(c,a,((index-(stop*2))/((float)stop)));
//        } else {
//          println("your wheel is ready madame"); 
//        }
       
//      float newHue = (hue(wheel)/255)*360;
//      float newSaturation = (saturation(wheel)/255)*100;
//      float newBrightness = (brightness(wheel)/255)*100;
//      colorMode(HSB,360,100,100);
//      color composite =  color(newHue,newSaturation,newBrightness);
//      //setColor(composite);
//      return composite;
//    }
