# ijkplayer-builder #
[ijkplayer] 編譯腳本.


## 使用 ##
- 下載或是 clone repository
- 執行腳本:
	- 命令: ./ijkplayer-builder.sh <#branch or tag#>
	- 未帶 branch or tag, 將使用 master branch.
	- 查無 branch or tag, 將不編譯.

**例如編譯 tag k0.7.4**

```shell
./ijkplayer-builder.sh k0.7.4
```

> 編譯過程將使用 [ijkplayer] default [設定][default].

確保網路連線順暢, 然後泡杯咖啡等待. :coffee:

一切順利的話 **IJKMediaFramework.framework**, **libssl.a**, **libcrypto.a** 將會編譯到你的桌面.

編譯完的 framework 支援, armv7, i386, x86_64, arm64.





[ijkplayer]: https://github.com/Bilibili/ijkplayer
[default]: https://github.com/Bilibili/ijkplayer/blob/master/config/module.sh
