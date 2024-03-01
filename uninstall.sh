#!/bin/bash

# Uninstall the cemit reverse ssh-service.

sudo systemctl disable cemit-softprio_reverse-ssh.service
sudo systemctl stop cemit-softprio_reverse-ssh.service
sudo rm /etc/systemd/system/cemit-softprio_reverse-ssh.service

