#!/system/bin/sh
[ ! "$MODDIR" ] && MODDIR=${0%/*}
MODPATH="/data/adb/modules/key"
date="$( date "+%y年%m月%d日%H时%M分%S秒")"
[[ ! -e ${MODDIR}/ll/log ]] && mkdir -p ${MODDIR}/ll/log
function log() {
logfile=1000000
maxsize=1000000
if  [[ "$(stat -t ${MODDIR}/ll/log/哈希值.log | awk '{print $2}')" -eq "$maxsize" ]] || [[ "$(stat -t ${MODDIR}/ll/log/哈希值.log | awk '{print $2}')" -gt "$maxsize" ]]; then
rm -f "${MODDIR}/ll/log/哈希值.log"
fi
}
cd ${MODDIR}/ll/log
log
logcat > ${MODDIR}/ll/log/VBMeta_Digest.txt &
vbmeta_digest=""
attempts=("bootlog" "getprop" "logcat" "resetprop")
for attempt in "${attempts[@]}"; do
    case $attempt in
        "bootlog")
            vbmeta_digest=$(grep "VBMeta Digest:" ${MODDIR}/ll/log/bootlog.txt | sed -n 's/.*VBMeta Digest:[[:space:]]*$$.*$$/\1/p')
            ;;
        "getprop")
            vbmeta_digest=$(getprop ro.boot.vbmeta.digest)
            ;;
        "logcat")
            vbmeta_digest=$(grep "VBMeta Digest" ${MODDIR}/ll/log/VBMeta_Digest.txt | awk -F "VBMeta Digest: " '{print $2}')
            ;;
        "resetprop")
            vbmeta_digest=$(resetprop -n ro.boot.vbmeta.digest)
            ;;
    esac
    if [ -n "$vbmeta_digest" ]; then
        echo "$date*已找到哈希值：$vbmeta_digest*" >> 哈希值.log
        break
    fi
    sleep 1
done
pkill -f logcat
rm -f ${MODDIR}/ll/log/VBMeta_Digest.txt
if [ -n "$vbmeta_digest" ]; then
    echo "$date*成功设置新值哈希值*" >> 哈希值.log
else
    echo "$date*设置新值哈希值失败*" >> 哈希值.log
fi
