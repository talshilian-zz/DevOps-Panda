#!/usr/bin/python
import urllib2
import tarfile
import subprocess
import requests
import time
import os
import logging
import sys

logging.basicConfig()
logger = logging.getLogger("kung-fu-panda")
logger.setLevel(logging.INFO)

def docker_up():
    # Run docker containers
    logger.info('starting docker')
    try:
       subprocess.check_call(["docker-compose", "up", "-d"])
    except subprocess.CalledProcessError:
        return False

    logger.info('docker is up')
    return True


def docker_down():
    # Remove docker containers and images
    logging.warning('down docker')
    subprocess.call(["docker-compose", "down", "--rmi", "all"])


def check_env():
    # Check health
    # wait for docker boot up
    time.sleep(3)
    logger.info('starting health check')
    try:
        # If request taking too much time, fail it
        request = requests.get('http://localhost:3000/health', timeout=3)
    except requests.exceptions.RequestException as e:
        return e

    return request.status_code


def health_check():
    status = check_env()
    if status == 200:
        logger.info('Success: Url health check passed')
    else:
        logger.warning(status)
        # Stop docker if something wrong
        docker_down()


def get_images():
    # Download images and ungz to the folder
    try:
        filedata = urllib2.urlopen('https://s3.eu-central-1.amazonaws.com/devops-exercise/pandapics.tar.gz')
        datatowrite = filedata.read()
    except Exception as e:
        logging.error(e)
        return False

    try:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        with open(current_dir + '/pandapics.tar.gz', 'wb') as f:
            f.write(datatowrite)
    except Exception as e:
        logging.error(e)
        return False

    try:
        tar = tarfile.open(current_dir + "/pandapics.tar.gz", "r:gz")
        tar.extractall(path=current_dir+"/pandaimages")
        tar.close()
    except Exception as e:
        logging.error(e)
        return False

    return True


images = get_images()

if not images:
    logging.error("error getting images, couldn't continue")
    sys.exit(-1)

run = docker_up()

if not run:
    logging.error("error running docker, couldn't continue")
    sys.exit(-1)

health_check()

logger.info('Done')