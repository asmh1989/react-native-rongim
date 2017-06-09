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