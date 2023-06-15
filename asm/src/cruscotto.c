#include <stdio.h>
#include <string.h>
#include <time.h>


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

void onoffmenu(int selection){

    int exitloop=0;

    printf("%s\n", strings[selection][0]);
    printf("premi freccia su + invio per selezionare ON\n");
    printf("premi freccia su + invio per selezionare OFF\n");
    
    while(!exitloop){
    
        fgets(inputbuffer, 100, stdin);

        switch(inputbuffer[2]) {
        
                case 65: // Up arrow
                    strings[selection][1] = options[0];
                    exitloop=1;
                                       
                    break;
                    
                case 66: // Down arrow
                    strings[selection][1] = options[1];
                    exitloop=1;

                    break;
            }

        for(size_t i=0; i < sizeof inputbuffer; ++i){
            inputbuffer[i] = 0;
        }

    }
    
}
     
              
int main(int argc, char **argv) {

    int selection = 0;
    int subselection = 0;
    int pressed = 0;
    int selmax;
    int numlampeggi = 3;



    if (argc > 1){
        if (strcmp(argv[1],"2244") == 0){
            selmax = 8;
        } else {
            selmax = 6;
        }
    } else {
        selmax = 6;
    }


    do {
        int skip = 0;

        printf("\e[1;1H\e[2J"); // Special code that clears the screen at every cicle

        if(!pressed){
           
            // Print the menu
            for (int i = 0; i<selmax; i++){

                if(i == selection){
                    printf("[o] ");
                } else{
                    printf("[ ] ");

                }
                printf("%s", strings[i][0]);
                printf(" %s\n", strings[i][1]);

            }
        } else {
            

            // ON-OFF
            if(selection == 4-1 || selection == 5-1){

                onoffmenu(selection);
                skip = 1;
                pressed = 0;
            }
            
            printf("%s\n", strings[selection][0]);
            
            // "Frecce direzione"
            int inputfrecce;
            if(selection == 7-1){
                printf("\nNumero dei lampeggi : %d \n Inserire nuovo valore : ", numlampeggi);
                scanf("%d", &inputfrecce);

                if (inputfrecce < 2) {
                    numlampeggi = 2;
                } else if (inputfrecce > 5) {
                    numlampeggi = 5;
                } else {
                    numlampeggi = inputfrecce;
                }
            }

            if(selection == 8-1){
                struct timespec ts;
                ts.tv_sec = 1000 / 1000;
                ts.tv_nsec = (1000 % 1000) * 1000000;
                printf(".");
                printf(".");
                printf(".");

                printf("pressione gomma resettata!\n");
                nanosleep(&ts, &ts);
                skip =1;
                pressed = 0;


            }
        }

        if(!skip){
        // Get the necessary character
        fgets(inputbuffer, 100, stdin);


        // Modify the selection according to the inserted value
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
        

        // Selection loop (up and down)
        if (selection < 1-1) {
            selection = selmax-1;
        } else if (selection > selmax-1) {
            selection = 1-1;
        }

        if (subselection < 1-1) {
            subselection = 2-1;
        } else if (subselection > 2-1) {
            subselection = 1-1;
        }

        // Confirm selection
        if(inputbuffer[0]==10 && pressed){
            pressed = 0;

            // If we are setting "ON" and "OFF"
            if(selection == 4-1 || selection == 5-1){
                strings[selection][1] = options[subselection];
            }

            subselection = 0;
        }

        for(size_t i=0; i < sizeof inputbuffer; ++i){
            inputbuffer[i] = 0;
        }

        }

    } while(1);

    return 0;
}
