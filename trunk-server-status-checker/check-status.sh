system_ids="system1 system2 ..."
alert_from="some-server@somedomain.com"
alert_emails="user1@somedomain.com,user2@somedomain.com,..."

function log {
    echo $(date) "$@"
}

for system_id in $system_ids; do
    status_file="/tmp/trstatus-${system_id}"
    last_status=$(cat "${status_file}")
    status=$(curl -fs "https://api.openmhz.com/status/${system_id}" | jq -r ".active")

    log "${system_id} is ${status}"

    if [ "${status}" != "${last_status}" ]; then
        message="${system_id} state has changed to ${status} at $(date)"
        log "${message}"

        if [ ! -z "${alert_emails}" ]; then
            echo "${message}" | mail -r "${alert_from}" -s "OpenMHZ System Status Change for ${system_id}" "${alert_emails}"
            log "Alert sent to ${alert_emails}"
        fi
    fi

    echo "${status}" > "${status_file}"
done
