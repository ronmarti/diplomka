#include <mongoc.h>
#include <bcon.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>

#ifndef FILENAME

	#define FILENAME "config.conf"

#endif

#ifndef MAX_THREADS

	#define MAX_THREADS 16

#endif


#include "configuration.h"
#include "parser.h"
#include "get_time.h"
#include "file_handler.h"
#include "mongo_connection.h"
#include "mongo_collection.h"


extern bson_t query;

char input_answers[4];
char input_config_path[100];
bool arg_answers;
bool arg_config;


void print_help();
