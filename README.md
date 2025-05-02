# Basic Bash Worker 
Version: 1.1.2

A modified dnanexus workspace app to allow interactive sessions via ssh, dx upload/download, dxfuse paths, and snapshots. Executible binaries can be added to the mod_bbw/resources/usr/bin/ folder. 


It requires an API token $raptoken 

## Run interactively:

```
PROJECT="Projectname"
dx run "$PROJECT:/mod_bbw" \
-iraptoken=$raptoken \
-imax_session_length=12h \
-irun_interactive=true \
-iproject="$PROJECT" \
--ssh -y
```

Once on the command line on the worker, to allow dx upload/download, type 
```
source .bashrc
```


## Run non-interactively: 
```
SCRIPTNAME="script.sh"
PROJECT="Projectname"
CMD="bash $SCRIPTNAME"

dx run "$PROJECT:/mod_bbw" \
-iraptoken=$raptoken \
-imax_session_length=12h \
-irun_interactive=false \
-iproject="$PROJECT" \
-isubmit_script="${PROJECT}:/path/to/$SCRIPTNAME" \
-icmd="$CMD" \
-y


## Optional:
To load files onto worker

```
-ifids="Project/path/to/file1" \
-fids=file2  # etc 
```

To load htslib and bcftools
```
-isnaphsot="Alport_Syndrome:/bbw_htslib_plink.2"
```

## Comments
`--ssh` can be used for non-interactive sessions, to see what's going on. 

In ssh : A byobu terminal is opened - to see what's happening with submit scipt, press f4 (and then again). or press f2 to create a new terminal

To close, type "sudo shutdown" or some combination of ctrl-x and ctrl-d

Timeout defaults to 12h now. 

To view/stream dxfuse style files ("streaming mode"), type e.g. 
```
PROJECT=Projectname
less project/$PROJECT/pathtofile/file.txt
```