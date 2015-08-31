# squid_notes
There include something that I think is very helpful to learn Squid, e.g. the link of blog and configuration.

## 1. Official Website
[www.squid-cache.org](http://www.squid-cache.org/)

## 2. Squid中文权威指南
[Squid中文权威指南](http://zyan.cc/book/squid/)

## 3. Squid analyzer
1. Add the below info to apache conf ***apache2/sites-enabled/000-default***:  
    ```apache
    Alias /squidreport /var/www/squidanalyzer
    <Directory /var/www/squidanalyzer>
        #Options -Indexes FollowSymLinks MultiViews
        Options Indexes FollowSymLinks MultiViews
        AllowOverride None
        Order deny,allow
        #Deny from all
        Allow from all
    </Directory>
    ```

2. To deploy squid analyzer just follow the steps on below link.

    [squidanalyzer](http://squidanalyzer.darold.net/install.html)
    
3. Configure

    **set 'CostPrice' value to 0**;
    **change the TransfertUnit from Bytes to MB in '/etc/squidanalyzer/squidanalyzer.conf'**;
    
4. Start analyed. we run this script in crontab:  
    ```bash
    0 2 * * * /usr/local/bin/squid-analyzer > /dev/null 2>&1
    ```
    
    if you want to get more info, please use "**squid-analyzer -h**"

## 4. Configurations in /etc/squid3/squid.conf

 cache_peer is the main configurations item for defining the peers as below example. 

 1. Pointing to local server  
    ```bash
    cache_peer 192.168.1.103  parent 80 0 no-query originserver name=server_2
    acl our_sites2 dstdomain sw-cache.yourdomain.net sw-cache.global.yourdomain.net
    cache_peer_access server_2 allow our_sites2
    ```
    
    **cache_peer**: - defines your neighbor caches and tells Squid how to communicate with them.  
    *10.129.0.132 -->hostname.*  
    *parent       --> type of cache parent/sibling.*   
    *80           --> proxy-port, neighbor's HTTP port number.*  
    *no-query     --> no-query to NOT send ICP queries to this neighbor.*  
    *name         --> name can be used to differentiate the peers.*  
    
    **cache_peer_access** --> The cache_peer_access rules determine which requests Squid will forward to a particular neighbor.
    *server_2 --> cache host*  
    *our_sites --> ACL name*  

 2. For redirection script  
 ```apache
 url_rewrite_program /usr/bin/perl /home/tool/copy_folder/squid-redirect.pl
 ```

 4. Path for Squid cache on squid server: (cache_dir type path MBytes L1 L2)  
 ```bash
 cache_dir ufs /srv/cache1 2000000 256 256
 cache_dir ufs /srv/cache2 2000000 256 256
 ```  
 
 **Mbytes** is the amount of disk space (MB) to use under this directory.  The default is 100 MB.  Change this to suit your configuration. Do NOT put the size of your disk drive here. Instead, if you want Squid to use the entire disk drive, subtract 20% and use that value.  
 **L1** is the number of first-level subdirectories which will be created under the 'Directory'.  The default is 16.  
 **L2** is the number of second-level subdirectories which will be created under each first-level directory.  The default is 256.

 4. Purge squid cache (in procent)  
 ```
 cache_swap_low 60
 cache_swap_high 95
 ```
 
 Squid has been setup on 80 port number.
 Other configurations are normal we can easily find about that on internet.
 
 ## 5.Setup virtual host on local site server.

1. Create configuration file(swrepo.global.yourdomain.net) with virtual host settings at location .

2. Add below entry for handling 404 error code.  
    ```
     ErrorDocument 404 /cgi-bin/c2d-redirect
     AddHandler cgi-script .cgi
    ```  
3. Copy **redirect.pl** file from git(for redirection to Squid server) and place it at **/cgi-bin/** enabled folder.

4. Enable virtual host via  a2ensite swrepo.global.yourdomain.net

5. Reload changes. **sudo /etc/init.d/apache2 reload.**

6. Refer logs locations in this file.

7. You can refer swrepo.global.yourdomain.net on Local site DEV server's apache configurations.
