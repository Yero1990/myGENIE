#!/bin/bash
# Script to simplify GENIE job submission to the grid

function SourceSetup() { 
	#source /cvmfs/larsoft.opensciencegrid.org/products/setups;
	source /cvmfs/fermilab.opensciencegrid.org/products/genie/bootstrap_genie_ups.sh;	
};

##### Parse any command-line options passed to this script ######
# This section is based on https://stackoverflow.com/a/29754866/4081973
#
# Currently, the allowed options for invoking this script are
#
# -p, --prod:  Submit jobs with the VOMS Production role (rather than the
#              usual Analysis role). The job will be run on the grid
#              using the anniepro account instead of your normal user
#              account. Job submission will fail unless you have permission
#              to submit production jobs.

# Check for a suitable version of the getopt program (should be installed
# on just about any flavor of Linux these days)
getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    echo "ERROR: enhanced getopt is not installed on this system."
    exit 1
fi

# Number of expected command-line arguments
NUM_EXPECTED=10

# Define the command-line options accepted by this script
OPTIONS=p:
LONGOPTIONS=prod:

# Parse the command line used to run this script using getopt
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")

if [[ $? -ne 0 ]]; then
    # getopt has complained about wrong arguments to stdout, so we can quit
    exit 2
fi

# Read getopt’s output this way to handle the quoting right
eval set -- "$PARSED"

# Process the options in order until we see --
while true; do
    case "$1" in
        -p|--prod)
            USE_PRODUCTION="y"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Error encountered while parsing the command-line options!"
            exit 3
            ;;
    esac
done

if [ "$#" -ne "$NUM_EXPECTED" ]; then
  echo "Usage: ./submit_samples.sh [--prod] NUM_JOBS JOB_NAME SPLINES_FILE OUTPUT_DIRECTORY GIT_CHECKOUT ENERGY PROBE TARGET TUNE EVENTGENLIST" 
  exit 1
fi

NUM_JOBS=$1
STEM=$2
SPLINES_FILE=$3
OUTPUT_DIRECTORY=$4
GIT_CHECKOUT=$5
ENERGY=$6
PROBE=$7
TARGET=$8
TUNE=$9
EVENTGENLIST=${10}

echo NUM_JOBS ${NUM_JOBS}
echo STEM ${STEM}
echo SPLINES_FILE ${SPLINES_FILE}
echo OUTPUT_DIRECTORY ${OUTPUT_DIRECTORY}
echo GIT_CHECKOUT ${GIT_CHECKOUT}
echo ENERGY ${ENERGY}
echo PROBE ${PROBE}
echo TARGET ${TARGET}
echo TUNE ${TUNE} 
echo EVENTGENLIST ${EVENTGENLIST}

GRID_RESOURCES_DIR=/pnfs/genie/persistent/users/cyero/Grid/

# Check if the USE_PRODUCTION variable is set
if [ ! -z ${USE_PRODUCTION+x} ]; then
  echo "Production job will run as geniepro"
  PROD_OPTION="--role=Production"
else
  echo "Analysis job will run as $(whoami)"
  PROD_OPTION="--role=Analysis"
fi

#source /cvmfs/fermilab.opensciencegrid.org/products/common/etc/setups
#source /cvmfs/fermilab.opensciencegrid.org/products/genie/bootstrap_genie_ups.sh
#source /cvmfs/larsoft.opensciencegrid.org/products/setups
SourceSetup
setup fife_utils

jobsub_submit -G genie --disk=20GB --expected-lifetime=24h -N $NUM_JOBS \
  $PROD_OPTION -f $SPLINES_FILE -d OUTPUT $OUTPUT_DIRECTORY \
  --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
  file://$GRID_RESOURCES_DIR/genie_samples_grid.sh $STEM $(basename $SPLINES_FILE) ${GIT_CHECKOUT} ${ENERGY} ${PROBE} ${TARGET} ${TUNE} ${EVENTGENLIST}
