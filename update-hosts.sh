#/bin/bash
if [ "$HOSTNAME" = tools ]; then
  echo "We don't need to update hosts in the tools container. Exiting."
  exit 1
fi

if grep "ADM 5.5.0-v1.0.0 host entries" /etc/hosts >/dev/null; then
  echo "Already done!"
  exit 0
fi

cat << EOF | sudo tee -a /etc/hosts >/dev/null

# ADM 5.5.0-v1.0.0 host entries
127.0.0.1 zk-1
127.0.0.1 zk-2
127.0.0.1 zk-3
127.0.0.1 kafka-1
127.0.0.1 kafka-2
127.0.0.1 kafka-3
127.0.0.1 schema-registry
127.0.0.1 connect
127.0.0.1 ksqldb-server
127.0.0.1 tools
127.0.0.1 control-center

EOF
echo Done!
