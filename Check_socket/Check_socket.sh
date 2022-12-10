export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME=${YOUT SOCKET INTERFACE}
torchrun --nproc_per_node=$GPU_PER_NODE \
    --master_port 12345 --nnodes=$NNODES \
    --node_rank=$NODE_RANK --master_addr=$MASTER_NODE_IP \
    ./ddp.py 