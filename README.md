<p align="center">
<a href="https://github.com/flytutu-susu/CloudFlare-DDNS/tree/main"><img src="https://img.shields.io/badge/CloudFlare-DDNS-brightgreen"></a>  
<a target="_blank" href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-_red.svg"></a>  
<a href="#python3"><img src="https://img.shields.io/badge/python-v3.8-blue"></a>
<a href="#table-of-contents"><img src="https://img.shields.io/badge/Docker-Build-brightgreen"></a>
<a href="#features"><img src="https://img.shields.io/badge/multi-platform-orange"></a>
<a href="#features"><img src="https://img.shields.io/badge/log-rotation-orange"></a>
</p>

<h4 align="center">简体中文 | <a href="https://github.com/flytutu-susu/CloudFlare-DDNS/blob/python/readme.en-us.md">English</a></h3>


CloudFlare DDNS是一个用于CloudFlare的动态域名解析服务，适用于家庭宽带，它能自动检测家庭宽带的IP变动，并自动更新域名的解析。

本程序仅适用于CloudFlare上的域名

右上角点个 ⭐ Star 不迷路



# Features

- 配置简单但丰富
- 具有邮件提醒功能，服务通知和异常提醒
- 支持docker运行
- 日志记录和滚动
- 支持同时更新多个域名
- 支持IPv6



# Table of Contents

