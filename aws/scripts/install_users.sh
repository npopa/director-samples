#!/bin/bash


cat <<EOF >/tmp/users_groups.txt
#Maybe this is a good format to capture the user/group info
#UID starts from 15000 and GID from 25000
#uid=5000(admin1) gid=3000(user) groups=3000(user),3003(huser),3002(hadmin)

#Cloudera Manager - Full administrator
uid=537304(u537304) gid=537304(u537304) groups=444279(cfa444279g)
uid=511977(cua511977) gid=511977(cua511977) groups=498302(cua498302g)
uid=558988(ca558988) gid=558988(ca558988) groups=403387(ca403387g)




EOF
