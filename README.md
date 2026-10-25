适用于 Xiaomi BE7000 的 OpenWrt（QWRT 分区方案，80 MB 分区）
这是给 Xiaomi BE7000（RC06，IPQ9574 + QCN9274） 用的 OpenWrt 固件，基于 QWRT bootloader 的分区方案（只有一个 rootfs 分区，80 MB）。
因为分区够大，常用东西可以一次全塞进固件：VPN、绕过封锁、samba、DLNA、
应用目录，都能一键安装。

⚠️ 测试版。 镜像在 Releases。如果你能接受刷失败后通过 recovery 回 QWRT，再刷。改动见
CHANGELOG。

本固件基于 kravasuper 的 BE7000 支持移植
（分支 xiaomi_be7000），迁到较新的 OpenWrt main，并带上了
Beam WRT（timofey-maykov）的以太网修复
和 Quarx2k 的发现。完整作者列表——谁贡献了什么、这里改了什么——见 CREDITS.md。

QWRT 80 MB 分区方案：好处和代价
小米原厂 bootloader 把闪存分成两个 40 MB 槽位（A/B），QWRT bootloader 则给系统
一个 80 MB 分区。

好处： 固件本身能塞进更多内置软件——这版镜像 53 MB，
原厂槽位放不下（Podkop 的 sing-box、zapret、samba、图表、应用目录）。留给软件包的空间
则和原厂分区方案的构建差不多（约 20 MB）。

代价：

没有第二个槽位：升级后起不来不会自动回滚——只能走 bootloader 的 recovery
（它不会被擦掉，但需要电脑和网线）；

从 beta4 起可以在 LuCI 里升级（系统 → 备份 / 刷写固件），能保留配置，但会覆盖唯一分区：
新镜像起不来就只能 recovery 救（写入前固件会检查镜像，尽量避免这种情况）；

要刷这版必须先有 QWRT bootloader；回原厂比 A/B 槽位的构建麻烦。

如果你更看重简单升级、以及在后备槽位保留原厂固件——选
Beam WRT。

beta5 的缺点和限制
beta5 是全新基线（OpenWrt main 22.10、内核 6.18.55），从 2026-10-23 起在作者的路由器上跑。
已验证：系统内从 beta4.1 升 beta5、beta5 升 beta5 并保留配置；2.4/5 GHz、带应用的 USB 磁盘、软件源都正常。
通过 recovery 刷 factory.ubi、以及恰好在这版上跑 extroot 都没验证（extroot 代码从 beta4.1 起没改）。beta5 没有 mini 版——
当前 mini 仍是 beta4.1-mini。

没合入 ath11k/ath12k 内存泄漏修复（openwrt/openwrt#24254、#25632 还没被
OpenWrt 接收；Quarx2k 已经加上了）。

LuCI 升级是 beta4 才有的。 从 beta3 及更早升到 beta4 只能走 recovery
（旧镜像里关了 sysupgrade）；之后再升就能在 LuCI 里做。升级只在一台路由器上验证过
（beta3 → beta3、beta3 → beta4、beta4 → beta4.1、beta4.1 → beta5）。固件不会自己找新版本：要手动从 Releases 下载
…-sysupgrade.bin（Beam WRT 有一键搜索并安装）。

5 GHz 的“双射频”模式（5G-1/5G-2）和 MLO 取自 Beam WRT，但没在作者硬件上
验证过——属于实验性功能。默认只开一个 5 GHz 射频。

硬件 NAT 卸载（PPE） 是新功能，默认关闭。已在一台路由器上用 Wi-Fi 客户端、
IPv4/IPv6 和按规则走的 VPN 验证过；有线场景的收益没测，
LAN 口桥接卸载也没验证。

Extroot（把 /overlay 迁到 USB）是 beta4.1 新增的，已在一台路由器和一个磁盘上验证
（USB 硬盘盒里的 NVMe）：迁移、重启、带 extroot 的 LuCI 升级、模拟磁盘掉线。
测试中有一回启动一分钟后磁盘上的根文件系统突然读不了（网络正常，SSH 和 LuCI 不通）；
原因没查出来，后面五次启动也没复现。针对这种情况有看门狗：它会重启路由器，如果再发生就把系统退回闪存。

不支持从原厂固件导入配置（Beam WRT 支持）。

只在作者的一台路由器上验证过。zapret/Podkop 对俄罗斯运营商封锁的效果没验证；
在真实磁盘上格式化为 ext4 也没验证。

没有使用 NSS 加速（qca-nss-ecm 等）：IPQ9574 没有开源 NSS 固件，
卸载改用 PPE 实现。

