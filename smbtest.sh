#!/bin/bash
#
#    __     ___________
#   (_ |\/||_)||_(_  |
#   __)|  ||_)||___) |
#
#
#       Use:    Only need to see permissions from SMB drives, but do not need the full functionality of smbmap? Have I got a bash script for you!
#                       Simply plug in the IP you want into the script, run and read the text file created!
#
#	Example		: ./smbtest.sh x.x.x.x
#
#	Filename	: smbtest.sh
#	Version		: v1.0.0
#
#	Requirements	: smbclient
#                         https://www.samba.org/samba/download/
#
#	Updated		: 26 Jan 2021
#	Created		: 26 Jan 2021
#
#	 Credit		: The Project was created due to not needing ShawnDEvans full smbmap.
#  			  But just a quick check of Read/Write using bash.
#  			  https://github.com/ShawnDEvans/smbmap
#
#	Author		: C0WB0Y-Ducky
#	Email		: cwbyducky@gmail.com
#	Website		: https://github.com/C0WB0Y-Ducky/SMBTEST
#
#
# 	    Copyright (C) 2021 Robert L Garey
#   This program is free software: you can redistribute it and/or modify it under the terms of the
#   GNU General Public License as published by the Free Software Foundation, either version 3 of
#   the License, or (at your option) any later version.
#   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#   See the GNU General Public License for more details.
#   You should have received a copy of the GNU General Public License along with this program.
#   It is located in the 'LICENSE' file in the root folder.
#   If not, see <https://www.gnu.org/licenses/>.


###############
#  Variables
###############
#takes the IP you submit as a variable
IP=$1
status=""

#checks for an IP as an argument
if [[ $# -eq 0 ]] ; then
    echo "Usage: ./smbtest.sh x.x.x.x"
    exit 0
fi

#runs smbclient and creates a shares.txt file of the Shares on the IP
smbclient -L //$IP -N | awk '{print $1}' > shares.txt

#clean up command to remove the newline character at the begining of the text file
tail -n +2 shares.txt > shares.tmp && mv shares.tmp shares.txt

#tmp file to test write access
touch tmp.tmp

#while loop to read the lines in the text file, this will iterate through and determine if you are able to read and write to the share
while IFS= read -r line
do
        status=""
        if [ $line != "Sharename" ] && [ $line != "---------" ] &&  [ $line != "SMB1" ]
        #if false
        then
                if smbclient //$IP/$line -N -c "dir" > /dev/null 2>&1
                then
                        status="Read"
                        if smbclient //$IP/$line -N -c "put tmp.tmp ; rm tmp.tmp" > /dev/null 2>&1
                        then
                                status="Read/Write"
                                echo $line - $status
                                smbclient //$IP/$line -N -c "dir"
                        else
                                echo $line - $status
                                smbclient //$IP/$line -N -c "dir"
                        fi
                else
                        status="None"
                        echo $line - $status
                fi
        else
                echo $line
        fi
done < shares.txt
