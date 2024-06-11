#!/usr/bin/bash

# these values can be overriden with exec (VAR='value' ./tf-entrypoint.sh)
: ${TF_MAAS_ACT:=testflinger-maastiff}
: ${MAAS_HOST:=10.245.128.4}
: ${MAAS_PORT:=5240}
: ${MAAS_API_KEY:='***REMOVED***'}

/usr/sbin/ip route change default via 10.245.128.1

echo
echo "###########################"
echo
echo "Logging into maas server..."
/usr/bin/maas login $TF_MAAS_ACT http://$MAAS_HOST:$MAAS_PORT/MAAS/ $MAAS_API_KEY

echo "Replicating maas-cli db..."
cp /root/.maascli.db /home/ubuntu/
chown ubuntu:ubuntu /home/ubuntu/.maascli.db

echo
echo "Exporting ssh pubkeys..."
echo "- User: root"
/opt/export_ssh_pubkey_agnt.py --path /root/ \
                          --mapi $MAAS_API_KEY \
                          --mhost $MAAS_HOST \
                          --mport $MAAS_PORT
echo
echo "- User: ubuntu"
/opt/export_ssh_pubkey_agnt.py --path /home/ubuntu/ \
                          --mapi $MAAS_API_KEY \
                          --mhost $MAAS_HOST \
                          --mport $MAAS_PORT
echo

echo "###########################"
echo
echo "Starting init.d and /etc/my_init services..."
# start init
echo
echo "Starting my_initd..."
/sbin/my_init -- bash -l
