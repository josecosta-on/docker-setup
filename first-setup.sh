#!/bin/bash

DIR=$1

if ! [ -f /code/$DIR/.docker/setup.lock ]
then
echo "
-----------------------------------------------------------------------------
First time setup 
-----------------------------------------------------------------------------"

mkdir -p /code/$DIR/.docker
usermod -a -G root nobody
rm -rf /code/$DIR/nvm \
    && mv $NVM_DIR /code/$DIR/ \
    && rm -rf $NVM_DIR \
    && ln -s /code/$DIR/nvm $NVM_DIR \
    && echo $NVM_DIR \
    && touch /code/$DIR/.docker/setup.lock

else
rm -rf $NVM_DIR && ln -s /code/$DIR/nvm $NVM_DIR 
exit 1
fi
