#!/bin/bash

## this is called by the code.py from modified workstation
#set -e -x -o pipefail

echo "Checking variable availability to bash script"
echo "Project: $project"
echo "Name of submission script: $submit_script"
echo "Input command: $cmd "

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

echo "downloading submit script"
echo "the location where the script should be downloaded to is": 
echo $(pwd)
dx download $submit_script
filename=$(basename "$submit_script")
echo "$filename"
echo "contents of $filename:"
cat $filename


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
            sudo shutdown now
            break
        fi
        sleep 30
    done
}

set +e
set -o pipefail


if [[ "$run_interactive" == "false" ]]; then
    timeout_loop & 
fi


eval "$cmd"
exit_code=$?
set +x
set -e  # Re-enable strict failure mode


#if [[ $exit_code -ne 0 ]]; then
#    echo "Warning: Command failed with exit code $exit_code"
#fi

if [[ "$run_interactive" == "true" ]]; then
    timeout_loop 
fi

sudo shutdown now
