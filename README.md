## Purpose

This [Docker](http://www.docker.com/) image runs a [MIT
Kerberos](http://web.mit.edu/kerberos/) KDC server and exposes the Kerberos
ports to the docker network.

The author does not currently publish the image in any public Docker
repository but a script, described below, is provided to easily create your
own image.

## License

The source code, which in this project is primarily shell scripts and the
Dockerfile, is licensed under the [BSD two-clause license](LICENSE.txt).

## Building the Docker image

This image depends on the the base BIDMS Debian Docker image from the
[bidms-docker-debian-base](http://www.github.com/calnet-oss/bidms-docker-debian-base)
project.  If you don't have that image built yet, you'll need that first.

Copy `config.env.template` to `config.env` and edit to set config values.

Create `imageFiles/tmp_passwords/kdc_master_pw` file to set a KDC master
password and create `imageFiles/tmp_passwords/kdc_admin_pw` to set a KDC
admin password.  Make sure there are no newlines after the passwords.

Make sure they are only readable by the owner:
```
chmod 600 imageFiles/tmp_passwords/kdc_master_pw \
  imageFiles/tmp_passwords/kdc_admin/pw
```

Make sure the `HOST_VOLUME_DIRECTORY` directory specified in `config.env`
does not exist yet on your host machine so that the build script will
initialize your directory, unless you're running `buildImage.sh` subsequent
times and want to keep your existing directory.

Build the container image:
```
./buildImage.sh
```

## Running

To run the container interactively (which means you get a shell prompt):
```
./runContainer.sh
```

Or to run the container detached, in the background:
```
./detachedRunContainer.sh
```

If everything goes smoothly, the container should expose Kerberos ports 88/udp and
750/udp to the docker network configured in `config.env`.

You can then use Kerberos clients operating within the docker network to
connect to the KDC.

If running interactively, you can exit the container by exiting the bash
shell.  If running in detached mode, you can stop the container with:
`docker stop bidms-kerberos` or there is a `stopContainer.sh` script
included to do this.

To inspect the running container from the host:
```
docker inspect bidms-kerberos
```

To list the running containers on the host:
```
docker ps
```

## Kerberos Persistence

Docker will mount the host directory specified in `HOST_VOLUME_DIRECTORY`
from `config.env` within the container as `/v1` and this is how the
Kerberos data files are persisted across container runs.

As mentioned in the build image step, the `buildImage.sh` script will
initialize an default Kerberos instance as long as the
`HOST_VOLUME_DIRECTORY` directory doesn't exist yet on the host at the
time `buildImage.sh` is run.  Subsequent runs of `buildImage.sh` will not
re-initialize Kerberos if the directory already exists on the host.

If you plan on running the image on hosts separate from the machine you're
running the `buildImage.sh` script on then you'll probably want to let
`buildImage.sh` initialize the Kerberos host directory and then copy the
`HOST_VOLUME_DIRECTORY` to all the machines that you will be running the
image on.  When copying, be careful about preserving file permissions.
