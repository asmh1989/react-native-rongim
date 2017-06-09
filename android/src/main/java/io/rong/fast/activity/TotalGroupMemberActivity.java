package io.rong.fast.activity;

import android.content.Context;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import com.reactlibrary.sm_rongim.R;

import java.util.ArrayList;
import java.util.List;

import io.rong.fast.ui.SelectableRoundedImageView;
import io.rong.imageloader.core.ImageLoader;
import io.rong.imkit.RongIM;
import io.rong.imlib.model.UserInfo;

/**
 * Created by zzx on 2016/10/31.
 */

public class TotalGroupMemberActivity extends BaseRongIMActivity {

    private List<UserInfo> mGroupMember;

    private ListView mTotalListView;
    private TotalGroupMember adapter;
    private EditText mSearch;

    @Override
    @SuppressWarnings("unchecked")
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_toatl_member);
        setTitle("群成员");
        initViews();
        mGroupMember = (List<UserInfo>) getIntent().getSerializableExtra("TotalMember");
        if (mGroupMember != null && mGroupMember.size() > 0) {
            setTitle("群成员(" + mGroupMember.size() + ")");
            adapter = new TotalGroupMember(mGroupMember, mContext);
            mTotalListView.setAdapter(adapter);
            mTotalListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    UserInfo userInfo = (UserInfo) adapter.getItem(position);
                    RongIM.getInstance().startPrivateChat(mContext, userInfo.getUserId(), userInfo.getName());
                }
            });
            mSearch.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {

                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    filterData(s.toString());
                }

                @Override
                public void afterTextChanged(Editable s) {

                }
            });
        }

    }

    private void filterData(String s) {
        List<UserInfo> filterDateList = new ArrayList<>();
        if (TextUtils.isEmpty(s)) {
            filterDateList = mGroupMember;
        } else {
            for (UserInfo resultEntity : mGroupMember) {
                if (resultEntity.getName().contains(s)) {
                    filterDateList.add(resultEntity);
                }
            }
        }
        adapter.updateListView(filterDateList);
    }

    private void initViews() {
        mTotalListView = (ListView) findViewById(R.id.total_listview);
        mSearch = (EditText) findViewById(R.id.group_member_search);
    }


    class TotalGroupMember extends BaseAdapter {

        private List<UserInfo> list;

        private Context context;

        private ViewHolder holder;


        public TotalGroupMember(List<UserInfo> list, Context mContext) {
            this.list = list;
            this.context = mContext;
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

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            if (convertView == null) {
                holder = new ViewHolder();
                convertView = LayoutInflater.from(context).inflate(R.layout.share_item, null);
                holder.mImageView = (SelectableRoundedImageView) convertView.findViewById(R.id.share_icon);
                holder.title = (TextView) convertView.findViewById(R.id.share_name);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
            UserInfo bean = list.get(position);
            holder.title.setText(bean.getName());

            ImageLoader.getInstance().displayImage(bean.getPortraitUri().toString(), holder.mImageView);
            return convertView;
        }


        public void updateListView(List<UserInfo> list) {
            this.list = list;
            notifyDataSetChanged();
        }
    }

    final static class ViewHolder {
        /**
         * 头像
         */
        SelectableRoundedImageView mImageView;

        TextView title;
    }
}
