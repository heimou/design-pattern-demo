#!/usr/bin/env bash
##############################################################
#     服务启动脚本
#     环境: centos7
#     Git地址： http://git.cyedtech.cn/education
#     mavan : 3.6.0 settings.xml 需要配置私服地址
#     java        1.8
#
##############################################################

gitUserName="gitUserName"
gitPassword="*******"
gitAddress="http://${gitUserName}:${gitPassword}@git.cyedtech.cn/education/apiV2/"



## 检测是否有git环境
function  check_git_environment() {
    echo "开始检测是否安装git 环境>>>>"
    version=`git --version|awk '{print $3}'`
  if [[ ${version} == null ]] ; then
   yum -y install gitv
  else
    echo "存在git 环境 版本为 $version"
  fi
}

## 检测是否有maven 地址
function checkAndConfigMaven() {
    echo "检测并且配置maven"


}


# 检测服务是否开启
function  checkExitsServiceAndStartService() {
    serviceStatus=`ps -ef|grep $1 |grep -v grep|cut -c 9-15`
    if [[ ${serviceStatus} != null ]]; then
      kill -9 ${serviceStatus}
   fi

      #删除上次备份
   rm -rf /execJar/$1
   mv /execJar/plan$1 /execJar/$1
   # 启动新的服务
   nohup java -jar /execJar/$1 > /execJar/$2 2>&1 &
   echo "服务启动完毕>>>>"
}

# 检测是否含有文件文件 没有就创建
function check_mkdir() {
     if [[ ! -d $1 ]]; then
       mkdir $1
 fi
}


# 拉取代码并打包
function  checkCodeAndInstall(){

  # 进入到临时文件夹 并且获取到所有分支
      check_mkdir temp
      cd temp
      check_mkdir $1
      cd $1

      git clone ${gitAddress}$2.git
      cd $2

      # 获取当前项目所有分支 切换到对应的分支
      gitBranch=`git branch -r`
      echo "当前项目的分支 ${gitBranch} 请输入需要打包的分支名称"
      read branchName
  # todo: 这里后面要加异常判断
      git checkout ${branchName}
      git pull

      echo "开始打包程序"
      mvn clean install -Dmaven.test.skip=true
    
      check_mkdir /execJar
      cd target

      #备份原来的jar
       check_mkdir /execJar/bak
       cp ${jarName} /execJar/bak/bak${jarName}

       cp $3 /execJar/plan$3
	cd ../../../ 
       rm -rf /$1
}







  #spet 1 检测系统环境 是否满足
 check_git_environment

 # spet 2 选取服务和分支
 echo "请选择要拉取的服务名称，并输入服务前的标号
  1  education-auth  2 education-course 3 education-exam
  4 education-gateway 5 education-service 6 education-paycenter
  7 education-sevenMembers 8 退出 "
  read selectServiceNum

   case ${selectServiceNum} in

    1) # 住建教育平台认证中心
      tempFilePath="auth`date +%s`"
      gitProjectName="education-auth"
      jarName="education-auth.jar"
      logFileName="education.log"
      ;;
    2) #住建教育平台课程服务模块
      tempFilePath="course`date +%s`"
      gitProjectName="education-course"
      jarName="education-course.jar"
      ;;
     3) #住建教育平台课程服务模块
      tempFilePath="exam`date +%s`"
      gitProjectName="education-exam"
      jarName="education-exam.jar"
      ;;
     4) #住建教育平台课程服务模块
      tempFilePath="gateway`date +%s`"
      gitProjectName="education-gateway"
      jarName="education-gateway.jar"
      ;;
     5) #住建教育平台课程服务模块
      tempFilePath="service`date +%s`"
      gitProjectName="education-service"
      jarName="test.jar"
      logFileName="education-service.log"
       ;;
      6) #住建教育平台课程服务模块
      tempFilePath="paycenter`date +%s`"
      gitProjectName="education-paycenter"
      jarName="education-paycenter.jar"
      logFileName="education-paycenter.log"
      ;;
       7)  #七大员教育平台
      tempFilePath="sevenMembers`date +%s`"
      gitProjectName="education-sevenMembers"
      jarName="education-sevenMembers.jar"
      logFileName="education-sevenMembers.log"
      ;;
       *) # 默认离开
          exit
         ;;
      esac

      # 拉取代码到本地并打包
      checkCodeAndInstall  ${tempFilePath} ${gitProjectName} ${jarName}

     # 启动服务
      echo `pwd`
      # 移动原来的包到备份中
      check_mkdir /execJar/logs
      checkExitsServiceAndStartService ${jarName} logs/${logFileName}

#      rm -rf temp/${tempFilePath}
      # End








