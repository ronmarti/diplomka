#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"
//#include "configuration.h"



void get_config()
{
		int i=0;
		char config_path[200]="";

		if(!arg_config) sprintf(config_path,"%s",FILENAME);
		else sprintf(config_path,"%s",input_config_path);
  			
		FILE *file = fopen (config_path, "r");

        if (file != NULL)
        { 
                char line[MAXBUF];
                int i = 0;

                while(fgets(line, sizeof(line), file) != NULL)
                {
                        char *cfline = NULL;
                        cfline = strstr((char *)line,DELIM);
                        cfline = cfline + strlen(DELIM);
						cfline[strcspn(cfline, "\n")] = 0;
    
                        if (i == 0){
                                memcpy(configstruct.uri,cfline,strlen(cfline));
                                //printf("%s",configstruct.imgserver);
                        } else if (i == 1){
                                memcpy(configstruct.db_name,cfline,strlen(cfline));
                                //printf("%s",configstruct.ccserver);
                        } else if (i == 2){
                                memcpy(configstruct.coll_name,cfline,strlen(cfline));
                                //printf("%s",configstruct.port);
                        } else if (i == 3){
                                memcpy(configstruct.out_file,cfline,strlen(cfline));
                                //printf("%s",configstruct.getcmd);
                        } else if (i == 4){
                                memcpy(configstruct.num_threads,cfline,strlen(cfline));
                                //printf("%s",configstruct.getcmd);
                        } else if (i == 5){
                                memcpy(configstruct.data_from,cfline,strlen(cfline));
                                //printf("%s",configstruct.getcmd);
                        } else if (i == 6){
                                memcpy(configstruct.data_to,cfline,strlen(cfline));
                                //printf("%s",configstruct.getcmd);
                        }
                        
						i++;
                } // End while
                fclose(file);
        } // End if file
        else{
			printf("Unable to open config file.");
			exit(EXIT_FAILURE);
		}
         
		if(atoi(configstruct.data_from)>atoi(configstruct.data_to)){
				printf("Incorrect DATA_FROM or DATA_TO parameters\n");
				exit(EXIT_FAILURE);				
		}
		 
		num_threads = atoi(configstruct.num_threads);
	
}