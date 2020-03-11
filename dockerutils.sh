#!/bin/sh
dockerContainerID()
{
    V_DOCKERCONTAINERID=$(docker ps | grep $1":" | cut -c 1-12)
}

dockerVersion()
{
    docker_version="$(docker version -f "{{ .Server.Version }}")"
    docker_major="$(echo "$docker_version" | cut -d . -f 1)"
    docker_minor="$(echo "$docker_version" | cut -d . -f 2)"
}