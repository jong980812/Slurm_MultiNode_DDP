#!/bin/bash

####################################################################################################################################
##                                              수정해야할 부분.                                                                  ##                                                                                                             
##                                                                                                                                ##
####################################################################################################################################
ORIGINAL_SH=/data/jong980812/project/VideoMAE_experiments/multinode_sh/original.sh #원본 스크립트. 여기서 arg수정해야함.                     
DIR=/data/jong980812/project/VideoMAE_experiments/result/NEW/CROSS_freeze #복사될 위치.                                            
#######################################################DIRECTORY#####################################################################
cd ${DIR}
if [ -d ./OUT ] && [ -d ./SH ];
then
mkdir OUT SH
fi
EACH_NODE_SH=${DIR}/SH
SLURM_OUT_DIR=${DIR}/OUT

JOB_NAME=VideoMAE_Cross_Freeze
MASTER_PORT=$((12000 + $RANDOM % 20000))                                                                                          
MASTER_NODE=sw10                                                                                         
GPU_PER_NODE=8                                                                                                          
NODES=2
WORLD_SIZE=$GPU_PER_NODE*$NODES                                                                    
NODE_LIST=("sw10" "sw15")
                                                                
####################################################################################################################################
####################################################################################################################################



echo -e "## SHOW NODES  : ${NODE_LIST[@]}"
echo -e "## MASTER NODE : ${NODE_LIST[0]}\n"

if [ ${#NODE_LIST[@]} -ne $NODES ] # 노드길이 설정 잘못하면
then 
    echo -e "ERROR: Node number ($NODES) not match Node list(${#NODE_LIST[@]})\n"
    exit 100
fi
if [ ${NODE_LIST[0]} != $MASTER_NODE ] # 노드길이 설정 잘못하면
then 
    echo -e "ERROR: MASTER Node is ($MASTER_NODE) not match Node list(${NODE_LIST[0]})\n"
    exit 100
fi
NODE_RANK=0
#건들일 필요없음.
for node in ${NODE_LIST[@]}
do
    cp -i $ORIGINAL_SH $EACH_NODE_SH/$node.sh    
    echo -e "Make $node script\n"
    #Original SH를 EACHNODESH에 가서 
    #하나씩 노드별로 스크립트 폼 만들어줌.
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
        #위에서 만든 스크립트를, 특정 $node에, $GPUPER_BATCH에 맞게 올림. sh뒤에 노드 랭크 1씩 더해서 넣어줌. 0~ (L-1)
        #if 문은, master 노드에서만 output찍힐 수 있도록함.
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



