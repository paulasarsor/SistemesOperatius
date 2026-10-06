# Sistemes Operatius: laboratorios y problemas

Soluciones a los laboratorios y problemas de la asignatura de Sistemas Operativos: scripts de shell (bash) y programas en C con procesos, tuberías y señales.

## Estructura

```
.
├── labs/
│   ├── lab1/        # Programación básica de scripts (4 ejercicios)
│   ├── lab2/        # Manipulación de ficheros y procesos (6 ejercicios)
│   └── lab3/        # Dilema del prisionero con fork, pipes y señales (C)
├── problemes/
│   ├── TP2/         # Suma de bytes de un directorio y suma de columnas con awk
│   ├── TP3/         # Contar archivos por directorio (con regexp opcional)
│   └── TP4/         # Palabra más larga de un fichero
├── tests/
│   └── run_tests.sh # Pruebas rápidas de todos los scripts
└── .gitignore
```

## Requisitos

- Linux (o macOS con bash 4+; los scripts usan `[[ ]]` y `${var^^}`)
- `gcc` y `make` para el lab3

## Scripts de shell

Todos se ejecutan desde la carpeta del ejercicio:

| Script | Uso | Qué hace |
|---|---|---|
| `lab1/ejercicio1.sh` | `<archivo1> <archivo2>` | Muestra los tamaños, concatena en `concatenados.txt` y muestra el nuevo tamaño |
| `lab1/ejercicio2.sh` | `<archivo> <permisos_octales>` | Muestra los permisos antes y después de un `chmod` |
| `lab1/ejercicio3.sh` | `<número>` | Tabla de multiplicar del 1 al 10 |
| `lab1/ejercicio4.sh` | `<cadena>` | Longitud y mayúsculas de la cadena (rechaza números) |
| `lab2/ejercicio1.sh` | `<archivo_log>` | Cuenta líneas `ERROR` y `WARNING` (ejemplo: `archivo_log.txt`) |
| `lab2/ejercicio2.sh` | `<directorio>` | Cuenta archivos y directorios (recursivo) |
| `lab2/ejercicio3.sh` | `<directorio> <patron> <reemplazo>` | Reemplaza texto dentro de todos los archivos (`sed -i`) |
| `lab2/ejercicio4.sh` | (interactivo) | Lista procesos por CPU y permite terminar uno o cambiar su prioridad |
| `lab2/ejercicio5.sh` | `<directorio>` | Reorganiza los archivos en subdirectorios por extensión |
| `lab2/ejercicio6.sh` | `<directorio> <busqueda> <reemplazo>` | Reemplaza texto en los nombres de archivo |
| `problemes/TP2/script.sh` | `<directorio>` | Suma los bytes de `ls -l` |
| `problemes/TP2/script_awk.sh` | `<fichero>` | Suma las dos columnas y cuenta en cuántas filas la primera es mayor |
| `problemes/TP3/grupo37.sh` | `<directorio> [regexp]` | Número de archivos por directorio |
| `problemes/TP4/script_ex2.sh` | `<fichero>` | Imprime fichero, longitud y palabra más larga |

**Atención:** `ejercicio3.sh`, `ejercicio5.sh` y `ejercicio6.sh` modifican archivos de verdad. Pruébalos sobre una copia.

## Lab 3: dilema del prisionero (C)

Simulación del dilema del prisionero iterado. El proceso padre actúa como árbitro y crea dos procesos hijo (los presos). Se comunican mediante dos tuberías sin nombre, y el padre indica el inicio de cada turno con la señal `SIGUSR1`.

Hay dos versiones:

- `practica3.c`: el hijo espera la señal con un bucle activo sobre una variable `volatile sig_atomic_t`.
- `practica3_sigsuspend.c`: el hijo espera con `sigsuspend`, sin gastar CPU.

```bash
cd labs/lab3
make                                  # compila las dos versiones
./practica3 pagos.csv <estr1> <estr2> <N>
make demo                             # ejemplo: tit-for-tat vs siempre traiciona, 5 turnos
```

Estrategias:

| Id | Estrategia |
|---|---|
| 0 | Aleatoria |
| 1 | Siempre coopera |
| 2 | Siempre traiciona |
| 3 | Tit for tat (empieza cooperando y repite la jugada anterior del otro) |
| 4 | Grim trigger (coopera hasta la primera traición y después siempre traiciona) |

`pagos.csv` es la matriz de pagos, una fila por combinación: `opcion_pr1,opcion_pr2,pena_pr1,pena_pr2` (0 = coopera, 1 = traiciona).

## Pruebas

```bash
./tests/run_tests.sh
```

Ejecuta los scripts sobre un directorio temporal y compila y prueba el lab3, sin tocar nada del repositorio.

## Limitaciones conocidas

- Los scripts no soportan bien nombres de archivo o directorio con espacios (usan expansión sin comillas).
- `lab2/ejercicio3.sh` falla si el patrón o el reemplazo contienen `/` (es el delimitador de `sed`).
- `lab2/ejercicio5.sh` no distingue archivos con el mismo nombre en distintos subdirectorios: al moverlos a la carpeta de su extensión, uno sobrescribe al otro.
- `lab2/ejercicio6.sh` aplica el reemplazo a la ruta completa, no solo al nombre del archivo.
- `lab3`: las estrategias deben estar entre 0 y 4, y `pagos.csv` no debe tener líneas vacías ni más de 4 filas.

## Nota

El repositorio solo contiene código propio. No incluye los enunciados, los tutoriales ni el material proporcionado por el profesorado.
