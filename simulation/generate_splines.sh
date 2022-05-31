#!/bin/bash
# shell script to generate cross-section splines (in .xml format)
# and convert to root file
# make sure to do: 
# 0. start a new spline session (screen -S spline.target)
# 1. source genie_env.sh
# 2. run this script the directory that contains Generator/ and Reweight/
# since the genie_env.sh will look for those directories
# 3. while running (gmkspl might take 24-48 hrs), cntrl + A + D to put on background, and potentially run another process in parallel
# 4. to quit a screen session after finished, do: screen -X -S [session # you want to kill] quit

target=$1   # user command-line input input (h2, d2, he4, c12, ca40, ca48, ar40, sn120)


scratch="/pnfs/genie/scratch/users/cyero/" #  ---> put the output here (for xml)
base_name="${target}_spline_G18_10a_02_11a"  # input/output files base name
splines_out=$scratch"splines/"$base_name
events_out=$scratch"events/"$base_name

echo "spline_out--->"$splines_out
echo "events_out--->"$events_out

beam_pdg="11"         # incident particle code (11 for electron)
Eb_max="11"           # upper limit on beam energy GeV
Eb="5.98636"          # actual beam energy

tgt_pdg_h2="1000010010"
tgt_pdg_d2="1000010020"    # target pdg code
tgt_pdg_he4="1000020040"
tgt_pdg_c12="1000060120"   # target pdg code
tgt_pdg_ca40="1000200400"
tgt_pdg_ca48="1000200480"
tgt_pdg_ar40="1000180400"  
tgt_pdg_sn120="1000501200"

nevts="50000"       # total number of events generated
tune="G18_10a_02_11a" # GENIE tune 

# Set Target PDG codes
if [ "${target}" = "h2" ]; then
    tgt_pdg=${tgt_pdg_h2}
    echo "Target Used: ${target} (PDG CODE: ${tgt_pdg})"

elif [ "${target}" = "d2" ]; then
    tgt_pdg=${tgt_pdg_d2}
    echo "Target Used: ${target} (PDG CODE: ${tgt_pdg})"

elif [ "${target}" = "he4" ]; then
    tgt_pdg=${tgt_pdg_he4}
    echo "Target Used: ${target} (PDG CODE: ${tgt_pdg})"

elif  [ "${target}" = "c12" ]; then
    tgt_pdg=${tgt_pdg_c12}
    echo "Target Used: ${target} (PDG CODE: ${tgt_pdg})"

elif  [ "${target}" = "ca40" ]; then
    tgt_pdg=${tgt_pdg_ca40}
    echo "Target Used: ${target} (PDG CODE: ${tgt_pdg})"

elif  [ "${target}" = "ca48" ]; then
    tgt_pdg=${tgt_pdg_ca48}
    echo "Target Used: ${target} (PDG CODE: ${tgt_pdg})"

elif [ "${target}" = "ar40" ]; then
    tgt_pdg=${tgt_pdg_ar40}
    echo "Target Used: ${target} (PDG CODE: ${tgt_pdg})"

elif [ "${target}" = "sn120" ]; then
    tgt_pdg=${tgt_pdg_sn120}
    echo "Target Used: ${target} (PDG CODE: ${tgt_pdg})"

elif [ "$1" = "" ]; then	
    echo "Please enter a target type: h2, d2, he4, c12, ca40, ca48, ar40, sn120"
    echo "example: ./generate_splines.sh sn120"
    exit 0
fi


# GENIE input flags information (see p. 105 of https://genie-docdb.pp.rl.ac.uk/DocDB/0000/000002/007/man.pdf)

# See PDG particle  codes: https://root.cern.ch/doc/master/TDatabasePDG_8cxx_source.html
# See Monte-Carlo Numbering Scheme: https://pdg.lbl.gov/2007/reviews/montecarlorpp.pdf
# See Numbering Scheme paper: https://arxiv.org/pdf/1812.05616.pdf

