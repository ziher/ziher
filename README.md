## ZiHeR

Open source book of account platform used by the scouts teams from [Związek Harcerstwa Rzeczypospolitej](http://www.zhr.pl) from Poland.

## Contributing
[![Build Status](https://travis-ci.org/ziher/ziher.png?branch=master)](https://travis-ci.org/ziher/ziher)
[![Code Climate](https://codeclimate.com/github/ziher/ziher.png)](https://codeclimate.com/github/ziher/ziher)
[![Coverage Status](https://coveralls.io/repos/ziher/ziher/badge.png)](https://coveralls.io/r/ziher/ziher)

## Getting started

### Docker (recommended)

The fastest way to run ZiHeR locally — one command, no Ruby/Postgres on the host.

Requirements: [Docker](https://docs.docker.com/get-docker/) with Compose plugin.

```bash
git clone https://github.com/ziher/ziher.git
cd ziher
docker compose -f docker-compose.dev.yml up
```

The first run builds the image, starts PostgreSQL, creates the database, runs
migrations and seeds, then boots Rails. Open http://localhost:3000 and log in
with `admin@dev.zhr.pl` / `admin@dev.zhr.pl` (superadmin seeded by `db/seeds.rb`).
A regular user `user@dev.zhr.pl` / `user@dev.zhr.pl` is also available.

The repository is bind-mounted into the container, so edits on the host are
picked up by Rails reload immediately.

#### Common commands

```bash
# run in the background
docker compose -f docker-compose.dev.yml up -d

# tail logs
docker compose -f docker-compose.dev.yml logs -f ziher

# rails console / rake tasks inside the container
docker compose -f docker-compose.dev.yml exec ziher bundle exec rails console
docker compose -f docker-compose.dev.yml exec ziher bundle exec rails db:migrate

# stop
docker compose -f docker-compose.dev.yml down

# full reset (also wipes the Postgres volume)
docker compose -f docker-compose.dev.yml down -v

# rebuild after Gemfile / Dockerfile changes
docker compose -f docker-compose.dev.yml up --build
```

### Vagrant (legacy)

To get ZiHeR up and running on your local machine:

1. Clone the git repo
1. Install [Vagrant](http://www.vagrantup.com/)
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. Cd to where you cloned ZiHeR
1. `vagrant up`
1. `vagrant ssh`
1. `cd /ziher`
1. `rails server -u webrick -b 0.0.0.0`
1. Go to http://192.168.33.10:3000 in your browser

## Copyright / License

Copyright (C) 2025 Marcin Stożek, Magda Stożek, Andrzej Stencel and other ZiHeR contributors.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

