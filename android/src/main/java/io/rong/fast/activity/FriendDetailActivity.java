package io.rong.fast.activity;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.MenuItem;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.reactlibrary.sm_rongim.R;

import io.rong.fast.RongCloudApplication;
import io.rong.fast.server.DialogWithYesOrNoUtils;
import io.rong.fast.server.OperationRong;
import io.rong.fast.ui.SelectableRoundedImageView;
import io.rong.fast.ui.SwitchButton;
import io.rong.imageloader.core.ImageLoader;
import io.rong.imkit.RongIM;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.UserInfo;

/**
 * Created by sun on 2016/10/26.
 */

public class FriendDetailActivity extends BaseRongIMActivity implements View.OnClickListener, CompoundButton.OnCheckedChangeListener {

    private UserInfo userInfo;
    private SwitchButton messageTop, messageNotification;
    private SelectableRoundedImageView mImageView;
    private TextView friendName;
    private String fromConversationId;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.fr_friend_detail);
        setTitle("用户详情");
        initView();
        fromConversationId = getIntent().getStringExtra("TargetId");
        if (!TextUtils.isEmpty(fromConversationId)) {
            //TODO 后续需要将网络获取 更改为 去数据库获取 再 设置备注
//            userInfo = RongUserInfoManager.getInstance().getUserInfo(fromConversationId); //无法获取id信息
            //好友界面进入详情界面
            requestUserInfo();
        }

    }

    private void requestUserInfo()
    {
        Thread getUser = new Thread(new Runnable() {
            @Override
            public void run() {
                final UserInfo info = RongCloudApplication.findUserById(fromConversationId);
                FriendDetailActivity.this.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        userInfo = info;
                        initData();
                        getState(userInfo);
                    }
                });
            }
        });
        getUser.start();
    }

    private void initData() {
        if (userInfo != null) {
            if (userInfo.getPortraitUri() != null) {
                ImageLoader.getInstance().displayImage(userInfo.getPortraitUri().toString(), mImageView);
            } else {
            }
            friendName.setText(userInfo.getName());
        }
    }

    private void initView() {
        LinearLayout cleanMessage = (LinearLayout) findViewById(R.id.clean_friend);
        mImageView = (SelectableRoundedImageView) findViewById(R.id.friend_header);
        messageTop = (SwitchButton) findViewById(R.id.sw_freind_top);
        messageNotification = (SwitchButton) findViewById(R.id.sw_friend_notfaction);
        friendName = (TextView) findViewById(R.id.friend_name);
        cleanMessage.setOnClickListener(this);
        messageNotification.setOnCheckedChangeListener(this);
        messageTop.setOnCheckedChangeListener(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        finish();
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.clean_friend) {
            DialogWithYesOrNoUtils.getInstance().showDialog(mContext, "是否清楚会话聊天记录?", new DialogWithYesOrNoUtils.DialogCallBack() {
                @Override
                public void executeEvent() {
                    if (RongIM.getInstance() != null) {
                        if (userInfo != null) {
                            RongIM.getInstance().clearMessages(Conversation.ConversationType.PRIVATE, userInfo.getUserId(), new RongIMClient.ResultCallback<Boolean>() {
                                @Override
                                public void onSuccess(Boolean aBoolean) {
                                    Toast.makeText(FriendDetailActivity.this, "清除成功", Toast.LENGTH_SHORT).show();

                                }

                                @Override
                                public void onError(RongIMClient.ErrorCode errorCode) {
                                    Toast.makeText(FriendDetailActivity.this, "清除失败", Toast.LENGTH_SHORT).show();

                                }
                            });
                        }
                    }
                }

                @Override
                public void executeEditEvent(String editText) {

                }

                @Override
                public void updatePassword(String oldPassword, String newPassword) {

                }
            });
        }
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        int id = buttonView.getId();

        if(id == R.id.sw_friend_notfaction) {
            if (isChecked) {
                if (userInfo != null) {
                    OperationRong.setConverstionNotif(mContext, Conversation.ConversationType.PRIVATE, userInfo.getUserId(), true);
                }
            } else {
                if (userInfo != null) {
                    OperationRong.setConverstionNotif(mContext, Conversation.ConversationType.PRIVATE, userInfo.getUserId(), false);
                }
            }
        } else if(id == R.id.sw_freind_top) {

            if (isChecked) {
                if (userInfo != null) {
                    OperationRong.setConversationTop(mContext, Conversation.ConversationType.PRIVATE, userInfo.getUserId(), true);
                }
            } else {
                if (userInfo != null) {
                    OperationRong.setConversationTop(mContext, Conversation.ConversationType.PRIVATE, userInfo.getUserId(), false);
                }
            }
        }
    }

    private void getState(UserInfo friend) {
        if (friend != null) {//群组列表 page 进入
            if (RongIM.getInstance() != null) {
                RongIM.getInstance().getConversation(Conversation.ConversationType.PRIVATE, friend.getUserId(), new RongIMClient.ResultCallback<Conversation>() {
                    @Override
                    public void onSuccess(Conversation conversation) {
                        if (conversation == null) {
                            return;
                        }

                        if (conversation.isTop()) {
                            messageTop.setChecked(true);
                        } else {
                            messageTop.setChecked(false);
                        }

                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {

                    }
                });

                RongIM.getInstance().getConversationNotificationStatus(Conversation.ConversationType.PRIVATE, friend.getUserId(), new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
                    @Override
                    public void onSuccess(Conversation.ConversationNotificationStatus conversationNotificationStatus) {

                        if (conversationNotificationStatus == Conversation.ConversationNotificationStatus.DO_NOT_DISTURB) {
                            messageNotification.setChecked(true);
                        } else {
                            messageNotification.setChecked(false);
                        }
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {

                    }
                });
            }
        }
    }
}
