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

Remember that it may take a while for the validator containers to fully initialise,
and you may not be able to execute commands against them immediately on starting `./drive`.
On my desktop machine, 20 seconds or so is required.

If you want a less interactive experience, you can just invoke commands
within the `driver` container directly, for example:

```bash
docker compose exec driver rake test_validate
```

Output from the command will appear in your terminal.

## Development Mode

The validator fleet has one distinguished member representing the current
production deployment, currently `v09x`. This validator's port 8080 is
bound to `localhost:8080` as well as being available within the
`docker compose` internal network.

The `all_apis` function examines the `RAILS_ENV` environmental variable
to determine which validators are available:

- Inside the `driver` service (where `RAILS_ENV` is set to `production`),
  `all_apis` returns an array of all available endpoints so that the
  same operation can be performed against each validator in turn.
- Outside the `driver` service (e.g., on the host) `all_apis` returns
  a singleton endpoint for `localhost:8080` which accesses the `v09x`
  container alone.

This arrangement allows the test framework itself to be developed
without having to rebuild the `driver` image for each change.

## Copyright and License

The contents of this repository are Copyright (C) the named contributors or their
employers, as appropriate.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

> <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
