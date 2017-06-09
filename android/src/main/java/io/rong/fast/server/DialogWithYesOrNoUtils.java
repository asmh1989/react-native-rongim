package io.rong.fast.server;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.widget.EditText;
import android.widget.LinearLayout;

import com.reactlibrary.sm_rongim.R;

/**
 * Created by zzx on 2016/10/27.
 */

public class DialogWithYesOrNoUtils {

    private static DialogWithYesOrNoUtils instance = null;

    public static DialogWithYesOrNoUtils getInstance() {
        if (instance == null) {
            instance = new DialogWithYesOrNoUtils();
        }
        return instance;
    }

    private DialogWithYesOrNoUtils() {
    }

    public void showDialog(Context context, String titleInfo, final DialogCallBack callBack) {
        AlertDialog.Builder alterDialog = new AlertDialog.Builder(context);
        alterDialog.setMessage(titleInfo);
        alterDialog.setCancelable(true);

        alterDialog.setPositiveButton("确认", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                callBack.executeEvent();
            }
        });
        alterDialog.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });
        alterDialog.show();
    }

    public interface DialogCallBack {
        void executeEvent();

        void executeEditEvent(String editText);

        void updatePassword(String oldPassword, String newPassword);
    }


    public void showEditDialog(Context context, String hintText, String OKText, final DialogCallBack callBack) {
        final EditText et_search;
        AlertDialog.Builder dialog = new AlertDialog.Builder(context);
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        LinearLayout layout = (LinearLayout) inflater.inflate(R.layout.dialog_view, null);
        dialog.setView(layout);
        et_search = (EditText) layout.findViewById(R.id.searchC);
        et_search.setHint(hintText);
        dialog.setPositiveButton(OKText, new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                String s = et_search.getText().toString().trim();
                callBack.executeEditEvent(s);
            }
        });

        dialog.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {

            }

        });
        dialog.show();
    }


    public void showUpdatePasswordDialog(final Context context, final DialogCallBack callBack) {
        final EditText oldPasswordEdit, newPasswrodEdit, newPassword2Edit;
        AlertDialog.Builder dialog = new AlertDialog.Builder(context);
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        LinearLayout layout = (LinearLayout) inflater.inflate(R.layout.dialogchangeview, null);
        dialog.setView(layout);
        oldPasswordEdit = (EditText) layout.findViewById(R.id.old_password);
        newPasswrodEdit = (EditText) layout.findViewById(R.id.new_password);
        newPassword2Edit = (EditText) layout.findViewById(R.id.new_password2);
        dialog.setPositiveButton("确认", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                String old = oldPasswordEdit.getText().toString().trim();
                String new1 = newPasswrodEdit.getText().toString().trim();
                String new2 = newPassword2Edit.getText().toString().trim();
                String cachePassword = context.getSharedPreferences("config", Context.MODE_PRIVATE).getString("loginpassword", "");
                if (TextUtils.isEmpty(old)) {
//                    Cocos2dxHelper.sCocos2dxHelperListener.showToast("初始密码不能为空", 0);
                    return;
                }
                if (TextUtils.isEmpty(new1)) {
//                    Cocos2dxHelper.sCocos2dxHelperListener.showToast("新密码不能为空", 0);
                    return;
                }
                if (TextUtils.isEmpty(new2)) {
//                    Cocos2dxHelper.sCocos2dxHelperListener.showToast("确认密码不能为空", 0);
                    return;
                }
                if (!cachePassword.equals(old)) {
//                    Cocos2dxHelper.sCocos2dxHelperListener.showToast("初始密码不正确", 0);
                    return;
                }
                if (!new1.equals(new2)) {
//                    Cocos2dxHelper.sCocos2dxHelperListener.showToast("两次密码不一致", 0);
                    return;
                }
                callBack.updatePassword(old, new1);
            }
        });

        dialog.setNegativeButton("取消", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {

            }

        });
        dialog.show();
    }

}
