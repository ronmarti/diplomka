#include <stdio.h>

#include "defines.h"


int main (int argc, char **argv){
	
	//---- Input parameters handling
	sprintf(input_answers,"");
	sprintf(input_config_path,"");
	arg_answers = 0;
	arg_config = 0;
	
    for (int i = 1; i < argc; ++i){
		if(!strcmp(argv[i],"-h") || !strcmp(argv[i],"help")) { 
			print_help();
			return 1;
		}
		if(!strcmp(argv[i],"-c") && i < (argc - 1)) { 
			if(argv[i+1][0]!='-'){
				arg_config = 1;
				sprintf(input_config_path,"%s",argv[i+1]);
			}
		}
		if(!strcmp(argv[i],"-a") && i < (argc - 1)) { 
			if(argv[i+1][0]!='-'){
				for(int j = 0; j<4;j++){
					if(argv[i+1][j]!='n' && argv[i+1][j]!='Y') {
						printf ("Invalid input parameter for -a. Type -h or \"help\" for help.");
						return 1;
					}
				}
				arg_answers = 1;
				sprintf(input_answers,"%s",argv[i+1]);
			}
		}
	}

	//---- Counting runtime
	clock_t begin = clock();
	
	//---- Welcome title
	printf("////////////////////////////////////////////////////////////////////////////////\n");
	printf("//                       -=  MongoDB data exporter =-                         //\n");
	printf("////////////////////////////////////////////////////////////////////////////////\n");
        
	//----  Get configuration parameters from config file  
	get_config();
   
	//----  Get actual local time
	get_curr_time();
	   
		//----  Initialize output file handling  
	file_handler_init();

  	//----  Open connection to mongo DB 
	mongo_connect();
	
	//----  Data management
	mongo_collection();
	
	//----  Destroy output file handler
	file_handler_destroy();
		
	//----  Close connection with mongo DB
	mongo_close_connection();

	clock_t end = clock();
	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	
	printf("RUN SUCCESSFUL\n");
	printf("Elapsed time: %f sec",time_spent);
	
	return EXIT_SUCCESS;
	
}

void print_help(){
	printf("Help for MongoDB data exporter\n");
	printf("\n");
	printf("This application is used to export data from MongoDB gathered by PLC measuring electrical power of industrial manipulators in industrial line.\n");
	printf("\n");
	printf("Application alows user to manage backup databases(delete old databases, create new backups), export data from specified database and cooolection into specified file and clear specified database\n");
	printf("\n");
	printf("Application can be used as multi-threaded. User specifies number of threads used in data conversion and export in order to faster process large amount of data.\n");
	printf("Each thread then processes its own block of data and stores into separate file - labeled pn (n ... number of thread)\n");
	printf("Application supports up to 16 threads running simultaneously.\n");
	printf("\n");
	printf("User can also specify time from which to which he wants data to be exported\n.");
	printf("Please note that in case of large amount of data, it can take some time for application to compute boundaries of data specified by time.");
	printf("Time specified is then added into name of output file in order to identify time of data it contains");
	printf("\n");
	printf("Application has a text user interface\n");
	printf("\n");
	printf("Input parameters:\n");
	printf("    -h   -   Displays help\n");
	printf("    -c   -   Specifies config location\n");
	printf("             Example:    run -c C:/files/data/config.conf\n");
	printf("                         reads configuration file \"config.conf\" located at C:/files/data/\n");
	printf("             In case no config file location is specified by user, default settings are used - \"config.conf\" in \n");
	printf("             the same directory as \"run\" application\n");
	printf("    -a   -   Specifies answers to questions during runtime\n");
	printf("             Allowed symbols: Y or n\n");
	printf("\n");
	printf("             Questions:\n");
	printf("                1. Delete old backup databases? (Y,n)\n");
	printf("                2. Make backup of a specified database? (Y,n)\n");
	printf("                3. Export data? (Y,n)\n");
	printf("                4. Clear specified database? (Y,n)\n");
	printf("             Example:    run -a YnYn\n");
	printf("                         application executed with these parameters will delete old backu databases, will not \n");
	printf("                         create a backup of specified databse, export data and will not clear specified database\n");
	printf("             In case no answers are specified as input parameter, program will start normally and ask these questions\n");
	printf("             during its runtime\n");
	printf("\n");
	printf("Config file format:\n");
	printf("    URI=mongodb://localhost:27017                     -    adress of the mongo DB\n");
	printf("    DB_NAME=depo                                      -    name of a Mongo database to connect\n");
	printf("    COLLECTION_NAME=pricna_stena                      -    name of a collection to connect\n");
	printf("    OUTPUT_FILE=C:/mongodb_program/data_export.csv    -    location and name of an output file for data export\n");
	printf("    NUM_THREADS=2                       -    specifies number of threads/output files for data export\n");
    printf("    DATA_FROM=0                         -    specifies time from which the data should be exported\n");
	printf("    DATA_TO=1701041215                  -    specifies time to which the data should be exported\n");
	printf("                                             format:  YYMMDDhhmm YY-year, MM-month, DD-day, hh-hour, mm-minute\n");
	printf("                                             if you do not want to use this option, just type 0\n");
	printf("\n");
	printf("Application executed with this config file will connect to MongoDB running at localhost on port 27010.\n");
	printf("It will try to connect to database \"depo\" and to collection \"pricna_stena\".\n");
	printf("Data to export will be chosen from the beginning to 4.1.2017 - 12:15.\n");
	printf("Because two threads are chosen, two output files will be generated.\n");
	printf("Application will export data into two files named:\n");
	printf("       data_export_0-1701041215_p1.csv\n");
	printf("       data_export_0-1701041215_p2.csv\n");
	printf("stored to \"C:/mongodb_program/\"\n");
	
	
}