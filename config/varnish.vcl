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

sub vcl_recv {
  # force no trailing slash (except for homepage)
  if (req.url != "/" && req.url ~ "(?i)/$") {
    set req.http.Location = "https://" + req.http.host + regsub(req.url, "(.+)/$", "\1");
    error 302 "Found"; 
  }
  # force ssl
  else if (req.http.X-Forwarded-Proto !~ "(?i)https") {
    set req.http.Location = "https://" + req.http.host + req.url; 
    error 302 "Found"; 
  }

  # always depersonalize all cdn resources, ttls set automatically by backend
  if (req.http.host ~ "(?i)^muscache\d?\.(pb|pbstage|powerbulletin)\.com$") {
    call depersonalize;
  }
  # homepage and forum page have guest/login split
  #XXX: below will not work right until we implement nocache cookie
  #else if (req.uri == "/" && req.http.cookie !~ "nocache=") {
  #  # if we get in here then we are not 'logged in'
  #  call depersonalize;
  #}
  # TODO: depersonalize profile page, hopefully same for logged in and logged out (can still augment with on-personalize)
  # this is flooder proof since they can't use a cookie to get around it, whereas homepage/profile pages are not, easy to spoof
  # we could try to mask it by using a weird keyname that is nondescript...
  #else if (req.uri ~ "^/profile") {
  #  call depersonalize;
  #}

}

sub vcl_fetch {
  set beresp.do_gzip = true;
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

    return(deliver); 
  }
  else if (obj.status == 500
           || obj.status == 502
           || obj.status == 503
           || obj.status == 504)
  {
    synthetic std.fileread("public/50x.html");
    return(deliver); 
  }
} 
