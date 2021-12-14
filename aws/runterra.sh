#!/bin/bash

cd terraform

echo
echo "##################################"
echo "# initialize terraform ..."
echo "##################################"
echo
terraform init
echo

echo
echo "##################################"
echo "# calculate the terraform plan ..."
echo "##################################"
echo
terraform plan -out myplan
echo

echo -n "DO you want to apply the plan and continue (yes or no)? "
echo 
read yesno
if [[ "$yesno" == "yes" ]]; then
   echo
   echo "##################################"
   echo "# apply the terraform plan ..."
   echo "##################################"
   echo
   terraform apply myplan
fi

terraform output > origin_output.txt
chmod -x cloudgate_inventory
cp cloudgate_inventory ../ansible_proxy/
cp cloudgate_ssh_config ../ansible_proxy/

cd ..
