#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"
//#include "configuration.h"

char path[500]="";
char filename_full[100]="";
char filename[100] = "";
char *extension = NULL;


#ifdef _WIN32

	/* Compiling for Windows */

	#include <windows.h>

	int file_exists(void){
	
		char pathi[500]="";
		
		WIN32_FIND_DATA f;

		sprintf(pathi,"%s%s",path,"*");
			
		HANDLE h = FindFirstFile(pathi, &f);
		
		if(h != INVALID_HANDLE_VALUE){
			do{
				if(!strcmp(f.cFileName,filename_full)) 	return 1;
			} while(FindNextFile(h, &f));
		}
		else{
			fprintf(stderr, "Error opening directory\n");
			exit(EXIT_FAILURE);
		}
		return 0;
	}

#else
#ifdef __unix__

	/* Compiling for UNIX / POSIX */

	#include <sys/types.h>
	#include <dirent.h>

	int file_exists(void){
		DIR *dir = opendir(path);
		if(dir){
			struct dirent *ent;
			while((ent = readdir(dir)) != NULL){
				if(!strcmp(ent->d_name,filename_full)) 	return 1;
			}
		}
		else{
			fprintf(stderr, "Error opening directory\n");
			exit(EXIT_FAILURE);
		}
		return 0;
	}
		
#else
	#error Unsupported Implementation
#endif
#endif

void file_handler_init()
{	
	
	int i = 0;
	int num = 0;
	
	memcpy(filename_full,strrchr(configstruct.out_file, '/'),strlen(strrchr(configstruct.out_file, '/')));
	sprintf(filename_full,"%s",filename_full+1);
	memcpy(path,configstruct.out_file,strlen(configstruct.out_file)-strlen(strrchr(configstruct.out_file, '/')+1));
	while(filename_full[i]!='.'){
		filename[i]=filename_full[i]; 
		i++;
	}
	extension = strstr((char *)configstruct.out_file,".") + strlen(".");
	
	sprintf(filename_full,"%s_%s-%s_p%d.%s",filename,configstruct.data_from,configstruct.data_to,1,extension);
	while(file_exists()){
		num++;
		sprintf(filename_full,"%s_%s-%s_%d_p%d.%s",filename,configstruct.data_from,configstruct.data_to,num,1,extension);
	}
    
	
	for(i=0;i<num_threads;i++){
		if(num)	{sprintf(outfile[i],"%s%s_%s-%s_%d_p%d.%s",path,filename,configstruct.data_from,configstruct.data_to,num,i+1,extension);
		}else sprintf(outfile[i],"%s%s_%s-%s_p%d.%s",path,filename,configstruct.data_from,configstruct.data_to,i+1,extension);
		fs[i] = fopen(outfile[i], "a");
	}
	
	if(fs[0] == NULL){
		printf("Unable to open output file\n");
		exit(EXIT_FAILURE);
	}
	
}


void file_handler_destroy()
{
	int i = 0;
	
	for(i=0;i<num_threads;i++){
		
		fclose(fs[i]);
		if(!data_exported) remove(outfile[i]);
	
	}
}