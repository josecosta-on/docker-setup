echo "
-----------------------------------------------------------------------------
First time setup 
-----------------------------------------------------------------------------"

usermod -a -G root nobody

rm -rf /code/${DOCKER_CODE} \
&& mv /usr/local/${DOCKER_CODE} /code/${DOCKER_CODE} \
&& rm -rf /usr/local/${DOCKER_CODE} \
&& ln -s /code/${DOCKER_CODE} /usr/local/${DOCKER_CODE}
echo /code/$DIR
touch ${DOCKER_PATH}/.first_setup-completed
