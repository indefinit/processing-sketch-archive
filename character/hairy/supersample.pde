// supersampling with guassian blur
final float clamp(float a) {
    return (a < 1) ? a : 1;
  }
class SuperSampler
{
PImage downsampled;
PImage tempImage;
PGraphics pgDirect;
PGraphics pg;
 boolean m_useDirect=false;
boolean m_tempUseDirect=false;
 
// from http://www.teamten.com/lawrence/graphics/gamma/
float GAMMA = 2.0;
int[] linear_to_gamma = new int[32769];
void SetupGammaTables()
{
    for (int i = 0; i < 32769; i++) {
        int result = (int)(sqrt(i/32768.0)*255.0 + 0.5);
        linear_to_gamma[i] = result;
    }
}
SuperSampler()
{
  SetupGammaTables();
  pgDirect=g;
  pg= createGraphics(width*2,height*2,P3D);
  tempImage = createImage(width,height*2, RGB);
}
void useDirect(boolean v) { m_tempUseDirect=v;}
int textScale(){ return m_useDirect ? 1 : 2;}
 
int height() { return pgDirect.height*textScale();}
int width() { return pgDirect.width*textScale();}
 
 
void GuassianSampleSpanFast( color[] inpix, color[] outpix, int stride, int offset0, int offset1, int width )
{
  int idx0 = offset0 +2*stride;
  int idx1 = offset1;
  
  int stride2 = stride*2;
  for (int i=2;i<width-2;i+=2)
  {  
    // convert to all integer
    // TODO perform gamma space correction
    color c0=inpix[idx0-stride2];
    int r0 =  c0 >> 16 & 0xFF;
    int g0 =  c0  >> 8 & 0xFF;
    int b0 =  c0  & 0xFF;
    
    r0=r0*r0;
    g0=g0*g0;
    b0=b0*b0;
    
    c0 = inpix[idx0+stride2];
    int r4 = c0 >> 16 & 0xFF;
    int g4 = c0 >> 8 & 0xFF;
    int b4 = c0  & 0xFF;
    r4=r4*r4;
    g4=g4*g4;
    b4=b4*b4;
    
    c0 = inpix[idx0-stride];
    int r1 = c0 >> 16 & 0xFF;
    int g1 = c0 >> 8 & 0xFF;
    int b1 = c0 & 0xFF;
    r1=r1*r1;
    g1=g1*g1;
    b1=b1*b1;
    c0 = inpix[idx0+stride];
    int r2 = c0  >> 16 & 0xFF;
    int g2 = c0  >> 8 & 0xFF;
    int b2 = c0  & 0xFF;
    r2=r2*r2;
    g2=g2*g2;
    b2=b2*b2;
    
    r2 = (r1+r2)<<2; // *4
    g2 = (g1+g2)<<2;
    b2 = (b1+b2)<<2;
    
    c0 = inpix[idx0];
    int r3 = c0 >> 16 & 0xFF;
    int g3 = c0 >> 8 & 0xFF;
    int b3 = c0  & 0xFF;
    r3=r3*r3;
    g3=g3*g3;
    b3=b3*b3;
    int r = r0+r4+r2+r3*6;
    int g = g0+g4+g2+g3*6;
    int b = b0+b4+b2+b3*6;
  
    r = linear_to_gamma[ r >>5]; // /16
    g = linear_to_gamma[g >>5];
    b = linear_to_gamma[b >>5];
     
    color res = (r<<16)|(g<<8)|b;
    outpix[idx1]= res;
    idx1+=stride;
    idx0+=stride2;
  }  
}
void GuassianSampleSpanFirst( color[] inpix, color[] outpix, int stride, int stridex, int stridex2,
                          int offset0, int offset1, int width, int step )
{
  int idx0 = offset0 +2*stride;
  int idx1 = offset1;
  
  int stride2 = stride*2;
  
  color c0=inpix[idx0];
  
  int r0 =  c0 >> 16 & 0xFF;
  int g0 =  c0  >> 8 & 0xFF;
  int b0 =  c0  & 0xFF;
  r0=r0*r0;
  g0=g0*g0;
  b0=b0*b0;
    
  int r1=r0;int r2=r0;
  int g1=g0;int g2=g0;
  int b1=b0;int b2=b0;
  for (int i=step;i<width-step;i+=step)
  {  
    c0 = inpix[idx0];
    int r3 = c0 >> 16 & 0xFF;
    int g3 = c0 >> 8 & 0xFF;
    int b3 = c0  & 0xFF;
    r3=r3*r3;
    g3=g3*g3;
    b3=b3*b3;
    
    c0 = inpix[idx0+1];
    int r4 = c0 >> 16 & 0xFF;
    int g4 = c0 >> 8 & 0xFF;
    int b4 = c0 & 0xFF;
    r4=r4*r4;
    g4=g4*g4;
    b4=b4*b4;
    
    int r = r0+r4+((r1+r3)<<2)+r2*6;
    int g = g0+g4+((g1+g3)<<2)+g2*6;
    int b = b0+b4+((b1+b3)<<2)+b2*6;
  
     r0=r2;g0=g2;b0=b2;
     r1=r3;g1=g3;b1=b3;
     r2=r4;g2=g4;b2=b4;
        
    r = linear_to_gamma[ r >>5]; // /16
    g = linear_to_gamma[g >>5];
    b = linear_to_gamma[b >>5];
    color res = (r<<16)|(g<<8)|b;
    outpix[idx1]= res;// transpose here
    idx1++;
    idx0+=2;
  }  
}
  
  
import java.util.concurrent.atomic.AtomicInteger;
 
AtomicInteger g_guassianWorkCnt;
  
class GuassianStrip implements WorkItem
{
  PImage in;
  color[]  out;
  PImage temp;
  int pass;
  int s;
  int e;
 
