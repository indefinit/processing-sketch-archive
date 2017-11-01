/**
 * OscSender class
 * @description: A simple wrapper for Andreas Schlegel's oscP5
 * To use, add this .pde in your Processing sketch and you should be good to go
 * @author: kevin siwoff
 * @date: 1-12-15
 */
import oscP5.*;
import netP5.*;

public class OscSender{
  private String _address;
  private int _sendPort;
  private int _receivePort;
  private OscP5 _oscP5;
  private NetAddress _broadcastLoc;

  /**
   * Default constructor w/ no args
   */
  OscSender(){
    this._address = "127.0.0.1";//localhost
    this._sendPort = 4000;
    this._receivePort = _sendPort + 1000;
    //we initialize our oscP5 instance by passing in parent and receive port
    _oscP5 = new OscP5(this, _receivePort);
    _broadcastLoc = new NetAddress(_address, _sendPort);
  }

  OscSender(String address, int port){
    this._address = address;
    this._sendPort = port;
    this._receivePort = port + 1000;
    //we initialize our oscP5 instance by passing in parent and receive port
    _oscP5 = new OscP5(this, _receivePort);
    _broadcastLoc = new NetAddress(_address, _sendPort);
  }
  
  public void sendOsc(OscBundle messageBundle){
    _oscP5.send(messageBundle, _broadcastLoc);
  }

  /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} int    val           value to bundle in address
   * @return {[type]}        OscBundle    You can use this to pass into the sendOsc() method.
   */
  public OscBundle buildMessage(String messAddress, int val){
    OscMessage oscMessage = new OscMessage(messAddress);
    oscMessage.add(val);

    OscBundle oscBundle = new OscBundle();
    oscBundle.add(oscMessage);
    return oscBundle;
  }  

  /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} int[]  vals       array of values to bundle in address
   * @return {[type]}        OscBundle    You can use this to pass into the sendOsc() method.
   */
  public OscBundle buildMessage(String messAddress, int[] vals){
    OscBundle oscBundle = new OscBundle();

    for(int val : vals){
      OscMessage oscMessage = new OscMessage(messAddress);
      oscMessage.add(val);
      oscBundle.add(oscMessage);
    }

    return oscBundle;
  }

  /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} float[]  vals       array of values to bundle in address
   * @return {[type]}        OscBundle    You can use this to pass into the sendOsc() method.
   */
  public OscBundle buildMessage(String messAddress, float[] vals){
    OscBundle oscBundle = new OscBundle();

    for(float val : vals){
      OscMessage oscMessage = new OscMessage(messAddress);
      oscMessage.add(val);
      oscBundle.add(oscMessage);
    }
    return oscBundle;
  }

}