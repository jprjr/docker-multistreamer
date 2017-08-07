# docker-multistreamer

A Docker image for [multistreamer](https://github.com/jprjr/multistreamer)

## Introduction

[Multistreamer](https://github.com/jprjr/multistreamer) is a webapp for publishing
to multiple video-streaming services at the same time.

This is an image for running multistreamer in a container.

Now with a handy video! https://youtu.be/HdDDtBOLme4

## Quick Start

You can get this up and running with docker-compose. Copy `docker-compose.override.yml.example`
to `docker-compose.override.yml` and edit as needed, then
then run `docker-compose up`. You'll have multistreamer's web interface
running on port 8081, RTMP ingest on 1935, and IRC on 6667.

With the default settings, there's no real authentication - users get automatically
created at login and saved to redis. Additionally, the chat web interface
is most likely broken, you need to change a few settings to make that work.

## Not-so-quick start

If you mount an htpasswd volume into the container at `/etc/htpasswd-auth-server/htpasswd`,
the container will launch an internal `htpasswd-auth-server` instead of the built-in
redis auth. Or if you're using docker-compose, drop an htpasswd file into the htpasswd
directory at the root of this repo.

If you want to provide actual authentication, set the `MULTISTREAMER_AUTH_ENDPOINT`
environment variable.

Multistreamer makes HTTP requests against said endpoint, using the status
code to determine if the password was correct. Here's a few usable endpoints:

* [redis-auth-server](https://github.com/jprjr/redis-auth-server) - auto-create
and store users in redis (included)
* [htpasswd-auth-server](https://github.com/jprjr/htpasswd-auth-server) - auth
against an htpasswd file (included)
* [ldap-auth-server](https://github.com/jprjr/ldap-auth-server) - auth against
LDAP.

### Things to know:

When you use container linking, Docker updates the `/etc/hosts` file with hostnames,
but nginx ignores that file, and *strictly* looks up hosts via DNS.

### Required environment variables

Here's the list of environment variables you absolutely need to set to ensure
this works correctly:

* `MULTISTREAMER_SESSION_SECRET` - this is used to encrypt client-side session data.

Multistreamer doesn't have any good way to figure out its public hostname,
what proxies it might be behind, whether or not you have an SSL terminator,
and so on - you're expected to provide that by setting these environment
variables. Note: these HTTP/RTMP URLs should be the root of your web host,
regardless of running multistreamer under some path. There's a dedicated
`MULTISTREAMER_HTTP_PREFIX` for changing your prefix.

* `MULTISTREAMER_PUBLIC_HTTP_URL` - This should be the root of the HTTP/HTTPS URL you want
your clients to use. If this is incorrect, things like websockets won't work
correctly.
* `MULTISTREAMER_PUBLIC_RTMP_URL` - This should be the root of the RTMP/RTMPS URL you
want your clients to use.
* `MULTISTREAMER_PUBLIC_IRC_HOSTNAME` - Set this to some hostname for IRC users
* `MULTISTREAMER_PUBLIC_IRC_PORT` - This should be the public-facing port you want
your clients to use.

### Running Multistreamer under some prefix

* `MULTISTREAMER_HTTP_PREFIX` - if you're running Multistreamer at something like
`http://example.com/multistreamer`, set this environment variable to `/multistreamer` (or
whatever your prefix is).

### Specifying a database

You can use a linked Postgres container or manually specify a host/user/pass/dbname.

If you link the official postgres container as `postgresql`, all the database settings
will be figured out. Otherwise, set these environment variables:

* `DB_HOST`
* `DB_PORT` - defaults to 5432
* `DB_USER` 
* `DB_PASS`
* `DB_NAME`

### Specifying a redis instance

You can use a linked Redis container or manually specify a redis host/port.

If you link the official redis container as `redisio`, all the redis settings
will be figured out. Otherwise, set these environment variables:

* `REDIS_HOST`
* `REDIS_PORT`

### Enabling streaming services

The [multistreamer wiki](https://github.com/jprjr/multistreamer/wiki) has details
on registering apps for Facebook, Twitch, and YouTube.

#### Twitch

Specify your client id, secret, and which ingest server to use:

* `MULTISTREAMER_TWITCH_CLIENT_ID`
* `MULTISTREAMER_TWITCH_CLIENT_SECRET`
* `MULTISTREAMER_TWITCH_INGEST_SERVER`

#### YouTube

Specify your client id, secret, and country code:

* `MULTISTREAMER_YOUTUBE_CLIENT_ID`
* `MULTISTREAMER_YOUTUBE_CLIENT_SECRET`
* `MULTISTREAMER_YOUTUBE_COUNTRY_CODE`

#### Facebook

Specify your app ip and secret:

* `MULTISTREAMER_FACEBOOK_APP_ID`
* `MULTISTREAMER_FACEBOOK_APP_SECRET`

#### Mixer

Specify your client id, secret, and which ingest server to use:

* `MULTISTREAMER_MIXER_CLIENT_ID`
* `MULTISTREAMER_MIXER_CLIENT_SECRET`
* `MULTISTREAMER_MIXER_INGEST_SERVER`

### Other environment variables

* `MULTISTREAMER_RTMP_PREFIX` - defaults to 'multistreamer' if unset. This is independent
from the HTTP prefix, and should be a single text value without slashes.
* `MULTISTREAMER_LOG_LEVEL` - defaults to 'error'
* `MULTISTREAMER_PUBLIC_IRC_SSL` - defaults to 'false', set to 'true' if you have an SSL
terminator for multistreamer's IRC port.
* `MULTISTREAMER_SESSION_NAME` - defaults to 'multistreamer'
* `MULTISTREAMER_LOG_QUERIES` - true/false, whether to log every SQL query
* `MULTISTREAMER_LOG_REQUESTS` - true/false, whether to log every HTTP request
* `MULTISTREAMER_IRC_FORCE_JOIN` - defaults to 'false', set to 'true' to have IRC users
force-joined into rooms when they go live.
* `MULTISTREAMER_WORKER_PROCESSES` - defaults to 1, you can change the number of workers
* `MULTISTREAMER_DNS_RESOLVER` - defaults to '8.8.8.8 ipv6=off', see http://nginx.org/en/docs/http/ngx_http_core_module.html#resolver
* `MULTISTREAMER_DICT_STREAMS_SIZE` - defaults to `10m`, this lets you change the shared dictionary
size for keeping active stream information.
* `MULTISTREAMER_DICT_WRITERS_SIZE` - defaults to `10m`, this lets you change the shared dictionary
size for keeping active chat reader/writer information.

