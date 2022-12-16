#!/bin/bash
#SBATCH -p batch 



export NCCL_SOCKET_IFNAME=enp28s0f1


OUTPUT_DIR=$4 # weight저장.
MASTER_NODE=$1
OMP_NUM_THREADS=1 python -m torch.distributed.launch \
    --nproc_per_node=$6 \
    --master_port $3 --nnodes=$5 \
    --node_rank=$2 --master_addr=${MASTER_NODE} \
    Your python.py

# if [ ${SLURM_NODELIST} == $1 ]
# then
#     echo "" > /data/jong980812/project/VideoMAE_experiments/results.txt
#     today="###Date: `date +%D` Time: `date +%T`###"
#     train_time=`tail -1  $OUTPUT_DIR/log.txt`
#     echo -e "${today} $5 Node $6 GPU ${train_time} OUTPUT: $OUTPUT_DIR"
# fi