# Slurm Multi-node Script

---

## Overview

This script automates the submission of multi-node jobs using Slurm. <br>[**master.sh**](master.sh) generates individual [**original.sh**](original.sh) for each node and submits them to the Slurm scheduler.

---

## Usage

1. Execute [master.sh](master.sh) to create a shell script for each node and submit them to Slurm.
2. Create your own script (e.g., [original.sh]) and set the `DIR` variable to "ORIGINAL_SH" in [master.sh].
3. Include your Distributed Data Parallel (DDP) module, such as "torchrun" or "torch.distributed.launch," in [original.sh].
4. Input parameters into [original.sh] using $1, $2, and so on, maintaining the sequence.
5. Customize the DDP parameters in [master.sh]. In this example, "torch.distributed.launch" parameters like `MASTER_NODE`, `MASTER_PORT`, etc., are parameterized.
6. Adapt the script according to your preferences.

---

Feel free to modify the design for better readability and clarity.

If master.sh submit your scripts in your own N nodes.<br>
Each node's DDP module will handshakes each other ( like checking communication )


## Be mindful of the following:

### master.sh

master.sh go to the $(DIR) directory and create OUT and SH folders. In the OUT folder, create $JOB_NAME.out and $JOB_NAME.err files. In the SH folder, copy $ORIGINAL_SH for each node.
```bash
JOB_NAME=My_multinode_job # Slurm Job name you want 
ORIGINAL_SH=./original.sh # Shell DIR you want to submit
DIR=./result/ # Set DIR of slurm .out, .err 
```
<br>

List the Node names mapped to the IP address of the server you are using. <br>
Set one of the nodes as MASTER_NODE and specify the number of GPUs to be used. <br>
In the example below, i use 4 nodes with 4 GPUs each, totaling 16 GPUs.

```bash
MASTER_NODE="cherry-y2"
NODE_LIST["cherry-y1"]=;         orders+=( "cherry-y1" )
NODE_LIST["cherry-y2"]=4;         orders+=( "cherry-y2" )
NODE_LIST["cherry-y3"]=4;        orders+=( "cherry-y3" )
NODE_LIST["cherry-y4"]=4;        orders+=( "cherry-y4" )
NODE_LIST["cherry-y5"]=4;        orders+=( "cherry-y5" )
NODE_LIST["cherry-y6"]=;        orders+=( "cherry-y6" )
NODE_LIST["cherry-y7"]=;         orders+=( "cherry-y7" )
```



You can rearrange the order of the arguments passed to original.sh here.

```bash
        sbatch -w $node \
        -J $JOB_NAME \
        --gres=gpu:$GPU_PER_NODE \
        --out $SLURM_OUT_DIR/%j_master_${JOB_NAME}.out \
        --error $SLURM_OUT_DIR/%j_master.err \
        $EACH_NODE_SH/$node.sh \
        ${MASTER_NODE} ${NODE_RANK} ${MASTER_PORT} ${SLURM_OUT_DIR} ${NODES} ${GPU_PER_NODE}
```

## original.sh
```sh
#!/bin/bash
#--------------------------------------------
#Your Slurm fixed parameter that don't have to control master.sh   
#ex)--time, worker, cpu, partition...
#--------------------------------------------

export NCCL_SOCKET_IFNAME="YOUR SOCKET NAME" #Set your ifconfig surely


