#!/system/bin/sh
[ ! "$MODDIR" ] && MODDIR=${0%/*}
while [[ "$(getprop sys.boot_completed)" -ne 1 ]] && [[ ! -d "/sdcard" ]];do sleep 1; done
while [[ `getprop sys.boot_completed` -ne 1 ]];do sleep 1; done
sdcard_rw() {
until [[ $(getprop sys.boot_completed) -eq 1 || $(getprop dev.bootcomplete) -eq 1 ]]; do sleep 1; done
}
sdcard_rw
if [[ -d ${MODDIR}/scripts ]]; then
  for i in $(ls ${MODDIR}/scripts/*); do
    if [ -f "${i}" ]; then
    chmod 0777 "${i}"
    su -c nohup "${i}" >/dev/null 2>&1 &
	fi
  done
fi

