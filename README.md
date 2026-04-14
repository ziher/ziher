## ZiHeR

Open source book of account platform used by the scouts teams from [Związek Harcerstwa Rzeczypospolitej](http://www.zhr.pl) from Poland.

## Contributing

[![Build Status](https://travis-ci.org/ziher/ziher.png?branch=master)](https://travis-ci.org/ziher/ziher)
[![Code Climate](https://codeclimate.com/github/ziher/ziher.png)](https://codeclimate.com/github/ziher/ziher)
[![Coverage Status](https://coveralls.io/repos/ziher/ziher/badge.png)](https://coveralls.io/r/ziher/ziher)

## Getting started

### Vagrant

To get ZiHeR up and running on your local machine:

1. Clone the git repo
1. Install [Vagrant](http://www.vagrantup.com/)
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. Cd to where you cloned ZiHeR
1. `vagrant up`
1. `vagrant ssh`
1. `cd /ziher`
1. `rails server -u webrick -b 0.0.0.0`
1. Go to <http://192.168.33.10:3000> in your browser

### Docker

The fastest way to run ZiHeR locally — one command, no Ruby/Postgres on the host.

Requirements: [Docker](https://docs.docker.com/get-docker/) with Compose plugin.

```bash
git clone https://github.com/ziher/ziher.git
cd ziher
docker compose -f docker-compose.dev.yml up
```

The first run builds the image and starts four services:

| Service | Description |
|---|---|
| `postgres` | PostgreSQL 16 database |
| `ziher` | Rails web application on port 3000 |
| `ziher-jobs` | Solid Queue worker (background jobs, KSeF sync) |
| `mailhog` | SMTP trap — catches all outgoing mail |

On first boot the entrypoint creates the database, runs migrations and seeds.
Open <http://localhost:3000> and log in with `admin@dev.zhr.pl` / `admin@dev.zhr.pl`
(superadmin). A regular unit user `user@dev.zhr.pl` / `user@dev.zhr.pl` is also
available.

The repository is bind-mounted into the container, so edits on the host are
picked up by Rails reload immediately.

#### Mail

All emails sent by the application (KSeF invoice assignments, sync failure
alerts, certificate expiry warnings) are caught by **MailHog** instead of being
delivered. Open <http://localhost:8025> to browse the inbox.

#### Common commands

```bash
# run in the background
docker compose -f docker-compose.dev.yml up -d

# follow logs for a specific service
docker compose -f docker-compose.dev.yml logs -f ziher
docker compose -f docker-compose.dev.yml logs -f ziher-jobs

# rails console
docker compose -f docker-compose.dev.yml exec ziher bundle exec rails console

# run migrations
docker compose -f docker-compose.dev.yml exec ziher bundle exec rails db:migrate

# run tests
docker compose -f docker-compose.dev.yml exec ziher bin/rails test

# stop all services
docker compose -f docker-compose.dev.yml down

# full reset — also wipes the Postgres volume
docker compose -f docker-compose.dev.yml down -v

# rebuild after Gemfile / Dockerfile changes
docker compose -f docker-compose.dev.yml up --build
```

### KSeF integration

Ziher pulls cost invoices from the Polish national e-invoice system (KSeF 2.0)
on a 30-minute schedule via Solid Queue.

**Setup:**

1. Log in as superadmin and open **KSeF → Konfiguracja KSeF**.
2. Fill in your organization's NIP and paste the KSeF certificate and private
   key (PEM format). Both are stored encrypted at rest. A passphrase is optional.
3. Click **Zapisz konfigurację**.

**Invoice flow:**

| Status | Meaning | Who acts |
|---|---|---|
| `nowa` | Freshly synced, pending review | Superadmin |
| `nieprzypisana` | Released to the claim pool | Any unit user |
| `przypisana` | Attached to a scout unit | Unit manager |
| `zaimportowana` | Imported into a journal as an entry | — |
| `odrzucona` | Dismissed (not relevant) | Superadmin |

- **Superadmin** assigns incoming invoices to units or releases them to the
  shared pool. Unit managers receive an email notification on assignment.
- **Unit managers** see invoices assigned to their units, choose an expense
  category per line item and import the invoice into the appropriate journal
  (finance or bank book) as a regular entry.

**Sync:**

The background worker (`ziher-jobs`) runs the sync automatically every 30 minutes.
To trigger it manually from the UI use the **Pobierz z KSeF** button on the invoice
list, or the **Uruchom synchronizację teraz** button in settings.

For a one-off backfill of a specific date range (max 3 months − 1 day) use the
**Synchronizacja jednorazowa** panel in settings — this does not affect the regular
sync watermark.

To trigger programmatically:

```bash
docker compose -f docker-compose.dev.yml exec ziher \
  bin/rails runner 'Ksef::SyncJob.perform_later'
```

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
