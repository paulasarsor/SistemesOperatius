#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <time.h>

#define PRESONER1_ID 1
#define PRESONER2_ID 2
#define NUM_OPCIONS 2
#define NUM_PAGAMENTS 4
#define MAX_LEN 100
#define COOPERA 0
#define TRAICIONA 1
#define COOPERA_DESCRIPCIO "coopera"
#define TRAICIONA_DESCRIPCIO "traiciona"
#define ESTRATEGIA_RANDOM 0
#define ESTRATEGIA_COOPERA 1
#define ESTRATEGIA_TRAICIONA 2
#define ESTRATEGIA_TIT_FOR_TAT 3
#define ESTRATEGIA_GRIM_TRIGGER 4

typedef struct {
      int opcio_pr1;
      int opcio_pr2;
      int pagament_pr1;
      int pagament_pr2;
} pagament;

//Variables globals de tipus sigset_t
sigset_t initial_mask;
sigset_t new_mask;

int llegir_pagaments(const char *filename, pagament *array, int max_size);
void signal_sigusr1();
void proceso_hijo(int, int, int, int);
void proceso_padre(int, int, int, int, pagament *, int);

int main(int argc, char *argv[]) {

      char *fitxer_pagaments;
      int estrategia_pr1, estrategia_pr2, N, pid1, pid2;
      pagament p_array[NUM_PAGAMENTS];

    // Llegir paràmetres
    if (argc != 5) {

        printf("%s <fitxer_pagaments> <estrategia_pr1> <estrategia_pr2> <N>\n", argv[0]);
        exit(1);
    }

        fitxer_pagaments = argv[1];
        estrategia_pr1 = atoi(argv[2]);
        estrategia_pr2 = atoi(argv[3]);
        N = atoi(argv[4]);

    if (N < 1) {

          printf("N no pot ser zero o negatiu!\n");
          exit(1);
    }

    // Llegir fitxer amb pagaments
    if (llegir_pagaments(fitxer_pagaments, p_array, NUM_PAGAMENTS) == -1) {

          printf("Error llegint el fitxer de pagaments!\n");
          exit(1);
    }

    
    //Creem dues canonades sense nom
    int pipe1[2], pipe2[2];
    pipe(pipe1);    //Pare escriu a fills
    pipe(pipe2);    //Fills escriuen al pare
    
    //Gestió de senyals: indiquem que quan es rep la senyal SIGUSR1 d'ha d'efectuar la funció signal_sigusr1
    signal( SIGUSR1, signal_sigusr1 );
    
   
    //Guardem la màscara inicial
    sigprocmask(SIG_BLOCK, NULL, &initial_mask);

    // Creem i configurem la nova màscara
    sigemptyset(&new_mask);
    sigaddset(&new_mask, SIGUSR1);

    // Apliquem la nova màscara de senyals que inclou SIGUSR1 (la senyal està bloquejada)
    sigprocmask(SIG_BLOCK, &new_mask, NULL);
    
    
    //Creem els fills i efectuem les funcions amb el codi dels fills i del pare
    pid1 = fork();
    if (pid1 == 0){
        proceso_hijo(estrategia_pr1,pipe1[0],pipe2[1], N);
    }
    pid2 = fork();
    if(pid2 == 0){
        proceso_hijo(estrategia_pr2,pipe1[0],pipe2[1], N);
    }
    
    proceso_padre(pid1,pid2,pipe2[0],pipe1[1], p_array, N);

    //Tanquem les canonades
    close(pipe1[0]);
    close(pipe1[1]);
    close(pipe2[0]);
    close(pipe2[1]);
    
    return 0;
}


int llegir_pagaments(const char *filename, pagament *array, int max_size) {
    
    FILE *fp;
    char line[MAX_LEN];
    char *token;
    int count = 0;

    fp = fopen(filename, "r");
    if (fp == NULL)
        return -1;
    

    while ( fgets(line, MAX_LEN, fp) != NULL && count < max_size ) {
        
        token = strtok(line, ",");
        array[count].opcio_pr1 = atoi(token);
        token = strtok(NULL, ",");
        array[count].opcio_pr2 = atoi(token);
        token = strtok(NULL, ",");
        array[count].pagament_pr1 = atoi(token);
        token = strtok(NULL, ",");
        array[count].pagament_pr2 = atoi(token);
        count++;
    }

    fclose(fp);
    return count;
}

//Funció que efectua la senyal
void signal_sigusr1() {
    return;
}

