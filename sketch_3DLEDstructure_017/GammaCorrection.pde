import java.awt.Color;
public class GammaCorrection {
      //inspired by Micah Scott / Fadecandy gamma correction
    private double gamma                       = 2.8; // Exponent for the nonlinear portion of the brightness curve
    private PVector whitepoint                 = new PVector(1.0,1.0,1.0); //Vector of [red, green, blue] values to multiply by colors prior to gamma correction
    private float linearSlope                  = 1.0; //Slope (output / input) of the linear section of the brightness curve
    private float linearCutoff                 = 1.0; //Y (output) coordinate of intersection between linear and nonlinear curves
    private int maxIn                          = 255; // Top end of INPUT range
    private int maxOut                         = 220; // Top end of OUTPUT range
    private int tableRes                       = 256; //size of our gamma correction table
    
    //these vals should match the HSB color range in our app sketch
    private float maxHueIn                     = 360.0; 
    private float maxSatIn                     = 100.0;
    private float maxBriIn                     = 100.0;

    int[] correctionTable; 
    GammaCorrection(){
      correctionTable = new int[tableRes];
      for(int i = 0; i < correctionTable.length; i++){
        //temporary fix
        int index = (int) Math.floor(Math.pow((double) i / (double) maxIn, gamma) * maxOut + 0.5);
        correctionTable[i] = index;
      }
    }

    /**
     * [getGammaVals description]
     * @param  {[type]} color   col           [description]
     * @param  {[type]} boolean isHsv         is the value passed as arg hsb?
     * @return {[int]}         Color as rgb 32bit int
     */
    int[] getGammaVals(float first, float second, float third, boolean isHsb){
      int _red; 
      int _green; 
      int _blue;
      int[] colors = new int[3];

      if(!isHsb){//it must be rgb
        int _first = (int) first;
        int _second = (int) second;
        int _third = (int) third;
        colors[0] = correctionTable[_first];
        colors[1] = correctionTable[_second];
        colors[2] = correctionTable[_third];
      }
      else {//it must be hsb

        
        //_red = (int) (255 * (Math.pow((double) first / (double) 255, gamma)));
        //_green = (int) (255 * (Math.pow((double) second / (double) 255, gamma)));
        //_blue = (int) (255 * (Math.pow((double) third / (double) 255, gamma)));

        float mappedHue = map(first, 0.0, maxHueIn, 0.0, 1.0);
        float mappedSat = map(second, 0.0, maxSatIn, 0.0, 1.0);
        float mappedBri = map(third, 0.0, maxBriIn, 0.0, 1.0);
        //println(mappedHue + " s: " + mappedSat + " b: " + mappedBri );
        
        Color _rgb = new Color(Color.HSBtoRGB(mappedHue, mappedSat, mappedBri));
        
        colors[2] = correctionTable[(int) _rgb.getRed()];
        colors[1] = correctionTable[(int) _rgb.getGreen()];
        colors[0] = correctionTable[(int) _rgb.getBlue()];

      }

      return colors;
    }
}
