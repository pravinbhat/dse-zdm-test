#!/bin/bash

cd ansible

"$(pwd)"

#echo
#echo ">>>> Configure recommended OS/Kernel parameters for DSE nodes <<<<"
#echo
#ansible-playbook -i hosts osparm_change.yaml --private-key=~/.ssh/origin-key -u ubuntu
#echo

echo
echo ">>>> Setup DSE application cluster <<<<"
echo
ansible-playbook -i hosts dse_app_install.yaml --private-key=~/.ssh/origin_key -u ubuntu
echo

cd ..
