import std;

backend default {
  .host = "127.0.0.1";
  .port = "3000";
  .connect_timeout = 3s; 
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
}

sub vcl_recv {
  # force ssl
  if (req.request == "GET" || req.request == "HEAD") {
    if (req.url != "/" && req.url ~ "(?i)/$") {
      set req.http.Location = "https://" + req.http.host + regsub(req.url, "(.+)/$", "\1");
      error 302 "Found"; 
    }
    else if (req.http.X-Forwarded-Proto !~ "(?i)https") {
      set req.http.Location = "https://" + req.http.host + req.url; 
      error 302 "Found"; 
    }
  }
}

sub vcl_deliver {
  unset resp.http.via;
  unset resp.http.x-varnish;
  unset resp.http.x-powered-by;
  set resp.http.Server ="powerbulletin";

  # security headers
  set resp.http.X-Content-Type-Options = "nosniff";
  set resp.http.X-XSS-Protection = "1; mode=block";
  set resp.http.X-Frame-Options = "SAMEORIGIN";
  set resp.http.Strict-Transport-Security = "max-age=31536000; includeSubDomains";
}

sub vcl_fetch {
  set beresp.do_gzip = true;
}

sub vcl_error { 
  # redirect, permanent
  if (obj.status == 301 || obj.status == 302) {
    set obj.http.Location = req.http.Location; 

    # never cache this type of redirect
    set obj.ttl = 0s;

    return(deliver); 
  }
} 
