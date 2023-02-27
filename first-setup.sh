#!/bin/bash

if ! [ -f /code/.system-v1/.docker/setup.lock ]
then
echo "
-----------------------------------------------------------------------------
First time setup 
-----------------------------------------------------------------------------"

mkdir -p /code/.system-v1/.docker
usermod -a -G root nobody
rm -rf /code/.system-v1/nvm \
    && mv $NVM_DIR /code/.system-v1/ \
    && rm -rf $NVM_DIR \
    && ln -s /code/.system-v1/nvm $NVM_DIR \
    && echo $NVM_DIR \
    && touch /code/.system-v1/.docker/setup.lock

else
rm -rf $NVM_DIR && ln -s /code/.system-v1/nvm $NVM_DIR 
exit 1
fi
