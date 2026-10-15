
curl -I -H "Host: jujutsu.k01.com" http://10.64.1.4/
# satu-satu
curl -I -H "Host: jujutsu.k01.com" http://10.64.1.4/

for i in {1..20}; do curl -s -o /dev/null -w "Request $i - HTTP Status: %{http_code}\n" -H "Host: jujutsu.k01.com" http://10.64.1.4/api; done