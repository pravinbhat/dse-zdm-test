#!/bin/bash

cd ansible_proxy

"$(pwd)"

echo
echo ">>>> Setup ZDM Proxy Cluster <<<<"
echo
ansible-playbook cloudgate_proxy_playbook.yml -i cloudgate_inventory
echo

echo
echo ">>>> Setup ZDM Proxy Monitoring <<<<"
echo
ansible-playbook monitoring_playbook.yml -i cloudgate_inventory
echo

cd ..
