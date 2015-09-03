# rake db:structure:dump
rake db:drop
rake db:create
PGPASSWORD=ziher psql -h localhost -U ziher -d ziher_development < postgres.dump
cp db/import-seeds.rb db/seeds.rb
rake db:seed
git checkout db/seeds.rb
