POSTGRES_VERSION=9.5.4.2
POSTGRES_SUB_VERSION=${POSTGRES_VERSION:0:3}
POSTGRES_URL=https://github.com/PostgresApp/PostgresApp/releases/download/$POSTGRES_VERSION/Postgres-$POSTGRES_VERSION.zip
# POSTGRES_URL=https://github.com/PostgresApp/PostgresApp/releases/download/9.1.0.0/PostgresApp-9-1-0-0.zip
NODE_VERSION=6.2.2
NODE_URL=https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-darwin-x64.tar.gz
REDIS_VERSION=3.2.3
REDIS_URL=http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz

# check if postgres is already cached
if [ ! -f /tmp/Postgres-$POSTGRES_VERSION.zip ]; then
  curl -sL $POSTGRES_URL -o /tmp/Postgres-$POSTGRES_VERSION.zip &
  echo "Downloading postgres.."
fi

# check if node is already cached
if [ ! -f /tmp/node-v$NODE_VERSION-darwin-x64.tar.gz ]; then
  curl -s $NODE_URL -o /tmp/node-v$NODE_VERSION-darwin-x64.tar.gz &
  echo "Downloading node.."
fi

# check if redis is already cached
if [ ! -f /tmp/redis-$REDIS_VERSION.tar.gz ]; then
  curl -s $REDIS_URL -o /tmp/redis-$REDIS_VERSION.tar.gz &
  echo "Downloading redis.."
fi

wait # wait for all the downloads to finish

CURRENT_PATH=$(pwd) # "$(dirname "${BASH_SOURCE[0]}")"
ENVIRONMENT=${VIRTUAL_ENV:=$CURRENT_PATH/venv}

# check that the environment exists
if [ ! -e $ENVIRONMENT ]; then
  echo "The path $ENVIRONMENT must exist, please run:"
  echo "$ virtualenv $ENVIRONMENT"
  exit 1
fi

# ensures that all the folders are present
mkdir -p $ENVIRONMENT/{bin,lib,include,share,run}


