#!/bin/bash

echo ====================== Przygowotuje maszyne...
sudo -H -u vagrant -i echo "export LANGUAGE=en_US.UTF-8" >> /etc/bash.bashrc
sudo -H -u vagrant -i echo "export LANG=en_US.UTF-8" >> /etc/bash.bashrc
sudo -H -u vagrant -i echo "export LC_ALL=en_US.UTF-8" >> /etc/bash.bashrc

locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export DEBIAN_FRONTEND=noninteractive
apt-get update

apt-get install --yes docker.io docker-compose
usermod -aG docker vagrant

echo ====================== Instaluje RVM
apt-get install --yes git curl vim
sudo -H -u vagrant -i bash -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
sudo -H -u vagrant -i bash -c "curl -L https://get.rvm.io | bash -s stable --ruby=2.4.2"
sudo -H -u vagrant -i echo "source /home/vagrant/.rvm/scripts/rvm" >> /home/vagrant/.bashrc

# some ruby variables to make ZiHeR a wee bit faster
sudo -H -u vagrant -i echo "export RUBY_GC_HEAP_INIT_SLOTS=800000" >> /home/vagrant/.bashrc
sudo -H -u vagrant -i echo "export RUBY_HEAP_FREE_MIN=100000" >> /home/vagrant/.bashrc
sudo -H -u vagrant -i echo "export RUBY_HEAP_SLOTS_INCREMENT=300000" >> /home/vagrant/.bashrc
sudo -H -u vagrant -i echo "export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1" >> /home/vagrant/.bashrc
sudo -H -u vagrant -i echo "export RUBY_GC_MALLOC_LIMIT=79000000" >> /home/vagrant/.bashrc
sudo -H -u vagrant -i echo "force_color_prompt=yes" >> /home/vagrant/.bashrc

# https://github.com/mitchellh/vagrant/issues/866 - ~/.bashrc is not loaded in 'vagrant ssh' sessions
sudo -H -u vagrant -i echo "source ~/.bashrc" >> /home/vagrant/.bash_profile

echo ====================== Instaluje PostgreSQL
docker-compose -f /vagrant/docker/docker-compose.yml up -d postgres
apt-get install --yes libpq-dev
docker exec -u postgres postgres bash -c "psql postgres -c \"create user ziher with password 'ziher' createdb\""

#echo ====================== Sciagam kod zrodlowy ZiHeR-a
# Tutaj mamy problem jajka i kury - co ma byc najpierw, kod wyciagniety z gita, czy git?
# Na razie zakladam, ze uzytkownik sciagnal sobie kod wczesniej i z katalogu glownego odpala Vagranta.
#sudo -H -u vagrant -i git clone https://github.com/zhr/ziher.git /vagrant/
sudo -H -u vagrant -i bash -c "git config --global color.ui true"

echo ====================== Sciagam gemy i uzupelniam baze danych
apt-get install --yes g++
# pakiety potrzebne dla wkhtmltopdf
apt-get install --yes libfontconfig1 libxrender1
sudo -H -u vagrant -i bash -c "gem install bundle"
sudo -H -u vagrant -i bash -c "cd /vagrant; bundle install"
sudo -H -u vagrant -i bash -c "cd /vagrant; rake db:create:all"
sudo -H -u vagrant -i bash -c "cd /vagrant; rake db:setup"
sudo -H -u vagrant -i bash -c "cd /vagrant; rake db:migrate RAILS_ENV=test"

echo '====================== ZiHeR jest gotowy do zabawy!'
echo '====================== Aby zalogowac sie na maszyne wpisz'
echo '====================== $ vagrant ssh <enter>'
echo '======================'
echo '====================== Nastepnie wejdz do katalogu z ZiHeRem'
echo '====================== $ cd /vagrant <enter>'
echo '======================'
echo '====================== Po czym odpal serwer http ktory poda Ci ZiHeRa na tacy'
echo '====================== $ rails server -b 0.0.0.0 <enter>'
echo '======================'
echo '====================== Po wykonaniu tych komend twoj wlasny i niepowtarzalny ZiHeR czeka na Ciebie :]'
echo '====================== W przegladarce wpisz: http://192.168.33.10:3000'
echo '====================== (uzytkownik: admin@ziher, haslo: admin@ziher)'
