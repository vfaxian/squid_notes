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
    
4. Start analyed.
    we run this script in crontab:
    
    ```bash
    0 2 * * * /usr/local/bin/squid-analyzer > /dev/null 2>&1
    ```
    if you want to get more info, please use "**squid-analyzer -h**"
