# ijkplayer-builder #
編譯版本: __k0.7.6__

[ijkplayer] 編譯腳本.


## 使用 ##
下載或是 clone repository, 執行腳本:

```shell
./ijkplayer-ios-build.sh
```

確保網路連線順暢, 然後泡杯咖啡等待. :coffee:

一切順利的話 __IJKMediaFramework.framework__ 將會編譯到你的桌面.

編譯完的 framework 支援, armv7, i386, x86_64, arm64.


## Carthage
可以透過 [carthage] 下載編譯好的 framework,  
下載過程可能會有錯誤, 但是不影響.

雖然透過 [carthage] 下載, 但基本上其 framework 還是 static framework, 並非是 dynamic framework,  
只是投機使用 [carthage] 下載罷了.




[ijkplayer]: https://github.com/Bilibili/ijkplayer
[carthage]: https://github.com/Carthage/Carthage
