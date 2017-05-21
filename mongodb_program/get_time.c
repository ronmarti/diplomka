#include <time.h>

#include "defines.h"
//#include "get_time.h"


void get_curr_time(){
	
	char *test_string;
	
	time_t rawtime;
	
	time ( &rawtime );
    timeinfo = *localtime ( &rawtime );
	
	//printf("[%d.%d.%d %d:%d:%d]\n",timeinfo.tm_mday, timeinfo.tm_mon + 1, timeinfo.tm_year + 1900, timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
			
}