# BasicBashWorker_for_UKBiobankDNANexus
Version: 1.2.1

Explore UKBiobank data on a DNANexus cloud worker, as if you were working on your own bash command-line. Interactive mode allows you to develop scripts which will work as intended as a submit job.

The BasicBashWorker is modified version of the dnanexus [cloud_workstation](https://documentation.dnanexus.com/developer/cloud-workstation) app, to allow interactive sessions via ssh, dx upload/download, the use of dxfuse paths, and the use of environmental snapshots. It can also be used as an alternative to the [swiss-army-knife](https://dnanexus.gitbook.io/uk-biobank-rap/working-on-the-research-analysis-platform/running-analysis-jobs/tools-library) to allow easier code improvement and data exploration.  

The worker has full Ubuntu, R and python functionality. Use the versions of other software that YOU choose. The build includes plink and [plink2](https://www.cog-genomics.org/plink/2.0/) (29 Jan 2025 versions) bundled.

## Requirements
- Access to a project hosted on DNANexus! I use this for UK Biobank RAP data, it may be usable in other cases. 
- Prior installation of dx-toolkit https://github.com/dnanexus/dx-toolkit (and see https://documentation.dnanexus.com/downloads#DNAnexus-Platform-SDK)
- One  time set up of dx [ssh_config](https://documentation.dnanexus.com/developer/apps/execution-environment/connecting-to-jobs#setting-up-your-environment-for-ssh-access)
- A dnanexus API token ($raptoken) 

## Important disclaimers
- This applet does not integrate well with the DNANexus Job "State" flags. Specifically, a submit job  be marked as "Done" even if the script has failed internally for some reason. Failures because of external factors (e.g. being kicked off a DNANexus worker) will be correctly logged.
- This is a Frankenstein applet that works well despite a bunch of warnings and error messages.  I am sure a competent coder would be able to tidy up redundancies and make it smoother. Please contact me if you want to!
- The user must explicitly include a "dx upload" command for any output file that they would like to be saved to their platform; unlike the swiss-army-knife, no files are automatically uploaded to the platform at the end of the job. (This is intentional to allow uploading of outputs as they complete which means that work done on a low-priority instance will not be lost if the user is kicked off.)


## Installation
Clone the folders to your local machine.
```
# choose  directory and name
LDIR=basicbashworker
git clone https://github.com/gtdoctor/BasicBashWorker_for_UKBiobankDNANexus.git $DIR
```

```{sh}
PROJECT="Projectname" #your DNA Nexus platform project name
DDIR="$PROJECT:/bbw" # choose a directry and name on DNAnexus platform

cd $DIR/
dx build -fd "$DDIR"

# Optional to have  htslib and bcftools precompiled
dx upload snapshot/bbw_htslib --path "$PROJECT:/bbw_htslib"
```

## Run interactively:

```
PROJECT="Projectname"
dx select $PROJECT

dx run "$PROJECT:/bbw" \
-iraptoken=$raptoken \
-imax_session_length=12h \
-irun_interactive=true \
-iproject="$PROJECT" \
--ssh -y
```

## Run non-interactively (submit mode) : 
```
SCRIPTNAME="script.sh"
PROJECT="Projectname"
CMD="bash $SCRIPTNAME"

dx run "$PROJECT:/bbw" \
-iraptoken=$raptoken \
-imax_session_length=12h \
-irun_interactive=false \
-iproject="$PROJECT" \
-isubmit_script="${PROJECT}:/path/to/$SCRIPTNAME" \
-icmd="$CMD" \
-y
```
You can ignore the following error messages:
```
Error while writing configuration data: PermissionError: [Errno 1] Operation not permitted:                                                                                                                      
'/home/dnanexus/.dnanexus_config'                                                                                                                                                                                
Error while writing configuration data: PermissionError: [Errno 13] Permission denied:                                                                                                                           
'/home/dnanexus/.dnanexus_config/sessions/4900'                                                                                                                                                                  
PermissionError: [Errno 13] Permission denied: '/home/dnanexus/.dnanexus_config/unsetenv'
```


To test submit mode, use this on your local commandline. The output should be a file in your UKB plaftform, $PROJECT:/Test_bbw/fullfile.txt that lists the content of your project root directory twice.   

```
#from within basicbashworker local directory
SCRIPTNAME="testscript.txt"
PROJECT="Projectname" 
CMD="bash $SCRIPTNAME"


dx mkdir ${PROJECT}:/Test_bbw
dx upload test/* --path ${PROJECT}:/Test_bbw/

dx run "$PROJECT:/bbw" \
-iraptoken=$raptoken \
-imax_session_length=10m \
-irun_interactive=false \
-iproject="$PROJECT" \
-isubmit_script="${PROJECT}:/Test_bbw/$SCRIPTNAME" \
-icmd="$CMD" \
-y
```
If you want to watch the log as it is generated (without sshing), add the --watch flag to the dx run command above.


## Optional:
To load files onto worker. include in the loading command

```
-ifids="$PROJECT:/path/to/file1" \
-fids=file2  # etc 
```

To load htslib and bcftools
```
-isnaphsot="$PROJECT:/bbw_htslib"
```

## Comments
`--ssh` can be used for non-interactive sessions, to see what's going on. 
In ssh : A byobu terminal is opened - to see what's happening with submit scipt, press f4 (and then again). or press f2 to create a new terminal
To close, type "sudo shutdown now" or some combination of ctrl-x and ctrl-d

Timeout defaults to 12h. 

**To view/stream dxfuse style files ("streaming mode"), type e.g.** 
```
PROJECT=Projectname
ls project/$PROJECT/
less project/$PROJECT/pathtofile/file.txt  #note this is different to the usual dnanexus /mnt/project/pathtofile.txt
```

Output must be explicltly uploaded to the project directory or will be lost when the worker terminates.

To add new programmes:
If you want to have them 'preloaded', you can either update the basicbashworker app, or create a snapshot. 
- For simple binaries with no dependencies, add the compiled programme with correct permission to basicbashworker/usr/bin/ folder; and then recompile the applet with "dx build"
- Alternatively, upload the binary to your DNANexus platform stoarge and modify the bash_update.sh to download it to the worker on startup, and then recompile the applet.  
-For more complex binaries with dependenceis, the worker has internet access, so you can install whatever you like and then use the [dx-snapshot utility](https://documentation.dnanexus.com/developer/cloud-workstation) to save a new snapshot. You will not have to recompile the basicbashworker to use the new snapshot, just update the command used when starting it up.

For other useful flags for dx run e.g. worker instance, priority etc, see https://documentation.dnanexus.com/user/helpstrings-of-sdk-command-line-utilities