和其他 BE7000 构建的区别
这版（beta5）	Beam WRT 1.5.0	Quarx2k r36844	kravasuper（22.06 镜像）
分区方案	QWRT，1 × 80 MB	原厂，2 × 40 MB（A/B）	NAND 或从 USB 启动（kexec）	原厂，2 × 40 MB（A/B）
内核 / Wi-Fi	6.18.55 / backports 7.2	6.18（1.4.0 中为 6.18.52；之后未注明版本）/ backports 7.2	6.18.55 / backports 7.2	6.18.35 / backports 6.18
回滚到原厂	通过 QWRT recovery	通过槽位，原厂保留	通过槽位 / 拔掉 U 盘	通过槽位
升级	通过标准 LuCI 页面 sysupgrade 并保留配置（从 beta3 起升级需 recovery）	在 LuCI 页面 sysupgrade 并保留配置	sysupgrade、attended sysupgrade	自 22.06 起没有新镜像
5 GHz 模式（单射频 / 双射频 / MLO）	✅ 三种都有（双射频 / MLO 为实验性）	✅ 三种都有	✅ 三种都有	单射频
硬件 NAT 卸载（PPE）	✅ 默认关闭	✅ 实验性	✅ offload 模块	—
适配本固件内核的软件源和 kmod	✅	✅	—	—
AmneziaWG	✅ + vpn:// 快速配置	✅	—	—
客户端 2.4 → 5 GHz 漫游（band steering）	✅ usteer	✅ 自带 roamd 守护进程	—	—
ath11k/ath12k 内存泄漏修复（#24254、#25632）	—	?	✅	—
zapret	✅	✅ Zapret Manager	—	—
Podkop、byedpi、pbr	✅	—	—	—
应用目录、Entware	✅	—	—	—
USB 上的 Docker	✅（+ qBittorrent、Jackett、Xray、Tailscale）	✅	—	—
更多装包空间	✅ extroot：USB 磁盘 ext4 分区，LuCI 页面；升级后仍在	✅ extroot；从 1.5.0 起第二个槽位放软件包（约 57 MB，不用 USB）	—	—
从原厂导入 Wi-Fi/WAN/LAN 配置	—	✅	—	—
从原厂用电脑脚本安装	—（需先刷 QWRT 再装）	—	✅	✅ 有教程
以上对比基于各作者仓库和发布说明，截至 2026-10-23。kravasuper 是移植作者，表里所有构建都基于他的移植；他从六月起不再发新镜像，但仍在向 OpenWrt 提交修复。如果你用的是原厂 bootloader，又想在后备槽位保留原厂固件——选 Beam WRT 或 Quarx2k。

包含内容
Wi-Fi： 2.4 GHz（ath11k，Wi-Fi 6）+ 5 GHz（ath12k QCN9274，Wi-Fi 7，最高 160 MHz），支持 802.11k/v、WPA3。

VPN： WireGuard、AmneziaWG（软件包 YAAWG 3.1.2；支持 AWG 2.0 协议——I1–I5、H 范围，旧格式没有 I1 的配置也能用）、OpenVPN。页面 VPN → 快速配置：
粘贴 AmneziaVPN 导出的 .conf 或 vpn:// 密钥 → 选“仅指定网站”或“全部流量”。

绕过封锁（默认关闭）：zapret、Podkop（sing-box：VLESS/Reality、
Trojan、Shadowsocks、Hysteria2）、byedpi、pbr、DNS over HTTPS。

硬件 NAT 卸载（PPE）——网络 → 硬件卸载（默认关闭）。

网络： SQM、UPnP、DDNS、adblock-fast、nlbwmon、vnStat、图表（collectd）、watchcat、banIP、IPv6
（运营商不下发前缀时自动启用 relay + NAT66）。

磁盘： samba4 + wsdd2、minidlna、NTFS/exFAT/ext4、自动挂载、可在 LuCI 里把 USB 磁盘
格式化为 ext4。

Extroot——系统 → USB 磁盘上的 Overlay：把 /overlay（配置和软件包）迁到
USB 磁盘的 ext4 分区。详见下文。

应用目录（服务 → 应用目录）：约 50 个精选程序，按类别分好，
一键安装/卸载：

装到路由器闪存——来自 OpenWrt 软件源（带俄语 LuCI 翻译）；

装到 USB 磁盘——qBittorrent、Xray、Tailscale、Docker、Jackett；

装到 USB 磁盘上的 Entware（约 3000 个软件包）——AdGuard Home、Syncthing、File Browser、rclone、
v2rayA、Python、Node.js…

驱动（4G/5G USB 上网卡、手机 USB 共享网络、打印机、NFS、MultiWAN）——来自本固件的软件源（约 930 个 kmod 都针对它的内核编译）。

