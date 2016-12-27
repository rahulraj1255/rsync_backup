# rsync_backup
Syncronizes home/ folder of two linux installations

rsync does a great job of syncing but still it lacks some features as delete simply because it doesn't have the information to decide whether the file was deleted or a new file was added in the other directory.

This script is to solve the problem of having information syncronous in multiple linux installations.


###USAGE:
  Create a new folder with name .rsync_backup in your home directory
Copy this script in it. Also create two text files "include-data.txt" and "exclude-data.txt" containing information as to which files and folders should be excluded from sync and if some specific files are to be synced which are excluded in exclude-data.txt.

Suppose if your home contains fod1/fode{1..2}/file{1..3} and you want to exclude fode1/ but include fod1/fode1/file1 your text files should be like


```
"include-data.txt"
/fod1/
/fod1/fode1/
/fod1/fode1/file1

"exclude-data.txt"
fod1/fode1/
```

Don't forget to change the mount point variables at the beginning of the script
