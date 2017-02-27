#!/bin/bash
set -x

rm -f /etc/service/nginx/down

# for production, looks good CI installs dependencies.
chown -R app:app /var/www
cd /var/www/rails-app
setuser app bundle install --path=../vendor/bundle
if [ "$PASSENGER_APP_ENV" = 'production' ]; then
  setuser app bin/rails assets:precompile
  setuser app bundle install --path=../vendor/bundle --without test development --deployment --clean
fi

SECRET_KEY_BASE=$(setuser app bin/rails secret)
echo "passenger_env_var 'SECRET_KEY_BASE' '$SECRET_KEY_BASE';" >> /etc/nginx/conf.d/10_setenv.conf
echo "passenger_env_var 'RDS_HOSTNAME' '$RDS_HOSTNAME';" >> /etc/nginx/conf.d/10_setenv.conf

# for production, looks good .ebextensions does the things like migration.
RAILS_ENV=$PASSENGER_APP_ENV setuser app bin/rails db:create db:migrate

sed -i -e 's!mesg n || true!mesg n 2>/dev/null || true!' /root/.profile

exit 0
