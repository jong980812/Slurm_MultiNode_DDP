#!/bin/bash

####################################################################################################################################
##                                              수정해야할 부분.                                                                  ##                                                                                                             
##                                                                                                                                ##
####################################################################################################################################
ORIGINAL_SH=./original.sh#원본 스크립트. 여기서 arg수정해야함.                     
DIR=${YOUR PATH}                                           
#######################################################DIRECTORY#####################################################################
cd ${DIR}
if [ -d ./OUT ] && [ -d ./SH ];
then
mkdir OUT SH
fi
EACH_NODE_SH=${DIR}/SH
SLURM_OUT_DIR=${DIR}/OUT

JOB_NAME=Example
MASTER_PORT=$((12000 + $RANDOM % 20000))                                                                                          
MASTER_NODE=A                                                                                         
GPU_PER_NODE=8                                                                                                        
NODES=2
WORLD_SIZE=$GPU_PER_NODE*$NODES                                                                    
NODE_LIST=("A" "B")
                                                                
####################################################################################################################################
####################################################################################################################################



echo -e "## SHOW NODES  : ${NODE_LIST[@]}"
echo -e "## MASTER NODE : ${NODE_LIST[0]}\n"

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
NODE_RANK=0

for node in ${NODE_LIST[@]}
do
    cp -i $ORIGINAL_SH $EACH_NODE_SH/$node.sh    
    echo -e "Make $node script\n"
    if [ ${node} == $MASTER_NODE ]
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

for ((num=0 ; num < 5 ; num++))
do 
    squeue -u $USER
    echo -e "\n\n"
    sleep 1s
done
slurm-gres-viz -i



