# Check Socket
This helps you to check the gpus can communicate each other
****

## Nodes communicate with Socket
If your Cluster have 8 Node, You want to use 2 Node (3, 7) 8GPU.<br>
'*' is GPU

NODE3: ********  
NODE7: ********<br>

The Master Node is &#60;NODE3 IP address&#62; (Usually, NODE name is NODE IP)<br>
nnodes=2<br>
master_addr=NODE3<br>
master_port=12345<br>
nproc_per_node=&#60;GPU per NODE>
****
Each NODE havs their own **node_rank** (0,1,2...), Job script<br> Example is below


### Own Node Jop script
1. Make SH file or Directly Run you terminal
2. 
    ```
    export NCCL_DEBUG=INFO 
    ```
    >Display NCCL Debuggin log
3. 
   ```
   export NCCL_SOCKET_IFNAME=${your socket interface name}
   ```
4.  NODE1
    ```
    torchrun --nproc_per_node=8 \
    --master_port 12345 --nnodes=2 \
    --node_rank=0 --master_addr=NODE1 \
    ./ddp.py 
    ```
    NODE2
    ```
    torchrun --nproc_per_node=8 \
    --master_port 12345 --nnodes=2 \
    --node_rank=1 --master_addr=NODE1 \
    ./ddp.py
    ```
    >"torch run" or "torch.distributed.launch"
5. In your Terminal, Exe each script in their node
   >Before run script, Chceck your Node can catch GPU for imort torch;torch.cuda.is_availabale()
6. If you see the Message "Send" and "Received" each GPUS<br>you can conclude that your cluster can communicate NODEs well.
