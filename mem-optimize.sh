#!/bin/bash
# Optimize memory. Use dirty_ratio, dirty_background_ratio, drop_caches
# Created by Yevgeniy Goncharov, http://sys-adm.in

# ---------------------------------------------------------- VARIABLES #

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPTPATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
SCRIPTNAME=`basename "$0"`

# Colorize

Info() {
	printf "\033[1;32m$@\033[0m\n"
}

Warning() {
	printf "\033[1;35m$@\033[0m\n"
}


Error()
{
	printf "\033[1;31m$@\033[0m\n"
}

# ---------------------------------------------------------- BODYs #

isRoot() {
	if [ $(id -u) -ne 0 ]; then
		Error "You must be root user to continue"
		exit 1
	fi
	RID=$(id -u root 2>/dev/null)
	if [ $? -ne 0 ]; then
		Error "User root no found. You should create it to continue"
		exit 1
	fi
	if [ $RID -ne 0 ]; then
		Error "User root UID not equals 0. User root must have UID 0"
		exit 1
	fi
}

isRoot

showParams() {
	sysctl -a | grep dirty
}

# Show current params
Info "\nCurrent params:\n"
showParams

# Adjust dirty params
Warning "\nAdjust new dirty params to - dirty_ratio=10, dirty_background_ratio=5\n"
sysctl -w vm.dirty_ratio=10 && sysctl -w vm.dirty_background_ratio=5
echo -e "${reset}"

# Save params
Info "\nSave params..\n"
sysctl -p

# Sync and clear cache
Info "Sync cache...\n"
sync; echo 3 > /proc/sys/vm/drop_caches;

# Show new params
Info "New params:\n"
showParams

# Done
Info "\nDone!\n"

exit