#!/bin/bash

## this is called by the code.py from modified workstation
set -e -x -o pipefail

echo "Project: $project"
echo "Name of submission script, if given: $submit_script"
echo "Input command, if given: $cmd "

#mount dxfuse
export PROJECT=$project
mkdir /home/dnanexus/project
dxfuse /home/dnanexus/project $project
export DXFUSE="/home/dnanexus/project/$project"
echo "Dxfuse directory root $DXFUSE"

echo "Resetting workspace directory"

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

#see if this works to add to login profile
cat << EOL >> ~/.bashrc
unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:
sudo chown -R dnanexus:dnanexus /home/dnanexus/.dnanexus_config
sudo chmod -R u+w /home/dnanexus/.dnanexus_config
source ~/.dnanexus_config/unsetenv
dx clearenv
dx login --noprojects --token $raptoken
dx select $project
EOL

export LC_ALL=C.UTF-8


echo "testing: dx pwd in bashstartupscript"
dx pwd
# could add a dx download file/script/binary here 

if [[ -n "$submit_script" ]]; then 
    echo "downloading submit script:"
    filename=$(basename "$submit_script")
    echo "$filename"
    echo "the location where the script should be downloaded to is": 
    echo $(pwd)
    dx download $submit_script
    echo "contents of $filename:"
    cat $filename
fi


# allow for timeout
timeout_loop() {
    while true; do
        now=$(date +'%s')
        #adjust datefile format
        raw=$(cat /home/dnanexus/.dx.timeout)
        formatted=$(echo "$raw" | awk '{printf "%s-%s-%s %s:%s:%s\n", $1,$2,$3,$4,$5,$6}')
        timeout=$(date -d "$formatted" +'%s')
        if (( now > timeout )); then
            echo "Session timed out. Shutting down."
            sleep 10 && sudo shutdown now
        fi
        sleep 30
    done
}

set +e
set -o pipefail

timeout_loop &
timeout_pid=$!
echo "timeout pid is $timeout_pid"

eval "$cmd"
exit_code=$?
set +x


if [[ "$run_interactive" == "true" ]]; then
    wait $timeout_pid
else
    if [[ $exit_code -ne 0 ]]; then
        echo "Warning: Supplied command/code failed with exit code $exit_code" 
            else
        echo "Supplied command/code appears to have completed."
    fi
    sleep 10 && sudo shutdown now # give time for error logging? 
fi

echo "shutting down" 
sleep 10 && sudo shutdown now


# if cmd=true and ri=true   - timer starts, command runs. once timer completes, shutdown ensues. regardless of whether command fails or completes or is incomplete, shutdown will not occur until timer completes 
# if cmd=true and ri=false - timer starts, cmd is runs. if command completes before timer, then shutdown. if command doesn't complete, shutdown still occurs from timer. 
# if no command and ri=true = timer starts, and process waits for it to finish then terminate
# if no command and ri=false = (this shouldn't happen; but) 
