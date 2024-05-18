#!/bin/bash

target="/var/www/html/mirrors/archlinux"
lock="/var/lock/syncrepo-archlinux.lck"
tmp="/tmp"

declare -A mirror_rsync_urls=(
    'rsync://mirror.aarnet.edu.au/archlinux/'
    'rsync://mirror.digitalpacific.com.au/archlinux/'
    'rsync://mirror.internode.on.net/archlinux/'
    'rsync://archlinux.c3sl.ufpr.br/archlinux/'
    'rsync://mirror.csclub.uwaterloo.ca/archlinux/'
    'rsync://mirrors.neusoft.edu.cn/archlinux/'
    'rsync://mirrors.tuna.tsinghua.edu.cn/archlinux/'
    'rsync://rsync.mirrors.ustc.edu.cn/archlinux/'
    'rsync://ftp.sh.cvut.cz/arch/'
    'rsync://mirrors.dotsrc.org/archlinux/'
    'rsync://mirror.one.com/archlinux/'
    'rsync://mirrors.xtom.ee/archlinux/'
    'rsync://arch.mirror.far.fi/archlinux/'
    'rsync://mirror.theo546.fr/archlinux/'
    'rsync://mirror.23m.com/archlinux/' 
    'rsync://mirror.f4st.host/archlinux/' 
    'rsync://ftp.gwdg.de/pub/linux/archlinux/' 
    'rsync://mirror.pseudoform.org/packages/' 
    'rsync://ftp.halifax.rwth-aachen.de/archlinux/' 
    'rsync://mirror.selfnet.de/archlinux/' 
    'rsync://mirrors.xtom.de/archlinux/' 
    'rsync://mirror.xtom.com.hk/repo/archlinux/' 
    'rsync://archlinux.mirror.liquidtelecom.com/archlinux/' 
    'rsync://mirrors.atviras.lt/archlinux/' 
    'rsync://mirror.ihost.md/archlinux/' 
    'rsync://ftp.nluug.nl/archlinux/' 
    'rsync://mirror.fsmg.org.nz/archlinux/' 
    'rsync://mirror.neuf.no/archlinux/' 
    'rsync://mirror.onet.pl/pub/mirrors/archlinux/' 
    'rsync://ftp.rnl.tecnico.ulisboa.pt/pub/archlinux/' 
    'rsync://mirrors.pidginhost.com/Arch/' 
    'rsync://mirror.surf/archlinux/' 
    'rsync://mirror.guillaumea.fr/archlinux/' 
    'rsync://ossmirror.mycloud.services/linux/archlinux/' 
    'rsync://archimonde.ts.si/archlinux/' 
    'rsync://mirror.funami.tech/arch/' 
    'rsync://ftp.acc.umu.se/mirror/archlinux/' 
    'rsync://pkg.adfinis.com/archlinux/' 
    'rsync://ftp.tku.edu.tw/archlinux/' 
    'rsync://archlinux.ip-connect.vn.ua/archlinux/'
    'rsync://arch.mirror.constant.com/archlinux/'
    'rsync://mirror.es.its.nyu.edu/archlinux/'
    'rsync://rsync.gtlib.gatech.edu/archlinux/'
    'rsync://mirror.hackingand.coffee/arch/'
    'rsync://mirrors.kernel.org/archlinux/'
    'rsync://mirrors.lug.mtu.edu/archlinux/'
    'rsync://iad.mirrors.misaka.one/archlinux/'
    'rsync://mirrors.ocf.berkeley.edu/archlinux/'
    'rsync://mirrors.rit.edu/archlinux/'
    'rsync://at.arch.mirror.kescher.at/mirror/arch/'
    'rsync://de.arch.mirror.kescher.at/mirror/arch/'
    'rsync://mirror.fra10.de.leaseweb.net/archlinux/'
    'rsync://mirror.dal10.us.leaseweb.net/archlinux/'
    'rsync://mirror.mia11.us.leaseweb.net/archlinux/'
    'rsync://mirror.sfo12.us.leaseweb.net/archlinux/'
    'rsync://mirror.wdc1.us.leaseweb.net/archlinux/'
)

if [ ! -d "${target}" ]; then
    mkdir -p "${target}"
fi

if [ ! -d "${tmp}" ]; then
    mkdir -p "${tmp}"
fi

exec 9>"${lock}"
flock -n 9 || exit

rsync_cmd() {
	local -a cmd=(rsync -rlH --safe-links --delete-after --timeout=600 --contimeout=60 --delay-updates --no-motd)
	
	if stty &>/dev/null; then
		cmd+=(-h -v --progress)
	else
		cmd+=(--quiet)
	fi

	"${cmd[@]}" "$@"
}
logger -t archlinux_mirror "Starting mirror synchronization"
for url in "${mirror_rsync_urls[@]}"; do
    logger -t archlinux_mirror "Syncing from $url"
    if rsync_cmd "${url}" "${target}"; then
        break
    else
        logger -t archlinux_mirror "rsync command failed for $url"
    fi
done
date -u +'%s' > "${target}/lastsync"
chown -R www-data:www-data /var/www/html/mirrors && chmod -R 750 /var/www/html/mirrors && chmod g+s /var/www/html/mirrors