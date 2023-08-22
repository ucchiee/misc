#!/bin/bash

input=$1
llfile="${input}.ll"
echo "$input"

# .c -> .dot
clang -S -emit-llvm "$1" -O2 -o "$llfile"
opt -dot-cfg -disable-output -enable-new-pm=0 "$llfile" --cfg-dot-filename-prefix="$input"

# *.dot -> .png
find . -type f -name "${input}*.dot" -print0 | xargs -I {} -0 dot -Tpdf {} -o "$(basename {} ".dot")".pdf