完整列表（约 7500 个程序、11000+ 个带 LuCI 翻译的软件包）——照常去系统 → 软件包看
（联网后软件包列表会自动下载）。

LuCI 为俄语界面。

mini 版（beta4.1-mini）
beta5 没做 mini；当前 mini 是 beta4.1-mini（自带内核和 beta4.1 软件源）。

给不需要预装一堆东西的人：镜像里就是原版 OpenWrt 的组成（俄语 LuCI、
防火墙、软件包管理器、wpad-basic-mbedtls），再加上 BE7000 在 QWRT 分区方案下正常使用必不可少的东西：

Wi-Fi 驱动和固件（ath11k 2.4 GHz、ath12k 5 GHz、board 文件）、以太网、PPE、USB；

QWRT 分区方案下的 LuCI 升级、升级后恢复自己装的软件包
（be7000-pkg-restore）、自动加载软件包列表、从备份恢复已启用的服务；

extroot（系统 → USB 磁盘上的 Overlay）和看门狗；

针对硬件的小修小补：EDMA 的 packet steering、USB hub 恢复、空的
board.json、启动日志。

上面“包含内容”里的东西都没有：没有 VPN（WireGuard 也没有——原版 OpenWrt 本来就不带）、没有绕过
封锁、samba、统计、应用目录、Docker、5 GHz 双射频/MLO 模式、PPE 页面
（卸载用防火墙里的标准勾选项）、NFC。我的默认设置（802.11k/v 漫游、DNS 缓存、vpn 区域、CPU performance 模式、软件卸载）也不会应用。
都可以从软件源装：mini 的内核和 beta4.1 一样，用的是 be7000-qwrt-beta4.1 软件源
（apk add luci-proto-amneziawg、apk add podkop、apk add luci-app-be7000-nfc…）。

beta4.1	beta4.1-mini
镜像（sysupgrade）	51 MB	20 MB
/overlay 可用空间	~20 MB	~46 MB
镜像中软件包数	415	175
来自软件源的包刷进闪存后占的空间比镜像里大（镜像用 xz 压缩）。如果几乎全装回去，
剩余空间会比完整版 beta4.1 少。预装包在服务没启动前不占运行内存。

完整版和 mini 之间切换靠 LuCI 升级。保留配置时配置还在，但
新镜像里没有的包要自己装（be7000-pkg-restore 只恢复
你在固件之外自己装的东西）。

安装（从 QWRT 刷入）
需要：电脑用网线接 LAN 口，以及 Releases 里的 …-squashfs-factory.ubi。

确认你用的是 QWRT bootloader，且 rootfs 分区是 80 MB（cat /proc/mtd）。

需要的话先备份配置（系统 → 备份 → “创建存档”）。

电脑设静态地址 192.168.1.10 / 255.255.255.0。

路由器断电 → 按住 Reset → 上电 → 保持 10–15 秒（橙色闪烁）→ 松开。

浏览器打开 http://192.168.1.1 → FIRMWARE UPDATE → 选 …-factory.ubi。等 3–5 分钟。

电脑改回 DHCP。LuCI：http://192.168.1.1，root 密码为空——马上设一个。
Wi-Fi：BE7000 / BE7000_5G，密码 be7000setup——记得改。

如果刷完后路由器长时间（> 5 分钟）橙色闪烁、起不来——再做一次
recovery：它在 bootloader 里，不会被擦掉。已知“擦掉了但没写进去”的原因是
bootloader 变量 loadaddr=0x0；在 bootloader 控制台（UART）里修：
setenv loadaddr 0x50000000; saveenv。QWRT 分区方案下系统里的 fw_printenv 可能显示
的不是 bootloader 实际使用的环境——别拿它当准。

升级
beta4 及以后——在 LuCI 里升级，保留配置：

从 Releases 下载 …-squashfs-sysupgrade.bin（不是 factory.ubi）。

系统 → 备份 / 刷写固件 → “刷写镜像…” → 选文件。

和发布页的 sha256sums.txt 对一下 SHA-256。勾选“保留配置”和“创建当前已安装软件包列表”——这样你自己装的包在联网后会自动装回来。“Force upgrade”不用勾。

点“继续”——路由器 3–4 分钟后重启。别断电。

写入前固件会检查镜像（是不是 BE7000 的、QWRT bootloader 能不能启动、放不放得下），不合格就直接拒绝，不会先擦掉；勾了“Force
upgrade”也会检查。写完后还会把写入内容和镜像比对。没有第二个槽位：如果升级后的系统
起不来（橙色常亮），只能像安装时那样走 recovery。

