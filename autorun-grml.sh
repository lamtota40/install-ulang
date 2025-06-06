#!/bin/bash

# Ambil waktu saat ini dalam format menit-detik
prefix=$(date +'%M-%S')
counter=1

# Cari nama file yang belum ada
while [[ -e "${prefix}-${counter}.txt" ]]; do
    ((counter++))
done

# Buat file baru dengan nama yang belum ada
touch "${prefix}-${counter}.txt"
