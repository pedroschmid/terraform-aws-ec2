#!/bin/bash

sudo yum update -y
sudo yum upgrade -y
sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx
sudo systemctl enable nginx