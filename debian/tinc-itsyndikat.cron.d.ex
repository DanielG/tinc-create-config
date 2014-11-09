#
# Regular cron jobs for the tinc-itsyndikat package
#
0 4	* * *	root	[ -x /usr/bin/tinc-itsyndikat_maintenance ] && /usr/bin/tinc-itsyndikat_maintenance
