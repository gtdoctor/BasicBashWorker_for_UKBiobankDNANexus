source ~/environment
source ~/.bashrc

export DX_RUN_DETACH=1

if [[ -z $BYOBU_BACKEND ]]; then
    if [[ -f /run/shm/dx_job_monitor_started ]]; then
        byobu
    else
        touch /run/shm/dx_job_monitor_started
        byobu new-session -n "${DX_JOB_ID:-unknown_dx_job}" "tail -n +1 -f -q dx_stdout dx_stderr" \; new-window -n DNAnexus 'bash --login'
    fi
else
    /etc/update-motd.d/dx-motd
fi

eval "$(register-python-argcomplete dx|sed 's/-o default//')"

if [[ -z $DX_SNAPSHOT_FILE ]]; then
    DX_SNAPSHOT_FILE=$(cat job_input.json | jq -r '.snapshot."$dnanexus_link"')
    if [[ $DX_SNAPSHOT_FILE != null ]]; then
        dx-check-snapshot-version $DX_SNAPSHOT_FILE 1>/dev/null || true
    fi
    export DX_SNAPSHOT_FILE
fi

source ~/.bashrc
