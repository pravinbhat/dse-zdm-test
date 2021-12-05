#!/bin/bash

cd ansible

"$(pwd)"

#echo
#echo ">>>> Configure recommended OS/Kernel parameters for DSE nodes <<<<"
#echo
#ansible-playbook -i hosts osparm_change.yaml --private-key=~/.ssh/origin-key -u ubuntu
#echo

echo
echo ">>>> Setup DSE Core cluster <<<<"
echo
ansible-playbook -i hosts dse_core_install.yaml --private-key=~/.ssh/origin_key -u ubuntu
echo

cd ..
