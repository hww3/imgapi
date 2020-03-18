
inherit Fins.FinsController;
inherit Fins.RootController;

constant __uses_session = 0;
constant __index_directly = 1;

protected void create(object application)
{
  ::create(application);
  before_filter(app->get_and_head_only);
}

void index(object id, object response, mixed ... args)
{
  if(id->variables->reload) app->clear_images();
//werror("index(%O, %O, %O)\n", id, response, args);
  if(sizeof(args) == 0) {
    generate_index(id, response);
    return;
  } else if(sizeof(args) == 1) {
    string uuid = args[0];
    get_manifest(id, response, uuid);
    return;    
  } else if(sizeof(args) == 2) {
    if(args[1] != "file") {
      response->bad_request();
      return;
    }
    string uuid = args[0];
    get_file(id, response, uuid);
    return;
  }

  response->bad_request();
 
}

protected void get_manifest(object id, object response, string uuid) {
  Standards.UUID.UUID u = Standards.UUID.UUID(uuid);

  mixed manifest = app->find_manifest(u);

  if(!manifest) {
    response->not_found(uuid);
    return;
  }

  m_delete(manifest, "_fn");

  manifest->state="active";

  response->set_data(Standards.JSON.encode(manifest));
  response->set_type("application/json"); 
}

protected void get_file(object id, object response, string uuid) {
  Standards.UUID.UUID u = Standards.UUID.UUID(uuid);
  if(!u) {
    response->bad_request("Invalid UUID");
    return;
  }
  
  Stdio.File file = app->get_file(u);
  
  if(!file)
  {
    response->not_found(uuid + "/file");
    return;
  }
  
  response->set_file(file);
  response->set_type("application/gzip");
}


protected void generate_index(object id, object response) 
{
  response->set_data(Standards.JSON.encode(app->get_manifests()));
  response->set_type("application/json");
}
