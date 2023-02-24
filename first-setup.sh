#!/bin/bash

if ! [ -f /code/.docker/setup.lock ]
then
echo "
-----------------------------------------------------------------------------
First time setup 
-----------------------------------------------------------------------------"

mkdir -p /code/.docker
usermod -a -G root nobody
rm -rf /code/nvm \
    && mv $NVM_DIR /code/ \
    && rm -rf $NVM_DIR \
    && ln -s /code/nvm $NVM_DIR \
    && echo $NVM_DIR \
    && touch /code/.docker/setup.lock

else
rm -rf $NVM_DIR && ln -s /code/nvm $NVM_DIR 
exit 1
fi
