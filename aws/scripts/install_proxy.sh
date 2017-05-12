#!/bin/bash

#### Install tinyproxy

. /tmp/params.sh

cat <<EOF >/etc/profile.d/proxy.sh
#!/bin/bash

export http_proxy=http://${DIRECTOR_HOST}:8888
export https_proxy=http://${DIRECTOR_HOST}:8888
EOF
chmod +x /etc/profile.d/proxy.sh

source /etc/profile.d/proxy.sh

echo "proxy=http://${DIRECTOR_HOST}:8888" >> /etc/yum.conf

