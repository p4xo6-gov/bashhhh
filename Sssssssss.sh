#!/bin/bash

# Verificar si se proporcionó un parámetro
if [ $# -eq 0 ]; then
    echo "Uso: $0 <nombre_usuario>"
    exit 1
fi

# Buscar el usuario en /etc/passwd
if grep -q "^$1:" /etc/passwd; then
    echo "SI"
else
    echo "NO"
fi
