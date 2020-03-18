
inherit Fins.Application;

string data_dir;
object monitor;

mixed images;

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

  monitor = Monitor(data_dir, change_cb);

}

void change_cb() {
  images = 0;
}


int get_and_head_only(object request, object response, mixed ... args)
{
  if ((<"GET", "HEAD">)[request->request_type]) return 1;
  response->bad_request(request->request_type + " not supported.");
  return 0;
}

Stdio.File get_file(object uuid) {

  mixed manifest = find_manifest(uuid);

  if(!manifest) {
    werror("Unable to find manifest for uuid " + uuid + "\n");
    return 0;
  }

werror("manifest: %O\n", manifest);
  string fn = Stdio.append_path(data_dir, manifest->_fn + ".zfs.gz");
  if(!file_stat(fn)) {
    werror("Unable to find " + manifest->_fn + ".zfs.gz\n");
    return 0;
  }

  Stdio.File file = Stdio.File(fn, "r");
  return file;
}

mapping find_manifest(object uuid) {

  foreach(get_manifests();; mixed manifest) {
     if(manifest && manifest->uuid == (string)uuid) return manifest + ([]);
  }

  return 0;
}

array get_manifests() {
  if(images) return images;

  ADT.List list = ADT.List();

  foreach(glob("*.json", get_dir(data_dir));; string fn) {
    mixed json;
    mixed err = catch(json = Standards.JSON.decode(Stdio.read_file(Stdio.append_path(data_dir, fn))));

    if(err) 
      werror("Error parsing JSON from file " + fn + ": " + Error.mkerror(err)->message());
    else if(json) 
      list->append(json + (["_fn": fn[..<5] ]));
  } 
  return (images=(array)list);
}

class Monitor {
  inherit Filesystem.Monitor.symlinks;

  function change_cb;

  void create(string datadir, function _change_cb) {
    ::create();
    change_cb = _change_cb;
    monitor(datadir, 3);
    set_nonblocking(1);
  }


  void file_created(string path, Stdio.Stat st) {
    werror("file_created: %O\n", path);
    if(change_cb) change_cb();
  }
 
  void file_deleted(string path) {
    werror("data changed: %O\n", path);
    if(change_cb) change_cb();
  }

  void data_changed(string path) {
    werror("data_changed: %O\n", path);
    if(change_cb) change_cb();
  }
}
