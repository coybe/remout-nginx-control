#!/bin/bash

/usr/bin/expect << EOF
	#最多不超过10分钟，命令执行持续的时间要比这个时间段，否则会提前退出
	set timeout 600  
	spawn ssh root@172.16.0.17
	expect { 
	"yes/no" { send "yes\n";exp_continue }
	"password" { send "hn_TWZN@web0804=+\r" }
	}
	expect "*]#" {send "/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf\n"}
	expect "*]#" {send "exit\n"}
	expect eof
EOF

echo "------------------------已启动web服务器上的nginx服务"