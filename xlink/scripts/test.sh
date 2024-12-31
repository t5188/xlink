clear
iptables -t mangle -L BLOCK_LOOPBACK4 -n -v
echo ""
echo ""
ip6tables -t mangle -L BLOCK_LOOPBACK6 -n -v
echo ""
echo ""

