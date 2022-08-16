#!/bin/bash                                                                                                          
#SBATCH --nodes=1                                                                                                    
#SBATCH --ntasks=1                                                                                                   
#SBATCH --mem-per-cpu=2000                                                                                            
#SBATCH --account=clas12                                                                                             
#SBATCH --job-name=mc_rgm                                                                                              
#SBATCH --partition=production                                                               
#SBATCH --time=40:00:00                                                                                               
#SBATCH --output=/farm_out/%u/%x-%j-%N.out                                                                           
#SBATCH --error=//farm_out/%u/%x-%j-%N.err                                                                           
#SBATCH --array=1-900                                                                                                     

TORUS=-1.0
SOL=-1.0
RUN=GENIE_C_6GeV_Q2_0_6

source /etc/profile.d/modules.sh
source /group/clas12/packages/setup.sh
module load clas12/pro
module switch gemc/4.4.2


srun gemc -USE_GUI=0  -SCALE_FIELD="TorusSymmetric, $TORUS" -SCALE_FIELD="clas12-newSolenoid, $SOL" -N=10000 -INPUT_GEN_FILE="lund, ../../lundfiles/lund_${RUN}_${SLURM_ARRAY_TASK_ID}.dat" -OUTPUT="evio, ../../eviofiles/out_${RUN}_${SLURM_ARRAY_TASK_ID}_torus${TORUS}_sol${SOL}.ev" /group/clas12/gemc/4.4.2/config/rgb_spring2019.gcard
echo "Finished GEMC"
echo "    "
echo "    "
echo "    "
srun evio2hipo -t $TORUS -s $SOL -i ../../eviofiles/out_${RUN}_${SLURM_ARRAY_TASK_ID}_torus${TORUS}_sol${SOL}.ev -o ../../mchipo/qe_${RUN}_${SLURM_ARRAY_TASK_ID}_torus${TORUS}_sol${SOL}.hipo
echo "Finished EVIO2Hipo"
echo "    "
echo "    "
echo "    "
srun recon-util -y /group/clas12/gemc/4.4.2/config/rgb_spring2019.yaml -i ../../mchipo/qe_${RUN}_${SLURM_ARRAY_TASK_ID}_torus${TORUS}_sol${SOL}.hipo -o ../../reconhipo/recon_qe_${RUN}_${SLURM_ARRAY_TASK_ID}_torus${TORUS}_sol${SOL}.hipo
echo "Finished RECON"
echo "    "
echo "    "
echo "    "
