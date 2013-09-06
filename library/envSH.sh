#!/bin/bash

#This script adds these tools to the environment
[ -z $lbt_dir ] && lbt_dir="$(dirname "${BASH_SOURCE[0]}")/sh"
export PATH="$lbt_dir":$PATH
unset lbt_dir