- [1. Background](#1-background)
- [2. Quick Start](#2-quick-start)
- [3. Configuration](#3-configuration)
- [4. Note](#4-note)
- [5. Usage - Docker](#5-usage---docker)
    - [5.1 Build or Pull Image](#51-build-or-pull-image)
    - [5.2 RUN](#52-run)
    - [5.3 Start with Linux](#53-start-with-linux)
    - [5.4 Log - Docker](#54-log---docker)
- [6. Usage - Direct](#6-usage---direct)
    - [6.1 Install](#61-install)
    - [6.2 Start](#62-start)
    - [6.3 Log](#63-log)
    - [6.4 Start At Boot](#64-start-at-boot)



# 1. Background

内网映射，内网穿透，在外访问家里的机器的方案

### IPv4

目前运营商给家庭宽带的IP都是动态的，庆幸的是虽然IP地址不固定，但分配到家庭路由器的却是一个实实在在的公网IP，所以我们只需**设置光猫桥接模式 + 路由器拨号上网 + 路由器NAT映射/DMZ主机**即可在公网访问家庭的设备。

且分配的公网IP会变动（每次间隔几天到十几天不等），为解决这一问题，可以购买一个域名，使用DDNS（Dynamic Domain Name Server，动态域名服务）将域名实时解析到宽带的IP。这样就可以在家搭建各种服务并通过访问**固定的域名**来访问，而无需租用昂贵的公网服务器

想实现这个目的，你需要一台一直运行的电脑来运行此DDNS程序



### IPv6

IPv6就简单了，运营商目前都给宽带配备了IPv6地址，只需在路由器上开启IPv6功能，电脑上确保有IPv6地址和DNS服务器地址即可使用IPv6联网。如果开了全局代理记得测试时关掉。

只要路由器的防火墙策略未限制外网流量访问内网，则无需NET映射，就能通过IPv6地址访问内网机器！



# 2. Quick Start

快速上手，Dokcer：

```shell
mkdir -p /home/docker/ddns
docker pull hesu65535/ddns
docker run -d --name ddns -v /home/docker/ddns:/home/CloudFlare-DDNS:rw --network host hesu65535/ddns
# run命令可选项-启动docker时启动容器: --restart=always
# run命令可选项-时区: -e TZ=Asia/Shanghai
cp /home/docker/ddns/conf/conf.json.example /home/docker/ddns/conf/conf.json
vi /home/docker/ddns/conf/conf.json
# 填写域名domain和api密钥key
# api密钥在这里获取: https://dash.cloudflare.com/profile/api-tokens
docker restart ddns
```

当然也可以作为python程序[直接运行](#usage---direct)。



# 3. Configuration

启动前需要配置`conf/conf.json`文件，参考conf.json.example，**只有domains、id、zone_id和key四项配置是必要的**，其余的可以不进行配置。



| 字段                     | 介绍                                                                                                                                                           |
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| domains                | A记录类型的域名，用于IPv4。支持同时更新多个域名，支持二级域名、三级域名等，如`["cc.bb.cn","q.w.cc.cn"]`。如果只使用IPv6，此项留白即可<br>程序只能更新已存在的DNS记录，而不能创建一个新的DNS记录。所以你**必须先在CloudFlare网页上创建一个解析**后，才能运行程序。 |
| domains_ipv6           | AAAA记录类型的域名，用于IPv6。如果只使用IPv4，此项留白即可。docker中使用IPv6，run命令需要`--network host`选项                                                                                  |
| ttl                    | Time To Live, DNS解析记录在DNS服务器上缓存时间，默认3600秒                                                                                                                    |
| id                     | cloudflare 的注册账号名称，一般为邮箱                                                       |
| zone_id                | 网站或者域名的区域id    |
| key                    | 从Cloudflare获取</a>的api key，有key才能获取和修改你的域名状态，保管好不要泄露此key                                   |
| frequency              | 多久检测一次你的ip变动，如有变动才更新你的域名解析状态，单位s                                                                                                                             |
| get_ipv6_local         | v2.2.4版本新增，默认ture。启用将从Python socket模块来获取本机ipv6地址，无需依赖外界，关闭则使用HTTP请求其它服务器来获取本机ipv6。 |
| mail_host              | SMT邮件服务器，如qq、163等。QQ邮箱[打开POP3/SMTP](https://service.mail.qq.com/detail/0/75)即可                                                     |
| mail_port              | 邮件服务器端口，必须是SMTP SSL端口                                                                                                                                        |
| mail_user              | 登录用户名，也是发件人                                                                                                                                                  |
| mail_pass              | 登录密码或key                                                                                                                                                     |
| receivers              | 数组，收件人地址，可以是多个。收件人 和 发件人 可以是同一个                                                                                                                              |
| mail_lang              | 邮件的语言。默认zh-cn，可选en-us                                                                                                                                        |
| auto_restart           | Linux、macOS下生效，默认不启用。在程序持续异常一段时间后，自我重启。v2.1.0版本已找到异常原因并解决，此项不再重要。                                                                                            |
| email_every_update     | 每次IP更新都发送邮件告知新IP，避免在DNS更新的十几二十分钟内无法访问。默认关闭，打开的前提是设置了邮件。                                                                                                      |



Q：邮件功能有什么用？

A：会收到以下邮件：ip变动后，推送CloudFlare成功；推送失败；程序因意外情况停止；程序自动重启

Q：如何开启邮件功能？

A：从mail_host到mail_pass，4个配置都填写正确，就会自动启用



测试邮件设置是否正确，会发送一封邮件到你的邮箱：

```
DDNS testEmail
# or
python ddns.py --test-email
```



# 4. Note

本程序只能更新域名的DNS记录，无法增加，请确保你的域名存在此DNS记录。



# 5. Usage - Docker

Doker的优点是不需要安装python环境，在开机自动启动方面不需要将脚本加入systemctl

## 5.1 Build or Pull Image

<b>从Docker Hub拉取</b>

```shell
docker pull hesu65535/ddns
```

本镜像基于最小的Linux alpine构建，Docker Hub显示22.04 M，`docker images`显示镜像大小为59.4M

Docker Hub中的镜像不一定是最新的，你也可以选择手动构建镜像



<b>手动构建镜像</b>

```shell
docker build --network=host -t hesu65535/ddns .
```

构建过程中下载`python:3.x.x-alpine`镜像和`pip install httpx`需要一点时间
构建时需要指定使用主机网络，否则可能会在install httpx模块时出现网络连接问题



## 5.2 RUN

```shell
docker run -d --name ddns -v <local dir>:/home/CloudFlare-DDNS:rw --network host hesu65535/ddns
# --restart=always
```

一定要用 -v 参数将本机的目录`<local dir>`挂载到容器内的`/home/CloudFlare-DDNS`，容器会将程序文件写出到`<local dir>`

接着在`<local dir>`中配置`conf/conf.json`，参考[Configuration](#configuration)

最后记得重启一下容器，因为最开始`docker run`时没有配置文件，所以ddns程序是没有成功运行的

```shell
docker restart ddns
```

IPv6请使用`--network host`选项，IPv4可以不用

查看ddns程序状态用`<local dir>`中的`ddns-docker`



## 5.3 Start with Linux

```shell
systemctl enable docker
docker update --restart=always ddns
```



## 5.4 Log - Docker

日志在`<local dir>/log`文件夹下

查看程序运行状态，以及历史更新记录，运行：

```shell
<local dir>/ddns-docker
```

查看所有日志文件：

```
ls -lh log/DDNS*.log*
```



当DDNS服务启动时，若`DDNS.log`超过2M便会触发自动归档。可以存储使用DDNS以来所有的日志。



# 6. Usage - Direct

直接在机器上运行程序

## 6.1 Install

下载即用

```
git clone -b python https://github.com/flytutu-susu/CloudFlare-DDNS.git
```

需要使用python3来运行，python需要安装httpx模块：

```
pip install httpx
```

更新程序：

```
git pull origin python
```



## 6.2 Start

**快速启动：**

```
python ddns.py
```



**Linux | Mac进阶使用：**

`DDNS`文件是一个功能强大的脚本，可以后台启动ddns.py程序，检测程序是否在后台运行，以及杀死程序

使用之前先编辑DDNS文件，修改第8行为CloudFlare-DDNS项目的**绝对路径**，修改第17行为python 3可执行文件路径即。这样做是为了在使用软链或设置程序随系统启动时能找到项目路径

`DDNS`脚本使用方法：

```
chmod +x DDNS
# usage
./DDNS {start|stop|status|restart|force-reload}
```

功能类似[Log - Docker](#log---docker)，但更强大



如果想在任何地方使用`DDNS`命令，可以在`/usr/bin`目录下建立软链接，注意`ln`命令要使用绝对路径，如

```
ln -s /root/CloudFlare-DDNS/DDNS /usr/bin/DDNS
```



**Windows使用：** 双击bat或vbs文件，程序运行状态请查看日志



## 6.3 Log

日志都在log文件夹下



<b>Linux</b>

查看日志文件

```
ls -lh log/DDNS*.log*
```

当DDNS服务启动时，若`DDNS.log`超过2M便会触发自动归档。可以存储使用DDNS以来所有的日志。

手动归档日志，用于在`DDNS status`打印信息过多时

```
DDNS archiveLog
# or
python ddns.py --archive
```



<b>Windows</b>

当DDNS服务启动时，若`DDNS.log`超过2M便会将旧的`DDNS.log`文件重命名为`DDNS-xxx.log.back`

手动归档日志:

```
python ddns.py --archive
```



## 6.4 Start At Boot

<b>Linux</b>

设置开机启动，仅示范RedHat系列，如CentOS 7 8和Rocky Linux 8，其他Linux发行版请自行编写脚本。

将DDNS注册为systemctl管理的服务

首先要按照[start](#start)中的步骤配置DDNS文件

接着配置DDNS.service文件，修改其中DDNS文件的路径，最后

```
cp  ./DDNS.service  /usr/lib/systemd/system/DDNS.service
systemctl daemon-reload
systemctl enable DDNS
```



<b>Windows</b>

将vbs文件[加入策略组](https://blog.csdn.net/yunmuq/article/details/110199091)
