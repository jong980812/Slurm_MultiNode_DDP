#!/bin/bash

####################################################################################################################################
##Custom Your parameter
####################################################################################################################################
ORIGINAL_SH=./original.sh   # The real script slurm will submit                     
DIR=${YOUR PATH}            # The Dir put your output file and above script files
#######################################################DIRECTORY#####################################################################
cd ${DIR}
if [ -d ./OUT ] && [ -d ./SH ];# check your directory
then
mkdir OUT SH
fi
EACH_NODE_SH=${DIR}/SH # EACH_NODE will make their own shell file
SLURM_OUT_DIR=${DIR}/OUT  # OUTPUT dir

JOB_NAME=Example
MASTER_PORT=$((12000 + $RANDOM % 20000))                                                                                          
MASTER_NODE="YOUR MATER NODE"                                                                
GPU_PER_NODE=8                                                                                                        
NODES=2                                                                    
NODE_LIST=("YOUR MASTER NODE" "THE REST NODE")
#The First node name must be Master node name
                                                                
####################################################################################################################################
####################################################################################################################################



echo -e "## SHOW NODES  : ${NODE_LIST[@]}"
echo -e "## MASTER NODE : ${NODE_LIST[0]}\n"

# Check Validation
if [ ${#NODE_LIST[@]} -ne $NODES ] 
then 
    echo -e "ERROR: Node number ($NODES) not match Node list(${#NODE_LIST[@]})\n"
    exit 100
fi
if [ ${NODE_LIST[0]} != $MASTER_NODE ]
then 
    echo -e "ERROR: MASTER Node is ($MASTER_NODE) not match Node list(${NODE_LIST[0]})\n"
    exit 100
fi


NODE_RANK=0  # don't modify this.

for node in ${NODE_LIST[@]}
do
    cp -i $ORIGINAL_SH $EACH_NODE_SH/$node.sh  
    # Copy from origin sh file form.  
    # So, you can just use ORIGINAL_SH
    echo -e "Make $node script\n"
    #Following is sbatch command, where the command is set above
    if [ ${node} == $MASTER_NODE ]#To mark that this job is master node's
    then
        sbatch -w $node \
        -J $JOB_NAME \
        --gres=gpu:$GPU_PER_NODE \
        --out $SLURM_OUT_DIR/%j_master.out \
        --error $SLURM_OUT_DIR/%j_master.err \
        $EACH_NODE_SH/$node.sh \
        ${MASTER_NODE} ${NODE_RANK} ${MASTER_PORT} ${SLURM_OUT_DIR} ${NODES} ${GPU_PER_NODE}

    else
        sbatch -w $node \
        -J $JOB_NAME \
        --gres=gpu:$GPU_PER_NODE \
        --out $SLURM_OUT_DIR/%j.out \
        --error $SLURM_OUT_DIR/%j.err \
        $EACH_NODE_SH/$node.sh \
        ${MASTER_NODE} ${NODE_RANK} ${MASTER_PORT} ${SLURM_OUT_DIR} ${NODES} ${GPU_PER_NODE}
    fi
        sleep 0.5s
        echo -e "\n"
        let NODE_RANK+=1
done

# Feedback your Job status
for ((num=0 ; num < 5 ; num++))
do 
    squeue -u $USER
    echo -e "\n\n"
    sleep 1s
done
slurm-gres-viz -i



