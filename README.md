# docker-ttrss

This [Docker](https://www.docker.com) image allows you to run the [Tiny Tiny RSS](http://tt-rss.org) feed reader. An image is available as a [trusted build on the docker index](https://hub.docker.com/r/talmai/docker-ttrss/).

## About Tiny Tiny RSS

> *From [the official readme](https://git.tt-rss.org/fox/tt-rss/src/master/README.md):*

Web-based news feed aggregator, designed to allow you to read news from any location, while feeling as close to a real desktop application as possible.

![](http://tt-rss.org/images/1.9/1.jpg)

## Quickstart

This section assumes you want to get started quickly, the following sections explain the
steps in more detail. So let's start.

Build your docker image:

```bash
$ make
```

If your docker hub is not configured for automated builds, push it via:

```bash
$ make push
```

The assumption is that you have a database service/container running somewhere. For example:

```bash
$ docker run -d --name ttrssdb postgres
```

Using it is as simple as launching this Tiny Tiny RSS installation linked to your fresh database:

```bash
$ docker run -d --link ttrssdb:db -p 80:80 talmai/docker-ttrss -e DB_TYPE=pgsql
```

Running this command for the first time will download the images automatically.

## Allowed parameters

You can specify the following parameters:

### Database type

```
-e DB_TYPE=pgsql
-e DB_TYPE=mysql
```

TT-RSS only runs on PostgreSQL (9.1 or newer) or MySQL (InnoDB is required). 

### Database Configuration

```
-e DB_PORT="<database port>" (defaults to 5432. Installation ports are 3306/mysql and 5432/pgsql)
-e DB_HOST=<database host> (defaults to 'localhost')
-e DB_NAME="<database name>" (defaults to "ttrss")
-e DB_USER="<database username>" (defaults to $DB_NAME)
-e DB_PASS="<database password>" (defaults to $DB_USER)
```

### HOST_URL

The `HOST_URL` config value should be set to the URL where this TinyTinyRSS
will be accessible at. Setting it correctly will enable PUSH support and make
the browser integration work. Default value: `http://localhost`.

For more information check out the [official documentation](https://github.com/gothfox/Tiny-Tiny-RSS/blob/master/config.php-dist#L22).

```
-e HOST_URL=https://example.org/ttrss
```

## Accessing your webinterface

The above example exposes the Tiny Tiny RSS webinterface on port 80, so that you can browse to:

http://localhost/

The default login credentials are:

* Username: admin
* Password: password

Obviously, you're recommended to change these as soon as possible.


### Original/Forked License notes

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

Copyright (c) 2005 Andrew Dolgov (unless explicitly stated otherwise).

Uses Silk icons by Mark James: http://www.famfamfam.com/lab/icons/silk/
