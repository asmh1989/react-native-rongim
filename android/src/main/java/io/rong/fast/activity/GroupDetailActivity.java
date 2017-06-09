package io.rong.fast.activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.reactlibrary.sm_rongim.R;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import io.rong.fast.RongCloudApplication;
import io.rong.fast.server.DialogWithYesOrNoUtils;
import io.rong.fast.server.OperationRong;
import io.rong.fast.ui.DemoGridView;
import io.rong.fast.ui.SelectableRoundedImageView;
import io.rong.fast.ui.SwitchButton;
import io.rong.imageloader.core.ImageLoader;
import io.rong.imkit.RongIM;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Group;
import io.rong.imlib.model.UserInfo;

/**
 * Created by sun on 2016/10/26.
 */

public class GroupDetailActivity extends BaseRongIMActivity implements View.OnClickListener, CompoundButton.OnCheckedChangeListener{

    private DemoGridView mGridView;
    private Group mGroup;
    private List <UserInfo> mGroupMember;
    private TextView mTextViewMemberSize, mGroupDisplayNameText;
    private SelectableRoundedImageView mGroupHeader;
    private SwitchButton messageTop, messageNotification;
    private String fromConversationId;
    private TextView mGroupName;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_detail_group);
        initViews();
        setTitle("群组信息");

        //群组会话界面点进群组详情
        fromConversationId = getIntent().getStringExtra("TargetId");
        if (!TextUtils.isEmpty(fromConversationId)) {
            requestGroupInfo();
        }
    }

    private void requestGroupInfo()
    {
        Thread getUser = new Thread(new Runnable() {
            @Override
            public void run() {
                final List<UserInfo> info = RongCloudApplication.findGroupMentionByID(fromConversationId);
                final Group group = RongCloudApplication.findGroupById(fromConversationId);

                GroupDetailActivity.this.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mGroup = group;
                        mGroupMember = setCreatedToTop(info);
                        if (mGroupMember != null && mGroupMember.size() > 0) {
                            setTitle("群组信息(" + mGroupMember.size() + ")");
                            mTextViewMemberSize.setText("全部组成员(" + mGroupMember.size() + ")");
                            mGridView.setAdapter(new GridAdapter(mContext, mGroupMember));
                        }

                        for (UserInfo info : mGroupMember) {
                            if (!TextUtils.isEmpty(info.getName())) {
                                mGroupDisplayNameText.setText(info.getName());
                            } else {
                                mGroupDisplayNameText.setText("无");
                            }
                        }

                        if (mGroup.getPortraitUri() != null) {
                            ImageLoader.getInstance().displayImage(mGroup.getPortraitUri().toString(), mGroupHeader);
                        } else {
                        }
                        mGroupName.setText(mGroup.getName());

                        if (RongIM.getInstance() != null) {
                            RongIM.getInstance().getConversation(Conversation.ConversationType.GROUP, mGroup.getId(), new RongIMClient.ResultCallback<Conversation>() {
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

                            RongIM.getInstance().getConversationNotificationStatus(Conversation.ConversationType.GROUP, mGroup.getId(), new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
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
                });
            }
        });
        getUser.start();
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.group_clean) {
            DialogWithYesOrNoUtils.getInstance().showDialog(mContext, "是否清除会话聊天记录?", new DialogWithYesOrNoUtils.DialogCallBack() {
                @Override
                public void executeEvent() {
                    if (RongIM.getInstance() != null) {
                        if (mGroup != null) {
                            RongIM.getInstance().clearMessages(Conversation.ConversationType.GROUP, mGroup.getId(), new RongIMClient.ResultCallback<Boolean>() {
                                @Override
                                public void onSuccess(Boolean aBoolean) {
                                    Toast.makeText(GroupDetailActivity.this, "清除成功", Toast.LENGTH_SHORT).show();
                                }

                                @Override
                                public void onError(RongIMClient.ErrorCode errorCode) {
                                    Toast.makeText(GroupDetailActivity.this, "清除失败", Toast.LENGTH_SHORT).show();

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
        } else if(id == R.id.group_member_size_item){
            Intent intent = new Intent(mContext, TotalGroupMemberActivity.class);
            intent.putExtra("TotalMember", (Serializable) mGroupMember);
            startActivity(intent);
        }
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        int id = buttonView.getId();
        if(id == R.id.sw_group_top) {
            if (isChecked) {
                if (mGroup != null) {
                    OperationRong.setConversationTop(mContext, Conversation.ConversationType.GROUP, mGroup.getId(), true);
                }
            } else {
                if (mGroup != null) {
                    OperationRong.setConversationTop(mContext, Conversation.ConversationType.GROUP, mGroup.getId(), false);
                }
            }
        } else if(id == R.id.sw_group_notfaction){
            if (isChecked) {
                if (mGroup != null) {
                    OperationRong.setConverstionNotif(mContext, Conversation.ConversationType.GROUP, mGroup.getId(), true);
                }
            } else {
                if (mGroup != null) {
                    OperationRong.setConverstionNotif(mContext, Conversation.ConversationType.GROUP, mGroup.getId(), false);
                }
            }

        }
    }


    private class GridAdapter extends BaseAdapter {

        private List<UserInfo> list;
        Context context;


        public GridAdapter(Context context, List<UserInfo> list) {
            if (list.size() >= 20) {
                this.list = list.subList(0, 19);
            } else {
                this.list = list;
            }

            this.context = context;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            if (convertView == null) {
                convertView = LayoutInflater.from(context).inflate(R.layout.social_chatsetting_gridview_item, null);
            }
            SelectableRoundedImageView iv_avatar = (SelectableRoundedImageView) convertView.findViewById(R.id.iv_avatar);
            TextView tv_username = (TextView) convertView.findViewById(R.id.tv_username);

            if(position < list.size()) { // 普通成员
                final UserInfo friend = list.get(position);
                if (friend != null && !TextUtils.isEmpty(friend.getName())) {
                    tv_username.setText(friend.getName());
                } else {
                }
                if (friend.getPortraitUri() != null) {
                    ImageLoader.getInstance().displayImage(friend.getPortraitUri().toString(), iv_avatar);
                }
                iv_avatar.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        UserInfo userInfo = friend;
                        RongIM.getInstance().startPrivateChat(mContext, userInfo.getUserId(), userInfo.getName());
                    }
                });
            }
            return convertView;
        }

        @Override
        public int getCount() {
            return list.size();
        }

        @Override
        public Object getItem(int position) {
            return list.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        /**
         * 传入新的数据 刷新UI的方法
         */
        public void updateListView(List<UserInfo> list) {
            this.list = list;
            notifyDataSetChanged();
        }

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private List<UserInfo> setCreatedToTop(List<UserInfo> groupMember) {
        List<UserInfo> newList = new ArrayList<>();
        for (UserInfo gr : groupMember)
        {
            newList.add(gr);
        }
        Collections.reverse(newList);
        return newList;
    }

    private void initViews() {
        messageTop = (SwitchButton) findViewById(R.id.sw_group_top);
        messageNotification = (SwitchButton) findViewById(R.id.sw_group_notfaction);
        messageTop.setOnCheckedChangeListener(this);
        messageNotification.setOnCheckedChangeListener(this);
        LinearLayout groupClean = (LinearLayout) findViewById(R.id.group_clean);
        mGridView = (DemoGridView) findViewById(R.id.gridview);
        mTextViewMemberSize = (TextView) findViewById(R.id.group_member_size);
        mGroupHeader = (SelectableRoundedImageView) findViewById(R.id.group_header);
        LinearLayout mGroupDisplayName = (LinearLayout) findViewById(R.id.group_displayname);
        mGroupDisplayNameText = (TextView) findViewById(R.id.group_displayname_text);
        mGroupName = (TextView) findViewById(R.id.group_name);
        RelativeLayout totalGroupMember = (RelativeLayout) findViewById(R.id.group_member_size_item);
        LinearLayout mGroupPortL = (LinearLayout) findViewById(R.id.ll_group_port);
        LinearLayout mGroupNameL = (LinearLayout) findViewById(R.id.ll_group_name);
        mGroupPortL.setOnClickListener(this);
        mGroupNameL.setOnClickListener(this);
        totalGroupMember.setOnClickListener(this);
        mGroupDisplayName.setOnClickListener(this);
        groupClean.setOnClickListener(this);
    }
}
