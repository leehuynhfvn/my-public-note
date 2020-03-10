#!/bin/bash
file=$1
for i in `cat $file`; do
	time=$(wget --user-agent="Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.136 YaBrowser/20.2.2.177 Yowser/2.5 Yptp/1.56 Safari/537.36" -t 2 -T 5 -p $i 2>&1 | tail -n2 | head -n1| awk '{print $5}')
	rm -rf $i
	echo "$i $time" >> kq.txt
done
	
