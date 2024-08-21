#!/bin/bash

# 设置版本号
current_version=20240821008

function update_script() {
    # 指定URL
    update_url="https://raw.githubusercontent.com/breaddog100/rivalz/main/rivalz.sh"
    file_name=$(basename "$update_url")

    # 下载脚本文件
    tmp=$(date +%s)
    timeout 10s curl -s -o "$HOME/$tmp" -H "Cache-Control: no-cache" "$update_url?$tmp"
    exit_code=$?
    if [[ $exit_code -eq 124 ]]; then
        echo "命令超时"
        return 1
    elif [[ $exit_code -ne 0 ]]; then
        echo "下载失败"
        return 1
    fi

    # 检查是否有新版本可用
    latest_version=$(grep -oP 'current_version=([0-9]+)' $HOME/$tmp | sed -n 's/.*=//p')

    if [[ "$latest_version" -gt "$current_version" ]]; then
        clear
        echo ""
        # 提示需要更新脚本
        printf "\033[31m脚本有新版本可用！当前版本：%s，最新版本：%s\033[0m\n" "$current_version" "$latest_version"
        echo "正在更新..."
        sleep 3
        mv $HOME/$tmp $HOME/$file_name
        chmod +x $HOME/$file_name
        exec "$HOME/$file_name"
    else
        # 脚本是最新的
        rm -f $tmp
    fi

}

# 部署节点
function install_node() {

    sudo apt update && sudo apt upgrade -y
    sudo apt install -y pkg in git curl screen npm

    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

    # 安装 Node.js
    sudo apt install -y nodejs

    # 检查 Node.js 版本
    node -v

    sudo npm list -g rivalz-node-cli
    sudo npm i -g rivalz-node-cli

    rivalz update-version
    screen -mS rivalz rivalz run

	echo "节点部署完成..."
}

# 查看节点日志
function view_logs(){
	screen -r rivalz
}

function stop_node(){
    screen -X -S rivalz quit
}

# 卸载节点
function uninstall_node() {
    echo "确定要卸载节点吗？[Y/N]"
    read -r -p "请确认: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "开始卸载节点..."
            stop_node
            sudo rm -f $HOME/.rivalz $HOME/.db
            echo "节点卸载完成。"
            ;;
        *)
            echo "取消卸载操作。"
            ;;
    esac
}

# 主菜单
function main_menu() {
	while true; do
	    clear
	    echo "===================Rivalz 一键部署脚本==================="
		echo "当前版本：$current_version"
		echo "沟通电报群：https://t.me/lumaogogogo"
		echo "推荐配置：4C8G3T;磁盘越多越好，最大3T"
	    echo "请选择要执行的操作:"
	    echo "1. 部署节点 install_node"
	    echo "2. 节点日志 view_logs"
	    echo "3. 停止节点 stop_node"
	    echo "1618. 卸载节点 uninstall_node"
	    echo "0. 退出脚本 exit"
	    read -p "请输入选项: " OPTION
	
	    case $OPTION in
	    1) install_node ;;
	    2) view_logs ;;
	    3) stop_node ;;
	    1618) uninstall_node ;;

	    0) echo "退出脚本。"; exit 0 ;;
	    *) echo "无效选项，请重新输入。"; sleep 3 ;;
	    esac
	    echo "按任意键返回主菜单..."
        read -n 1
    done
}

# 检查更新
update_script

# 显示主菜单
main_menu