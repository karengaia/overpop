To view your crontab file:
crontab -l

To edit your crontab file:
crontab -e
(By default this uses vi as an editor, to use a different editor (emacs):
"setenv EDITOR emacs" )

To remove your crontab file:
crontab -r

Here's how you would run the program log.pl located in /usr/home/eric at
different times:

3:15am every weekday morning:
15 3 * * 1-5 /usr/home/eric/log.pl

The first and fifteenth of each month:
0 0 1,15 * * /usr/home/eric/log.pl

Every Monday
0 0 * * 1 /usr/home/eric/log.pl

The first and fifteenth of each month and every monday:
0 0 1,15 * 1 /usr/home/eric/log.pl

Check number of rows on ml_users and ml_subscriptions


