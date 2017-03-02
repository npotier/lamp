#
# VCL file for Varnish.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and http://varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "80";
}

sub vcl_recv {
    set req.http.Surrogate-Capability = "abc=ESI/1.0";

    unset req.http.Forwarded;

    if (req.http.X-Forwarded-Proto == "https" ) {
        set req.http.X-Forwarded-Port = "443";
    } else {
        set req.http.X-Forwarded-Port = "80";
    }

    # Normalize Content-Encoding
    if (req.http.Accept-Encoding) {
        # Compress a compressed format is silly
        if (req.url ~ "\.(jpg|jpeg|png|gif|gz|tgz|bz2|lzma|tbz|zip|rar)(\?.*|)$") {
            unset req.http.Accept-Encoding;
        }
        # use gzip when possible, otherwise use deflate
        if (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            # unknown algorithm, remove accept-encoding header
            unset req.http.Accept-Encoding;
        }
    }

    # Clean cookie from things useless for us
    if (req.http.Cookie) {
        set req.http.Cookie = ";" + req.http.Cookie;
        set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
        set req.http.Cookie = regsuball(req.http.Cookie, ";(PHPSESSID)=", "; \1=");
        set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");

        if (req.http.Cookie == "") {
            unset req.http.Cookie;
        }
    }
    if (req.url ~ "^/[^?]+\.(jpeg|jpg|png|gif|ico|js|css|txt|gz|zip|lzma|bz2|tgz|tbz|html|htm)(\?.*|)$") {
        unset req.http.cookie;
    }

    if (req.url ~ "^/[^?]+\.(jpeg|jpg|png|gif|ico|txt|gz|zip|lzma|bz2|tgz|tbz|html|htm)(\?.*|)$") {
        set req.url = regsub(req.url, "\?.*$", "");
    }

}

sub vcl_backend_response {
    if (beresp.http.Surrogate-Control ~ "ESI/1.0") {
        unset beresp.http.Surrogate-Control;
        set beresp.do_esi = true;
    }

    set beresp.do_esi = true;
    set beresp.ttl = 1800s;
    set beresp.grace = 12h;

    if (beresp.status == 403 || beresp.status == 404 || beresp.status == 503 || beresp.status == 500) {
        set beresp.ttl = 10s;
    }
}

sub vcl_deliver {
    if (resp.http.X-Varnish ~ "[0-9]+ +[0-9]+") {
      set resp.http.X-Cache = "HIT";
    } else {
      set resp.http.X-Cache = "MISS";
    }
}
