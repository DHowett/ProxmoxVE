#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/DHowett/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 DHowett ORG
# Author: DHowett
# License: MIT | https://github.com/DHowett/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Dictionarry-Hub/prrofilarr

APP="Profilarr"
var_tags="${var_tags:-arr;media}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/profilarr/ ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  if check_for_gh_release "profilarr" "Dictionarry-Hub/profilarr"; then
    msg_info "Stopping Services"
    systemctl stop profilarr
    msg_ok "Services Stopped"

    PYTHON_VERSION="3.9" setup_uv
    fetch_and_deploy_gh_release "profilarr" "Dictionarry-Hub/profilarr" "tarball" "latest" "/opt/profilarr"

    msg_info "Updating Profilarr"
    cd /opt/profilarr
    $STD uv venv /opt/profilarr/backend/.venv
    $STD /opt/profilarr/backend/.venv/bin/python -m ensurepip --upgrade
    $STD /opt/profilarr/backend/.venv/bin/python -m pip install --upgrade pip
    $STD /opt/profilarr/backend/.venv/bin/python -m pip install -r /opt/profilarr/backend/requirements.txt
    chmod -R 755 /opt/profilarr
    msg_ok "Updated Profilarr"

    msg_info "Starting Services"
    systemctl start profilarr
    msg_ok "Services Started"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:6868${CL}"