# install postgres
# ===============================
if [ ! -e $ENVIRONMENT/bin/postgres ]; then
  unzip /tmp/Postgres-$POSTGRES_VERSION -d /tmp/
  # scan the dirrectory for any excecutable file before we copy them.
  for file in $(find /tmp/Postgres.app/Contents/Versions/$POSTGRES_SUB_VERSION -type f -perm -u+x); do
    # check to see if the file has any `/Application/Postgres.app` references
    for dependency in $(otool -L $file | grep Postgres.app | grep -v '\:$' | awk '{print $1}'); do
      # change them to the local $ENVIRONMENT
      install_name_tool -change $dependency $ENVIRONMENT/lib/$(basename $dependency) $file
    done
  done

  cp -r /tmp/Postgres.app/Contents/Versions/$POSTGRES_SUB_VERSION/bin/* $ENVIRONMENT/bin
  cp -r /tmp/Postgres.app/Contents/Versions/$POSTGRES_SUB_VERSION/include/* $ENVIRONMENT/include
  cp -r /tmp/Postgres.app/Contents/Versions/$POSTGRES_SUB_VERSION/lib/* $ENVIRONMENT/lib
  cp -r /tmp/Postgres.app/Contents/Versions/$POSTGRES_SUB_VERSION/share/* $ENVIRONMENT/share
  # clean up
  rm -rf /tmp/{Postgres-$POSTGRES_VERSION,Postgres.app}
fi

# install node
# ===============================
if [ ! -e $ENVIRONMENT/bin/node ]; then
  tar -xzvf /tmp/node-v$NODE_VERSION-darwin-x64.tar.gz -C /tmp/
  cp -r /tmp/node-v$NODE_VERSION-darwin-x64/bin/* $ENVIRONMENT/bin
  cp -r /tmp/node-v$NODE_VERSION-darwin-x64/include/* $ENVIRONMENT/include
  cp -r /tmp/node-v$NODE_VERSION-darwin-x64/lib/* $ENVIRONMENT/lib
  cp -r /tmp/node-v$NODE_VERSION-darwin-x64/share/* $ENVIRONMENT/share
  # fixes npm
  ln -sf ../lib/node_modules/npm/bin/npm-cli.js $ENVIRONMENT/bin/npm
  # clean up
  rm -rf /tmp/node-v$NODE_VERSION-darwin-x64
fi


# install redis
# ===============================
if [ ! -e $ENVIRONMENT/bin/redis-server ]; then
  tar -xzvf /tmp/redis-$REDIS_VERSION.tar.gz -C /tmp/
  # compile redis
  cd /tmp/redis-$REDIS_VERSION
  make && make PREFIX=$ENVIRONMENT install
  cd -
  # clean up
  rm -rf /tmp/redis-$REDIS_VERSION
fi


# setup commands
# ===============================
IFS='' read -r -d '' HELPER_FUNCTIONS <<-'EOF'
function start_pg() {
  if [ -e $ENVIRONMENT/data/postmaster.pid ]; then
    echo "Postgres is already running.";
    return 1;
  fi;

  printf 'Starting postgres';

  # hides away the fact that the process was forked
  { $ENVIRONMENT/bin/postgres -D $ENVIRONMENT/data \
      -d 5 \
      -c listen_addresses= \
      >> /tmp/greendale_pg.log 2>&1 & } 3>&2 2>/dev/null

  while [ ! -f $ENVIRONMENT/data/postmaster.pid ]; do
    printf '.';
    sleep 1;
  done;

  printf " Done\n";
};

function stop_pg() {
  if [ ! -e $ENVIRONMENT/data/postmaster.pid ]; then
    echo "Postgres is not running.";
    return 1;
  fi;

  kill -INT $(head -1 $ENVIRONMENT/data/postmaster.pid);
  echo "Postgres stopped."
};

function status_pg() {
  if [ -e $ENVIRONMENT/data/postmaster.pid ]; then
    echo "Postgres is running.";
  else
    echo "Postgres is not running.";
  fi;
};

function start_redis() {
  if [ -e $ENVIRONMENT/run/redis.pid ] && ps -p $(head -1 $ENVIRONMENT/run/redis.pid) > /dev/null; then
    echo "Redis is already running.";
    return 1;
  fi;

  printf 'Starting redis';

  # hides away the fact that the process was forked
  { $ENVIRONMENT/bin/redis-server >> /tmp/greendale_redis.log 2>&1 & } 3>&2 2>/dev/null
  echo $! > $ENVIRONMENT/run/redis.pid

  printf " Done\n";
};

function stop_redis() {
  if [ ! -e $ENVIRONMENT/run/redis.pid ]; then
    echo "Redis is not running.";
    return 1;
  fi;

  kill -INT $(head -1 $ENVIRONMENT/run/redis.pid);
  rm -rf $ENVIRONMENT/run/redis.pid
  echo "Redis stopped."
};

function status_redis() {
  if [ -e $ENVIRONMENT/run/redis.pid ] && ps -p $(head -1 $ENVIRONMENT/run/redis.pid) > /dev/null; then
    echo "Redis is running.";
  else
    echo "Redis is not running.";
  fi;
};
EOF

IFS='' read -r -d '' HELPER_VARIABLES <<-'EOF'
export DJANGO_SETTINGS_MODULE=settings.local_settings
EOF

# setup the commands in the activate command, so we can use them from there
echo "$HELPER_FUNCTIONS" | sed 's/ENVIRONMENT/VIRTUAL_ENV/g' > $ENVIRONMENT/bin/_helper_functions.sh
echo "$HELPER_VARIABLES" > $ENVIRONMENT/bin/_helper_variables.sh
chmod +x $ENVIRONMENT/bin/{_helper_variables,_helper_functions}.sh

# set up the commands to be used inside this file
eval "$HELPER_FUNCTIONS"
eval "$HELPER_VARIABLES"

# only write the function link and variables once
if ! grep -q ". ./_helper_functions" $ENVIRONMENT/bin/activate; then
  echo ". _helper_functions.sh" >> $ENVIRONMENT/bin/activate
  echo ". _helper_variables.sh" >> $ENVIRONMENT/bin/activate
fi


# set up the user
# ===============================
if [ ! -e $CURRENT_PATH/settings/local_settings.py ]; then
  cp $CURRENT_PATH/settings/local.py $CURRENT_PATH/settings/local_settings.py
fi


# setup the db
# ===============================
if [ ! -e $ENVIRONMENT/data ]; then
  $ENVIRONMENT/bin/initdb -D $ENVIRONMENT/data
  start_pg # starts the db
  $ENVIRONMENT/bin/psql postgres < .utils/reset-db.sql
fi


# install python dependencies
# ===============================
PATH=$ENVIRONMENT/bin:$PATH
export CFLAGS="-I$(xcrun --show-sdk-path)/usr/include/sasl"
REQUIREMENTS_PATH=$CURRENT_PATH/requirements
# saves time by not trying to install the two dependencies (eab_base, student-path)
# we're going to be installing locally anyways.. no need to clone it from git.. slow
REQUIREMENTS_WITHOUT_MAIN_DEPS=$(cat $REQUIREMENTS_PATH/local.txt | grep -v '^#\|git\|^$' | tr '\n' ' ' | sed "s|base.txt|$REQUIREMENTS_PATH/base.txt|")
$ENVIRONMENT/bin/pip install $REQUIREMENTS_WITHOUT_MAIN_DEPS
$ENVIRONMENT/bin/pip install -e ../eab_base
$ENVIRONMENT/bin/pip install -e ../student-path
