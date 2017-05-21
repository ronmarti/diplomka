#include "defines.h"

//* base 64 coding characters
char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

void mongo_collection()
{

//---- variables	
	
	bson_error_t err;

	pthread_t threads[MAX_THREADS];
	
	int i = 0;
	int j = 0;
	int index[MAX_THREADS];
	char input = 0;
	data_exported = 0;
	
//----
	
	//* get collection
	collection = mongoc_client_get_collection (client, configstruct.db_name, configstruct.coll_name);
	
	//* count number of items in collection
	count = mongoc_collection_count(collection, 0, &query, 0, 0, NULL, &err);
	//* initialization of number of remaining items
	remaining = count;

	//* initialization of thread indices
	for(i=0;i<MAX_THREADS;i++){
		index[i]=i;
	}	
	
//---- text interface	
	
	if(!arg_answers){
	printf("//\n");
	printf("// Current date and time:            %d.%d.%d   %02d:%02d:%02d\n",timeinfo.tm_mday, timeinfo.tm_mon + 1, timeinfo.tm_year + 1900, timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
	printf("//\n");
	printf("// Connected to Mongo database: %25s\n", configstruct.db_name);
	printf("// Chosen collection to export: %25s\n", configstruct.coll_name);
	printf("// Chosen number of threads/output files:               %d\n",num_threads);
	printf("//\n");
	printf("// Total number of items in database: %d\n",count);	
	}
	
	//* delete existing backup databases
	delete_backup_db();
	
	if(!arg_answers){
	printf("//\n");	
	printf("// Counting boundaries ...\n");
	}
	select_from_to();
	
	if(!arg_answers){
	printf("// Done.\n");
	printf("//\n");
	printf("//\n");
	
	printf("// You are about to export %d items\n",data_to-data_from);
	if(!strcmp(configstruct.data_from,"0")){printf("// from the beginning\n");}
	else{printf("// from %c%c.%c%c.%c%c %c%c:%c%c\n",configstruct.data_from[0],configstruct.data_from[1],configstruct.data_from[2],configstruct.data_from[3],configstruct.data_from[4],configstruct.data_from[5],configstruct.data_from[6],configstruct.data_from[7],configstruct.data_from[8],configstruct.data_from[9]);}
	if(!strcmp(configstruct.data_to,"0")){printf("// to the end\n");}
	else{printf("// to %c%c.%c%c.%c%c %c%c:%c%c\n",configstruct.data_to[0],configstruct.data_to[1],configstruct.data_to[2],configstruct.data_to[3],configstruct.data_to[4],configstruct.data_to[5],configstruct.data_to[6],configstruct.data_to[7],configstruct.data_to[8],configstruct.data_to[9]);}
	printf("// from collection: \"%s\" \n",configstruct.coll_name);
	printf("// from database: \"%s\" \n",configstruct.db_name);
	printf("// into file: \"%s\" \n",configstruct.out_file);
	}
	printf("//\n");
	
	//* create a backup of chosen database
	backup_db();
	
	if(!arg_answers){
	printf("//\n");
	
	//* export data
	printf("// Do you want to start the data export (Y/n)? ");

	}
	
	while(input != 'Y' && input != 'n'){
		
		if(arg_answers)	input = input_answers[2];
		else scanf (" %c", &input);
						
		if(input == 'Y'){
			
			printf("//\n");
			printf("// Commencing data export.\n");
							
			for(i=0;i<num_threads;i++){
				pthread_create(&threads[i],NULL,&export_data,&index[i]);
				for(j=0;j<100000000;j++){}
			}
	
			for(i=0;i<num_threads;i++){
				pthread_join(threads[i], NULL);
			}

			printf("\n//\n");
			printf("// Export finished.\n");
			data_exported = 1;
			break;
		}
		else if (input == 'n'){
			printf("// Data will not be exported.\n");
		}
		else {
			printf("// Invalid character. (Y/n) ");
			input = 0;
		}
	}
	input = 0;
	printf("//\n");
	
	//* clear chosen database
	clear_db();
	
	
	printf("//\n");
	printf("////////////////////////////////////////////////////////////////////////////////\n");
	
	
//---- free collection	
	mongoc_collection_destroy (collection);
	
}

//---- export data function
void* export_data(void* arg){

	//* thread index
	int ind = *((int*)arg);
	
	//---- variables
	//* mongo variables
	mongoc_cursor_t *cursor = NULL;
    const bson_t *doc = NULL;
    bson_t *opts = NULL;
	bson_t *query_1 = NULL;
	bson_error_t error;
	
	//* auxillary variables
	unsigned int i = 0;
	unsigned int j = 0;
	unsigned int k = 0;
	unsigned int soucet = 0;
	
	//* string variables
	unsigned char *str = NULL;
	unsigned char *cfline = NULL;
	unsigned char uuid_coded[3000]="";
	unsigned char hex_coded[2000]="";
	unsigned char char_coded[2000]="";
	unsigned char timestamp[1000]="";
	unsigned char IWs1[1000]="";
	unsigned char IWs2[1000]="";

	//* output values variables
	int values[1000]={0};//100
	
	//* select first item
	opts = BCON_NEW ("skip", BCON_INT64 (ind*((data_to-data_from)/num_threads) + data_from),"limit", BCON_INT64 ((data_to-data_from)/num_threads));

	query_1 = bson_new ();

	cursor = mongoc_collection_find_with_opts (
		collection,
		query_1,
		opts,  // additional options (opts)
		NULL); // read prefs, NULL for default 

		
	if (mongoc_cursor_error (cursor, &error)) {
		fprintf (stderr, "Cursor Failure: %s\n", error.message);
		exit(EXIT_FAILURE);
	}
	
	printf("\r// ...");
	
	//* go through all items 	
	while (mongoc_cursor_next (cursor, &doc)) {
	
		//* item data to string
		str = bson_as_json (doc, NULL);
		
		//* select only data from string (UUID formated) 
	    cfline = strstr((char *)str,"$binary\" : \"");
		cfline = cfline + strlen("$binary\" : \"");

		str = NULL;
		
		while(cfline[j] != '"'){
		
			uuid_coded[j]=cfline[j];
			j++;
			
		}
		j = 0;
		
		cfline = NULL;
	
		//* convert UUID coded data into 8-bit hex 		
		for(k=0;k<800;k++){
			
			j = 0;
			
			while(uuid_coded[2*k] != base64[j]){
				j++;
			}
			
			soucet = 64*j;
			j = 0;
			
			while(uuid_coded[2*k+1] != base64[j]){
				j++;
			}
		
			soucet = soucet + j;
			
			hex_coded[3*k]=(soucet >> 8) & 0xf;
			hex_coded[3*k+1]=(soucet >> 4) & 0xf;
			hex_coded[3*k+2]=(soucet & 0xf);
			soucet = 0;
		}

		j = 0;
			
		//* get timestamp 	
		sprintf(timestamp,"20%x%x %x%x %x%x %x%x %x%x %x%x.%x%x%x",hex_coded[0],hex_coded[1],hex_coded[2],hex_coded[3], hex_coded[4], hex_coded[5], hex_coded[6], hex_coded[7], hex_coded[8], hex_coded[9], hex_coded[10], hex_coded[11], hex_coded[12], hex_coded[13], hex_coded[14]);
	
		//* join 8-bit hex data into chars
		for(k=0;k<620;k++){
			
			char_coded[k]=(hex_coded[2*k+18] * 0x10) + hex_coded[2*k+19]; 
		}

		//* chars into 16-bit hex
		for(k=0;k<38;k++){
		
			IWs1[k]=char_coded[k*16+11];
			IWs2[k]=char_coded[k*16+12];
		}

		//* join into 32-bit integer
		for(k=0;k<15;k++){
			
			values[k] = IWs2[2*k+1]*0x1000000 + IWs1[2*k+1]*0x10000 + IWs2[2*k]*0x100 + IWs1[2*k];
			//values[k] = values[k] & 0x0000ffff;
			
		}

	    //* print into csv file
		fprintf(fs[ind], "%s; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f; %.2f;\n",
				timestamp, 
				(float)values[0]/100, (float)values[1]/100, (float)values[2]/100, (float)values[3]/100,	(float)values[4]/100, 
				(float)values[5]/100, (float)values[6]/100, (float)values[7]/100, (float)values[8]/100, (float)values[9]/100, 
				(float)values[10]/100, (float)values[11]/100, (float)values[12]/100, (float)values[13]/100, (float)values[14]/100,
				(float)values[15]/100, (float)values[16]/100, (float)values[17]/100, (float)values[18]/100);
			
			
		remaining--;
		if(remaining<=((data_to-data_from)%num_threads))remaining=0;
		fflush(stdout);
		printf("\r// Remaining: %6d of %6d",remaining,data_to-data_from);
	}
	
	fflush(stdout);
	printf("\r// Remaining: %6d of %6d",0,data_to-data_from);
	
	bson_destroy (query_1);
	bson_destroy (opts);
	mongoc_cursor_destroy (cursor);
	pthread_exit(NULL);
	
}

void clear_db(){
	
	mongoc_database_t *dropdb = NULL;
	char **db_names = NULL;
	bson_error_t error;
	char input = 0;
	
	if(!arg_answers) printf("// Do you want to clear collection \"%s\" from database \"%s\" (Y/n)? ",configstruct.coll_name,configstruct.db_name);
		
	while(input != 'Y' && input != 'n'){
		
		if(!arg_answers) scanf (" %c", &input);
		else input = input_answers[3];
												
		if(input == 'Y'){
			
			dropdb = mongoc_client_get_database (client, configstruct.db_name);
			mongoc_database_drop (dropdb, &error);
			dropdb = NULL;
			printf("//\n");
			printf("// Database cleared.\n");
			break;
		}
		else if (input == 'n'){
			printf("// Database will not be cleared.\n");
		}
		else {
			printf("// Invalid character. (Y/n) ");
			input = 0;
		}
	}
	input = 0;
	
}


void delete_backup_db(){
	
	mongoc_database_t *dropdb = NULL;
	bson_error_t error;
	
	char **db_names = NULL;
	char input = 0;
	int i = 0;
	
		
	if ((db_names = mongoc_client_get_database_names (client, &error))) {
	
		for (i = 0; db_names[i]; i++){
			
			if(strstr(db_names[i], "backup") != NULL){
		
				printf("// Backup databases found.\n");
				printf("// \n");
						
				if(!arg_answers) printf("// Do you want to delete backup database \"%s\"? (Y/n) ", db_names[i]);
				
				while(input != 'Y' && input != 'n'){
		
					if(!arg_answers) scanf (" %c", &input);
					else input = input_answers[0];
												
					if(input == 'Y'){
						dropdb = mongoc_client_get_database (client, db_names[i]);
						mongoc_database_drop (dropdb, &error);
						dropdb = NULL;
						printf("// Backup database deleted.\n");
						break;
					}
					else if (input == 'n'){
						printf("// Backup database will not be deleted.\n");
					}
					else {
						printf("// Invalid character. (Y/n) ");
						input = 0;
					}
				}
				input = 0;
			}
		}
    } 
	else {
		fprintf (stderr, "Command failed: %s\n", error.message);
	}
	
	bson_strfreev (db_names);
	
}

void backup_db (){

	mongoc_database_t *admindb = NULL;
	bson_error_t error;
	bson_t *command = NULL;
	
	char backup_db_name[100] = "";
	char input = 0;
   	
	sprintf(backup_db_name,"backup_%s_%d-%d-%d_%02d%02d",configstruct.db_name,timeinfo.tm_mday,timeinfo.tm_mon+1,timeinfo.tm_year + 1900,timeinfo.tm_hour, timeinfo.tm_min);
   
	/* Must do this from the admin db */
	admindb = mongoc_client_get_database (client, "admin");

	command = BCON_NEW ("copydb",
						BCON_INT32 (1),
						"fromdb",
						BCON_UTF8 (configstruct.db_name),
						"todb",
						BCON_UTF8 ("targetDB"));
					//	BCON_UTF8 (backup_db_name));
	
	
	if(!arg_answers ) printf("// Do you want to make a backup of \"%s\"? (Y/n) ", configstruct.coll_name);
				
	while(input != 'Y' && input != 'n'){
		
		if(!arg_answers) scanf (" %c", &input);
		else input = input_answers[1];
												
		if(input == 'Y'){
		
			printf("// Making backup. Please wait...\n");
			if (!mongoc_database_command_simple (admindb, command, NULL, NULL, &error)) {
				fprintf (stderr, "Error with database backup: %s\n", error.message);
				exit(EXIT_FAILURE);
			}
			else {
			printf("// Database backed up as \"%s\"\n",backup_db_name);
			}
			break;
		}
		else if (input == 'n'){
			printf("// Backup will not be made.\n");
		}
		else {
			printf("// Invalid character. (Y/n) ");
			input = 0;
		}
	}
				
    bson_destroy (command);
	mongoc_database_destroy (admindb);

}

void select_from_to(){
	
	mongoc_cursor_t *cursor = NULL;
    const bson_t *doc = NULL;
    bson_t *opts = NULL;
	bson_t *query_1 = NULL;
	bson_error_t error;

	unsigned char *str = NULL;
	unsigned char *cfline = NULL;
	unsigned char uuid_coded[3000]="";
	unsigned char hex_coded[2000]="";
	unsigned char char_coded[2000]="";
	unsigned char timestamp[1000]="";
	unsigned char timestamp_sec[100]="";

	unsigned int pom = 0;
	unsigned int j = 0;
	unsigned int k = 0;
	unsigned int soucet = 0;
	int diff = 0;
	
	bool found_from = 0;
	bool found_to = 0;
	
	unsigned int skip = 0;
	

	if(!strcmp(configstruct.data_from,"0"))	{found_from = 1;}
	if(!strcmp(configstruct.data_to,"0")) {found_to = 1;}
	
	while(!found_from){
		
		opts = BCON_NEW ("skip", BCON_INT64 (skip),"limit", BCON_INT64 (1));
		query_1 = bson_new ();
		cursor = mongoc_collection_find_with_opts (collection, query_1, opts, NULL);
		
		if (mongoc_cursor_error (cursor, &error)) {
			fprintf (stderr, "Cursor Failure: %s\n", error.message);
			exit(EXIT_FAILURE);
		}
	
		while (mongoc_cursor_next (cursor, &doc)) {

			str = bson_as_json (doc, NULL);
			cfline = strstr((char *)str,"$binary\" : \"");
			cfline = cfline + strlen("$binary\" : \"");

			str = NULL;
		
			j = 0;
			
			while(j<50){
			
				uuid_coded[j]=cfline[j];
				j++;
			}

			j = 0;
		
			cfline = NULL;
	
			//* convert UUID coded data into 8-bit hex 		
			for(k=0;k<50;k++){
			
				j = 0;
			
				while(uuid_coded[2*k] != base64[j]){
					j++;
				}
			
				soucet = 64*j;
				j = 0;
			
				while(uuid_coded[2*k+1] != base64[j]){
					j++;
				}
		
				soucet = soucet + j;
			
				hex_coded[3*k]=(soucet >> 8) & 0xf;
				hex_coded[3*k+1]=(soucet >> 4) & 0xf;
				hex_coded[3*k+2]=(soucet & 0xf);
				soucet = 0;
			}
				
			j = 0;
			
			//* get timestamp 	
			sprintf(timestamp,"%x%x%x%x%x%x%x%x%x%x",hex_coded[0],hex_coded[1],hex_coded[2],hex_coded[3], hex_coded[4], hex_coded[5], hex_coded[6], hex_coded[7], hex_coded[8], hex_coded[9]);
			sprintf(timestamp_sec,"%x%x",hex_coded[10],hex_coded[11]);
				
			if(atoi(timestamp)>atoi(configstruct.data_from)){
				found_from=1;
				break;
			}	
			if(strcmp(timestamp,configstruct.data_from)==0){
				found_from=1;
				break;
			}
			else{
					
				for(j=0;j<10;j++){
					if(timestamp[j]!=configstruct.data_from[j]){
						pom=j;
						break;
					}
				}	
					
				if(9-pom==0){
			
					if(configstruct.data_from[pom]-timestamp[pom] > 1){
						skip = skip + 800;
						break;
					}
					else {
						if(timestamp_sec[0]<'5'){
							skip = skip + 200;
							break;
						}
						else if (timestamp_sec[1]<'9'){
							skip = skip + 25;
							break;
						}
						else{
							skip++;
							break;
						}
					}
				}
				
				if(9-pom>0){
					if(9-pom>2){
						if(9-pom>4){
							if(9-pom>6){
								if(9-pom>8){
									skip = skip + 10000000;
									break;
								}
								skip = skip + 1000000;
								break;
							}
							skip = skip + 100000;
							break;
						}
						skip = skip + 10000;
						break;
					}
					skip = skip + 1000;
					break;
				}
			}
		}
	}
		
	j = 0;
	pom = 0;
	if(!strcmp(configstruct.data_from,"0"))	{data_from = 0;}
	else{data_from = skip;}
	skip = count;
						
	while(!found_to){
			
		opts = BCON_NEW ("skip", BCON_INT64 (skip-1),"limit", BCON_INT64 (1));
		query_1 = bson_new ();
		cursor = mongoc_collection_find_with_opts (collection, query_1, opts, NULL);
		
		if (mongoc_cursor_error (cursor, &error)) {
			fprintf (stderr, "Cursor Failure: %s\n", error.message);
			exit(EXIT_FAILURE);
		}
	
		while (mongoc_cursor_next (cursor, &doc)) {

			str = bson_as_json (doc, NULL);
			cfline = strstr((char *)str,"$binary\" : \"");
			cfline = cfline + strlen("$binary\" : \"");
			str = NULL;
			j = 0;

			while(j<50){
			
				uuid_coded[j]=cfline[j];
				j++;
			
			}

			j = 0;
			cfline = NULL;
	
			//* convert UUID coded data into 8-bit hex 		
			for(k=0;k<50;k++){
			
				j = 0;
				while(uuid_coded[2*k] != base64[j]){j++;}
			
				soucet = 64*j;
				j = 0;
			
				while(uuid_coded[2*k+1] != base64[j]){j++;}
		
				soucet = soucet + j;
				hex_coded[3*k]=(soucet >> 8) & 0xf;
				hex_coded[3*k+1]=(soucet >> 4) & 0xf;
				hex_coded[3*k+2]=(soucet & 0xf);
				soucet = 0;
			}
				
			j = 0;
			
			//* get timestamp 	
			sprintf(timestamp,"%x%x%x%x%x%x%x%x%x%x",hex_coded[0],hex_coded[1],hex_coded[2],hex_coded[3], hex_coded[4], hex_coded[5], hex_coded[6], hex_coded[7], hex_coded[8], hex_coded[9]);
			sprintf(timestamp_sec,"%x%x",hex_coded[10],hex_coded[11]);
				
			if(atoi(timestamp)<atoi(configstruct.data_to)){
				found_to=1;
				break;
			}
			if(strcmp(timestamp,configstruct.data_to)==0){
				found_to=1;
				break;
			}
			else{
					
				for(j=0;j<10;j++){
					if(timestamp[j]!=configstruct.data_to[j]){
						pom=j;
						break;
					}
				}	

				if(9-pom==0){
					if(timestamp[pom]-configstruct.data_to[pom] > 1){
						skip = skip - 800;
						break;
					}
					else {
						if(timestamp_sec[0]>'1'){
							skip = skip - 200;
							break;
						}
						else if (timestamp_sec[1]>'0'){
							skip = skip - 25;
							break;
						}
						else{
							skip--;
							break;
						}
					}
				}
				if(9-pom>0){
					if(9-pom>2){
						if(9-pom>4){
							if(9-pom>6){
								if(9-pom>8){
									skip = skip - 10000000;
									break;
								}
								skip = skip - 1000000;
								break;
							}
							skip = skip - 100000;
							break;
						}
						skip = skip - 10000;
						break;
					}
					skip = skip - 1000;
					break;
				}
			}
		}
	}
		
	if(!strcmp(configstruct.data_to,"0")){data_to = count;}
	else{data_to = skip;}
	
}

