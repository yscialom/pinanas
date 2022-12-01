#!/bin/sh

assembles () {
    input="application.yml"
    while IFS=$'\n' read apps
    do
        cat "$apps".dc.yml >> docker-compose.yml
    done
rm *.dc.yml
rm applications.yml
}

clean () {
    rm *.dc.yml
    rm applications.yml
}

assembles

