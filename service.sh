#!/bin/bash
ipset restore --exist < /root/.wepn/ipset-rules
sleep 1
iptables-restore < /root/.wepn/iptables-rules
