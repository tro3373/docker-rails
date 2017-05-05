IMAGENAME=
CONTAINERNAME=rails
DBCONTAINERNAME=postgres
VERSION=1.0.0

RAILS_VERSION=5.1.0.rc1

all_container=`docker ps -a -q`
active_container=`docker ps -q`
images=`docker images | awk '/^<none>/ { print $$3 }'`

# .PHONY: `build` ディレクトリがあっても実行
.PHONY: build
default: build bundle_install

build_all: build gen_gemfile rails_new bundle_update add_database_env db_setup stop done

done:
	@echo "Done!"

# @see http://qiita.com/skyriser/items/2cf98b747ed6577cc5ee
# @see https://docs.docker.com/compose/rails/#define-the-project
# @see http://qiita.com/kbaba1001/items/39f81156589dd9a0d678
# docker-compose build
# docker build .
build:
	docker-compose build

gen_gemfile:
	@if [ ! -e ./app ]; then \
		mkdir app; \
	fi; \
	if [ ! -e ./app/Gemfile ]; then \
		echo "source 'https://rubygems.org'" >> ./app/Gemfile \
		&& echo "gem 'rails', '${RAILS_VERSION}'" >> ./app/Gemfile; \
	fi; \
	if [ ! -e ./app/Gemfile.lock ]; then \
		touch ./app/Gemfile.lock; \
	fi

rails_new:
	@docker-compose run web bundle install \
	&& docker-compose run web bundle exec rails new . --force --database=postgresql --skip-bundle \
	&& sudo chown -R $$USER:$$USER ./app

# database.yml 内の `pool:` の文字列の入っている行の次の行に、DB USER/PASS/HOST のENV設定を追加する.
# $(shell sed -i -e '/pool:/s/\(.\+\)/\1\n  username: <%= ENV["DB_USERNAME"] %>\n  password: <%= ENV["DB_PASSWORD"] %>\n  host: <%= ENV["DB_HOST"] %>/g' ./app/config/database.yml)
add_database_env:
	@sed -i -e '/pool:/s/\(.\+\)/\1\n  username: <%= ENV["DB_USERNAME"] %>\n  password: <%= ENV["DB_PASSWORD"] %>\n  host: <%= ENV["DB_HOST"] %>/g' ./app/config/database.yml

bundle_install:
	docker-compose run web bundle install \
	&& sudo chown -R $$USER:$$USER ./app

bundle_update:
	docker-compose run web bundle update \
	&& sudo chown -R $$USER:$$USER ./app

db_setup:
	docker-compose run web bundle exec rake db:setup \
		|| docker-compose run web bundle exec rake db:migrate

db_migrate:
	docker-compose run web bundle exec rake db:migrate

start:
	docker-compose up -d && docker-compose logs

stop:
	docker-compose stop && docker-compose rm -f

restart: stop start

logs:
	docker-compose logs

console: attach

attach:
	docker exec -it $(CONTAINERNAME) /bin/bash --login

console_db: attach_db

attach_db:
	docker exec -it $(DBCONTAINERNAME) /bin/bash --login

# tag:
# 	docker tag $(IMAGENAME):$(VERSION) $(NAME):latest

clean: clean_container clean_images

clean_images:
	@if [ "$(images)" != "" ] ; then \
		docker rmi $(images); \
	fi

clean_container:
	@for a in $(all_container) ; do \
		for b in $(active_container) ; do \
			if [ "$${a}" = "$${b}" ] ; then \
				continue 2; \
			fi; \
		done; \
		docker rm $${a}; \
	done
