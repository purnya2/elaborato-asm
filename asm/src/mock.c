#include <stdio.h>

void main(){
    char *strings[3] = {"one","two","three"};

    for (int i = 0; i<3; i++){
        printf("%s", strings[i]);
    }

}