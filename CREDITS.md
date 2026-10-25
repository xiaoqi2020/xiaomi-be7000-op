来源与致谢
这版固件建立很多人的工作之上。下面列出谁做了什么、具体取用了什么，以及在这版固件中、在原有基础上又改了什么。

OpenWrt 中的 Xiaomi BE7000 支持
作者 / 项目	取用了什么	这里改了什么
OpenWrt（main，2026-10-01）和 openwrt/backports	整个系统、内核 6.18.54、来自 7.2 内核的 Wi-Fi 驱动、LuCI、软件包	—
kravasuper（分支 xiaomi_be7000，提交 790d036a）	移植基础：板级 DTS、镜像 profile、Wi-Fi 校准（caldata）、IPQ9574（2.4 GHz）的 ath11k 补丁和 ath12k（5 GHz，QCN9274）补丁、板级脚本、NFC；以太网接收修复“qualcommbe: fix PPE EDMA RX DMA mappings”（已进 OpenWrt，补丁 0362——这版也能用）	移植迁到较新的 OpenWrt main（内核 6.18.36 → 6.18.54，backports 6.18 → 7.2）：两个 ath11k/ath12k 补丁已进 upstream，已移除；IPQ9574 支持补丁适配了新驱动结构；镜像改为 QWRT 分区方案（单个 UBI 80 MB），内核分区上限也相应调高
timofey-maykov / Beam WRT	以太网补丁 0900（qcom-ppe 里 napi_disable 卡死）、0901（BaseR QCA8084 不是致命错误）、0902（端口回退时数组越界）、0903（抢占 BaseR 后重新配置 XPCS）；DTS 修改——内核不通过 RPM 给 l2 稳压器投票（部分板子上会静音以太网接收）；在 profile 里加 ath11k-ahb 的思路；启动确认脚本 be7000-bootconfirm；干净安装时 Wi-Fi 的处理思路。从 beta3 起： PPE 硬件卸载修复 0905（EDMA 接收）、0906（表项整行写入——没有它流不生效）、0907（PPE 上的桥接单独选项），mac80211 393（到 Wi-Fi 客户端的转发路径），LuCI 页面“硬件卸载”和 be7000-ppe；5 GHz“双射频”和 MLO 模式：ath12k 308–311、iwinfo 008、DTS 006（MLO 内存）和 007（通过 pinctrl 的 TLMM6/7 射频线）、be7000-5g-split、LuCI 面板、按模式校准、dual-MAC 板级数据；DTS 011（TrustZone 预留，和原厂一样）；DT 池的 CMA（010）；packet-steering.sh（以太网接收不集中到 CPU0）；闪存里的启动日志 be7000-bootlog；恢复空的 board.json。beta4： sysupgrade“写系统启动时所在分区”的逻辑（他们的补丁 003）——这是我们在 QWRT 分区方案上 sysupgrade 的基础；升级后把用户自己装的包装回来的思路；extroot 设备——be7000-extroot 命令集、占用磁盘检查、delay_root 15 秒、从 LuCI 后台启动和“存储”页面。beta5： 0908（按 JEDEC ID 设置 NAND ECC 强度，ESMT 闪存）、ath12k 312–315（固件崩溃后的恢复）	be7000-ppe 脚本：关闭时只关硬件卸载，软件卸载保留；我们的 RPS 调优不碰 qcom_ppe 端口；bootlog 适配 QWRT 分区方案（crash_syslog = mtd26）；单分区 QWRT 方案上的 sysupgrade（卷号、释放分区、写入前后检查镜像），装回软件包走标准 sysupgrade -k 列表；extroot：磁盘和固件构建绑定（Beam 升级后会挂上旧的 upper），升级后把配置迁到磁盘，磁盘掉线看门狗，不格式化迁移，带配置回退，修 fstools（gpiochip0 而不是根）
Quarx2k / OpenWRT-BE7000（Quarx2k，Nickolai Semendiaev）	精确的“四条链路都接到同一个 5 GHz 射频”接线（TLMM6/7），原生 WCSS 驱动的思路。从 beta3 起： 内核补丁 9511（QCA8084 时钟在可睡眠上下文读取）、9518（QCA8084 MAC 时钟不切源——链路掉线时 MAC4 超时）、0374（PHY 链路状态传给 XPCS）	—
openwrt/openwrt#20604（dima424658 及参与者）	板子信息：UART 1.8 V，通过 UART + TFTP 启动	—
openwrt-xiaomi/xmir-patcher	访问原厂固件（SSH）——迁移第一步	—
QWRT	bootloader 和单 rootfs 80 MB 分区方案、网页 recovery	发现并描述了 bootloader 的坑 loadaddr=0x0（recovery 擦除分区但不写入）。beta1–beta3 的结论“单分区上的 sysupgrade 会擦掉系统”是错的：bootloader 按 UBI 卷号取内核和系统，而 sysupgrade 把卷号挪了。从 beta4 起，这个分区方案上的 sysupgrade 能正常工作
硬件 NAT 卸载（PPE）和 NSS
作者 / 项目	取用了什么
hurrian / Kenneth Kasilag——openwrt/openwrt#24178 “[RFC] qualcommbe: add PPE offload support”	补丁系列 0500–0520 和 generic 767–769：通过 switchdev 的桥接、L3 流表、netfilter 的 flowtable 卸载、IPv4/IPv6、PPPoE、WAN 上的 VLAN、DS-Lite/MAP-E、TBF 限速器、虚拟端口。按 Beam WRT 汇总的版本取用（tree 014）
JuliusBairaktaris	IPQ807x 的 HPPE 卸载驱动——Quarx2k 那套卸载方案的基础（未包含在本固件中，作为前身列出）
qosmio（nss-packages、qca-sdk-nss-fw）	qca-nss-ecm 支持的内核补丁（0910–0917）——beta1–beta2 中有；beta3 已移除（没有 NSS 固件时 ECM 不工作，钩子和 PPE 卸载冲突）
JuliusBairaktaris/nss-packages	NSS 软件包源码（驱动、ECM、clients）——不包含在镜像里：IPQ9574 没有开源 NSS 固件，卸载改走 PPE（见上）
VPN 和绕过封锁
作者 / 项目	取用了什么	这里改了什么
Amnezia VPN（amneziawg-linux-kernel-module）	AmneziaWG 内核模块	页面 VPN → 快速配置：粘贴 AmneziaVPN 应用导出的 .conf 或 vpn:// 密钥（在浏览器里解包），选择“仅指定网站”/“全部流量”，防 IPv6 泄漏
YAAWG	OpenWrt 用的 amneziawg-tools、kmod-amneziawg、luci-proto-amneziawg 3.1.2 软件包（AWG 2.0 协议）	—
ITDog / Podkop	Podkop 和 luci-app-podkop	修了和 Docker 的冲突（在所有网桥上做 iptables 过滤会破坏 Podkop 的透明代理）
SagerNet / sing-box	Podkop 内核（VLESS/Reality、Trojan、Shadowsocks、Hysteria2）	编译时去掉了内置 Tailscale（−10 MB）
bol-van / zapret 和 remittor / zapret-openwrt	DPI 绕过，以及它的 OpenWrt 软件包/LuCI 页面	能和 USB 磁盘上的 /opt 卷共存（固件目录会覆盖到卷上面）
hufrea / byedpi	ByeDPI	自制的 OpenWrt 软件包（init + uci）
XTLS / Xray-core、Tailscale	从官方 release 装到 USB 磁盘	安装配方，磁盘加载后自动启动
4PDA 主题“OpenWrt 上绕过封锁的方法”	当前可用绕过方法的合集，选型时参考了它	—
应用和列表
作者 / 项目	取用了什么	这里改了什么
c0re100 / qBittorrent Enhanced Edition	qBittorrent 静态编译版（HTTPS 可用）	BT 默认只走 WAN（不会漏进 VPN）；加了“WebUI 密码”按钮
Jackett	PT/BT 站点索引器	装到 ext4 卷，限制内存，ICU 自动安装
Entware	约 3000 个路由器软件包的仓库	从应用目录一键安装，服务自动启动
Hagezi DNS blocklists	adblock-fast 默认用 Hagezi Pro 列表	—
这版固件做了什么
有些思路其他作者已经做过——文中已注明。

