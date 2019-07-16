#!/bin/sh

main() {
  if [ "$WERCKER_YARN_INSTALL_USE_CACHE" == "true" ]; then
    info "Using wercker cache"
    setup_cache
  fi

  set +e
  yarn_install
  set -e

  success "Finished yarn install"
}

setup_cache() {
  debug 'Creating $WERCKER_CACHE_DIR/wercker/yarn'
  mkdir -p "$WERCKER_CACHE_DIR/wercker/yarn"
  
  debug 'Configuring yarn to use wercker cache'
  yarn config set cache-folder "$WERCKER_CACHE_DIR/wercker/yarn"
}

clear_cache() {
  warn "Clearing yarn cache"
  yarn cache clean
  
  # make sure the cache contains something, so it will override cache that get's stored
  debug 'Creating $WERCKER_CACHE_DIR/wercker/yarn'
  mkdir -p "$WERCKER_CACHE_DIR/wercker/yarn"
  printf keep > "$WERCKER_CACHE_DIR/wercker/yarn/.keep"
}

yarn_install() {
  local retries=3;
  for try in $(seq "$retries"); do
    info "Starting yarn install, try: $try"
    yarn install $WERCKER_YARN_INSTALL_OPTIONS && return;

    if [ "$WERCKER_YARN_INSTALL_CLEAR_CACHE_ON_FAILED" == "true" ]; then
      clear_cache
    fi
  done

  fail "Failed to successfully execute yarn install, retries: $retries"
}

main;
