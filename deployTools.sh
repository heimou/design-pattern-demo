#!/usr/bin/env bash
########################################################
#    centos7 一键部署工具
#    java 1.8
#    git
#    maven 3.6.3
#    禅道   12.0
#    mysql 8
#    nginx1.14.2
#
########################################################
# 检测防火墙是否开启
function firewalld_check() {
   if [[ ${fireWalldFlag} -eq null ]]; then
       systemctl start firewalld
   fi
}
# 检测是否含有文件文件 没有就创建
function check_mkdir() {
  if [[ ! -d $1 ]]; then
    mkdir $1
  fi
}


## 安装git 环境
function  install_git_environment() {
  echo "开始检测是否安装git 环境>>>>"
  version=`git --version|awk '{print $3}'`
  if [[ ${version} == null ]] ; then
    echo "未检测git 环境 开始安装git>>>>>"
   yum -y install git
   echo "git 安装完毕，版本为 `git --version|awk '{print $3}'`"
  else
    echo "存在git 环境 版本为 $version"
  fi
}

#java 源码 安装
function yum_java8_install() {
    echo "开始安装java 8 yum 源处理"
    yum -y install java-1.8.0-openjdk-devel.x86_64

    echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.181-3.b13.el7_5.x86_64" >> /etc/profile
    echo "export JRE_HOME=$JAVA_HOME/jre" >> /etc/profile
    echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
    echo "export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >>/etc/profile
    source /etc/profile
   echo "java8 环境安装完毕,现在开始检测是否ok"
  version=`java -version`
  echo "java 版本"$ version
}

# nginx 源码安装
function yum_nginx_install() {
        echo "开始安装 nginx1.14.2 >>>>>>"
         yum -y install gcc pcre-devel openssl openssl-devel
         wget https://nginx.org/download/nginx-1.14.0.tar.gz
         tar -xzvf nginx-1.14.0.tar.gz
         mv nginx-1.14.0 /usr/local/nginx
         rm -rf nginx-1.14.0.tar.gz
#         echo "将准备好的nginx.conf 替换到 /usr/local/nginx/conf/nginx.conf"
#         mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.cong.bak
#         mv ${currentPath}/conf/nginx.conf /usr/local/nginx/conf/nginx.conf
         # 进入nginx 目录配置   检测配置./configure
         cd /usr/local/nginx/
         # 新建文件夹 logs
         mkdir logs
         ./configure
         echo "配置文件检测是否出现 ./configure: error提示,如果没有 请按Entry 进行下一步编译,\
            否则请按 n 退出当前安装，解决nginx_check 错误后 重新安装"
         read inputCheckNginx
         if [[ ${inputCheckNginx} == 'n' ]]; then
             # 删除nginx 源码
             echo "结束安装！"
          else
             echo "开始编译nginx"
             make
             make install
             echo "export NGINX_HOME=/usr/local/nginx" >>/etc/profile
             echo "export PATH=$PATH:$NGINX_HOME/sbin" >>/etc/profile
             source /etc/profile
#             firewalld_check
#             firewall-cmd --permanent --zone=public --add-port=4200/tcp;
#             firewall-cmd --reload
             /usr/local/nginx/sbin/nginx
             echo "nginx 安装完毕>>>>>>>>>>"
         fi
}

# 校验服务器时间
function check_date() {
     yum install -y ntp
     systemctl enable ntpd
     rm -rf /etc/sysconfig/ntpd
     touch /etc/sysconfig/ntpd
     echo " OPTIONS=`"-g -x"` " >> /etc/sysconfig/ntpd
     systemctl start ntpd.service
     ln -sf /usr/share/zoneinfo/Asia/Shanghai/etc/localtime
     echo "服务器系统时间:`date`"
}



# yum install maven
function yum_install_maven() {
 check_mkdir /tools/maven
 cd /tools/maven
 wget https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
 tar -zxvf apache-maven-3.6.3-bin.tar.gz apache-maven-3.6.3
 echo "export MAVEN_HOME=/tools/maven/apache-maven-3.6.3" >>/etc/profile
 echo "export PATH=$PATH:$MAVEN_HOME/bin" >>/etc/profile
 source /etc/profile
 echo "更换配置settings.xml，路径地址 /tools/maven/apache-maven-3.6.3/conf"
}


#step1  java
echo "是否需要安装jdk 1.8 ? 确认请输入 y,不需要启动请按 Enter 键跳过"
read inputSystem
if [[ ${inputSystem} == "y" ]]; then
    yum_java8_install
fi

#step2 时间校对
echo "开始时间校对 默认为东八区时间? 确认请输入 y,不需要启动请按 Enter 键跳过"
read inputTime
if [[ ${inputTime} == "y" ]]; then
    check_date
fi

#step3 nginx
echo "是否需要安装 nginx ? 确认请输入 y,不需要启动请按 Enter 键跳过"
read inputNginx
if [[ ${inputNginx} == "y" ]]; then
    echo "请准备好配置文件 nginx.conf 在脚本同级目录>>>>>>>>"
    yum_nginx_install
fi

#step4 maven
echo "是否需要安装 maven3.6.3 ? 确认请输入 y,不需要启动请按 Enter 键跳过"
read inputNginx
if [[ ${inputNginx} == "y" ]]; then
    yum_install_maven
fi





