## RongIM

提供融云im聊天功能

* `setToken`
设置token

```
{
    "method":"SMOSmRongim",
    "params":{
        "method":"setToken",
        "token":"..."
    }
}
```

* `openChat`
打开聊天界面

```
{
    "method":"SMOSmRongim",
    "params":{
        "method":"openChat",
        "token":"...",           // userid
        "title":"...",          
        "action":"pchat/gchat",  //单聊, 还是群聊
    }
}
```

* `openChatlist`
打开聊天列表

```
{
    "method":"SMOSmRongim",
    "params":{
        "method":"openChatlist",
    }
}
```


---


## http 接口

### 前提
* 所有的HTTP请求头必须添加：X-CLIENT-ID，值为当前的客户端SessionID
* 
---
### 获取用户信息
  	/im/rong/userinfo?token=XXX
##### 说明
* token为userid

#### 返回
	{"UserID":"oudi","UserName":"oudi","PortraitUri":"http://www.rongcloud.cn/images/logo.png"}
##### 说明
* ContentType：application/json;charset=utf-8
* UserID：用户编号
* UserName：用户名称（昵称）
* PortraitUri：头像URL

---

### 获取群组信息
  	/im/rong/groupinfo?token=XXX
##### 说明
* token为groupid

#### 返回
	{"GroupID":"oudi","GroupName":"oudi","PortraitUri":"http://www.rongcloud.cn/images/logo.png"}
##### 说明
* ContentType：application/json;charset=utf-8
* GroupID：群组编号
* GroupName：群组名称
* PortraitUri：群组头像URL​

---

### 获取群组成员
  	/im/rong/groupmembers?token=XXX
##### 说明
* token为groupid

#### 返回
	["oudi","sandy"]
##### 说明
* Json数组

---

### 获取Token
  	/im/rong/token?token=XXX
##### 说明
* token为userid

#### 返回
	"token"
##### 说明
* Json字符串​

---

### 初始化结果回传
  	/im/rong/initial?token=XXX
##### 说明
* token为状态
	* 0 : 失败
	* 1 : 成功

#### 返回空
​
---

### 未读消息回传
  	/im/rong/unreadmsg?token=XXX
##### 说明
* token为未读消息数量

#### 返回空