  GuassianStrip( PImage _in, color[]  _out, PImage _temp, int _pass, int _s, int _e) {
    pass=_pass;s=_s;e=_e;in=_in;out=_out;temp=_temp;
  }
  public void run(int threadId )
  {
    if ( pass==0){
       for (int i=s;i<e;i++)
            GuassianSampleSpanFirst( in.pixels, temp.pixels, 1, 1,2,i*in.width, i*temp.width, in.width,2);
 
      if ( g_guassianWorkCnt.decrementAndGet()==0){
         int oh=temp.width;
         int amt=(oh/32)+(oh%32)==0 ? 0 : 1;
         g_guassianWorkCnt.set(amt);
         for (int i=1;i<oh-2;i+=32)
          g_renderQueue.execute( new GuassianStrip(in,out,temp,1,i,min(i+32,oh-2)));
      } 
    }
    else
    {
        for (int i=s;i<e;i++)
          GuassianSampleSpanFast( temp.pixels, out, temp.width, i,i,temp.height);
       
    //  if ( g_guassianWorkCnt.decrementAndGet()==0)   
      //    pgDirect.updatePixels();
 
    }
  }
};
  
 
void DownSampleGuassian( PImage in, color[] out, PImage temp )
{
  in.updatePixels();  
    int oh=in.height;
   int amt=(oh/32)+(oh%32)==0 ? 0 : 1;
    
    g_guassianWorkCnt  = new AtomicInteger(amt);
     for (int i=1;i<oh-2;i+=32)
    {
      g_renderQueue.execute( new GuassianStrip(in,out,temp,0,i,min(i+32,oh-2)));
    }
}
// faster version required
void Apply()
{
  loadPixels();
  DownSampleGuassian( pg, pixels, tempImage);
}
void beginDraw(boolean reset){
  m_useDirect=m_tempUseDirect;
  pgDirect =(g);
  if (!m_useDirect){
    g=pg;
    pg.beginDraw();
    if (reset)
      pg.resetMatrix();
     else{
      pg.scale(2,2,1);
     }
  }
}
void endDraw()
{
   if (!m_useDirect)
   {
     pg.endDraw();
     g=pgDirect;
     Apply();
   }
}
}

