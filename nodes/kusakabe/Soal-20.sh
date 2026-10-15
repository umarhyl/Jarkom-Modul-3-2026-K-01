#!/bin/sh
apk update > /dev/null 2>&1
apk add apache2-utils > /dev/null 2>&1

ab -n 600 -c 30 -H "Host: jujutsu.k01.com" http://10.64.1.4/
sleep 2
ab -n 600 -c 30 -H "Host: jujutsu.k01.com" http://10.64.1.4/api
EOF

chmod +x benchmark_soal20.sh
./benchmark_soal20.sh