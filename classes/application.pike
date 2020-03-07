
inherit Fins.Application;

string data_dir;

void start()
{
  if(!startup_arguments) 
    throw(Error.Generic("No data directory specified!\n"));

  if(sizeof(startup_arguments) > 1) 
    throw(Error.Generic("Too many arguments specified.\n"));

  data_dir = startup_arguments[0];  
  Stdio.Stat stat = file_stat(data_dir);

  if(!stat || !stat->isdir)
    throw(Error.Generic("Data dir " + data_dir + " must be a directory.\n"));

  logger->info("Using image data directory " + data_dir);
}

int get_and_head_only(object request, object response, mixed ... args)
{
  if ((<"GET", "HEAD">)[request->request_type]) return 1;
  response->bad_request(request->request_type + " not supported.");
  return 0;
}
