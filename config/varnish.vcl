import std;

backend default {
  .host = "127.0.0.1";
  .port = "3000";
  .connect_timeout = 3s; 
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
}

sub depersonalize_response {
  unset beresp.http.set-cookie;
}

# default behavior from stock varnish config
# NOTES:
# we had to override the default behavior where varnish will not
# cache if a cookie is sent in the request header, hence this sub
sub default_vcl_recv {
  if (req.restarts == 0) {
    if (req.http.x-forwarded-for) {
        set req.http.X-Forwarded-For =
    	req.http.X-Forwarded-For + ", " + client.ip;
    } else {
        set req.http.X-Forwarded-For = client.ip;
    }
  }
  if (req.request != "GET" &&
    req.request != "HEAD" &&
    req.request != "PUT" &&
    req.request != "POST" &&
    req.request != "TRACE" &&
    req.request != "OPTIONS" &&
    req.request != "DELETE") {
      /* Non-RFC2616 or CONNECT which is weird. */
      return (pipe);
  }
  if (req.request != "GET" && req.request != "HEAD") {
      /* We only deal with GET and HEAD by default */
      return (pass);
  }
  #XXX: original behavior
  #if (req.http.Authorization || req.http.Cookie) {
  #XXX: new behavior
  if (req.http.Authorization) {
      /* Not cacheable by default */
      return (pass);
  }
  return (lookup);
}

sub vcl_recv {
  # REDIRECT: force ssl
  if (  req.http.user-agent !~ "Zombie\.js/"
     && req.http.X-Forwarded-Proto !~ "(?i)https"
     )
  {
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

  call default_vcl_recv;
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

  # if no-cache is set, do not cache (varnish is too stupid to do this by default)
  # this can be hard-overridden by passing the header x-varnish-ttl (see below)
  #
  # and we DO use this trick to tell upstream servers to never cache our main forum pages
  # but to keep it cached a very long time in varnish
  if (beresp.http.cache-control ~ "(?i)no-cache")
  {
    set beresp.ttl = 0s;
  }

  # webapp has specified a varnish-specific ttl to override max-age (this is ultimate override)
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
