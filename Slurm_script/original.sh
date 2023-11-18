#!/bin/bash
#SBATCH -p batch 
#SBATCH --time
#SBATCH --cpus-per-gpu
#SBATCH --mem-per-gpu
#Add your sbatch parameter



export NCCL_SOCKET_IFNAME="YOUR SOCKET NAME"

# Argument sequence can be controled in master.sh
OUTPUT_DIR=$4 # weight저장.
MASTER_NODE=$1
OMP_NUM_THREADS=1 python -m torch.distributed.launch \
    --nproc_per_node=$6 \
    --master_port $3 --nnodes=$5 \
    --node_rank=$2 --master_addr=${MASTER_NODE} \
    Your python.py
    --python arguments..
    --.. \
    --.. \

