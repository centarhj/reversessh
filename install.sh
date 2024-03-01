#!/bin/bash
eval $(grep '^RSSH_.*=.*' config.ini)

sudo -v

sudo apt install autossh

if [ $(grep -c ^${RSSH_LOCALUSER}: /etc/passwd) -eq 0 ]; then
  sudo adduser --disabled-password -gecos "User for reverse ssh to cemit" $RSSH_LOCALUSER
fi

if [ $(grep -c ^${RSSH_LOCALUSER}: /etc/passwd) -eq 0 ]; then
  echo Please create the user $RSSH_LOCALUSER before continuing the script. Please rerun the script.
  exit 1
fi

user_home=$(awk -F: "/$RSSH_LOCALUSER/ {print \$6}" /etc/passwd)
sshdir=$user_home/.ssh
sudo -u $RSSH_LOCALUSER mkdir -m 700 -p $sshdir
sudo -u $RSSH_LOCALUSER ssh-keygen -t ed25519 -f ${sshdir}/id_cemit-softprio_reverse-ssh -N ""
publickey=$(sudo -u $RSSH_LOCALUSER cat $sshdir/id_cemit-softprio_reverse-ssh.pub)

/usr/bin/ssh-keyscan -p $RSSH_SERVER_PORT $RSSH_HOST |sudo -u $RSSH_LOCALUSER tee -a $sshdir/known_hosts >/dev/null



cat << _show_public_key_
  skicka innehållet i filen $sshdir/id_cemit-softprio_reverse-ssh.pub
---
 $publickey
---
_show_public_key_


cat << _config_file_ | sudo -u $RSSH_LOCALUSER tee -a $sshdir/config
Host ssh-server
  Hostname $RSSH_HOST
  Port $RSSH_SERVER_PORT
  User $RSSH_USER
  IdentityFile ${sshdir}/id_cemit-softprio_reverse-ssh
  ServerAliveInterval 30
  ServerAliveCountMax 3
  ExitOnForwardFailure yes
  RemoteForward $RSSH_REMOTE_PORT localhost:$RSSH_LOCAL_PORT

_config_file_


cat << _service_file_ | sudo tee /etc/systemd/system/cemit-softprio_reverse-ssh.service
[Unit]
Description=Keeps a reverse ssh tunnel open to the Cemit ssh server
After=network.target

[Service]
ExecStart=/usr/bin/autossh -M 0 -N ssh-server -F $sshdir/config
Restart=always
RestartSec=20
KillMode=mixed
User=$RSSH_LOCALUSER

[Install]
WantedBy=multi-user.target

_service_file_


sudo systemctl daemon-reload

sudo systemctl enable cemit-softprio_reverse-ssh.service --now
