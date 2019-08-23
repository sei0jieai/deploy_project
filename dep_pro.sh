#!/bin/bash
###############################
#decription:de	
117.78.42.21
#author:kl
#version:1.0
###############################
#常用变量
shell_name="dep_pro.sh"
time=$(date '+%Y%m%d-%H%M%S')
bak_path="/data/backup/${pro_name}"
log_file=/root/shell_deploy/logs/${shell_name}.log

#GIT变量
git_code_path="/root/shell_deploy/git_code"
git_pro_name="kl-jenkins-javatest"
git_url="https://github.com/sei0jieai"
git_branch_name="master"

#工程目录-列表
#tomcat目录
pro_name="apache-tomcat-8.5.43-devopstest"
pro_path="/data/${pro_name}"

#备份目录
backup_path="/data/backup/${pro_name}"

#部署目录(工程目录)
deploy_path="/test-dev/$pro_name/ROOT/"

#回滚目录（上一次备份目录）
rollback_path="/test-dev/rollback/$pro_name/ROOT_${time}"
function shell_log()
{
    log_info=$1
    echo -e "$(date +"%F %T") ${shell_name} ${log_info}" | tee -a ${log_file}
}