#====================
# gmkspl input flags
# (utility to write-out cross-section
# values in .XML format)
#====================
# -p : specifies incident particle PDG code,  for example incident electron will be: -p 11

# -t : specifies target PDG code (using PDG2006 conventions 10LZZZAAAI)
# L: strange number (0 for stable nuclei), ZZZ: 3-digit atomic number, AAA: 3-digit mass number, I: isomer number (0 for ground-state nuclei)
# Relevant targets for RGM:
#      Hydrogen (1H) :       L ZZZ AAA I
#      Deuteron (2H) : -t 10 0 001 002 0
#      Helium-4      : -t 10 0 002 004 0
#      Carbon-12     : -t 10 0 006 012 0
#      Calcium-40    : -t 10 0 020 040 0
#      Calcium-48    : -t 10 0 020 048 0
#      Argon-40      : -t 10 0 018 040 0   
#      Sn-120        : -t 10 0 050 120 0

# -e : specifies the maximum (OR UPPER LIMIT) incident "beam" energy in the range of each spline (GeV)

# -n : Specified the number of knots per spline (J. Barrow recommends 100 - 250 knots
#      the more knots, the more "accuracy" (in terms of how the model is evaluated

# -o : specifies the name of an outpout cross-section XML file (if not specified, GENIE writes-out 'xsec_splines.xml'

# --tune : specifies which tune to use (recommended by Afro is tune: G18_10a_02_11a)

# --event-generator-list : list of event generators to load, (since I want to simulate electro-nuclear interactions, I assume EM is sufficient)
#                          to show how all of the other background that contributes to your supposed signal, an event-generator-list should NOT be used       

# Since RGM highest beam energy was 5.98 GeV,  I would think setting an upper limit of: ~ 6 GeV will be OK, or is it better to go up to 11 GeV )??


# generate pion electro production off deuterium: d(e,e'pi)  with incident e- beam energy of 5.98
cmd_xml="gmkspl -p ${beam_pdg} -n 250 -t ${tgt_pdg} -e ${Eb_max} -o ${splines_out}.xml --tune ${tune} --event-generator-list EM"
echo "Executing ----> ${cmd_xml}"
echo "Writing splines file to ---> "$splines_out
eval ${cmd_xml}

# The output cross sections on d(e,e') will range up to beam energies Eb_max and will be in .xml format (in the next step, the user can specify which beam energy Eb to use)

#=========================
# gevgen input flags
# (generic GENIE event
# generation application)
#=========================

# flags

# -n : specifies number of events to generate
# -p : specifies incident particle PDG code, for example for electrons, -p 11
# -t : specifies target PDG codes (see notes above)
# -e : specifies incident energy or energy range  (Im assuming in this case, I should enter the exact beam energy, for example, -e 5.98636, corresponding to part of the RGM data)
#      or is it suggested I specify a range of energies??? (which accoring to docs, I would have to specify a neutrino (I guess electrons in my case) flux spectrum.
# --event-generator-list : see gmkspl flags above
# --tune : see gmkspl flags above
# --cross-sections : specify the name of the input XML file ( should have been generated by the gmkspl command already )

#cmd_gen="gevgen -n ${nevts} -p ${beam_pdg} -t ${tgt_pdg} -e ${Eb} --tune ${tune} --event-generator-list EM --cross-sections ${out_splines}.xml -o ${out_events}.ghep.root" 
#echo "Executing ----> ${cmd_gen}"
#eval ${cmd_gen}
# the output will be a GEHEP file of the form: ${base_name}, with cross sections which must then be converted to a ROOT file

#==================================
# gntpc input flags
# (utility to convert the native
# GENIE GHEP event file to either
# plain text, XML or .root )
#==================================

# -f : specifies the output format, where 'gst' is a GENIE summary ntuple format that can be used for plotting with ROOT
# -i : specifies the output file name

#cmd_gntpc="gntpc -f gst -i ${out_events}.ghep.root -o ${out_events}.root"
#echo "Executing ----> ${cmd_gntpc}"
#eval ${cmd_gntpc}
