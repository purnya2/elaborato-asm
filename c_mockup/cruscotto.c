#include <stdio.h>
#include <string.h>


char *strings[8][2]={
                        {"Setting Automobile:",         ""              }, 
                        {"Data:",                       "15/06/2014"    }, 
                        {"Ora:",                        "15:32"         }, 
                        {"Blocco automatico porte:",    "ON"            }, 
                        {"Back-home:",                  "ON"            }, 
                        {"Check olio",                  ""              }, 
                        {"Freccie direzione",           ""             }, 
                        {"Reset pressione gomme",       ""              }, 
                    };

char *options [2]= {"ON", "OFF"};

char inputbuffer[100];

              
int main() {
    int selection = 0;
    int subselection = 0;
    int pressed = 0;
    int selmax = 8;


    do {

        printf("\e[1;1H\e[2J"); // codice speciale che elimina i contenuti dello schermo a ogni loop

        // se premuto
        if(!pressed){
            // visualizzo la lista principale
            for (int i = 0; i<selmax; i++){
                if(i == selection){
                    printf("\033[31;1;4m[%d]\033[0m ", i+1);
                } else{
                    printf("[%d] ", i+1);

                }
                printf("%s", strings[i][0]);
                printf(" %s\n", strings[i][1]);

            }
        } else {
            printf("%s\n", strings[selection][0]);

            // ON-OFF
            if(selection == 4-1 || selection == 5-1){
                for (int i = 0; i< 2; i++){
                    if(i == subselection){
                        printf("\033[31;1;4m[%d]\033[0m ", i+1);
                    } else{
                        printf("[%d] ", i+1);
                    }
                    printf("%s\n", options[i]);
                }
            }

            // Frecce direzione
            int 
            if(selection == 7-1){
                scanf
            }
        }

        // prendo il carattere necessario
        fgets(inputbuffer, 100, stdin);


        // modifico la selezione in base al valore di c
        if(!pressed){

            switch(inputbuffer[2]) {
                case 65: // Up arrow
                    selection -= 1;
                    break;
                case 66: // Down arrow
                    selection += 1;
                    break;
                case 67: // Right arrow
                    pressed = 1;
            }

        } else {

            switch(inputbuffer[2]) {
                case 65: // Up arrow
                    subselection -= 1;
                    break;
                case 66: // Down arrow
                    subselection += 1;
                    break;
            }
            
        }
        

        // loop della selezione su e giu
        if (selection < 1-1) {
            selection = 6-1;
        } else if (selection > 6-1) {
            selection = 1-1;
        }

        if (subselection < 1-1) {
            subselection = 2-1;
        } else if (subselection > 2-1) {
            subselection = 1-1;
        }

        // conferma selezione
        if(inputbuffer[0]==10 && pressed){
            pressed = 0;

            // se stiamo settando gli ON e OFF
            if(selection == 4-1 || selection == 5-1){
                strings[selection][1] = options[subselection];
            }

            subselection = 0;
        }

        for(size_t i=0; i < sizeof inputbuffer; ++i){
            inputbuffer[i] = 0;
        }

    } while(1);

    return 0;
}
