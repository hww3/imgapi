
inherit Fins.FinsController;
inherit Fins.RootController;

constant __uses_session = 0;

Fins.FinsController images;

protected void create(object application)
{
  ::create(application);
  images = load_controller("images_controller");
  before_filter(app->get_and_head_only);
}

void index(object id, object response, mixed ... args)
{
  string req = sprintf("%O", mkmapping(indices(id), values(id)));
  string con = master()->describe_object(this);
  string method = function_name(backtrace()[-1][2]);
  object v = view->get_view("internal:index");

  v->add("appname", "imgapi");
  v->add("request", req);
  v->add("controller", con);
  v->add("method", method);

  response->set_view(v);
}

void ping(object id, object response, mixed ... args)
{
  mapping r = ([]);

  r->ping = "pong";
  r->version = "1.0";
  r->imgapi = Val.true;
  
  response->set_data(Standards.JSON.encode(r));
  response->set_type("application/json");
}
