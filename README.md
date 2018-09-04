# OPNetworkLogger

Simple but very useful network logger based on [facebook flipper](https://github.com/facebook/flipper).

简单粗暴，但却很有用的网络请求日志。

### Usage

将**OPNetworkLogger**目录加入到工程中，然后在**AppDelegate.m**中加入如下代码：

    #import "OPNetworkLogger.h"

    ...

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        ...

        #ifdef DEBUG
        [[OPNetworkLogger defaultLogger] start]; // 启用网络截取
        [[OPNetworkLogger defaultLogger] startWebServer]; // 启动web服务，监听10086端口
        #endif

        ...
    }

如果使用模拟器直接打开[localhost:10086/log](http://localhost:10086/log), 如果使用真机，请查看IP地址替换localhost，确保电脑与手机在同一Wi-Fi下。
