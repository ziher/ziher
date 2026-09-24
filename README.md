## ZiHeR

Open source book of account platform used by the scouts teams from [Związek Harcerstwa Rzeczypospolitej](http://www.zhr.pl) from Poland.

## Contributing
[![Build Status](https://travis-ci.org/ziher/ziher.png?branch=master)](https://travis-ci.org/ziher/ziher)
[![Code Climate](https://codeclimate.com/github/ziher/ziher.png)](https://codeclimate.com/github/ziher/ziher)
[![Coverage Status](https://coveralls.io/repos/ziher/ziher/badge.png)](https://coveralls.io/r/ziher/ziher)

## Getting started

ZiHeR runs locally in Docker on macOS, Windows, and Linux.

1. Install [Docker](https://docs.docker.com/get-docker/) with Compose.
1. On Windows, also install GNU Make (`winget install ezwinports.make`, Chocolatey, or MSYS2).
1. Clone the git repo and `cd` into it.
1. `make up`
1. Open http://localhost:3000 once the log shows the Rails server. The first start creates the database and seed data.
1. Sign in as `admin@dev.zhr.pl` / `admin@dev.zhr.pl`.

`make up` rebuilds the dev image when needed. Gem and apt downloads stay in the Docker build cache, so later builds skip packages that have not changed.

Other targets: `make logs`, `make shell`, `make test`, `make db-reset`, `make down`, `make clean`.

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

