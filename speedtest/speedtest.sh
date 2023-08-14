speedtest_file="speedtest.txt" #https://gist.github.com/ofou/654efe67e173a6bff5c64ba26c09d058
speedtest_domains_file="speedtest_domains.txt"
speedtest_ips_file="speedtest_ips.txt"

speedtest_website_ips=(
151.101.0.230
151.101.1.91
151.101.128.230
151.101.129.91
151.101.130.219
151.101.192.230
151.101.193.91
151.101.194.219
151.101.2.219
151.101.64.230
151.101.65.91
151.101.66.219
52.18.84.232
52.216.213.141
52.216.243.83
52.217.110.211
52.217.70.139
52.217.75.155
52.217.80.243
54.231.160.85
54.231.199.229
54.74.197.71
96.45.82.209
96.45.82.93
96.45.83.144
96.45.83.41
)

extract_column_4(){
  echo > "$speedtest_domains_file"
  csvcut -c 4 "$speedtest_file" > "$speedtest_domains_file"
}

extract_ips(){

  echo > "$speedtest_ips_file"
  echo "------------- servers" >> "$speedtest_ips_file"

  while IFS= read -r line; do
      domain_or_ip=$(echo "$line" | cut -d ':' -f 1)
      port=$(echo "$line" | cut -d ':' -f 2)

      echo "$domain_or_ip"

      # is it IP address?
      if echo "$domain_or_ip" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
         echo "$domain_or_ip:$port" >> "$speedtest_ips_file"
      else
#          echo "$domain_or_ip:$port"
          ip_addresses=$(host "$domain_or_ip" | awk '/has address/ {print $NF}')
#          [ -n "$ip_addresses" ] && echo "$ip_addresses:$port"
           [ -n "$ip_addresses" ] && echo "$ip_addresses" | awk -v port="$port" '{print $0":"port}' >> "$speedtest_ips_file"
#          echo -------
      fi
  done < "$speedtest_domains_file"


  # remove duplicates
  sort -u "$speedtest_ips_file" -o tmp
  cat tmp > "$speedtest_ips_file"
  rm tmp



  # add website ips
  echo "------------- websites" >> "$speedtest_ips_file"
  for ip in "${speedtest_website_ips[@]}"; do
      echo "$ip:443">> "$speedtest_ips_file"
  done
}





#extract_column_4
extract_ips



