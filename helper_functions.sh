#!/bin/bash


get_block () {
    if [ $# -ne 1 ]; then
        echo "Usage: get_block <level|blockhash>"
        return 1
    fi
    T_INPUT=$1
    T_BLOCKDATA=$($CLIENT rpc get /chains/main/blocks/$T_INPUT)

    echo ${T_BLOCKDATA}
}

get_cycle_start_level () {
    if [ $# -ne 1 ]; then
        echo "Usage: get_current_cycle_start_level <level|blockhash>"
        return 1
    fi
    T_INPUT=$1
    T_CONSTANTS=$($CLIENT rpc get /chains/main/blocks/$T_INPUT/metadata)

    T_LEVELINFO_LEVEL=$(echo $T_CONSTANTS | jq .level_info.level)
    T_LEVELINFO_CYLEPOSITION=$(echo $T_CONSTANTS | jq .level_info.cycle_position)
    
    T_CYCLESTARTLEVEL=$(($T_LEVELINFO_LEVEL - $T_LEVELINFO_CYLEPOSITION)) 
    echo ${T_CYCLESTARTLEVEL}

}

get_balance_updates() {
    if [ $# -ne 2 ]; then
        echo "Usage: get_balance_updates <level|blockhash> <address>"
        return 1
    fi
    T_INPUT=$1
    T_ADDRESS=$2
    T_BLOCKDATA=$($CLIENT rpc get /chains/main/blocks/$T_INPUT)
    T_BALANCE_UPDATES=$(echo "$T_BLOCKDATA" | jq ".metadata.balance_updates[] | select(.staker.baker==\"$T_ADDRESS\" or .contract==\"$T_ADDRESS\")")

    echo ${T_BALANCE_UPDATES}
}

get_balance() {
    if [ $# -ne 2 ]; then
        echo "Usage: get_balance <level|blockhash> <address>"
        return 1
    fi
    T_INPUT=$1
    T_ADDRESS=$2
    T_BALANCE=$($CLIENT rpc get /chains/main/blocks/$T_INPUT/context/contracts/$T_ADDRESS/balance | sed 's/"//g')

    echo ${T_BALANCE}
}

get_unstaked_frozen_deposits() {
    if [ $# -ne 2 ]; then
        echo "Usage: get_unstaked_frozen_deposits <level|blockhash> <address>"
        return 1
    fi
    T_INPUT=$1
    T_ADDRESS=$2
    T_UNSTAKEDFROZENBALANCE=$($CLIENT rpc get /chains/main/blocks/$T_INPUT/context/delegates/$T_ADDRESS/unstaked_frozen_deposits)
    
    echo ${T_UNSTAKEDFROZENBALANCE}
}

get_minimal_block_time() {
    if [ $# -ne 1 ]; then
        echo "Usage: get_minimal_block_time <level|blockhash>"
        return 1
    fi
    T_INPUT=$1
    T_CONSTANTS=$($CLIENT rpc get /chains/main/blocks/$T_INPUT/context/constants)

    T_MINIMALBLOCKTIME=$(echo $T_CONSTANTS | jq .minimal_block_delay | sed 's/"//g')
    echo ${T_MINIMALBLOCKTIME}   
}

get_blocks_per_cycle () {
    if [ $# -ne 1 ]; then
        echo "Usage: get_blocks_per_cycle <level|blockhash>"
        return 1
    fi
    T_INPUT=$1
    T_CONSTANTS=$($CLIENT rpc get /chains/main/blocks/$T_INPUT/context/constants)

    T_BLOCKSPERCYCLE=$(echo $T_CONSTANTS | jq .blocks_per_cycle)
    echo ${T_BLOCKSPERCYCLE}
}

get_baker_balance () {
    if [ $# -ne 2 ]; then
        echo "Usage: get_baker_balance <level|blockhash> <baker>"
        return 1
    fi
    T_INPUT=$1
    T_BAKER=$2
    T_BAKERINFO=$($CLIENT rpc get /chains/main/blocks/$T_INPUT/context/delegates/$T_BAKER)
    echo ${T_BAKERINFO}
}

get_attestation_rights () {
    if [ $# -ne 2 ]; then
        echo "Usage: get_attestation_rights <level|blockhash> <baker>"
        return 1
    fi
    T_INPUT=$1
    T_BAKER=$2
    T_ATTESTATION_RIGHTS=$($CLIENT rpc get /chains/main/blocks/$T_INPUT/helpers/attestation_rights?delegate=$T_BAKER | jq ".[].delegates[].attestation_power" )
    echo ${T_ATTESTATION_RIGHTS}
}

get_current_level () {
    if [ $# -ne 0 ]; then
        echo "Usage: get_current_level"
        return 1
    fi
    T_CONSTANTS=$($CLIENT rpc get /chains/main/blocks/head/metadata)
    T_CURRENTLEVEL=$(echo $T_CONSTANTS | jq .level_info.level)
    echo ${T_CURRENTLEVEL}
}

get_cycle () {
    if [ $# -ne 1 ]; then
        echo "Usage: get_cycle <level|blockhash>"
        return 1
    fi
    T_INPUT=$1
    T_CONSTANTS=$($CLIENT rpc get /chains/main/blocks/$T_INPUT/metadata)
    T_CYCLE=$(echo $T_CONSTANTS | jq .level_info.cycle)
    echo ${T_CYCLE}
}

delegate () {
    if [ $# -ne 2 ]; then
        echo "Usage: delegate <delegator> <baker>"
        return 1
    fi
    T_DELEGATOR=$1
    T_BAKER=$2
    T_OUTPUT=$($CLIENT set delegate for $T_DELEGATOR to $T_BAKER)
    T_BLOCKHASH=$(echo "$T_OUTPUT" | grep "Operation found in block:" | awk '{print $5}')
    echo ${T_BLOCKHASH}
}
