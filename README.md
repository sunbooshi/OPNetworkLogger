# OPNetworkLogger

Simple but very useful network logger based on [facebook flipper](https://github.com/facebook/flipper).

简单粗暴，但却很有用的网络请求日志。

OPNetworkLogger使用了[flipper](https://github.com/facebook/flipper)的网络插件的代码，来截取App的所有网络请求，
然后使用了[GCDWebServer](https://github.com/swisspol/GCDWebServer)建立了一个简单的HTTP服务器，可以直接在浏览器里查看App所有网络请求日志。

这些请求日志包含了请求参数、返回数据以及该请求所耗时间等等，可以方便定位接口问题。


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

### ToDo


- [ ] 增加log解析
- [ ] 增加将请求转为curl命令的功能


### 吐槽

之所以做了OPNetworkLogger是因为flipper目前还不支持真机运行，而且由于使用了一些其它库，在打包的时候无法生成armv7的包，
但flipper对我们确实有用，尤其是网络插件。我们的后端服务不太稳定，而且极其善于推卸，
有各种各样的理由推脱，不查找问题，这导致我们花了大量时间去复现接口问题。

除此之外，后端人员还会要求将所有请求参数拼接好，然后他们来查找问题，大量接口是post方式，
导致参数拼接只能靠人肉操作，这相当的繁琐。所以在log解析工具里，我将增加生成curl命令的功能。

以上种种，促使我想把flipper中的网络插件提取出来，做成单独的功能。
整个工作意想不到的简单，抛开纠结的时间，大概只用了一个下午。
为什么这么快呢？

首先，flipper网络插件部分架构清晰，很容易使用，整个代码只修改了一个头文件引用。
其次，实现的简单粗暴。纠结了很久，本来是希望写入本地文件，而且也担心性能问题，
后来一想，毕竟网络请求不多，而且重点在于随时解决使用中的问题，而不是追查之前的问题，
写入文件意义不大，直接将所有数据存入数组，不会造成太多影响。
这本来也是在flipper还不完善的情况下的无奈之举，没必要花太多精力。

最后，这个工具的真正意义是吊打后端服务，让他们没法推卸责任，减少App开发用于扯皮的时间，
够用就行。

只是，希望以后这样的工具少写，多花精力在完善App上而不是相互扯皮！
