# Slurm Multi node script 
## Method
****
1. the [master.sh](master.sh) will make sh file each node and submit sh scripts to Slurm
2. First, if you make your own script(original.sh) and set DIR to "ORIGINAL_SH" in master.sh
3. At this time, original.sh have your DDP module such as "torchrun" or "torch.distributed.launch" 
4. you can input parameter into original.sh by using $1,$2.... (keep sequence)
5. In my case, I parameterize "torch.distributed.launch" paramter in master.sh. (MASTER_NDOE, master_port...etc)
6. It can be cutomed in your taste
****
If master.sh submit your scripts in your own N nodes.<br>
Each node's DDP module will handshakes each other ( like checking communication )


Check directly for watching code<br>
<br>
### Original.sh
```sh
#!/bin/bash
#--------------------------------------------
#Your Slurm fixed parameter that don't have to control master.sh   
#ex)--time, worker, cpu, partition...
#--------------------------------------------

export NCCL_SOCKET_IFNAME="YOUR SOCKET NAME" #Set your ifconfig surely


