/**
 * OscManager class
 * @description: A simple wrapper for Andreas Schlegel's oscP5
 * To use, add this .pde in your Processing sketch and you should be good to go
 * @author: kevin siwoff
 * @date: 1-12-15
 */
import oscP5.*;
import netP5.*;

class OscManager {
  private String _address;
  private int _sendPort;
  private int _receivePort;
  private OscP5 _oscP5;
  private NetAddress _broadcastLoc;
  public ArrayList<Byte> byteBuffer;
  //holds all of our byte buffers
  public ArrayList<ArrayList<Byte>> byteBuffers;

  /**
   * Default constructor w/ no args
   */
  OscManager(){
    this._address = "127.0.0.1";//localhost
    this._sendPort = 3000;
    this._receivePort = _sendPort + 1000;
    //we initialize our oscP5 instance by passing in parent and receive port
    _oscP5 = new OscP5(this, _receivePort);
    _broadcastLoc = new NetAddress(_address, _sendPort);
    byteBuffer = new ArrayList<Byte>();
    byteBuffers = new ArrayList<ArrayList<Byte>>(8);
  }

  OscManager(String address, int port){
    this._address = address;
    this._sendPort = port;
    this._receivePort = port + 1000;
    //we initialize our oscP5 instance by passing in parent and receive port
    _oscP5 = new OscP5(this, _receivePort);
    _broadcastLoc = new NetAddress(_address, _sendPort);
    byteBuffer = new ArrayList<Byte>();
    
    //create 8 byteBuffers
    byteBuffers = new ArrayList<ArrayList<Byte>>(){{
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
    }};

  }
  
  public OscP5 getInstance(){
    return _oscP5;
  }

  public ArrayList<Byte> getByteBuffer(){
    return byteBuffer;
  }

  /**
   * gets a given byteBuffer from our byteBuffers ArrayList
   * @param  {[type]} int i             [description]
   * @return {[type]}     [description]
   */
  public ArrayList<Byte> getByteBuffer(int i){
    return byteBuffers.get(i);
  }

  public void sendOsc(OscBundle messageBundle){
    _oscP5.send(messageBundle, _broadcastLoc);
  }
  
  public void sendOsc(OscMessage message){
    _oscP5.send(message, _broadcastLoc);
  }

   /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} byte[]  vals       array of byte values to bundle in address
   * @return {[type]}        OscMessage    You can use this to pass into the sendOsc() method.
   */
  public OscMessage buildMessage(String messAddress, byte[] vals){
    OscMessage oscMessage = new OscMessage(messAddress);
    oscMessage.add(vals); 
    return oscMessage;
  }

  /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} int    val           value to bundle in address
   * @return {[type]}        OscBundle    You can use this to pass into the sendOsc() method.
   */
  public OscMessage buildMessage(String messAddress, int val){
    OscMessage oscMessage = new OscMessage(messAddress);
    oscMessage.add(val);

    return oscMessage;
  }  

  /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} int[]  vals       array of values to bundle in address
   * @return {[type]}        OscBundle    You can use this to pass into the sendOsc() method.
   */
  public OscMessage buildMessage(String messAddress, int[] vals){
    OscMessage oscMessage = new OscMessage(messAddress);
    for(int val : vals){
      oscMessage.add(val);
    }

    return oscMessage;
  }

  /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} float[]  vals       array of values to bundle in address
   * @return {[type]}        OscBundle    You can use this to pass into the sendOsc() method.
   */
  public OscMessage buildMessage(String messAddress, float[] vals){
    OscMessage oscMessage = new OscMessage(messAddress);
    for(float val : vals){
      oscMessage.add(val);
    }
    return oscMessage;
  }

  public void addColorBytes(byte[] data){
    for(byte component : data){
      byteBuffer.add(component);
    }
  }

  public void addColorBytes(int i, byte[] data){
    ArrayList<Byte> buffer = getByteBuffer(i);
    // println(buffer.size());
    for(int j=0; j < data.length; j++){
      buffer.add(data[j]);
      // if(buffer == null || buffer.size() <= 0) buffer.set(j, data[j]);//buffer.add(data[j]);
      //else println(buffer.get(0));//buffer.set(j, data[j]);
    }
  }
  
  public void clearByteBuffer(){
    byteBuffer.clear();
  }

  public void clearByteBuffer(int i){
    byteBuffers.get(i).clear();
  }

  public int getByteBufferSize(){
    return byteBuffer.size();
  } 
}
