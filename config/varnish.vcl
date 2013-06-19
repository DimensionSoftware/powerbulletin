import std;

backend default {
  .host = "127.0.0.1";
  .port = "3000";
  .connect_timeout = 3s; 
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
}

sub depersonalize {
  # strip cookies so request is depersonalized (not able to be identified as a particular user by backend by stripping cookies)
  # this also allows default varnish logic to cache request (it avoids cookie requests by default)
  unset req.http.cookie;
  unset req.http.cache-control;
  unset req.http.pragma;
}

sub depersonalize_response {
  unset beresp.http.set-cookie;
}

sub vcl_recv {
  # REDIRECT: force ssl
  if (req.http.X-Forwarded-Proto !~ "(?i)https") {
    set req.http.Location = "https://" + req.http.host + req.url; 
    error 302 "Found"; 
  }

  # pipe any socket.io requests
  if (req.url ~ "(?i)^/socket\.io/") {
    return (pipe);
  }

  # REDIRECT: force no trailing slash (except for homepage)
  if (req.url != "/" && req.url ~ "(?i)/$") {
    set req.http.Location = "https://" + req.http.host + regsub(req.url, "(.+)/$", "\1");
    error 302 "Found"; 
  }
  
  # depersonalize everything EXCEPT urls starting with /auth or /resources or /admin or /socket.io or /ajax
  # also depersonalize ending in /new /edit because they 404 when user is not allowed to do so
  if (  req.url !~ "(?i)^/(auth|resources|admin|socket\.io|ajax)"
     && req.url !~ "(?i)/new$"
     && req.url !~ "(?i)/edit/[^/]+$"
     )
  {
    call depersonalize;
  }
}

sub vcl_fetch {
  set beresp.do_stream = false;
  set beresp.do_gunzip = true;
  set beresp.do_gzip = true;

  # don't cache 404's or redirects
  if (  beresp.status == 404
     || beresp.status == 301
     || beresp.status == 302
     || beresp.status == 303
     )
  {
    set beresp.ttl = 0s;
  }

  # remove set-cookie on all buth /auth (/auth is the only thing that sets cookies)
  if (req.url !~ "(?i)^/(auth)") {
    call depersonalize_response;
  }

  # webapp has specified a varnish-specific ttl to override max-age
  if (beresp.http.x-varnish-ttl)
  {
    set beresp.ttl = std.duration(beresp.http.x-varnish-ttl, 0s);
    # remove internal header
    unset beresp.http.x-varnish-ttl;
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

sub vcl_error { 
  # redirect, permanent
  if (obj.status == 301 || obj.status == 302) {
    set obj.http.Location = req.http.Location; 

    # never cache this type of redirect
    set obj.ttl = 0s;

    return (deliver); 
  }
  else if (  obj.status == 500
          || obj.status == 502
          || obj.status == 503
          || obj.status == 504
          )
  {
    synthetic std.fileread("public/50x.html");
    return (deliver); 
  }
}

sub vcl_pipe {
  # WEBSOCKET support enabled, (have to get to pipe first, though)
  if (req.http.upgrade ~ "(?i)websocket") {
    set bereq.http.upgrade = req.http.upgrade;
  }
  # we want to process headers every request, no keep-alive!
  # this fixes issue where gzip wasn't happening every request (and/or header branding)
  set bereq.http.connection = "close";
}
