#!/bin/bash

# docker image to use
DOCKER_IMAGE_NAME="ngiger/luna-demo2"

# local name for the container
DOCKER_CONTAINER_NAME="luna-demo2"

SSH_KEY_PRIVATE="-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAsD5eqjrxpMeFkvXihUhNM2ef2rssrBuReu3plWquRJcftYsj
mGLya1iw2uF/n85pmHp2doLIG32KrVKkB7YWwFBrTQmn6kwnDtgbtzmsQVzrWphn
wcTECBCXqvxlNC2oJcEHmZm+X9n0nEQnzn92Ri8g/8V3BNe9QM2OTU1ntrebo2ok
OQdvCumQvRfmQZjmUn9a73tt4wU5U8+e5SC0Lm3Zs4hFhcVioSyVctyDftNkL29i
AtDD4vOgmFqQ+L7SVj6RU5OBnWMZrCb/8Uip+et/atosEqtwYGkMoZwp+aJbIOcg
j4aPuEzsq/fGVDeqP8ZRzu3PBbn4IUc1Ui6wHwIDAQABAoIBACrSvMW4FMbpA/e1
bxjbfIalAx5upGgdOrgX3s3DYhyga7/80uVQBX83yaElcZEu4lF+UBJzrJOhaXS7
w8dr4xNPdwL8+aPgZQ0iTXmztbscDMOyjGN0n/0lqvSM5zpKbbTeti4IQU2g8+KU
XOe76M0c3nPHUygGE6IPUChQSocGpoul1ATvPW9bnt5XOC5zh79jkrDgMeupS6px
Gpqhkh0a3pHAOJ/I4y0+kcg3OkecSecf4xR6KPvi56p8p/ChFO8AK1uBLLTBe1mD
2xgBUVNgV7KtUwK6Lv+7O3dkANbaH4GBy7wPceCJ1Mb6sz0KbKbMCeeV0Ic+59ml
Yv2lBKECgYEA4dZ0VN7aOdHUvCK6du1yHTdl1C2OG2AiOLq2QOnnje92cW5gqlCM
2cxm1R0RLiR7IcJCWOc2VpbDhaXY8inpN/pnqH89Mt3x1ka9APmhfx9tkJ1C55PJ
r8PdlQMVfvfHhOR5LoM34YvMb1BAv1wyVmnc03+G9FD87Yq7W6ex9ZMCgYEAx8hC
iB8n9giDh1cyT0caJXdCpgC1ApT4GveuFrwzeoHkgbmhnq4ntAKYHC7PFlosw8EQ
1Zfiv0EQmlBjGb1DN/hXWpdNfo9e/7LZv8HjFCR7DdBnZa0pnj3Z7sykPqvEOk0g
wk24HDNjJS61pCKxYbS4KOsncoOeQOrUsrZiMsUCgYBMBlOXFoZEHJ0O0GoRCxH1
P+bprIRANvaOPlyIMbWflFM9EDk+XGtuDl83stdLv0AsNyb6oqsqLwqW/SOxMeau
z38BvAOwEgMNbTbHE0IId1385tPU/W1R3A/F0An2ehcSZ49b1xSCuvsRJeUGBlVz
vaN3F2Eo8fKTTLaRvjwsPQKBgQCsxs5zNq6yoq5Nj+WclltQZ5GmSxpAP2FKwUU3
uE+09T0Py+CwgOEpVs0CIqFKLXZlXUUX1CFvUe/v5PGvwvStJQM2/38vowJ/lMeo
hR/DvcEGM2QYlOdXSRp+4VByOs6btTRNljVRfkeSUpEYgEBzxX03NheJe7aTYgPN
AtpuGQKBgHpSxfEhrH4WCInjqOz0effzC0o2VxAVFZzAI1jBFS4mVvYFDGqDrwk6
ubR2e9QxtL7JiFHIT7pgM+KRVHGlsOis6fLTPrqN0KIe80Da7xAvoCB7CMlGDjQa
864wsVEeDxEDDDRSYM929Zh5+SKJ33LmXa3e8nM4docsanDFXRkH
-----END RSA PRIVATE KEY-----"

# write ssh key to temp. file
SSH_KEY_FILE_PRIVATE=$(tempfile)
echo "${SSH_KEY_PRIVATE}" > ${SSH_KEY_FILE_PRIVATE}

# check if container already present
TMP=$(docker ps -a | grep ${DOCKER_CONTAINER_NAME})
CONTAINER_FOUND=$?

TMP=$(docker ps | grep ${DOCKER_CONTAINER_NAME})
CONTAINER_RUNNING=$?

if [ $CONTAINER_FOUND -eq 0 ]; then

	echo -n "container '${DOCKER_CONTAINER_NAME}' found, "

	if [ $CONTAINER_RUNNING -eq 0 ]; then
		echo "already running"
	else
		echo -n "not running, starting..."
		TMP=$(docker start ${DOCKER_CONTAINER_NAME})
		echo "done"
	fi

else
	echo -n "container '${DOCKER_CONTAINER_NAME}' not found, creating..."
	TMP=$(docker run -d -P --name ${DOCKER_CONTAINER_NAME} ${DOCKER_IMAGE_NAME})
	echo "done"
fi

#wait for container to come up
sleep 2

# find ssh port
SSH_URL=$(docker port ${DOCKER_CONTAINER_NAME} 22)
SSH_URL_REGEX="(.*):(.*)"

SSH_INTERFACE=$(echo $SSH_URL | awk -F  ":" '/1/ {print $1}')
SSH_PORT=$(echo $SSH_URL | awk -F  ":" '/1/ {print $2}')

echo "ssh running at ${SSH_INTERFACE}:${SSH_PORT}"

echo ssh -i ${SSH_KEY_FILE_PRIVATE} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -Y -X root@${SSH_INTERFACE} -p ${SSH_PORT} eclipse/eclipse -data workspace
ssh -i ${SSH_KEY_FILE_PRIVATE} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -Y -X root@${SSH_INTERFACE} -p ${SSH_PORT} eclipse/eclipse -data workspace
# rm -f ${SSH_KEY_FILE_PRIVATE}
