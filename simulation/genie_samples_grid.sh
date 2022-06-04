#!/bin/bash

function SourceSetup() { 
	#source /cvmfs/larsoft.opensciencegrid.org/products/setups;
	source /cvmfs/fermilab.opensciencegrid.org/products/genie/bootstrap_genie_ups.sh; 
};

STEM=$1
SPLINES_FILE=$2
GIT_CHECKOUT=$3
ENERGY=$4
PROBE=$5
TARGET=$6
TUNE=$7
EVENTGENLIST=$8

# Create a dummy file in the output directory. This is a hack to get jobs
# that fail to end themselves quickly rather than hanging on for a long time
# waiting for output to arrive.
DUMMY_OUTPUT_FILE=${CONDOR_DIR_OUTPUT}/${JOBSUBJOBID}_${STEM}_dummy_output
touch ${DUMMY_OUTPUT_FILE}

cd $CONDOR_DIR_INPUT
#source /cvmfs/fermilab.opensciencegrid.org/products/genie/bootstrap_genie_ups.sh
#source /cvmfs/larsoft.opensciencegrid.org/products/setups
SourceSetup

setup root v6_12_06a -q e17:debug
setup geant4 v4_10_4_p02b -q e17:prof
#setup root v6_12_04e -q e15:prof
#setup geant4 v4_10_6_p01d -q e20:prof
setup lhapdf v5_9_1k -q e17:debug
setup log4cpp v1_1_3a -q e17:debug
setup pdfsets v5_9_1b
#setup gcc v9_3_0
setup gdb v8_1
setup git v2_15_1

# C.Y. if Generator/ repo exists, this command is NOT needed
#git clone https://github.com/GENIE-MC/Generator.git genie-build
#git clone https://github.com/afropapp13/Generator.git genie-build
#git clone https://github.com/Yero1990/Generator.git Generator

export GENIEBASE=$(pwd)
export GENIE=$GENIEBASE/Generator
export PYTHIA6=$PYTHIA_FQ_DIR/lib
export LHAPDF5_INC=$LHAPDF_INC
export LHAPDF5_LIB=$LHAPDF_LIB
export LD_LIBRARY_PATH=$GENIE/lib:$LD_LIBRARY_PATH
export PATH=$GENIE/bin:$PATH
unset GENIEBASE

### Check out tagged v3_2_0 release
#cd $GENIE
#git checkout tags/R-3_02_00 -b v3.2.0

# Check out the requested git branch, tag, or commit
cd $GENIE
git checkout -b temp ${GIT_CHECKOUT}

# Configure for the build
./configure \
  --enable-gsl \
  --enable-rwght \
  --with-optimiz-level=O2 \
  --with-log4cpp-inc=${LOG4CPP_INC} \
  --with-log4cpp-lib=${LOG4CPP_LIB} \
  --with-libxml2-inc=${LIBXML2_INC} \
  --with-libxml2-lib=${LIBXML2_LIB} \
  --with-lhapdf5-lib=${LHAPDF_LIB} \
  --with-lhapdf5-inc=${LHAPDF_INC} \
  --with-pythia6-lib=${PYTHIA_LIB} \
  --enable-geant4

# Build GENIE
make

# Get a randomly-selected random number seed using bash
myseed=${RANDOM}

echo STEM ${STEM}
echo SPLINES_FILE ${SPLINES_FILE}
echo GIT_CHECKOUT ${GIT_CHECKOUT}
echo ENERGY ${ENERGY}
echo PROBE ${PROBE}
echo TARGET ${TARGET}
echo TUNE ${TUNE}
echo EVENTGENLIST ${EVENTGENLIST}


# Generate some events
cd ${CONDOR_DIR_INPUT}
printf -v PADDED_PROCESS "%05d" $EVENTGENLIST
output_file_stem="${CONDOR_DIR_OUTPUT}/${STEM}_${myseed}_${PADDED_PROCESS}"
gevgen -n 100000 -e ${ENERGY} -p ${PROBE} -t ${TARGET} --tune ${TUNE} --event-generator-list ${EVENTGENLIST} --seed ${myseed} --cross-sections ${SPLINES_FILE} -o ${output_file_stem}.ghep.root

# Make a gst-format summary file for easy plotting
gntpc -i ${output_file_stem}.ghep.root -o ${output_file_stem}.gst.root -f gst
