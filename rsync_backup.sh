#!/bin/bash
ubuntu='879be3ca-00fd-4b9c-8f42-c182ba794e94';
mate='5382ae7b-dde5-4133-a151-d10ec46559fe';
ls /media/rahul/$ubuntu
if [ $? -ne 0 ]; then
	ls /media/rahul/$mate
	if [ $? -ne 0 ]; then
		echo "Please mount the drive first!!"
		exit
	fi
fi
if(ls /media/rahul/* | grep $ubuntu ); then
	distro=$ubuntu;
else
	distro=$mate;
fi
current_DATE=$(date +"%Y%m%d%H%M%S")
cd ~/..;
[ ! -e ./rahul/.rsync_backup/Sync_dates.txt ] && echo "Bad thing" && touch ./rahul/.rsync_backup/Sync_dates.txt
last_DATE=$(tail -n 1 ./rahul/.rsync_backup/Sync_dates.txt)
[ ! -z "$last_DATE" ] && echo "Last sync Happened on :"$last_DATE
echo "Current date :"$current_DATE
if [ "$last_DATE" == "" ] ; then
	rsync -auv ./rahul/ /media/rahul/$distro/home/rahul/ --exclude-from './rahul/.rsync_backup/exclude-data.txt'
	rsync -auv ./rahul/ /media/rahul/$distro/home/rahul/ --include-from './rahul/.rsync_backup/include-data.txt' --exclude '*'
	rsync -auv /media/rahul/$distro/home/rahul/ ./rahul/ --exclude-from './rahul/.rsync_backup/exclude-data.txt'
        rsync -auv /media/rahul/$distro/home/rahul/ ./rahul/ --include-from './rahul/.rsync_backup/include-data.txt' --exclude '*'
	echo $current_DATE >> ./rahul/.rsync_backup/Sync_dates.txt
	echo "First Sync"
exit
fi
#checking if output1 files exists 
[ -e ./rahul/.rsync_backup/output1_source.txt ] && rm ./rahul/.rsync_backup/output1_source.txt
touch ./rahul/.rsync_backup/output1_source.txt
[ -e ./rahul/.rsync_backup/output1_destination.txt ] && rm ./rahul/.rsync_backup/output1_destination.txt
touch ./rahul/.rsync_backup/output1_destination.txt
	# creating output files of rsync
rsync -avn ./rahul/ /media/rahul/$distro/home/rahul/ --exclude-from './rahul/.rsync_backup/exclude-data.txt' > ./rahul/.rsync_backup/output_source.txt
rsync -avn ./rahul/ /media/rahul/$distro/home/rahul/ --include-from './rahul/.rsync_backup/include-data.txt' --exclude '*' >> ./rahul/.rsync_backup/output_source.txt
rsync -avn /media/rahul/$distro/home/rahul/ ./rahul/ --exclude-from './rahul/.rsync_backup/exclude-data.txt' > ./rahul/.rsync_backup/output_destination.txt
rsync -avn /media/rahul/$distro/home/rahul/ ./rahul/ --include-from './rahul/.rsync_backup/include-data.txt' --exclude '*' >> ./rahul/.rsync_backup/output_destination.txt
#rsync -avn ./rahul/ /media/rahul/$distro/home/rahul/ --exclude-from './rahul/.rsync_backup/exclude-data.txt' > ./rahul/.rsync_backup/output_source.txt
#rsync -avn /media/rahul/$distro/home/rahul/ ./rahul/ --include-from './rahul/.rsync_backup/include-data.txt' --exclude-from './rahul/.rsync_backup/exclude-data.txt' > ./rahul/.rsync_backup/output_destination.txt

# creating output1_source files
x=0
y=0
IFS=''
remove=false
insert=false
while IFS='' read -r line  || [[ -n "$line" ]]; do
        x=$(($x+1))
        if [[ "$line" == "sending incremental file list" ]]; then
		 insert=true
		y=$x
	fi
        [ -z "$line" ] && insert=false
        if [[ ( $x -gt 1 ) ]] && [[ $insert == true ]] && [[ $x -ne $y ]]
        then
                echo ${line} >> "./rahul/.rsync_backup/output1_source.txt"
        fi
done < "./rahul/.rsync_backup/output_source.txt"
#awk '{gsub(/ /,"\\ ")}8' ./rahul/.rsync_backup/output1_source.txt > ./rahul/.rsync_backup/output2_source.txt
keep=false
continue_for_all=false
while IFS='' read -r line || [[ -n "$line" ]]; do
	line=$line
	echo $keep
	if [[ $keep == true ]] ; then
		if  [[ "$line" == "$prev_line"* ]] && [[ ! -z "$prev_line" ]]
		then
			continue

		else
			keep=false
		fi
	fi
        stamp=$(stat -c %z "/home/rahul/$line" | cut -c 1-19)
        stamp=${stamp// }
        stamp=${stamp//:}
        stamp=${stamp//-}
	if [[ $last_DATE -gt $stamp ]]; then
	if [ ! -e "/media/rahul/$distro/home/rahul/$line" ]
	then
		prev_line=$line
		if [[ $continue_for_all == true ]]; then
			keep=true
			rm -r "/home/rahul/$line"
			echo "/home/rahul/$line removed"
			continue
		fi
		echo "/home/rahul/$line will be removed.."
		( subshell_temp=0;
		select yn in Continue Stop Continue_for_all Stop_all
		 do
			case $yn in 
				"Continue" ) rm -r "/home/rahul/$line" ; subshell_temp=1;break;;
				"Stop" ) subshell_temp=2;break;;
                                "Continue_for_all" ) subshell_temp=3;rm -r "/home/rahul/$line" ;break;;
				"Stop_all" ) subshell_temp=4;exit;;
			esac
		done
		echo $subshell_temp >> "./rahul/.rsync_backup/subshell.txt" )</dev/tty
		subshell_temp=$(tail -n 1 ./rahul/.rsync_backup/subshell.txt)
		echo valueis$subshell_temp
		if [[ $subshell_temp == 1 ]]; then
			keep=true;
		elif [[ $subshell_temp == 3 ]]; then
			keep=true;
			continue_for_all=true;
		elif [[ $subshell_temp == 4 ]]; then
			break;
		fi
	fi
	fi
echo "One$keep"
done < "./rahul/.rsync_backup/output1_source.txt"
# creating output1_destination files
x=0
remove=false
insert=false
IFS=''
while IFS='' read -r line  || [[ -n "$line" ]]; do
        x=$(($x+1))
        if [[ "$line" == "sending incremental file list" ]]; then
		 insert=true
		y=$x
	fi
        [ -z "$line" ] && insert=false
        if [[ ( $x -gt 1 ) ]] && [[ $insert == true ]] && [[ $x -ne $y ]]
        then
                echo ${line} >> "./rahul/.rsync_backup/output1_destination.txt"
        fi
done < "./rahul/.rsync_backup/output_destination.txt"
#awk '{gsub(/ /,"\\ ")}8' ./rahul/.rsync_backup/output1_destination.txt > ./rahul/.rsync_backup/output2_destination.txt
keep=false
continue_for_all=false
while IFS='' read -r line || [[ -n "$line" ]]; do
	line=$line
	if [[ $keep == true ]] ; then
		if  [[ "$line" == "$prev_line"* ]] && [[ ! -z "$prev_line" ]]
		then
			continue

		else
			keep=false
		fi
	fi
        stamp=$(stat -c %z "/media/rahul/$distro/home/rahul/$line" | cut -c 1-19)
        stamp=${stamp// }
        stamp=${stamp//:}
        stamp=${stamp//-}
	if [[ $last_DATE -gt $stamp ]]; then
	if [ ! -e /home/rahul/$line ]
	then
		prev_line=$line
		if [[ $continue_for_all == true ]]; then
			keep=true
			rm -r "/media/rahul/$distro/home/rahul/$line"
			echo "/media/rahul/$distro/home/rahul/$line removed"
			continue
		fi
		echo "/media/rahul/$distro/home/rahul/$line will be removed.."
		(select yn in Continue Stop Continue_for_all Stop_all
		 do
			case $yn in 
				"Continue" ) rm -r "/media/rahul/$distro/home/rahul/$line";subshell_temp=1;break;;
				"Stop" ) subshell_temp=2;break;;
                                "Continue_for_all" ) rm -r "/media/rahul/$distro/home/rahul/$line"; subshell_temp=3;break;;
				"Stop_all" ) subshell_temp=4;break;;
			esac
		done
		echo $subshell_temp >> "./rahul/.rsync_backup/subshell.txt")</dev/tty
		subshell_temp=$(tail -n 1 ./rahul/.rsync_backup/subshell.txt)
		if [[ $subshell_temp == 1 ]]; then
			keep=true;
		elif [[ $subshell_temp == 3 ]]; then
			keep=true;
			continue_for_all=true;
		elif [[ $subshell_temp == 4 ]]; then
			break;
		fi
	fi
	fi
done < "./rahul/.rsync_backup/output1_destination.txt"
 # Final Syncing
sleep 2
current_DATE=$(date +"%Y%m%d%H%M%S")
echo $current_DATE >> ./rahul/.rsync_backup/Sync_dates.txt
#rsync -auvn ./rahul/ /media/rahul/$distro/home/rahul/ --include-from './rahul/.rsync_backup/include-data.txt' --exclude-from './rahul/.rsync_backup/exclude-data.txt'
#rsync -auvn  /media/rahul/$distro/home/rahul/ ./rahul/ --include-from './rahul/.rsync_backup/include-data.txt' --exclude-from './rahul/.rsync_backup/exclude-data.txt'
rsync -auv ./rahul/ /media/rahul/$distro/home/rahul/ --exclude-from './rahul/.rsync_backup/exclude-data.txt'
rsync -auv ./rahul/ /media/rahul/$distro/home/rahul/ --include-from './rahul/.rsync_backup/include-data.txt' --exclude '*'
rsync -auv /media/rahul/$distro/home/rahul/ ./rahul/ --exclude-from './rahul/.rsync_backup/exclude-data.txt'
rsync -auv /media/rahul/$distro/home/rahul/ ./rahul/ --include-from './rahul/.rsync_backup/include-data.txt' --exclude '*'

