
package com.reactlibrary.sm_rongim;

import android.support.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import io.rong.fast.RongCloudApplication;
import io.rong.imkit.RongIM;
import io.rong.imlib.RongIMClient;

public class SMOSmRongimModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private final static  String NAME = "SMOSmRongim";
  private final static  String SERVER = "__SERVER";
  private final static  String PORT = "__PORT";
  private final static  String DEVICE = "__DEVICE";

  public static String mToken="";

  public static String mDeviceID = "";
  public static String mServer = "";
  public static String mPort = "";


  public SMOSmRongimModule(ReactApplicationContext context) {
    super(context);
    this.reactContext = context;
    RongCloudApplication.Init(reactContext);

    mDeviceID = RongCloudApplication.prefernces.getString(DEVICE, "");
    mServer = RongCloudApplication.prefernces.getString(SERVER, "");
    mPort = RongCloudApplication.prefernces.getString(PORT, "");


    new Thread(new Runnable() {
      @Override
      public void run() {
        try {
          Thread.sleep(1000);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }

        refreshServer();

      }
    }).start();
  }


  private void refreshServer(){
    WritableMap params = Arguments.createMap();
    params.putString("module", NAME);
    sendEvent(reactContext,"onServerInfo", params);
  }


  protected void sendEvent(ReactApplicationContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(eventName, params);
  }

  @Override
  public String getName() {
    return NAME;
  }

  @ReactMethod
  public void setServerInfo(ReadableMap params){
    android.util.Log.d("ReactNativeJS..", ":setServerInfo: " + params.toString());
    String device = params.getString("id")+"";
    String ip = params.getString("server")+"";
    String port = params.getInt("port2")+"";
    boolean change = false;

    if(mDeviceID != device && device.length()>0){
      mDeviceID = device;
      change = true;
    }

    if(mServer != ip && ip.length()>0){
      mServer = ip;
      change = true;
    }

    if(mPort != port && port.length()>0){
      mPort = ip;
      change = true;
    }

    if(change){
      refreshCahe();
    }
  }

  private void refreshCahe(){
    RongCloudApplication.prefernces.edit().putString(SERVER, mServer).apply();
    RongCloudApplication.prefernces.edit().putString(PORT, mPort).apply();
    RongCloudApplication.prefernces.edit().putString(DEVICE, mDeviceID).apply();

  }

  @ReactMethod
  public void setToken(ReadableMap params, Callback callback){
    // token 实现, 返回参数用WritableMap封装, 调用callback.invoke(WritableMap)
    refreshServer();
    String t = params.getString("token");
    t = t.replaceAll(" ", "+");
    if(!mToken.equals(t) && t.length() > 0){
      RongIM.getInstance().logout();
      mToken = t;
      RongCloudApplication.prefernces.edit().putString(RongCloudApplication.RONGIM_TOKEN, mToken).apply();

      startConnectIM();

      return;
    }

    if(RongIM.getInstance().getCurrentConnectionStatus() != RongIMClient.ConnectionStatusListener.ConnectionStatus.CONNECTED)
    {
      startConnectIM();
    }

  }


  @ReactMethod
  public void openChat(ReadableMap params, Callback callback){
    // openChat 实现, 返回参数用WritableMap封装, 调用callback.invoke(WritableMap)

    final String title = params.getString("title");
    final String userid = params.getString("token");
    final String action = params.getString("action");

    reactContext.runOnUiQueueThread(new Runnable() {
      @Override
      public void run() {
        //启动会话界面
        if (RongIM.getInstance() != null){
          if("pchat".equals(action)) {
            RongIM.getInstance().startPrivateChat(reactContext, userid, title);
          } else {
            RongIM.getInstance().startGroupChat(reactContext, userid, title);
          }
        }
      }
    });
  }


  @ReactMethod
  public void openChatlist(ReadableMap params, Callback callback){
    // chatlist 实现, 返回参数用WritableMap封装, 调用callback.invoke(WritableMap)
    //启动会话列表界面
    if (RongIM.getInstance() != null)
      RongIM.getInstance().startConversationList(reactContext);
  }


  private  void startConnectIM()
  {
    reactContext.runOnUiQueueThread(new Runnable() {
      @Override
      public void run() {
        RongCloudApplication.connectIM(mToken, reactContext);
      }
    });
  }
}
