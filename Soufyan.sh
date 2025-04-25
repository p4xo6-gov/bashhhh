#!/bin/bash

contador=0

for archivo in *; do
    if [ -w "$archivo" ]; then
        ((contador++))
    fi
done

echo "Número de ficheros con permiso de escritura: $contador"
