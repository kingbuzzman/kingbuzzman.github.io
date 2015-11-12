#/bin/env/sh

CURRENT_PATH="$(dirname "${BASH_SOURCE[0]}")"
ENVIRONMENT="$CURRENT_PATH/env"

if [ ! -d $ENVIRONMENT ]; then
    mkdir $ENVIRONMENT

    # download ruby
    if [ ! -f /tmp/ruby-2.1.7.tar.bz2 ]; then
      curl -o /tmp/ruby-2.1.7.tar.bz2 "https://rvm.io/binaries/osx/10.10/x86_64/ruby-2.1.7.tar.bz2" &
    fi

    # download node
    if [ ! -f /tmp/node-v0.12.7-darwin-x64.tar.gz ]; then
      curl -o /tmp/node-v0.12.7-darwin-x64.tar.gz "http://nodejs.org/dist/v0.12.7/node-v0.12.7-darwin-x64.tar.gz" &
    fi

    # wait for the downloads to finish
    wait

    # prep the environment
    mkdir -p $ENVIRONMENT/lib/
    mkdir -p $ENVIRONMENT/bin/
    mkdir -p $ENVIRONMENT/include/

    # install ruby
    tar -xjf /tmp/ruby-2.1.7.tar.bz2 -C /tmp/
    cp -r /tmp/ruby-2.1.7/lib/* $ENVIRONMENT/lib/
    cp -r /tmp/ruby-2.1.7/bin/* $ENVIRONMENT/bin/
    cp -r /tmp/ruby-2.1.7/include/* $ENVIRONMENT/include/
    $ENVIRONMENT/bin/gem install bundler

    # install node
    tar -zxvf /tmp/node-v0.12.7-darwin-x64.tar.gz -C /tmp/
    cp -r /tmp/node-v0.12.7-darwin-x64/lib/* $ENVIRONMENT/lib/
    cp -r /tmp/node-v0.12.7-darwin-x64/bin/* $ENVIRONMENT/bin/
    cp -r /tmp/node-v0.12.7-darwin-x64/include/* $ENVIRONMENT/include/
    ln -sf ../lib/node_modules/npm/bin/npm-cli.js $ENVIRONMENT/bin/npm # fixes npm
    # this is going to stay in this environment anyway, no need to polute it with node_modules everywhere
    $ENVIRONMENT/bin/npm config set global true
fi

export PATH="$ENVIRONMENT/bin:$PATH"

bundle install
npm install coffee-script@1.10.0

# helper functions

function runserver() {
    foreman start
}

function cleanup() {
    rm -rf .sass-cache
    rm -rf *.html
    rm -rf css/
    rm -rf js/
}
