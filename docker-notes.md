# Chromium inside docker

Chromium needs to create a sandbox in order isolate browser tabs form each other and from the system. In order to run chromium without disabling the sandbox, the container can
- run privileged (has root access on the host)
- run with CAP_SYS_ADMIN (almost has root access on the host, can break out from container)
- run with additionally white-listed syscalls in a seccomp profile.

A good article and the profile by Niclas Portmann can be found [here](https://ndportmann.com/chrome-in-docker/) and [here](https://github.com/tkp1n/chromium-ci/blob/master/README.md).

## Further reading

- Docker [default capabilities](https://github.com/moby/moby/blob/master/oci/caps/defaults.go#L6-L19)
- Docker [security](https://docs.docker.com/engine/security/)
- Docker seccomp [profiles](https://docs.docker.com/engine/security/seccomp/)
- Docker seccomp [tutorial](https://github.com/docker/labs/tree/master/security/seccomp)

## Build the image

`docker build -t url-to-pdf-api .`

## Run the image

`docker run -it --rm -p 9000:9000 --env ALLOW_HTTP=true  --security-opt=seccomp:$(pwd)/chromium_seccomp.json  url-to-pdf-api:latest`