import std;

backend default {
  .host = "127.0.0.1";
  .port = "3000";
  .connect_timeout = 3s; 
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
}

sub vcl_deliver {
  unset resp.http.via;
  unset resp.http.x-varnish;
  unset resp.http.x-powered-by;
  set resp.http.Server ="powerbulletin";
}

sub vcl_fetch {
  set beresp.do_gzip = true;
}
