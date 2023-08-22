#!/bin/bash

input=$1
llfile="$(basename "${input}" ".c").ll"
echo "$input"

# .c -> .dot
clang -S -emit-llvm "$1" -o "$llfile"
opt -dot-cfg -disable-output -enable-new-pm=0 "$llfile" --cfg-dot-filename-prefix="$input"

# *.dot -> .png
find . -type f -name "${input}*.dot" -print0 | xargs -I {} -0 dot -Tpng {} -o "$(basename {} ".dot")".png
