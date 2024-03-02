#!/bin/bash

target="/var/www/html/mirrors/archlinux"
tmp="/tmp"
lock="/var/lock/syncrepo-archlinux.lck"
bwlimit=0

# Array of mirror URLs and their corresponding rsync URLs
declare -A mirror_rsync_urls=(
    ['https://mirror.aarnet.edu.au/pub/archlinux/lastupdate']='rsync://mirror.aarnet.edu.au/archlinux/'
    ['https://archlinux.mirror.digitalpacific.com.au/lastupdate']='rsync://mirror.digitalpacific.com.au/archlinux/'
    ['http://mirror.internode.on.net/pub/archlinux/lastupdate']='rsync://mirror.internode.on.net/archlinux/'
    ['http://archlinux.c3sl.ufpr.br/lastupdate']='rsync://archlinux.c3sl.ufpr.br/archlinux/'
    ['https://mirror.csclub.uwaterloo.ca/archlinux/lastupdate']='rsync://mirror.csclub.uwaterloo.ca/archlinux/'
    ['https://mirrors.neusoft.edu.cn/archlinux/lastupdate']='rsync://mirrors.neusoft.edu.cn/archlinux/'
    ['https://mirrors.tuna.tsinghua.edu.cn/archlinux/lastupdate']='rsync://mirrors.tuna.tsinghua.edu.cn/archlinux/'
    ['https://mirrors.ustc.edu.cn/archlinux/lastupdate']='rsync://rsync.mirrors.ustc.edu.cn/archlinux/'
    ['https://ftp.sh.cvut.cz/arch/lastupdate']='rsync://ftp.sh.cvut.cz/arch/'
    ['https://mirrors.dotsrc.org/archlinux/lastupdate']='rsync://mirrors.dotsrc.org/archlinux/'
    ['https://mirror.one.com/archlinux/lastupdate']='rsync://mirror.one.com/archlinux/'
    ['https://mirrors.xtom.ee/archlinux/lastupdate']='rsync://mirrors.xtom.ee/archlinux/'
    ['http://arch.mirror.far.fi/lastupdate']='rsync://arch.mirror.far.fi/archlinux/'
    ['https://mirror.theo546.fr/archlinux/lastupdate']='rsync://mirror.theo546.fr/archlinux/'
    ['https://mirror.23m.com/archlinux/lastupdate']='rsync://mirror.23m.com/archlinux/' 
    ['https://mirror.f4st.host/archlinux/lastupdate']='rsync://mirror.f4st.host/archlinux/' 
    ['http://ftp.gwdg.de/pub/linux/archlinux/lastupdate']='rsync://ftp.gwdg.de/pub/linux/archlinux/' 
    ['https://mirror.pseudoform.org/lastupdate']='rsync://mirror.pseudoform.org/packages/' 
    ['https://ftp.halifax.rwth-aachen.de/archlinux/lastupdate']='rsync://ftp.halifax.rwth-aachen.de/archlinux/' 
    ['https://mirror.selfnet.de/archlinux/lastupdate']='rsync://mirror.selfnet.de/archlinux/' 
    ['https://mirrors.xtom.de/archlinux/lastupdate']='rsync://mirrors.xtom.de/archlinux/' 
    ['https://mirror.xtom.com.hk/archlinux/lastupdate']='rsync://mirror.xtom.com.hk/repo/archlinux/' 
    ['https://archlinux.mirror.liquidtelecom.com/lastupdate']='rsync://archlinux.mirror.liquidtelecom.com/archlinux/' 
    ['https://mirrors.atviras.lt/archlinux/lastupdate']='rsync://mirrors.atviras.lt/archlinux/' 
    ['https://mirror.ihost.md/archlinux/lastupdate']='rsync://mirror.ihost.md/archlinux/' 
    ['http://ftp.nluug.nl/os/Linux/distr/archlinux/lastupdate']='rsync://ftp.nluug.nl/archlinux/' 
    ['https://mirror.fsmg.org.nz/archlinux/lastupdate']='rsync://mirror.fsmg.org.nz/archlinux/' 
    ['https://mirror.neuf.no/archlinux/lastupdate']='rsync://mirror.neuf.no/archlinux/' 
    ['http://mirror.onet.pl/pub/mirrors/archlinux/lastupdate']='rsync://mirror.onet.pl/pub/mirrors/archlinux/' 
    ['https://ftp.rnl.tecnico.ulisboa.pt/pub/archlinux/lastupdate']='rsync://ftp.rnl.tecnico.ulisboa.pt/pub/archlinux/' 
    ['https://mirrors.pidginhost.com/arch/lastupdate']='rsync://mirrors.pidginhost.com/Arch/' 
    ['https://mirror.surf/archlinux/lastupdate']='rsync://mirror.surf/archlinux/' 
    ['https://mirror.guillaumea.fr/archlinux/lastupdate']='rsync://mirror.guillaumea.fr/archlinux/' 
    ['http://ossmirror.mycloud.services/os/linux/archlinux/lastupdate']='rsync://ossmirror.mycloud.services/linux/archlinux/' 
    ['https://archimonde.ts.si/archlinux/lastupdate']='rsync://archimonde.ts.si/archlinux/' 
    ['https://mirror.funami.tech/arch/lastupdate']='rsync://mirror.funami.tech/arch/' 
    ['https://ftp.acc.umu.se/mirror/archlinux/lastupdate']='rsync://ftp.acc.umu.se/mirror/archlinux/' 
    ['https://pkg.adfinis.com/archlinux/lastupdate']='rsync://pkg.adfinis.com/archlinux/' 
    ['http://ftp.tku.edu.tw/Linux/ArchLinux/lastupdate']='rsync://ftp.tku.edu.tw/archlinux/' 
    ['https://archlinux.ip-connect.vn.ua/lastupdate']='rsync://archlinux.ip-connect.vn.ua/archlinux/'
    ['https://arch.mirror.constant.com/lastupdate']='rsync://arch.mirror.constant.com/archlinux/'
    ['http://mirror.es.its.nyu.edu/archlinux/lastupdate']='rsync://mirror.es.its.nyu.edu/archlinux/'
    ['http://www.gtlib.gatech.edu/pub/archlinux/lastupdate']='rsync://rsync.gtlib.gatech.edu/archlinux/'
    ['https://mirror.hackingand.coffee/arch/lastupdate']='rsync://mirror.hackingand.coffee/arch/'
    ['https://mirrors.kernel.org/archlinux/lastupdate']='rsync://mirrors.kernel.org/archlinux/'
    ['https://mirrors.lug.mtu.edu/archlinux/lastupdate']='rsync://mirrors.lug.mtu.edu/archlinux/'
    ['https://iad.mirrors.misaka.one/archlinux/lastupdate']='rsync://iad.mirrors.misaka.one/archlinux/'
    ['https://mirrors.ocf.berkeley.edu/archlinux/lastupdate']='rsync://mirrors.ocf.berkeley.edu/archlinux/'
    ['https://mirrors.rit.edu/archlinux/lastupdate']='rsync://mirrors.rit.edu/archlinux/'
    ['https://at.arch.mirror.kescher.at/lastupdate']='rsync://at.arch.mirror.kescher.at/mirror/arch/'
    ['https://de.arch.mirror.kescher.at/lastupdate']='rsync://de.arch.mirror.kescher.at/mirror/arch/'
    ['https://mirror.fra10.de.leaseweb.net/archlinux/lastupdate']='rsync://mirror.fra10.de.leaseweb.net/archlinux/'
    ['https://mirror.dal10.us.leaseweb.net/archlinux/lastupdate']='rsync://mirror.dal10.us.leaseweb.net/archlinux/'
    ['https://mirror.mia11.us.leaseweb.net/archlinux/lastupdate']='rsync://mirror.mia11.us.leaseweb.net/archlinux/'
    ['https://mirror.sfo12.us.leaseweb.net/archlinux/lastupdate']='rsync://mirror.sfo12.us.leaseweb.net/archlinux/'
    ['https://mirror.wdc1.us.leaseweb.net/archlinux/lastupdate']='rsync://mirror.wdc1.us.leaseweb.net/archlinux/'
)

