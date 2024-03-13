#!/bin/bash

if test -f ${DOCKER_PATH}/.first_setup-completed; then
  exit
fi

mkdir -p ${DOCKER_PATH}
touch ${DOCKER_PATH}/.first_setup-completed

echo "
-----------------------------------------------------------------------------
First time setup 
-----------------------------------------------------------------------------"
usermod -a -G root nobody
rm -rf /code/${DOCKER_CODE} \
&& mv /usr/local/${DOCKER_CODE} /code/${DOCKER_CODE} \
&& rm -rf /usr/local/${DOCKER_CODE} \
&& ln -s /code/${DOCKER_CODE} /usr/local/${DOCKER_CODE}

touch ${DOCKER_PATH}/.javaversion
chmod 777 ${DOCKER_PATH}
echo -e '#!/bin/bash\nsource /usr/bin/java-switch ${JAVA_CODE}\n' > ${DOCKER_PATH}/.javaversion
