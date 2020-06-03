#!/bin/bash

cat << "EOF"

██████╗ ███████╗██╗  ██╗███████╗████████╗███████╗██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██╔══██╗██╔════╝██║ ██╔╝██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
██║  ██║█████╗  █████╔╝ ███████╗   ██║   █████╗  ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██║  ██║██╔══╝  ██╔═██╗ ╚════██║   ██║   ██╔══╝  ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
██████╔╝███████╗██║  ██╗███████║   ██║   ███████╗██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
EOF

printf "\n"
echo "$(tput setaf 2)Running Automation to gather data on" $1

echo $1 | assetfinder -subs-only | grep -E "$1$" | anew | httprobe --prefer-https > $1.hosts.txt | /root/tools/./findomain-linux -t $1 | anew | httprobe --prefer-https > $1.host$
cat $1.hosts.txt | /root/tools/./aquatone -out /var/www/html/$1/$1-aqua-out
nuclei -l $1.hosts.txt -t /root/tools/nuclei-templates/*/*.yaml -o /var/www/html/$1/nuclei-$1.txt
for url in `cat $1.hosts.txt`; do gau $url | grep "\.js" | anew /var/www/html/$1/js-$1.txt; done
for end in `cat /var/www/html/$1/js-$1.txt`; do python3 /root/tools/LinkFinder/linkfinder.py -i $end -o cli | anew /var/www/html/$1/endpoints-$1.txt; done
subjack -w $1.hosts.txt -t 100 -timeout 30 -o /var/www/html/$1/subjack-$1.txt -ssl -c /root/tools/subjack/fingerprints.json
naabu -hL $1.hosts.txt -o /var/www/html/$1/ports-$1.txt
mkdir /var/www/html/$1/$1-Params
cat $1.hosts.txt | waybackurls | sort -u >> waybackdata | gf ssrf | tee -a /var/www/html/$1/$1-Params/SSRF-$1.txt
cat $1.hosts.txt | waybackurls | sort -u >> waybackdata | gf ssti | tee -a /var/www/html/$1/$1-Params/SSTI-$1.txt
cat $1.hosts.txt | waybackurls | sort -u >> waybackdata | gf sqli | tee -a /var/www/html/$1/$1-Params/SQL-$1.txt
cat $1.hosts.txt | waybackurls | sort -u >> waybackdata | gf lfi | tee -a /var/www/html/$1/$1-Params/LFI-$1.txt
cat $1.hosts.txt | waybackurls | sort -u >> waybackdata | gf rce | tee -a /var/www/html/$1/$1-Params/RCE-$1.txt
cat $1.hosts.txt | waybackurls | sort -u >> waybackdata | gf redirect | tee -a /var/www/html/$1/$1-Params/REDIRECT-$1.txt
python3 /root/tools/dirsearch/dirsearch.py --url-list=$1.hosts.txt -e php,html,zip,js,jar,jsp -x 301,401,302,400,403,402,500,529,429,405,407,503 --threads=50 --simple-report=/var/www/html/$1/dirsearch-$1.txt