lastupdate_url=''
latest_timestamp=0
source_url=''

for url in "${!mirror_rsync_urls[@]}"; do
    timestamp=$(curl -s --connect-timeout 10 -I "$url" | awk '/Last-Modified/{print $NF}' | date +"%s" -f -)
    
    if ((timestamp > latest_timestamp)); then
        latest_timestamp=$timestamp
        lastupdate_url=$url
        source_url=${mirror_rsync_urls[$url]}
    fi
done

if [ -z "$lastupdate_url" ]; then
    exit 1
fi

if [ -z "$source_url" ]; then
    exit 1
fi

[ ! -d "${target}" ] && mkdir -p "${target}"
[ ! -d "${tmp}" ] && mkdir -p "${tmp}"

exec 9>"${lock}"
flock -n 9 || exit

rsync_cmd() {
	local -a cmd=(rsync -rtlH --safe-links --delete-after ${VERBOSE} "--timeout=600" "--contimeout=60" -p --delay-updates --no-motd "--temp-dir=${tmp}")
	
	if stty &>/dev/null; then
		cmd+=(-h -v --progress)
	else
		cmd+=(--quiet)
	fi

	if ((bwlimit>0)); then
		cmd+=("--bwlimit=$bwlimit")
	fi

	"${cmd[@]}" "$@"
}
logger -t archlinux_mirror "Selected mirror server: $source_url"
rsync_cmd "${source_url}" "${target}"
date -u +'%s' > "${target}/lastsync"
chown -R www-data:www-data /var/www/html/mirrors && chmod -R 750 /var/www/html/mirrors && chmod g+s /var/www/html/mirrors
