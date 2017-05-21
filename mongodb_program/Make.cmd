cls

cl.exe /IC:\mongo-c-driver\include\libbson-1.0 /IC:\mongo-c-driver\include\libmongoc-1.0 /IC:\pthreads\include data_exporter.c parser.c get_time.c mongo_connection.c mongo_collection.c configuration.c file_handler.c

link data_exporter.obj parser.obj get_time.obj mongo_connection.obj mongo_collection.obj configuration.obj file_handler.obj "C:\mongo-c-driver\lib\mongoc-1.0.lib" "C:\mongo-c-driver\lib\bson-1.0.lib" "C:\pthreads\lib\x64\pthreadVC2.lib"

del data_exporter.obj parser.obj get_time.obj mongo_connection.obj mongo_collection.obj configuration.obj file_handler.obj

echo ---------------------------------------

data_exporter.exe