//Codi dels fills
void proceso_hijo(int estrategia, int llegir, int escriure, int N){
    
    int i, decisio, option, aux=0;
    
    //Inicialitza la llavor del generador de nombres aleatoris
    srand(getpid());
    
    //Bucle d'N iteracions
    for(i=0; i<N ; i++){
        
        //Espera a rebre la senyal SIGUSR1 y reestableix la màscara que bloqueja SIGUSR1
        sigsuspend(&initial_mask);
        sigprocmask(SIG_SETMASK, &new_mask, NULL);
        
        //Llegim des de pipe1 la decisió del torn anterior de l'altre presoner, proporcionada per el pare
        if(i > 0)   //en el primer torn no es pot llegir la decisió del torn anterior
            read(llegir, &decisio, sizeof(decisio));
        
        //Generem la decisió d'acord amb l'estrategia seleccionada per al presoner
        switch (estrategia) {
            
            //Es genera aleatoriament
            case ESTRATEGIA_RANDOM:
                option = rand()%2;
                break;
            
            //Sempre coopera
            case ESTRATEGIA_COOPERA:
                option = COOPERA;
                break;
            
            //Sempre traiciona
            case ESTRATEGIA_TRAICIONA:
                option = TRAICIONA;
                break;
                
            //Comença cooperant i després fa el mateix que l'altre presoner ha fet al torn anterior
            case ESTRATEGIA_TIT_FOR_TAT:
                if(i==0)
                    option = COOPERA;
                else
                    option = decisio;
                break;
            
            //Comença cooperant i continua cooperant fins que l'altre presoner traiciona una volta, aleshores sempre traiciona
            case ESTRATEGIA_GRIM_TRIGGER:
                if(i==0)
                    option = COOPERA;
                else if(decisio == COOPERA && aux==0){
                    option = COOPERA;
                }
                else{
                    aux=1;
                    option = TRAICIONA;
                }
                break;
            
            default:
                break;
        }
        
        //Es transmet l'opció generada al pare per la canonada pipe2
        write(escriure, &option, sizeof(option));
        
    }
    
    exit(0);
}

//Codi del pare
void proceso_padre( int pid1, int pid2, int llegir, int escriure, pagament *array, int N){
    
    int i,j, aux, jugada_pr1,jugada_pr2, pena_pr1=0, pena_pr2=0, acumulat_pr1=0, acumulat_pr2=0;
    
    //Desbloquegem SIGUSR1
    sigprocmask(SIG_SETMASK, &initial_mask, NULL);
      
    //Bucle d'N iteracions
    for( i=0; i<N; i++ ){
        
        printf("\nHa començat el torn %d\n",i+1);
        
        //Envia senyal SIGUSR1 d'inici de torn al presoner 1
        kill(pid1, SIGUSR1);
        
        //Escriu al presoner 1 la jugada del presoner 2 del torn anterior
        if(i>0)
            write(escriure, &jugada_pr2, sizeof(jugada_pr2));
        
        //Llegeix la jugada del presoner 1 d'aquest torn (primer guarda en aux la del anterior per poder enviar-la al presoner 2)
        if(i>0)
            aux = jugada_pr1;
          read(llegir, &jugada_pr1, sizeof(jugada_pr1));
        
        
        
        //Envia senyal SIGUSR1 d'inici de torn al presoner 2
        kill(pid2, SIGUSR1);
        
        //Escriu al presoner 2 la jugada del presoner 1 del torn anterior
        if(i>0)
            write(escriure, &aux, sizeof(aux));
        
        //Llegeix la jugada del presoner 2 d'aquest torn
        read(llegir, &jugada_pr2, sizeof(jugada_pr2));
        
        
        //S'utilitza la matriu de pagaments per determinar la quantitat d'anys de càstig que rep cada un
        for(j=0 ; j<NUM_PAGAMENTS ; j++){
            if(jugada_pr1==array[j].opcio_pr1 && jugada_pr2 ==array[j].opcio_pr2){
                pena_pr1 = array[j].pagament_pr1;
                pena_pr2 = array[j].pagament_pr2;
            }
        }
        
        //S'imprimeix per pantalla
        printf("Pena presoner 1: %d \nPena presoner 2: %d\n", pena_pr1, pena_pr2);
        
        //S'actualizen dues variables que guarden les penes acumulades dels dos presoners
        acumulat_pr1 += pena_pr1;
        acumulat_pr2 += pena_pr2;
    }
    
    //Imprimeix la informació sobre la pena total acumulada dels dos presoners
    printf("\nPena total presoner 1: %d \nPena total presoner 2: %d\n\n", acumulat_pr1, acumulat_pr2);
    
    return;
}
