# `ukf-testbed`

This repository contains a framework used to perform tests on the
UK federation's tooling, specifically those parts which validate
SAML metadata before publication.

The testbed operates as a collection of Docker containers established by
`docker compose`. A `driver` service is initially idle and is used to
run test operations, or can be used interactively. It is accompanied
by a fleet of validator containers each with a different configuration;
each of these is a variation of the `md-validator` microservice.

The containers operate within a private network but are otherwise isolated
from each other and from the host. The exception is the `driver` service,
which mounts the host `tests` directory as `/application/tests` to allow
development of individual tests without needing to rebuild the containers.

Build the container images using `./build-images`.

Establish the running containers using `./up`; remove them using `./down`.

Executing `./drive` will open a `bash` shell within the `driver` service
in which test operations can be performed.

Remember that it may take a few seconds for the validator containers to fully initialise,
and you may not be able to execute commands against them immediately on starting `./drive`.
