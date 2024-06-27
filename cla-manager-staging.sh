#!/bin/bash
APP_DIR=~/cla-enforcer
APP_BIN=$APP_DIR/bin/cla-enforcer
APP_LOG=$APP_DIR/logs/app-staging.log
APP_PID=$APP_DIR/app-staging.pid
APP_ENV=$APP_DIR/.env.staging

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
    kill -9 $(cat $APP_PID)
    rm -f $APP_PID
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
