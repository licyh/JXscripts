


iplist=(01 02 03 04 05 06 07 08 10)


#for removing /benchmark* /system
for ((i=${#iplist[@]}-1; i>=0; i--))
do
expect << EOF
proc do_exec_startnodes {} {
  set timeout -1
  spawn ssh vagrant@11.11.1.2${iplist[i]}
  expect {
    "yes/no" {send "yes\r"; exp_continue}
    "password:" {send "vagrant\r"}
  }
  expect ":~"
  if {"${iplist[i]}"=="10"} { 
    send "hadoop-daemon.sh start namenode\r" 
  } else { 
    send "hadoop-daemon.sh start datanode\r"
  }
  expect ":~"
  send "exit\r"
}

do_exec_startnodes
EOF
done

           
sleep 5s                                                                                                                                                                                                      
hdfs dfs -rm -r /benchmarks* /system                                                                                                                                                                                      
sleep 5s
hdfs dfsadmin -report
hdfs dfs -df -h
sleep 5s
hdfs dfs -df -h
sleep 5s
hdfs dfs -df -h


for ip in ${iplist[@]}
do
expect << EOF
proc do_scp {} {
  set timeout -1
  spawn scp /home/vagrant/hadoop/install/hadoop-2.6.0/etc/hadoop/hdfs-site.xml vagrant@11.11.1.2$ip:~/hadoop/install/hadoop-2.6.0/etc/hadoop/hdfs-site.xml
  expect {
    #"yes/no" {send "yes\r"; exp_continue}
    "password:" {send "vagrant\r"} 
  }
  expect eof
}

proc do_exec_stopnodes {} {
  set timeout -1
  spawn ssh vagrant@11.11.1.2$ip
  expect {
    "yes/no" {send "yes\r"; exp_continue}
    "password:" {send "vagrant\r"}
  }
  expect ":~"
  if {"$ip"=="10"} { 
    send "hadoop-daemon.sh stop namenode\r" 
  } else { 
    send "hadoop-daemon.sh stop datanode\r"
  }
  expect ":~"
  send "exit\r"
}

do_scp
do_exec_stopnodes
#11.11.1.2$ip vagrant
EOF
done


sleep 10s


for ((i=${#iplist[@]}-1; i>=0; i--))
do
expect << EOF
proc do_exec_startnodes {} {
  set timeout -1
  spawn ssh vagrant@11.11.1.2${iplist[i]}
  expect {
    "yes/no" {send "yes\r"; exp_continue}
    "password:" {send "vagrant\r"}
  }
  expect ":~"
  if {"${iplist[i]}"=="10"} { 
    send "hadoop-daemon.sh start namenode\r" 
  } else { 
    send "hadoop-daemon.sh start datanode\r"
  }
  expect ":~"
  send "exit\r"
}

do_exec_startnodes
EOF
done


sleep 5s
hdfs dfsadmin -report
hdfs dfs -df -h


for ((i=0; i<3; i++))
do
expect << EOF
proc do_exec_writedata {} {
  set timeout -1
  spawn ssh vagrant@11.11.1.2${iplist[i]}
  expect {
    "yes/no" {send "yes\r"; exp_continue}
    "password:" {send "vagrant\r"}
  }
  expect ":~"
  send "cd ~/hadoop/install/hadoop-2.6.0/share/hadoop/mapreduce\r"
  expect ":~"
  send "hadoop jar hadoop-mapreduce-client-jobclient-2.6.0-tests.jar TestDFSIO -write -nrFiles 100 -fileSize 300\r"
  expect ":~"
  send "hdfs dfs -mv /benchmarks /benchmarks$i\r"
  expect ":~"
  send "exit\r"
}

do_exec_writedata
EOF
sleep 3s
done


hdfs dfsadmin -report
hdfs dfs -df -h




