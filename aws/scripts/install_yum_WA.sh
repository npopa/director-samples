#!/bin/bash

#WA for Director installing mysql-connector-java.
#TODO - remove /sbin/yum in the postscript 
cat <<-\EOF > /sbin/yum
#!/bin/bash

#prevent director from installing mysql-connector-java

YUM_PARAMS=$@

if ([[ $YUM_PARAMS == *"install"* ]] && [[ $YUM_PARAMS == *"mysql-connector-java"* ]]) \
    || ([[ $YUM_PARAMS == *"install"* ]] && [[ $YUM_PARAMS == *"mysql-devel"* ]]); then
  echo "Cowardly refusing to install mysql connector package! Moving on."
  exit 0
fi

/usr/bin/yum $@

EOF

chmod +x /sbin/yum
