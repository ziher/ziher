# rake db:structure:dump
rake db:drop
rake db:create
PGPASSWORD=ziher psql -h localhost -U ziher -d ziher_development < postgres.dump
rake db:seed
