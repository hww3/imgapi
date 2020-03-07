
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

  mixed manifest = find_manifest(u);

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

  mixed manifest = find_manifest(u);

  if(!manifest) {
    response->not_found(uuid);
    return;
  }

  string datadir = app->data_dir;
  string fn = Stdio.append_path(datadir, manifest->_fn + ".zfs.gz");
  if(!file_stat(fn)) {
    response->not_found(uuid + "/file");
    return;
  }

  Stdio.File file = Stdio.File(fn, "r");
  response->set_file(file);
  response->set_type("application/gzip");
}

protected void generate_index(object id, object response) 
{
  ADT.List list = ADT.List();
  string datadir = app->data_dir;
  foreach(glob("*.json", get_dir(datadir));; string fn) {
    list->append(Standards.JSON.decode(Stdio.read_file(Stdio.append_path(datadir, fn))));    
  }
  
  response->set_data(Standards.JSON.encode((array)list));
  response->set_type("application/json");
}

protected mapping find_manifest(object uuid) {
    ADT.List list = ADT.List();
  string datadir = app->data_dir;
  foreach(glob("*.json", get_dir(datadir));; string fn) {
    mixed manifest = Standards.JSON.decode(Stdio.read_file(Stdio.append_path(datadir, fn)));
    if(manifest && manifest->uuid == (string)uuid) return manifest + (["_fn": fn[..<5] ]);
  }

  return 0;
}
