#!/bin/bash

## this is called by the code.py from modified workstation
#set -e -x -o pipefail

echo "Checking variable availability to bash script"
echo "Max session length: '$max_session_length'"
echo "Name of submission script: '$submit_script'"
echo "Input command: '$cmd'"
echo "Project: $project"



# echo "location of dxfuse"
# echo "$(which dxfuse)"

#mount dxfuse
mkdir /home/dnanexus/project
dxfuse /home/dnanexus/project "Alport_Syndrome"
export DXFUSE="/home/dnanexus/project/Alport_Syndrome"
echo "Dxfuse directory root $DXFUSE"
# ls  $DXFUSE | head 

echo "restting workspace directory"

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
dx download Gdoc/scripts/startupscript 

# echo "testing dxfuse in bashstartupscript"
# export DRAGENPATH="project/Alport_Syndrome/Bulk/DRAGEN WGS/DRAGEN population level WGS variants, pVCF format [500k release]/chr11"

#echo "zcat view"
#zcat  "${DRAGENPATH}/ukb24310_c11_b6753_v1.vcf.gz" | head -n1

echo "downloading submit script"
echo "the location where the script should be downloaded to is": 
echo pwd
dx download $submit_script
filename=$(basename "$submit_script")
echo "$filename"
echo "contents of $filename:"
cat $filename


set +e  # Allow failure
set -x
eval "$cmd"
exit_code=$?
set +x
set -e  # Re-enable strict failure mode

if [[ $exit_code -ne 0 ]]; then
    echo "Warning: Command failed with exit code $exit_code"
fi

if [[ "$run_interactive" == "true" ]]; then
    tail -f /dev/null
fi



