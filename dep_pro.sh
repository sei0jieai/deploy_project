#!/bin/bash
###############################
#decription:deploy the project
#author:kl
#version:1.0
###############################
#常用变量
shell_name="dep_pro.sh"
time=$(date '+%Y%m%d-%H%M%S')
log_file="/root/shell_deploy/logs/${shell_name}.log"
dep_pack_path="/root/"
dep_pack_name="apache-tomcat-8.5.43-devopstest.war"
pro_pid=`ps -ef|grep $pro_name|grep -v 'grep'|awk -F " " '{print $2}'`
#工程目录-列表
#tomcat目录
pro_name="apache-tomcat-8.5.43-devopstest"
pro_path="/data/${pro_name}"
config_file="/test-dev/config_file/${pro_name}/"

#备份目录
backup_path="/data/backup/${pro_name}"

#部署目录(工程目录)
zip_pack_name="apache-tomcat-8.5.43-devopstest.war"
deploy_path="/test-dev"

#回滚目录（上一次备份目录）
rollback_path="/test-dev/rollback"

function shell_log()
{
    log_info=$1
    echo -e "$(date +"%F %T") ${shell_name} ${log_info}" | tee -a ${log_file}
}

function backup()
{
    local backup_filename="${pro_name}_bak_${time}.tar.gz"
    #备份部署目录到备份目录
    if [ -d ${deploy_path}/${pro_name} ];then
        touch ${deploy_path}/${pro_name}
            mv ${deploy_path}/${pro_name} ${backup_path}/${pro_name}_bak_${time}
        [ $? -eq 0 ] && shell_log "move to ${backup_path} success." || { shell_log "move to ${backup_path} failed."; exit 1; }
    fi
    #解压新包到部署目录
    mkdir ${deploy_path}/${pro_name} && unzip /root/${zip_pack_name} -d ${deploy_path}/${pro_name}
}


function add_conf()
{
    #复制配置文件至配置文件夹，以WEB-INF为例子
    cp -f ${config_file}/* ${deploy_path}/${pro_name}/WEB-INF
    if [ $? -eq 0 ]; then
        shell_log "copy config_file success!"
    else
        shell_log "copy config_file failed!" && exit 1
    fi
}




function deploy()
{
    local choice_num=$1
    case ${choice_num} in
        #jenkins服务器上执行
        backup)
            backup
            ;;
        add_conf)
            add_conf
            ;;
    esac
}


deploy $*