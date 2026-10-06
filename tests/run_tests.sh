#!/bin/bash
# Pruebas rápidas de los scripts del repositorio.
# Uso (desde la raíz del repo): ./tests/run_tests.sh
# Trabaja siempre en un directorio temporal: no modifica nada del repo.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

ok=0
fail=0

# check <descripción> <esperado> <obtenido>
check() {
    if [ "$2" == "$3" ]; then
        ok=$((ok + 1))
        echo "  OK    $1"
    else
        fail=$((fail + 1))
        echo "  FALLA $1 (esperado: '$2', obtenido: '$3')"
    fi
}

# rc <comando...>: devuelve el código de salida sin mostrar la salida
rc() { "$@" >/dev/null 2>&1; echo $?; }

cd "$TMP" || exit 1

echo "== lab1"
echo "hola" > a.txt; echo "mundo!!" > b.txt
out=$("$ROOT/labs/lab1/ejercicio1.sh" a.txt b.txt)
check "ejercicio1: tamaño concatenado" "Tamaño del archivo concatenado: 13 bytes" "$(echo "$out" | tail -1)"
check "ejercicio1: faltan argumentos" "1" "$(rc "$ROOT/labs/lab1/ejercicio1.sh" a.txt)"
"$ROOT/labs/lab1/ejercicio2.sh" a.txt 640 >/dev/null
check "ejercicio2: chmod 640" "-rw-r-----" "$(ls -l a.txt | awk '{print $1}')"
check "ejercicio2: permisos inválidos" "1" "$(rc "$ROOT/labs/lab1/ejercicio2.sh" a.txt 999)"
check "ejercicio2: archivo inexistente" "1" "$(rc "$ROOT/labs/lab1/ejercicio2.sh" nope 644)"
check "ejercicio3: 7 x 10" "7 x 10 = 70" "$("$ROOT/labs/lab1/ejercicio3.sh" 7 | tail -1)"
check "ejercicio4: mayúsculas" "Cadena en mayúsculas: HOLA" "$("$ROOT/labs/lab1/ejercicio4.sh" hola | tail -1)"
check "ejercicio4: rechaza números" "1" "$(rc "$ROOT/labs/lab1/ejercicio4.sh" 123)"

echo "== lab2"
out=$("$ROOT/labs/lab2/ejercicio1.sh" "$ROOT/labs/lab2/archivo_log.txt")
check "ejercicio1: errores y avisos" "21 18" "$(echo "$out" | grep -o '[0-9]*$' | tr '\n' ' ' | sed 's/ $//')"
mkdir -p d/sub; echo foo > d/x.txt; echo foo > d/sub/y.log
check "ejercicio2: archivos" "Cantidad de archivos: 2" "$("$ROOT/labs/lab2/ejercicio2.sh" d | head -1)"
"$ROOT/labs/lab2/ejercicio3.sh" d foo BAR >/dev/null
check "ejercicio3: reemplazo en contenido" "BAR" "$(cat d/x.txt)"

mkdir -p e5/sub1/deep e5/sub2
echo 1 > e5/a.txt; echo 2 > e5/sub1/b.txt; echo 3 > e5/sub1/deep/c.log; echo 4 > e5/Makefile
"$ROOT/labs/lab2/ejercicio5.sh" e5 >/dev/null 2>&1
check "ejercicio5: clasifica por extensión" \
      "e5/log/c.log e5/sin_extension/Makefile e5/txt/a.txt e5/txt/b.txt" \
      "$(find e5 -type f | sort | tr '\n' ' ' | sed 's/ $//')"
check "ejercicio5: borra directorios vacíos" "" "$(find e5 -type d -empty)"
check "ejercicio5: sin subdirectorios originales" "0" "$(find e5 -type d \( -name sub1 -o -name sub2 -o -name deep \) | wc -l | tr -d ' ')"

mkdir -p e6/s; touch e6/foo1.txt e6/s/foo2.txt
"$ROOT/labs/lab2/ejercicio6.sh" e6 foo baz >/dev/null
check "ejercicio6: renombra archivos" "e6/baz1.txt e6/s/baz2.txt" "$(find e6 -type f | sort | tr '\n' ' ' | sed 's/ $//')"

echo "== problemes"
mkdir -p dd/sub; echo aaaa > dd/f1; echo bbbbbbbb > dd/sub/f2
esperado=$(ls -l dd | awk 'NR>1{s+=$5} END{print s}')
check "TP2/script.sh: suma de bytes" "$esperado" "$("$ROOT/problemes/TP2/script.sh" dd)"
check "TP2/script_awk.sh: sumas" "22 24" "$("$ROOT/problemes/TP2/script_awk.sh" "$ROOT/problemes/TP2/awk-text.txt" | head -1)"
check "TP3: cuenta archivos" "directorio: dd nfiles: 2" "$("$ROOT/problemes/TP3/grupo37.sh" dd | head -1)"
echo "unas palabras largas elefante" > w.txt
check "TP4: palabra más larga" "w.txt 8 palabras" "$("$ROOT/problemes/TP4/script_ex2.sh" w.txt)"

echo "== lab3 (necesita gcc)"
if command -v gcc >/dev/null; then
    gcc -O2 -o p3 "$ROOT/labs/lab3/practica3.c" 2>/dev/null
    gcc -O2 -o p3s "$ROOT/labs/lab3/practica3_sigsuspend.c" 2>/dev/null
    for b in p3 p3s; do
        out=$(timeout 10 ./$b "$ROOT/labs/lab3/pagos.csv" 3 2 3 | awk '/Pena total/{printf "%s ", $NF}')
        check "$b: tit-for-tat vs traiciona (N=3)" "7 4 " "$out"
        out=$(timeout 10 ./$b "$ROOT/labs/lab3/pagos.csv" 1 1 4 | awk '/Pena total/{printf "%s ", $NF}')
        check "$b: coopera vs coopera (N=4)" "4 4 " "$out"
    done
else
    echo "  (gcc no encontrado, se omite)"
fi

echo
echo "Resultado: $ok correctas, $fail fallidas"
[ "$fail" -eq 0 ]
