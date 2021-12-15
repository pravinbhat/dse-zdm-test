#!/bin/bash

cd terraform

echo
echo "##################################"
echo "# Destroy terraform ..."
echo "##################################"
echo
terraform destroy
echo

cd ..
