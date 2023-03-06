#!/bin/bash
#SBATCH -p batch_ce_ugrad 
#SBATCH --cpus-per-gpu=16
#SBATCH --mem-per-gpu=30G
#SBATCH --time=3-00:00:0

#Add your sbatch parameter
export NCCL_SOCKET_IFNAME=enp34s0

OUTPUT_DIR=$4 # weight저장.
torchrun --nproc_per_node=$6 \
    --master_port $3 --nnodes=$5 \
    --node_rank=$2 --master_addr=$1 \
    /data/jong980812/project/Slurm_MultiNode_DDP/Check_socket/ddp.py