从 beta3 及更早版本——只能走 recovery，和安装一样（这些镜像里禁用了 sysupgrade）。配置请提前备份，刷完再恢复。

回滚到 QWRT——用 QWRT 的 …-nand-factory.bin 走 recovery。

普通重启后橙色常亮
如果路由器本来用得好好的，重启（或断电）后橙色常亮、起不来——多半是
bootloader 环境被重置了：bootcmd 回到出厂的
bootipq，在这个 QWRT bootloader 构建上会立刻重启，一直循环。
beta4.1 及以前的镜像可能自己把这个环境擦掉（env 大小写错，64K 写成 256K）；beta5 已修。这种情况 recovery 没用，得上 UART（115200，1.8 V）：打断
自动启动，执行

text
setenv loadaddr 0x50000000
setenv bootargs console=ttyMSM0,115200n8 ubi.mtd=rootfs ubi.block=0,ubi_rootfs root=/dev/ubiblock0_1 rootfstype=squashfs rootwait
setenv bootcmd 'ubi read 0x50000000 kernel; bootm 0x50000000'
saveenv
boot
从系统里检查：fw_printenv bootcmd（从 beta5 起 /etc/config/ubootenv 里应该是
envsize '0x40000'；如果写的是 0x10000，fw_printenv 显示的环境就不对）。

Extroot：把 /overlay 放到 USB 磁盘上
闪存里给配置和软件包的空间约 20 MB。系统 → USB 磁盘上的 Overlay 会把 /overlay 迁到
USB 磁盘分区，空间就变成分区那么大。命令行也一样：

text
be7000-extroot list                     # 分区及为何某个不能用
be7000-extroot use /dev/sda3 --yes      # 格式化为 ext4 并迁移
be7000-extroot use /dev/sda3 --keep     # 迁移到已有 ext4 而不格式化
be7000-extroot status
be7000-extroot revert --yes --reboot    # 退回闪存（配置会被复制）
需要 256 MB 以上的 ext4 分区。 NTFS/exFAT/FAT 不行——没有 Linux 权限。
数据盘不用格式化：在旁边单独分一个区（比如 Windows“磁盘管理”里分）再选它。已挂载的分区和小于 256 MB 的分区，页面不会列出来。

LuCI 升级能用。 磁盘和固件构建绑定：新版本第一次启动时先从闪存起来，带着迁移过去的配置，再把配置迁到磁盘（旧内容放到
upper.prev），重启，等你联网后把你自己装的包装回来。旧包和内核模块不会带到新固件里。

如果启动时磁盘没接上——路由器从闪存跑，用的是迁移时的配置；页面会显示这个状态。

如果运行中磁盘掉了（USB 故障、线松了），磁盘上的系统就读不了了。看门狗 15 秒内发现并重启路由器；如果启动后 10 分钟内磁盘第二次消失，就关掉 extroot，路由器回到闪存启动。

/overlay 在磁盘上时，别从运行中的路由器上拔磁盘。

别把特别吃 USB 的东西放在同一块盘上——比如把 BT 下载目录放到 NTFS 分区。ntfs3 驱动在往文件中间写之前会先把前面的零补齐；
USB 队列一块盘只有一个，队列一忙，磁盘上的根文件系统就读不了——路由器就“卡死”（网络
还在，SSH/LuCI 不通）。BT 请下到 ext4，或者把 /overlay 放到另一块盘上。

软件包源
固件会自动连 https://trall9.github.io/be7000-openwrt/<版本>/——里面有适配它内核的驱动（kmod）
和本构建的软件包（zapret、podkop、amneziawg、byedpi…）。软件包用构建密钥签名；
密钥已内置在固件里。官方 OpenWrt target 源被禁用了：它的 kmod 是针对别的内核编译的，装不上。

从源码构建
sh
git clone https://github.com/Trall9/be7000-openwrt.git
cd be7000-openwrt
./build.sh ~/openwrt-be7000 $(nproc)          # 完整版
MINI=1 ./build.sh ~/openwrt-be7000-mini $(nproc) # mini
source/patches/——OpenWrt 之上的改动（git am），source/files/——固件文件，
source/diffconfig——配置（files-mini/、diffconfig-mini——用于 mini），source/feeds.lock——OpenWrt 和软件源的提交。
自己构建会用你自己的密钥签名软件包——本仓库的软件源不会认
（要连自己的软件源一起构建：bin/targets/…/packages）。

反馈问题
Issues。请附上：

sh
cat /etc/openwrt_release; uptime
be7000-health-check
be7000-crashlog
logread > /tmp/log.txt; dmesg > /tmp/dmesg.txt
