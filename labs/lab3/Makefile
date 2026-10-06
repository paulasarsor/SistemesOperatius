CC     = gcc
CFLAGS = -Wall -Wextra -O2

all: practica3 practica3_sigsuspend

practica3: practica3.c
	$(CC) $(CFLAGS) $< -o $@

practica3_sigsuspend: practica3_sigsuspend.c
	$(CC) $(CFLAGS) $< -o $@

# Ejemplo: tit-for-tat contra "siempre traiciona" durante 5 turnos
demo: all
	./practica3 pagos.csv 3 2 5

clean:
	rm -f practica3 practica3_sigsuspend

.PHONY: all demo clean
