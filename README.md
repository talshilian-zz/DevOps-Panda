# BigPanda Devops exrecise

Tested on Python 2.7

### Description

Docker docker-compose.yml will read Dockerfile from github: 

* App https://github.com/bigpandaio/ops-exercise

* DB: https://github.com/bigpandaio/ops-exercise/db

build images and run containers.

### How to run:

1. Install dependencies

```
pip install requests
```

2. Make sh executable

```
chmpd +x flow-compose.sh
```

3. Run

```
./flow-compose.sh
```

### Script output:

* In case of everything is ok and health check (http://localhost:3000/health) returns 200, make it success and print out "Success: Url health check passed"

* If anything failed, print out "Error: Url health check failed"

### Comments:

1. I'm mapping images to the folder ./pandaimages instead of /opt/app/public/images - following error correction

2. In addition to 500 status check, I'm using timeou of 3 sec. and fail docker on timeout
