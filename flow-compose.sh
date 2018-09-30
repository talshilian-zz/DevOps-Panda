#!/usr/bin/python

import urllib2
import tarfile
import subprocess
import requests
import time
import os

def docker_up():
    # Run docker containers
    print ("statrting docker")
    subprocess.call(["docker-compose", "up", "-d"])
    print ("docker is up")

def docker_down():
    # Remove docker containers and images
    print ("down docker")
    subprocess.call(["docker-compose", "down", "--rmi", "all"])

def health_check():
    # Check health
    # wait for docker boot up
    time.sleep(3)
    print ("starting health check")
    try:
        # If request taking too much time, fail it
        request = requests.get('http://localhost:3000/health', timeout=3)
    except requests.exceptions.RequestException as e:  # This is the correct syntax
        print e
        return 500

    return request.status_code


def get_images():
    # Download images and ungz to the folder
    filedata = urllib2.urlopen('https://s3.eu-central-1.amazonaws.com/devops-exercise/pandapics.tar.gz')
    datatowrite = filedata.read()
    current_dir = os.path.dirname(os.path.abspath(__file__))

    with open(current_dir + '/pandapics.tar.gz', 'wb') as f:
        f.write(datatowrite)

    tar = tarfile.open(current_dir + "/pandapics.tar.gz", "r:gz")
    tar.extractall(path=current_dir+"/pandaimages")
    tar.close()


get_images()
docker_up()
status = health_check()
if status == 200:
    print('Success: Url health check passed')
elif status == 500:
    print('Error: Url health check failed')
    # Stop docker if something wrong
    docker_down()

print ("Done.")