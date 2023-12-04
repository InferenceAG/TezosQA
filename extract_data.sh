#!/bin/bash

# Note:
# - baker's values for current_frozen_deposits, frozen_deposits, and staking_balance are the same at cyle start and cycle end of previous cycle.

source helper_functions.sh

export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y
CLIENT="./tezos/octez-client -d ./"
BAKER="tz1SpCandJN3VJWPZjYB99aMTFaMYPh8QTJN"
OUTPUTFILE="file_$(date +'%Y%m%d_%H%M%S').txt"

DELEGATIONLEVEL=6783
UNDELEGATIONLEVEL=13400

BLOCKSPERCYCLE=$(get_blocks_per_cycle $DELEGATIONLEVEL)

CYCLESTART=$(get_cycle_start_level "$DELEGATIONLEVEL")
CYCLEEND=$(($CYCLESTART + $BLOCKSPERCYCLE - 1))

append_to_file() {
  local file="$1"
  local data="$2"

  # Check if the file exists
  if [ -e "$file" ]; then
    # Append data to the file
    echo "$data" >> "$file"
  else
    echo "Error: File $file does not exist."
    exit 1
  fi
}
get_header () {
  G_OUTPUT=$(append_to_comma_string "blocklevel" "cycle")
  G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "balance")
  G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "full_balance")
  G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "current_frozen_deposits")
  G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "frozen_deposits")
  G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "staking_balance")
  G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "delegated_balance")
  G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "attestation_power")
  G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "unstaked_frozen_deposits")
  G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "balance_updates")
  echo $G_OUTPUT
}

append_to_comma_string() {
  local string="$1"
  local value="$2"

  echo "$string;$value" 
}

get_data () {
    if [ $# -ne 1 ]; then
        echo "Usage: get_data <level>"
        return 1
    fi
    T_LEVEL=$1
    T_BAKER_BALANCE=$(get_baker_balance $T_LEVEL $BAKER)

    TEMP=$(get_cycle $T_LEVEL)
    G_OUTPUT=$(append_to_comma_string "$T_LEVEL" $TEMP)   

    T_BALANCE=$(get_balance $T_LEVEL $BAKER)
    G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "$T_BALANCE")
    
    TEMP=$(echo $T_BAKER_BALANCE | jq ".full_balance" | sed 's/"//g')
    G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" $TEMP)

    TEMP=$(echo $T_BAKER_BALANCE | jq ".current_frozen_deposits" | sed 's/"//g')
    G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" $TEMP)

    TEMP=$(echo $T_BAKER_BALANCE | jq ".frozen_deposits" | sed 's/"//g')
    G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" $TEMP)

    TEMP=$(echo $T_BAKER_BALANCE | jq ".staking_balance" | sed 's/"//g')
    G_OUTPUT=$(append_to_comma_string $G_OUTPUT $TEMP)

    TEMP=$(echo $T_BAKER_BALANCE | jq ".delegated_balance" | sed 's/"//g')
    G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" $TEMP)

    T_ATTESTATION_POWER=$(get_attestation_rights $T_LEVEL $BAKER)
    G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "$T_ATTESTATION_POWER")

    T_UNSTAKED_FROZEN_DEPOSITS=$(get_unstaked_frozen_deposits $T_LEVEL $BAKER)
    G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "$T_UNSTAKED_FROZEN_DEPOSITS")

    T_BALANCE_UPDATES=$(get_balance_updates $T_LEVEL $BAKER )
    G_OUTPUT=$(append_to_comma_string "$G_OUTPUT" "$T_BALANCE_UPDATES")

    echo $G_OUTPUT
}

get_header > $OUTPUTFILE


UNDELEGATION_CYCLESTART=$(get_cycle_start_level "$UNDELEGATIONLEVEL")
STOP=$(($UNDELEGATION_CYCLESTART + (10 *  $BLOCKSPERCYCLE) ))
while [ $CYCLESTART -le $STOP ]
do
    echo $CYCLESTART
    OUT=$(get_data $(($CYCLESTART - 2)))
    append_to_file $OUTPUTFILE "$OUT"

    OUT=$(get_data $(($CYCLESTART - 1)))
    append_to_file $OUTPUTFILE "$OUT"

    OUT=$(get_data $(($CYCLESTART)))
    append_to_file $OUTPUTFILE "$OUT"
    
    CYCLESTART=$(($CYCLESTART + $BLOCKSPERCYCLE ))
done   


