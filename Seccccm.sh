#!/bin/bash

# Función para multiplicar
multiplicar() {
    echo "Resultado de multiplicación: $(( $1 * $2 ))"
}

# Función para dividir
dividir() {
    if [ $2 -eq 0 ]; then
        echo "Error: división por cero"
    else
        echo "Resultado de división: $(( $1 / $2 ))"
    fi
}

# Verificar que se pasaron 2 parámetros
if [ $# -ne 2 ]; then
    echo "Uso: $0 <número1> <número2>"
    exit 1
fi

multiplicar $1 $2
dividir $1 $2
