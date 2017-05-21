#include <mongoc.h>
#include <bcon.h>

#include "defines.h"
//#include "mongo_connection.h"

bson_t query;

void mongo_connect(){

	mongoc_init ();

    client = mongoc_client_new (configstruct.uri);

	if (!client) {
		fprintf (stderr, "Failed to parse URI.\n");
		exit(EXIT_FAILURE);
	}

	mongoc_client_set_error_api (client, 2);

	bson_init (&query);
		
}


void mongo_close_connection(){
		
	bson_destroy (&query);
	//mongoc_collection_destroy (collection);
	mongoc_client_destroy (client);

	mongoc_cleanup ();
    	
}