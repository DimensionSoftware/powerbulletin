import std;

backend d0 {
  .host = "127.0.0.1";
  .port = "6000";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a0 {
  .host = "127.0.0.1";
  .port = "3000";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a1 {
  .host = "127.0.0.1";
  .port = "3001";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a2 {
  .host = "127.0.0.1";
  .port = "3002";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a3 {
  .host = "127.0.0.1";
  .port = "3003";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a4 {
  .host = "127.0.0.1";
  .port = "3004";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a5 {
  .host = "127.0.0.1";
  .port = "3005";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a6 {
  .host = "127.0.0.1";
  .port = "3006";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a7 {
  .host = "127.0.0.1";
  .port = "3007";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a8 {
  .host = "127.0.0.1";
  .port = "3008";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend a9 {
  .host = "127.0.0.1";
  .port = "3009";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c0 {
  .host = "127.0.0.1";
  .port = "4000";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c1 {
  .host = "127.0.0.1";
  .port = "4001";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c2 {
  .host = "127.0.0.1";
  .port = "4002";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c3 {
  .host = "127.0.0.1";
  .port = "4003";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c4 {
  .host = "127.0.0.1";
  .port = "4004";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c5 {
  .host = "127.0.0.1";
  .port = "4005";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c6 {
  .host = "127.0.0.1";
  .port = "4006";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c7 {
  .host = "127.0.0.1";
  .port = "4007";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c8 {
  .host = "127.0.0.1";
  .port = "4008";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend c9 {
  .host = "127.0.0.1";
  .port = "4009";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}

# socket io backends
backend s0 {
  .host = "127.0.0.1";
  .port = "5000";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend s1 {
  .host = "127.0.0.1";
  .port = "5001";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend s2 {
  .host = "127.0.0.1";
  .port = "5002";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend s3 {
  .host = "127.0.0.1";
  .port = "5003";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend s4 {
  .host = "127.0.0.1";
  .port = "5004";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend s5 {
  .host = "127.0.0.1";
  .port = "5005";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend s6 {
  .host = "127.0.0.1";
  .port = "5006";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend s7 {
  .host = "127.0.0.1";
  .port = "5007";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend s8 {
  .host = "127.0.0.1";
  .port = "5008";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}
backend s9 {
  .host = "127.0.0.1";
  .port = "5009";
  .connect_timeout = 5s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = {
    .url = "/probe";
    .interval = 3s;
    .timeout = 1s;
    .window = 2;
    .threshold = 1;
  }
}

# main app backends
director default round-robin {
  {
    .backend = a0;
  }
  {
    .backend = a1;
  }
  {
    .backend = a2;
  }
  {
    .backend = a3;
  }
  {
    .backend = a4;
  }
  {
    .backend = a5;
  }
  {
    .backend = a6;
  }
  {
    .backend = a7;
  }
  {
    .backend = a8;
  }
  {
    .backend = a9;
  }
}

# for muscache.* cache backends
director cache round-robin {
  {
    .backend = c0;
  }
  {
    .backend = c1;
  }
  {
    .backend = c2;
  }
  {
    .backend = c3;
  }
  {
    .backend = c4;
  }
  {
    .backend = c5;
  }
  {
    .backend = c6;
  }
  {
    .backend = c7;
  }
  {
    .backend = c8;
  }
  {
    .backend = c9;
  }
}

director socket round-robin {
  {
    .backend = s0;
  }
  {
    .backend = s1;
  }
  {
    .backend = s2;
  }
  {
    .backend = s3;
  }
  {
    .backend = s4;
  }
  {
    .backend = s5;
  }
  {
    .backend = s6;
  }
  {
    .backend = s7;
  }
  {
    .backend = s8;
  }
  {
    .backend = s9;
  }
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
  # remove www. on these domains:
  if (req.http.host ~ "(?i)www\.dimensionsoftware.com") {
    error 750 "Moved Permanently";
  }

  # REDIRECT: force ssl
  if (  req.http.user-agent !~ "Zombie\.js/"
     && req.http.X-Forwarded-Proto !~ "(?i)https"
     )
  {
    if (req.http.host != "lbox.org" && req.http.host != "hoerling.com" && req.http.host != "dimensionsoftware.com") {
      set req.http.Location = "https://" + req.http.host + req.url; 
      error 302 "Found"; 
    }
  }

  # if it starts with /socket.io then send to socket backend
  if (req.url ~ "(?i)^/socket\.io/") {
    set req.backend = socket;
    # pipe any socket.io requests as they are long polling requests
    return (pipe);
  }
  # if it is dimensionsoftware.com
  else if (req.http.host ~ "(?i)^dimensionsoftware\.com$") {
    set req.backend = d0;
  }
  # if it is hoerling.com
  else if (req.http.host ~ "(?i)^hoerling\.com$" || req.http.host ~ "(?i)^lbox\.org$") {
    error 750 "Moved Permanently";
  }
  # if it is a cdn domain send to cache backend
  else if (req.http.host ~ "(?i)^muscache\d?\.(pb|powerbulletin)\.com$") {
    set req.backend = cache;
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

  # cache socket.io js client library for 1 year
  if (req.url ~ "(?i)^/socket.io/socket.io.js") {
    # 365 * 24 * 60 * 60 = 31536000
    # AKA 1 Year
    set beresp.http.Cache-Control = "max-age=31536000; must-revalidate";
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
  if (obj.status == 750) {
    set obj.http.Location = "http://dimensionsoftware.com" + req.url;
    set obj.status = 301;
    return (deliver);
  }

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
