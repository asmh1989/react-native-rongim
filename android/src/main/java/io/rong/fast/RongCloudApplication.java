package io.rong.fast;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.util.Log;
import android.widget.Toast;


import com.facebook.react.bridge.ReactApplicationContext;
import com.reactlibrary.sm_rongim.SMOSmRongimModule;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import io.rong.imkit.RongIM;
import io.rong.imkit.userInfoCache.RongUserInfoManager;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Group;
import io.rong.imlib.model.UserInfo;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import static android.content.Context.MODE_PRIVATE;

/**
 * Created by sun on 2016/11/1.
 */

public class RongCloudApplication {

    public static final String TAG="VT_RCApplication";

    public static final String RONGIM_TOKEN="RONG_IM_TOKEN";
    public static final String RONGIM_CURRENTUSERID="RONG_IM_CURRENT_USERID";

    private static RongCloudApplication mApplication;
    public static SharedPreferences prefernces;


    private Context mContext;

    private RongCloudApplication(Context context)
    {
        mContext = context;

        if(prefernces == null){
            prefernces = context.getSharedPreferences("rong_im_token", MODE_PRIVATE);
        }

        RongIM.init(context);

        RongIM.setUserInfoProvider(new RongIM.UserInfoProvider() {

            @Override
            public UserInfo getUserInfo(String userId) {
                UserInfo cache = RongUserInfoManager.getInstance().getUserInfo(userId);
                if(cache != null) return cache;

                return findUserById(userId);//根据 userId 去你的用户系统里查询对应的用户信息返回给融云 SDK。
            }

        }, true);

        RongIM.setGroupInfoProvider(new RongIM.GroupInfoProvider(){

            @Override
            public Group getGroupInfo(String groupId) {

                Group cache = RongUserInfoManager.getInstance().getGroupInfo(groupId);
                if(cache != null) return cache;

                return findGroupById(groupId);
            }
        }, true);
    }

    public static void Init(Context context){
        if(mApplication == null){
            mApplication = new RongCloudApplication(context);
        }
    }

    public  static Request newRequest(String url)
    {
        Log.d(TAG, "Http Get = "+url);
        return new Request.Builder()
                .url(url)
                .addHeader("X-CLIENT-ID", SMOSmRongimModule.mDeviceID)
                .build();
    }

    static public String getServerInfo()
    {
        return SMOSmRongimModule.mServer + ":" + SMOSmRongimModule.mPort;
    }

    static public List<UserInfo> findGroupMentionByID(String groupId)
    {
        String httpIPAndImagePort = getServerInfo();
        String url = "http://" + httpIPAndImagePort + "/im/rong/groupmembers?token=" + groupId;
        OkHttpClient client = new OkHttpClient();

        Request request = newRequest(url);

        Response response = null;

        List <UserInfo> info = new ArrayList();

        try {
            response = client.newCall(request).execute();
            String data = response.body().string();


            JSONArray obj = new JSONArray(data);

            int iSize = obj.length();
            for (int i = 0; i < iSize; i++) {
                info.add(findUserById(obj.getString(i)));
            }

            return info;
        } catch (IOException e) {
            e.printStackTrace();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return info;
    }

    static public Group findGroupById(String groupId)
    {
        String httpIPAndImagePort = "http://" + getServerInfo();
        String url = httpIPAndImagePort + "/im/rong/groupinfo?token=" + groupId;
        OkHttpClient client = new OkHttpClient();

        Request request = newRequest(url);

        Response response = null;
        Group info = new Group(groupId, "Unknown", Uri.parse(""));

        try {
            response = client.newCall(request).execute();
            String data = response.body().string();

            JSONObject obj = new JSONObject(data);

            info.setName(obj.getString("GroupName"));
//            info.setId(obj.getString("GroupID"));
            String uri = obj.getString("PortraitUri");
            if(uri.indexOf("http") == -1)
            {
                uri = httpIPAndImagePort + uri;
            }
            info.setPortraitUri(Uri.parse(uri));

            RongIM.getInstance().refreshGroupInfoCache(info);


            return info;
        } catch (IOException e) {
            e.printStackTrace();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return info;
    }

    static public UserInfo findUserById(String userId)
    {
        String httpIPAndImagePort = "http://" + getServerInfo();
        String url = httpIPAndImagePort + "/im/rong/userinfo?token=" + userId;
        OkHttpClient client = new OkHttpClient();

        Request request = newRequest(url);

        Response response = null;
        UserInfo info = new UserInfo(userId, "", Uri.parse(""));

        try {
            response = client.newCall(request).execute();
            String data = response.body().string();

            JSONObject obj = new JSONObject(data);

            info.setName(obj.getString("UserName"));
//            info.setUserId(obj.getString("UserID"));
            String uri = obj.getString("PortraitUri");
            if(uri.indexOf("http") == -1)
            {
                uri = httpIPAndImagePort + uri;
            }
            info.setPortraitUri(Uri.parse(uri));

            RongIM.getInstance().refreshUserInfoCache(info);

            return info;
        } catch (IOException e) {
            e.printStackTrace();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return info;

    };

    public static String getUserToken()
    {
        String userId = RongCloudApplication.prefernces.getString(RongCloudApplication.RONGIM_CURRENTUSERID, "");

        if(userId.length() == 0) return "";

        String httpIPAndImagePort = "http://" + getServerInfo();
        String url = httpIPAndImagePort + "/im/rong/token?token=" + userId;
        OkHttpClient client = new OkHttpClient();

        Request request = newRequest(url);

        Response response = null;
        UserInfo info = new UserInfo(userId, "", Uri.parse(""));

        try {
            response = client.newCall(request).execute();
            String data = response.body().string();

            Log.d(TAG, "http: new token:"+data);
            RongCloudApplication.prefernces.edit().putString(RongCloudApplication.RONGIM_TOKEN, data).apply();

            return data;
        } catch (IOException e) {
            e.printStackTrace();
        }

        return "";
    }

    public static void connectIM(final String token, final ReactApplicationContext activity)
    {
        RongIM.connect(token, new RongIMClient.ConnectCallback() {
            @Override
            public void onTokenIncorrect() {
                //Connect Token 失效的状态处理，需要重新获取 Token
                Log.e(TAG, "——onTokenIncorrect—-, token="+token);
                activity.runOnUiQueueThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity, "token已失效", Toast.LENGTH_LONG).show();
                    }
                });

                String t = getUserToken();
                if(t.length() > 0){
                    connectIM(t, activity);
                }

            }

            @Override
            public void onSuccess(String userId) {
                Log.e(TAG, "——onSuccess—-" + userId);

                RongCloudApplication.prefernces.edit().putString(RongCloudApplication.RONGIM_CURRENTUSERID, userId).apply();
            }

            @Override
            public void onError(final RongIMClient.ErrorCode errorCode) {
                Log.e(TAG, "——onError—-" + errorCode);
                activity.runOnUiQueueThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity, "IM服务器连接失败, errorCode"+errorCode, Toast.LENGTH_LONG).show();
                    }
                });

            }
        });
    }

    public static RongCloudApplication getInstance(){
        return mApplication;
    }
}
