#!/usr/bin/env bash

export FACTER_pwd
FACTER_pwd=$(pwd)
export FACTER_group_name=dm

ENVS=(
  jhoblitt-larry
  jhoblitt-moe
  jhoblitt-curly
  prod
)

for e in "${ENVS[@]}"; do
  export FACTER_env_name="${e}"
  bundle exec puppet apply --modulepath="$(pwd)/modules" --hiera_config=./hiera.yaml ./casc.pp
done
