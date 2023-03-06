#!/bin/bash

####################################################################################################################################
JOB_NAME=Example
ORIGINAL_SH=/data/jong980812/project/Slurm_MultiNode_DDP/New_version/origin.sh   # The real script slurm will submit                     
DIR=/data/jong980812/project/Slurm_MultiNode_DDP/log #${YOUR PATH}            # The Dir put your output file and above script files
#######################################################DIRECTORY#####################################################################
cd ${DIR}

EACH_NODE_SH=${DIR}/SH # EACH_NODE will make their own shell file
SLURM_OUT_DIR=${DIR}/OUT  # OUTPUT dir
MASTER_PORT=$((12000 + $RANDOM % 20000)) 

############YOUT GPUS################
declare -A NODE_LIST    
declare -a orders;
# 0 GPU is Empty
# Orders list needs to be keep order sequene
NODE_LIST["moana-y1"]=;         orders+=( "moana-y1" )
NODE_LIST["moana-y2"]=;         orders+=( "moana-y2" )
NODE_LIST["moana-y3"]=;         orders+=( "moana-y3" )
NODE_LIST["moana-y4"]=;         orders+=( "moana-y4" )
NODE_LIST["moana-y5"]=1;        orders+=( "moana-y5" )
NODE_LIST["moana-y6"]=1;        orders+=( "moana-y6" )
NODE_LIST["moana-y7"]=2;        orders+=( "moana-y7" )
#############Get MASTERNODE#########
NODES=0
ALL_GPUS=0
for i in "${!orders[@]}"
do
    if [[ "${NODE_LIST[${orders[$i]}]}" != "" ]] # The First not None Node is master node.
    then
        MASTER_NODE=${orders[$i]}
    break
  fi
done
for i in "${!orders[@]}"
do
    if [[ "${NODE_LIST[${orders[$i]}]}" != "" ]] # The First not None Node is master node.
    then
        let ALL_GPUS+=${NODE_LIST[${orders[$i]}]}
        ((NODES++))
    else
        :
    fi
done
echo -e "\033[2m====================\033[0m\033[1m\033[3m\033[46mJOB Information\033[0m\033[2m====================\033[0m"
echo -e "\033[33m\033[3mJOB NAME\033[0m:${JOB_NAME}" 
echo -e "   \033[33m\033[3mNODES\033[0m:${NODES}" 
echo -e "     \033[33m\033[3mDIR\033[0m:${DIR}" 
echo -e "\033[33m\033[3mALL GPUS\033[0m:${ALL_GPUS}" 
echo -e "\033[2m\033[1m=======================================================\033[0m"
echo ""

echo -e "\033[2m====================\033[0m\033[1m\033[3m\033[42mGPUS Information\033[0m\033[2m====================\033[0m"
color_code=0 #Random Color
for i in "${!orders[@]}"
do
    gpu_color=$((31 + color_code % 6))
    if [[ "${NODE_LIST[${orders[$i]}]}" == "" ]]
    then 
        NODE_LIST["${orders[$i]}"]=0     #Convert Non to zero
    fi
    if [[ ${orders[$i]} == $MASTER_NODE ]]
    then 
        echo -e -n "\033[41m${orders[$i]}\033[0m:"
    else
        echo -e -n "${orders[$i]}:"
    fi
    for (( j=1; j<=${NODE_LIST[${orders[$i]}]}; j++ ))
    do
        printf "\033[${gpu_color}m[$j]\033[0m"
    done
    printf "\n"
    ((color_code++)) #Next seed color code.
done
echo -e "\033[2m\033[1m========================================================\033[0m"



                                                                
####################################################################################################################################




echo -e "\033[2m\033[1m========================================================\033[0m"
echo -e "\033[3mDo you want to continue? \033[41m(y/n)\033[0m"
echo -n "Answer: "
read answer
if [[ "$answer" == "n" || "$answer" == "N" || "$answer" == "ㅜ" ]]; then
  echo "You chose to stop."
  exit 0
fi
# Continue with the program
echo "You chose to continue."

if [ -d ./OUT ] && [ -d ./SH ]; #check your directory
then
    echo -e "\033[47mAlready OUT,SH folder\033[0m"
    mv $(find . -name "*.time") 20$(date +%y_%m_%d__\(%H:%M\)).time #Change New time
else
    echo -e "\033[46mNEW OUT,SH folder\033[0m"
    mkdir OUT SH 20$(date +%y_%m_%d__\(%H:%M\)).time #Time recording
fi
echo "";echo ""
NODE_RANK=0  # Don't modify this.

for i in "${!orders[@]}"
do
    node=${orders[$i]}
    GPU_PER_NODE=${NODE_LIST[${orders[$i]}]}
    if [[ $GPU_PER_NODE -eq 0 ]]
    then 
        continue
    fi
    cp -i $ORIGINAL_SH $EACH_NODE_SH/$node.sh  
    # Copy from origin sh file form.  
    # So, you can just use ORIGINAL_SH
    echo -e "Make \033[36m\033[1m$node\033[0m script\n"
    #Following is sbatch command, where the command is set above
    if [ ${node} == $MASTER_NODE ] #To mark that this job is master node's 
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
        echo -e "\n"
        let NODE_RANK+=1
done

# Feedback your Job status
for ((num=0 ; num < 5 ; num++))
do 
    squeue -u $USER
    echo -e "\n\n"
    sleep 0.5s
done
slurm-gres-viz -i -m



