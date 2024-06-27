#!/bin/bash

# Configuration
APP_DIR=~/cla-enforcer
APP_BIN=$APP_DIR/bin/cla-enforcer
APP_LOG=$APP_DIR/logs/app.log
APP_PID=$APP_DIR/app.pid
APP_ENV=$APP_DIR/.env
PUMA_PORT=5000 # Change to 5005 for staging

# Charger le profil bash
source ~/.bash_profile

start() {
    if [ -f $APP_PID ] && kill -0 $(cat $APP_PID); then
        echo "Application is already running"
        exit 1
    fi
    echo "Starting application..."
    cd $APP_DIR
    bundle exec dotenv -f $APP_ENV $APP_BIN > $APP_LOG 2>&1 &
    echo $! > $APP_PID
    echo "Application started with PID $(cat $APP_PID)"
}

stop() {
    if [ ! -f $APP_PID ] || ! kill -0 $(cat $APP_PID); then
        echo "Application is not running"
        exit 1
    fi
    echo "Stopping application..."

    # Kill the main application process
    kill -9 $(cat $APP_PID)
    rm -f $APP_PID

    # Kill only the Puma processes listening on the specified port
    PUMA_PIDS=$(lsof -i tcp:$PUMA_PORT -t)
    if [ ! -z "$PUMA_PIDS" ]; then
        echo "Stopping Puma processes on port $PUMA_PORT..."
        kill -9 $PUMA_PIDS
        echo "Puma processes on port $PUMA_PORT stopped"
    fi

    echo "Application stopped"
}

restart() {
    stop
    start
}

status() {
    if [ -f $APP_PID ] && kill -0 $(cat $APP_PID); then
        echo "Application is running with PID $(cat $APP_PID)"
    else
        echo "Application is not running"
    fi

    # Check for Puma processes listening on the specified port
    PUMA_PIDS=$(lsof -i tcp:$PUMA_PORT -t)
    if [ ! -z "$PUMA_PIDS" ]; then
        echo "Puma processes are running on port $PUMA_PORT with PIDs: $PUMA_PIDS"
    else
        echo "No Puma processes are running on port $PUMA_PORT"
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
