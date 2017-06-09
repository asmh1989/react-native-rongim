package io.rong.fast.activity;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.MenuItem;

import com.reactlibrary.sm_rongim.SMOSmRongimModule;

import io.rong.fast.RongCloudApplication;
import io.rong.imkit.RongIM;
import io.rong.imlib.RongIMClient;

/**
 * Created by sun on 2016/10/26.
 */

public class BaseRongIMActivity extends FragmentActivity {

    protected static final String TAG="VT_RongIMActivity";
    protected Context mContext;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        Log.d(TAG, "onCreate: "+Thread.currentThread().getStackTrace()[3].getClassName());
        getActionBar().setDisplayHomeAsUpEnabled(true);

    }

    @Override
    public boolean onMenuItemSelected(int featureId, MenuItem item) {
        switch (item.getItemId()){
            case android.R.id.home:
                finish();
                return true;
        }
        return super.onMenuItemSelected(featureId, item);
    }

    /**
     * 收到 push 消息后，选择进入哪个 Activity
     * 如果程序缓存未被清理，进入 MainActivity
     * 程序缓存被清理，进入 LoginActivity，重新获取token
     * <p/>
     * 作用：由于在 manifest 中 intent-filter 是配置在 ConversationListActivity 下面，所以收到消息后点击notifacition 会跳转到 DemoActivity。
     * 以跳到 MainActivity 为例：
     * 在 ConversationListActivity 收到消息后，选择进入 MainActivity，这样就把 MainActivity 激活了，当你读完收到的消息点击 返回键 时，程序会退到
     * MainActivity 页面，而不是直接退回到 桌面。
     */
    protected void enterActivity() {
        String token = RongCloudApplication.prefernces.getString(RongCloudApplication.RONGIM_TOKEN, "");
        if (SMOSmRongimModule.mToken.equals("") && token.length() > 0
                && RongIM.getInstance().getCurrentConnectionStatus() != RongIMClient.ConnectionStatusListener.ConnectionStatus.CONNECTED) {
            reconnect(token);
        }
    }


    private void reconnect(String token) {
        RongIM.connect(token, new RongIMClient.ConnectCallback() {
            @Override
            public void onTokenIncorrect() {
                Log.e(TAG, "---onTokenIncorrect--");

                String newToken = RongCloudApplication.getUserToken();

                if(newToken.length() > 0){
                    reconnect(newToken);
                }
            }

            @Override
            public void onSuccess(String s) {

                finish();

                RongIM.getInstance().startConversationList(BaseRongIMActivity.this);
                Log.i(TAG, "---onSuccess--" + s);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e)
            {
                Log.e(TAG, "---onError--" + e);
            }
        });

    }
}
