#! /bin/bash
# first arg: cfg file for check_logfiles
# second arg: max days logfile can be old (in days)
# Author: Clemens Feuerstein, c.feuerstein@scc.co.at
# Version: 0.3

function age() {
   local filename=$1
   local changed=`stat -c %Y "$filename"`
   local now=`date +%s`
   local elapsed

   let elapsed=now-changed
   echo $elapsed
}

exec 0<$1
while read line
do
  string=$line
  pattern="`echo $line | cut -d= -f1`"
  
  if [[ $pattern = "logfile " ]]; then
      file="`echo $line | cut -d\' -f2`"
  fi
done
if [ -e $file ]; then
  maxAge=$(($2*60*60*24))
  currAge=$(age "$file")
else
  echo "CRITICAL: logfile is not available"
  exit 2
fi

file_date=`stat -c %y "$file"`
file_date=`echo $file_date | cut -c3-16`

echo -n File from: $file_date "| " 

if (( currAge > maxAge )); then
  echo "CRITICAL: the date of the logfile is too old"
  exit 2
fi

/usr/lib/nagios/plugins/check_logfiles --config $1

exit $?

# workaround for while loop with piped input
# when it reads via pipe, variables forget their value

# write filename to an tmp file
#tail -n 20 $FILENAME > /tmp/tmp_check_transferred_size
# set stdin to the file
#exec 0</tmp/tmp_check_transferred_size
#while read line
#do
#  string=$line
#  pattern="`echo "$string" | cut -d: -f1`"
#  if [[ $pattern = "Total transferred file size" ]]; then
#    output="`echo "$string" | cut -d: -f2 | cut -d' ' -f2`"
#  fi  
#done