迁到较新的 OpenWrt（内核 6.18.54，Wi-Fi 驱动 7.2），并适配 BE7000 补丁
（同样迁到 backports 7.2，包括 max_tx_ring 修改；Beam WRT 更早做过，9 月 29 日）。

QWRT 80 MB 分区方案的镜像，并支持在该方案下从 LuCI 升级并保留配置（从 beta4 起）：
写入前检查镜像（包括勾“Force upgrade”时），写入后再比对。

应用目录：约 50 个程序，一键装到闪存、USB 磁盘或 Entware。

在 GitHub Pages 上提供适配固件内核的驱动和软件包源（Beam WRT 更早有了自己的 kmod 源）。

“外置磁盘上的软件”：Docker、Jackett、qBittorrent、Xray、Tailscale、Entware 装到 USB 磁盘；
NTFS/exFAT 上用文件形式的 ext4 卷，ext4 上直接装到磁盘；可在 LuCI 里把磁盘格式化为 ext4
（Beam WRT 也有 USB 上的 Docker）。

VPN → 快速配置：支持 AmneziaVPN 的 vpn:// 密钥，“指定网站”/“全部流量”模式，防 IPv6 泄漏。

固件内置绕过封锁：Podkop、zapret、byedpi、pbr；修了 Podkop 和 Docker 的冲突。

USB 磁盘稳定性：usb-watchdog、修复“脏”NTFS（scanvol）、自动挂载。

运营商路由器后面的 IPv6：不下发前缀时自动启用 relay + NAT66；
修了客户端地址学习（accept_untracked_na）。

Wi-Fi 和网络调优：AQL、ath12k 中断分配、RPS、flow offload、关闭 U-APSD、
802.11k/v、CPU governor；检查脚本 be7000-wifi-check。

诊断：内核崩溃日志（mtdoops）、磁盘上的持久日志、夜间配置备份、
内存看门狗、be7000-health-check。

软件包列表自动下载；LuCI 为俄语界面。
