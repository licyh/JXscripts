

destip=11.11.1.208

rm ~/write.log

expect -c "
#begin
set timeout -1
spawn ssh vagrant@$destip
expect {
  \"yes/no\" {send \"yes\r\"; exp_continue}
  \"password:\" {send \"vagrant\r\"}
}

#body
expect \":~\"
send \"rm ~/read.log\r\"

#end
expect \":~\"
send \"exit\r\"
"

for ((i=0; i<6; i++))
do
:<<note
  if ((i==7)); then
echo This is begin ------ ljx
expect << EOF
proc do_exec_startbalance {} {
  set timeout -1
  spawn ssh vagrant@11.11.1.209
  expect {
    "yes/no" {send "yes\r"; exp_continue}
    "password:" {send "vagrant\r"}
  }
  expect ":~"
  send "hdfs balancer -threshold 5.0 > balance.log &\r"
  expect ":~"
  send "exit\r"
}

do_exec_startbalance
EOF
echo This is end ------- ljx
  fi 
note
  cd ~/hadoop/install/hadoop-2.6.0/share/hadoop/mapreduce
  hadoop jar hadoop-mapreduce-client-jobclient-2.6.0-tests.jar TestDFSIO -write -nrFiles 20 -fileSize 100 >> ~/write.log 2>&1
  sleep 1s
  expect ~/r_doing.exp $destip
  sleep 1s
done

sleep 5s

grep "Test exec time sec" ~/write.log > ~/write.result

expect << EOF
#begin
set timeout -1
set destip [lindex $argv 0]

spawn ssh vagrant@$destip

expect {
  "yes/no" {send "yes\r"; exp_continue}
  "password:" {send "vagrant\r"}
}

#body
expect ":~"
send "grep 'Test exec time sec' ~/read.log > ~/read.result\r"

#end
expect ":~"
send "exit\r"
EOF


