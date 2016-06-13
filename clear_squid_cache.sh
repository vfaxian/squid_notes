#!/bin/sh
# this is used for clean up the squid cache files.
# you can running "sudo ./clear_squid_cache.sh cda-front.net(the domain of the cached files)"

squidcache_path="/srv/cache"
squidclient_path="/usr/bin/squidclient"
grep -a -r $1 $squidcache_path/* | strings | grep "http:" | awk -F'http:' '{print "http:"$2;}' > cache_list.txt
for url in `cat cache_list.txt`; do
$squidclient_path -m PURGE -p 80 $url
done
