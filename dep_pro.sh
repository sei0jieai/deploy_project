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
dep_pack_name="web.war"
#工程目录-列表
#tomcat目录
pro_name="apache-tomcat-8.5.43-devopstest"
pro_path="/data/${pro_name}"
config_file="/test-dev/config_file/${pro_name}/*.conf"

#备份目录
backup_path="/data/backup/${pro_name}"

#部署目录(工程目录)
zip_pack_name="web.war"
deploy_path="/test-dev/$pro_name/ROOT"

#回滚目录（上一次备份目录）
rollback_path="/test-dev/rollback/$pro_name/ROOT"

function shell_log()
{
    log_info=$1
    echo -e "$(date +"%F %T") ${shell_name} ${log_info}" | tee -a ${log_file}
}

function backup()
{
    local backup_filename="${pro_name}_bak_${time}.tar.gz"
    if [ -f ${backup_filename} ]; then 
        touch ${backup_filename} 
    fi
    #备份回滚目录到备份目录
    tar czf ${backup_filename} ${rollback_path} && mv ${backup_filename} ${backup_path}/${pro_name}/  && rm -rf ${rollback_path}/* && shell_log "backup rollback path OK!"
    
    #备份部署目录到回滚目录
    
    mv ${deploy_path}/* ${rollback_path}/
    #解压新版本包到部署目录
    
    unzip -d ${deploy_path} /root/${zip_pack_name} && shell_log "unzip pack sucess" 
    #重启服务
}






function deploy()
{
    local choice_num=$1
    case ${choice} in
        #jenkins服务器上执行
        backup)
            backup
            ;;
    esac
}


deploy