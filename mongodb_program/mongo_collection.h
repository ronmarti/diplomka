mongoc_collection_t *collection;

//---- function prototypes
void mongo_collection();
void* export_data(void* arg);
void backup_db();
void delete_backup_db();
void clear_db();
void select_from_to();

//---- variables
int count;	//* number of elements
int remaining;	//* number of remaining elements
int data_from;
int data_to;

bool data_exported;

