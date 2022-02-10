## Setup
docker-compose up -d

Connectivity tested on Android + iOS devices. It seems Android devices do not require L2TP server to have port 1701/tcp open.

The above example will accept connections from both L2TP/IPSec and OpenVPN clients at the same time.

Mix and match published ports:

-p 500:500/udp -p 4500:4500/udp -p 1701:1701/tcp for L2TP/IPSec

-p 1194:1194/udp for OpenVPN.

-p 443:443/tcp for OpenVPN over HTTPS.

-p 5555:5555/tcp for SoftEther VPN (recommended by vendor).

-p 992:992/tcp is also available as alternative.

Any protocol supported by SoftEther VPN server is accepted at any open/published port (if VPN client allows non-default ports).

add to /etc/sysconfig/iptables

-A INPUT -p tcp -m tcp -m state --state NEW -m multiport --dports 1701,5555 -m comment --comment VPN -j ACCEPT

-A INPUT -p udp -m udp -m state --state NEW -m multiport --dports 500,1194,1701,4500 -m comment --comment VPN -j ACCEPT

## Credentials
All optional:

-e PSK: Pre-Shared Key (PSK), if not set: "notasecret" (without quotes) by default.

-e USERS: Multiple usernames and passwords may be set with the following pattern: username:password;user2:pass2;user3:pass3. Username and passwords are separated by :. Each pair of username:password should be separated by ;. If not set a single user account with a random username ("user[nnnn]") and a random weak password is created.

-e SPW: Server management password. ⚠️

-e HPW: "DEFAULT" hub management password. ⚠️



## 其它的VPN使用

docker run --name l2tp --env-file ./vpn.env --restart=always -p 500:500/udp -p 4500:4500/udp -d --privileged hwdsl2/ipsec-vpn-server

vpn.env

VPN_IPSEC_PSK=vpn
VPN_USER=vpn
VPN_PASSWORD=NzA2ODI3M
VPN_ADDL_USERS=vpnuser1 vpnuser2
VPN_ADDL_PASSWORDS=aa123123 aa123123



