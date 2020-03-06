
inherit Fins.Application;

string data_dir;

void start()
{
  if(!startup_arguments) throw(Error.Generic("No data directory specified!\n"));

  if(sizeof(startup_arguments) > 1) throw(Error.Generic("Too many arguments specified.\n"));

  Stdio.Stat stat = file_stat(startup_arguments[0]);

  if(!stat || !stat->isdir)
    throw(Error.Generic("Data dir " + startup_arguments[0] + " must be a directory.\n"));

  data_dir = startup_arguments[0];  

  logger->info("Using image data directory " + data_dir);
}
