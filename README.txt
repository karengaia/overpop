# Overpopulation.org Website

Development Setup

Follow these instructions:

1. Install prerequisites: Apache, Perl 5, PHP 5.3, MySQL 5, Perl DBD::mysql
2. Clone this Git project.
3. Configure Apache:
  1. Create VirtualHost for 'overpop'
  2. Point DocumentRoot to ```./subdomains/www``` (full path to ```www```)
  3. ```ScriptAlias /cgi-bin/ ./subdomains/www/cgi-bin``` (full path to ```cgi-bin```)
4. Add ```127.0.0.1 overpop``` to /etc/hosts
5. Make directory: ```mkdir -p ./subdomains/www/autosubmit/sections```
6. Grant write access to the web server for the following paths:
  ```chmod 777 ./subdomains/www/autosubmit/templates```
  ```chmod 777 ./subdomains/www/autosubmit/sections```
  ```chmod 777 ./subdomains/www/prepage/```
  ```chmod 777 ./subdomains/www```
  ```chmod 666 ./subdomains/www/counter/count.txt```
7. Create "overpop" database in MySQL. user=root, empty password.
8. Visit http://overpop/cgi-bin/article.pl?display%article_control
9. Click on the following links:
  ```Save newsMidColumn```
  ```Index view```
  ```Save index```
10. Visit the home page: http://overpop/
