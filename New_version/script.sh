#!/bin/bash
declare -A NODE_LIST    
declare -a orders;
# 0 GPU is Empty
# Orders list needs to be keep order sequene
NODE_LIST["moana-y1"]=;         orders+=( "moana-y1" )
NODE_LIST["moana-y2"]=;         orders+=( "moana-y2" )
NODE_LIST["moana-y3"]=;        orders+=( "moana-y3" )
NODE_LIST["moana-y4"]=;         orders+=( "moana-y4" )
NODE_LIST["moana-y5"]=1;         orders+=( "moana-y5" )
NODE_LIST["moana-y6"]=2;        orders+=( "moana-y6" )
NODE_LIST["moana-y7"]=2;        orders+=( "moana-y7" )
for i in "${!orders[@]}"
do
    node="${orders[$i]}"
    GPU_PER_NODE=${NODE_LIST[${orders[$i]}]}
    if [[ $GPU_PER_NODE -eq 0 ]]
    then 
        continue
    fi
    echo "$node $GPU_PER_NODE"
done