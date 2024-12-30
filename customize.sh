#!/system/bin/sh
##########################
# xray_lite Customization#
##########################
SKIPUNZIP=1
ASH_STANDALONE=1
unzip_path="/data/adb"

# Define the paths of source folder and the destination folder
source_folder="/data/adb/xray_lite"
destination_folder="/data/adb/xray_lite$(date +%Y%m%d_%H%M%S)"

# Check if the source folder exists
if [ -d "$source_folder" ]; then
    # If the source folder exists, execute the move operation
    mv "$source_folder" "$destination_folder"
    ui_print "- 正在备份已有文件"
    # Delete old folders and update them
    rm -rf "$source_folder"
else
    # If the source folder does not exist, output initial installation information 
    ui_print "- 正在初始安装"
fi

ui_print "- 正在释放文件"
unzip -o "$ZIPFILE" 'xray_lite/*' -d $unzip_path >&2
unzip -j -o "$ZIPFILE" 'xray_lite_service.sh' -d /data/adb/service.d >&2
unzip -j -o "$ZIPFILE" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "$ZIPFILE" "module.prop" -d $MODPATH >&2
ui_print "- 正在设置权限"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive /data/adb/xray_lite/ 0 3005 0755 0644
set_perm_recursive /data/adb/xray_lite/scripts/ 0 3005 0755 0700
set_perm /data/adb/service.d/xray_lite_service.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755
set_perm /data/adb/xray_lite/scripts/ 0 0 0755
ui_print "- 完成权限设置"
ui_print "- 还原配置文件"

# 找到文件夹对应的最大的数字
largest_folder=$(find /data/adb -maxdepth 1 -type d -name 'xray_lite[0-9]*' | sed 's/.*xray_lite//' | sed 's/_//g' | sort -nr | head -n 1)

# 使用这个最大的数字，重新匹配回原始文件夹名
if [ -n "$largest_folder" ]; then
  for folder in /data/adb/xray_lite*; do
    clean_name=$(echo "$folder" | sed 's/.*xray_lite//' | sed 's/_//g')
    if [ "$clean_name" = "$largest_folder" ]; then
      ui_print "- Found folder: $folder"
      
      # 覆盖 /data/adb/xray_lite/confs 目录中的内容
      if [ -d "$folder/confs" ]; then
        cp -rf "$folder/confs/"* /data/adb/xray_lite/confs/
        cp -f "$folder/scripts/settings.ini" /data/adb/xray_lite/scripts/
        ui_print "- Copied contents of $folder/confs to /data/adb/xray_lite/confs/"
        ui_print "- 成功还原配置文件"
        ui_print "- 成功还原settings.ini"
      fi
      break
    fi
  done
else
  ui_print "- 首次安装，无备份配置可还原"
fi

ui_print "- enjoy!"
# 2024 1116
