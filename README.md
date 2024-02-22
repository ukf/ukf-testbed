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
docker compose exec driver rake validate_all
```

Output from the command will appear in your terminal.

## Development Mode

The validator fleet has one distinguished member representing the current
production deployment, currently `v09x`. This validator's port 8080 is
bound to `localhost:8080` as well as being available within the
`docker compose` internal network.

The `Testbed.all_endpoints` function examines the `RAILS_ENV` environmental variable
to determine which validators are available:

- Inside the `driver` service (where `RAILS_ENV` is set to `production`),
  `all_endpoints` returns an array of all available endpoints so that the
  same operation can be performed against each validator in turn.
- Outside the `driver` service (e.g., on the host) `all_endpoints` returns
  a singleton endpoint for `localhost:8080` which accesses the `v09x`
  container alone.

This arrangement allows the test framework itself to be developed
without having to rebuild the `driver` image for each change.

## Test Setup

Individual unit tests are added to suitable subdirectories of `/tests/`. Each 'type' of unit test *should* go into its own subdirectory (or subdirectory hierarchy), for example, XML tests inside `/tests/xml/`. Tests can be executed against the fleet of validators by running the command `rake validate_all` inside the `driver` service.

### XML Test Setup

Unit tests that take XML elements (e.g. an `EntityDescriptor`) need to be
placed in the `/tests/xml` directory and have a `.xml` file extension.
Running `rake validate_all` from the `driver` service will process all
test files using the `xml_tests.rb` module against the `default` validator fleet.

The validators to run can be configured via a sidecar YAML file (see Individual Test Configuration).

## Individual Test Configuration

The execution options and the expected outcome of individual tests can be configured in a sidecar YAML file.
The YAML file needs the same name as, and must be co-located with, the test. For example:

```bash
/tests/<type>/<test-name>.<ext>
/tests/<type>/<test-name>.yaml
```

The YAML file can configure the following test options:

- The `expected` result of the test. This includes:
  - The result `status`, which is one-of, `error`, `info`, or `warning`.
  - The `component_id` of the component that generated the result.
  - The result description `message`.
- Which `validators` to run. If none are specified, the `default` validator is used.

An example sidecar YAML options file is show below:

``` yaml
expected:
  - status: error
    component_id: component_identifier
    message: "expected error message"
validators:
  - validator_1
  - validator_2
```

If a validator produces an "error", "info", or "warning" result for a given test
that is not described by that test's `expected` configuration option, the test
will fail. The actual result and expected result are equal if the String value
of their `status`, `component_id`, and `message` match exactly.

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
