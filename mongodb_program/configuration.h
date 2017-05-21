#ifndef MAXBUF
	#define MAXBUF 1024 
#endif	
	
#ifndef DELIM
	#define DELIM "="
#endif

struct config
{
   char uri[MAXBUF];
   char db_name[MAXBUF];
   char coll_name[MAXBUF];
   char out_file[MAXBUF];
   char num_threads[MAXBUF];
   char data_from[MAXBUF];
   char data_to[MAXBUF];
};

unsigned int num_threads;
 
struct config configstruct;


void get_config();