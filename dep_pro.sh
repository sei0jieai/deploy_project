#!/bin/bash
###############################
#decription:deploy the project
#author:kl
#version:1.0
###############################
#常用变量
source /etc/profile
shell_name="dep_pro.sh"
time=$(date '+%Y%m%d-%H%M%S')
log_file="/root/shell_deploy/logs/${shell_name}.log"
dep_pack_path="/root/"
dep_pro_name="apache-tomcat-8.5.43-devopstest.war"
pro_pid=`ps -ef|grep apache-tomcat-8.5.43-devopstest|grep -v 'grep'|awk -F " " '{print $2}'`
#工程目录-列表
#tomcat目录
pro_name="apache-tomcat-8.5.43-devopstest"
pro_path="/data/${pro_name}"
config_file_path="/test-dev/config_file/${pro_name}/"
#mkdir -p ${config_file_path}

#备份目录
backup_path="/data/backup/${pro_name}"

#部署目录(工程目录)
zip_pro_name="apache-tomcat-8.5.43-devopstest.war"
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
    
}

function unzip_package()
{
   #解压新包到部署目录
    mkdir ${deploy_path}/${pro_name} && mv -f /root/${zip_pro_name} ${deploy_path}/${pro_name}/ && unzip ${deploy_path}/${pro_name}/${zip_pro_name} -d ${deploy_path}/${pro_name} 
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

function stop_pro()
{
    pro_num=$(ps -ef | grep "${pro_name}/conf" | grep -v "grep" | wc -l)
    if [ "$pro_num" -eq "1" ];then
        local pro_pid=$(ps -ef | grep "${pro_name}/conf" | grep -v "grep" | awk -F " " '{print $2}')
        echo -e "jstat status:\n$(jstat -gcutil $pro_pid)" >> ${log_file}
        kill -9 ${pro_pid}
        [ $? -eq 0 ] && shell_log "kill ${pro_pid} process success." || { shell_log "kill ${pro_pid} process failed, exit!"; exit 1; }
    elif [ "$pro_num" -eq "0" ];then
        shell_log "warning: $pro_num ${pro_name} running!"
    else
        shell_log "warning: $pro_num ${pro_name} running! exit."
        exit 1
    fi
}

function start_pro()
{
    
    if [ $(ps -ef | grep "${pro_name}/conf" | grep -v "grep" | wc -l) -eq 0 ];then
        sh ${pro_path}/bin/startup.sh
        sleep 2
        local pro_pid=$(ps -ef | grep "${pro_name}/conf" | grep -v "grep" | awk -F " " '{print $2}')
        shell_log "start ${pro_name} PID:${pro_pid}"
    else
        shell_log "${pro_name} already started, do nothing."
    fi
    #tail -f ${pro_path}/logs/catalina.out
}

function rollback()
{
    #获取时间最近的一个备份包
    [ ! -d ${rollback_path} ] && mkdir -p ${rollback_path}
        local last_package=$(ll -t ${rollback_path} | grep "${pro_path}" | head -1 | awk -F " " '{print $NF}')
    [ ! -z ${last_package} ] && shell_log "the rolled back file is ${rollback_path}/${last_package}" || { shell_log "no rolled back file in ${rollback_path}, exit!"; exit 1; }
    
#####################################################################################
    
    if [ -d ${deploy_path}/${pro_name} ];then
        touch ${deploy_path}/${pro_name}}
        mv ${deploy_path}/${pro_name} ${rollback_path}/${pack_name}_roll_${time}
        [ $? -eq 0 ] && shell_log "move to ${rollback_path} success." || { shell_log "move to ${rollback_path} failed."; exit 1; }
    fi
    if [ -e ${pro_path}.zip ];then
        touch ${pro_path}.zip
        mv ${pro_path}.zip ${rollback_path}/${pack_name}.zip_roll_${now_time}
    elif [ -e ${pro_path}.tar.gz ];then
        touch ${pro_path}.tar.gz
        mv ${pro_path}.tar.gz ${rollback_path}/${pack_name}.tar.gz_roll_${now_time}
    elif [ -e ${pro_path}.war ];then
        touch ${pro_path}.war
        mv ${pro_path}.war ${rollback_path}/${pack_name}.tar.gz_roll_${now_time}
    fi

    cp -r ${mod_bak_dir}/${last_package} ${pro_path}
    [ $? -eq 0 ] && shell_log "copy ${last_package} to /data/xpand success." || shell_log "copy ${last_package} to /data/xpand failed."    
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
        stop_pro)
            stop_pro
            ;;
        start_pro)
            start_pro
            ;;
        rollback)
            rollback
            ;;
    esac
}


deploy $*