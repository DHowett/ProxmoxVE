#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: DHowett
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Dictionarry-Hub/profilarr

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

PYTHON_VERSION="3.9" setup_uv
fetch_and_deploy_gh_release "profilarr" "Dictionarry-Hub/profilarr" "tarball" "latest" "/opt/profilarr"
msg_info "Installing Profilarr"
cd /opt/profilarr
$STD apt install -yy git
$STD uv venv /opt/profilarr/backend/.venv
$STD /opt/profilarr/backend/.venv/bin/python -m ensurepip --upgrade
$STD /opt/profilarr/backend/.venv/bin/python -m pip install --upgrade pip
$STD /opt/profilarr/backend/.venv/bin/python -m pip install -r /opt/profilarr/backend/requirements.txt
chmod -R 755 /opt/profilarr
mkdir /config
chmod -R 755 /config
msg_ok "Installed Profilarr"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/profilarr.service
[Unit]
Description=Profilarr
Wants=network-online.target
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/profilarr/backend
ExecStart=/opt/profilarr/backend/.venv/bin/gunicorn --bind 0.0.0.0:6868 --timeout 600 app.main:create_app()
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now profilarr
msg_ok "Configured Service"

motd_ssh
customize
cleanup_lxc
