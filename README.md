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

If you want a less interactive experience, you can just invoke commands
within the `driver` container directly, for example:

```bash
docker compose exec driver rake validate_all
```

Output from the command will appear in your terminal.

## Terminology

The production UK federation tooling performs *checks* on metadata.

The purpose of this testbed is to perform *tests* on those checks.

Each test is composed of an XML *test file* and an optional
sidecar *options file* controlling the execution of the test.

A test is executed by sending the *test data* from the test file to
one or more *endpoints* providing a metadata validation web service.

Each addressed web service runs a requested *validator* on the test data.
This is a named sequence of MDA stages; the result is a possibly empty
set of *status metadata* which is returned to the testbed driver.

A test *succeeds* if the returned status metadata matches the
test's expected results. The test *fails* if any differences
are detected.

## Endpoints

The `docker compose` deployment currently includes four containers
implementing a fleet of metadata validation web services which are referenced
inside the testbed as the following named *endpoints*:

- `v09x` represents the current production deployment. Its name reflects
  that environment's composition: v0.9 of the Shibboleth Metadata
  Aggregator, and the Xalan XSL processor included in the classpath.
- `v09` is identical to `v09x` with the exclusion of the Xalan processor.
  Because this can run neither the old nor new versions of the URL checking
  code (the old system involves a Xalan extension, while the new system only
  exists under MDA v0.10), we do not expect to ever use this configuration
  in production.
- `v010x` is anticipated to represent the next step in the evolution of
  the UK federation tooling, switching out MDA v0.9 for MDA v0.10 but
  retaining Xalan for compatibility until we are certain that all of the
  XSL in the production deployment behaves the same under the XSL processor
  included in the JDK.
- `v010` is, for now, the anticipated final state for the UK federation
  deployment once all compatibility issues are resolved so that Xalan can
  be removed.

## Development mode

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

## Configuring tests

Individual unit tests are created by adding files to suitable subdirectories
of the `tests` directory, with specific subdirectories representing different
types of test, with the organisation of directories below that being determined
by the test type.

For example, XML tests (currently the only type supported by the testbed) are
placed in inside `tests/xml/` in subdirectories representing the rules being
tested.

Tests can be executed against the fleet of validators by running the command
`rake validate_all` inside the `driver` service.

### XML test configuration

The testbed treats every file with an `.xml` extension under the `tests/xml/`
directory as a separate XML test. These test files will normally contain
a single `EntityDescriptor` element representing a SAML entity.

Running `rake validate_all` from the `driver` service will process all
test files using the `xml_tests.rb` module against the `default` validator fleet.

## Test options

Each test is configured through named *options*. Each option has a defined
default which is used when the option is not otherwise specified.

The available options, and their defaults, are:

- The `expected` result of the test. This is an array of objects representing
  MDA `StatusMetadata` item metadata. Each includes:

  - The result `status`, which is one of: `error`, `info`, or `warning`. These
    correspond to `ErrorStatus`, `InfoStatus` and `WarningStatus` respectively.
  - The `component_id` of the component that generated the result.
  - The result description `message`.

  Note that `expected` is *ordered*; a test will be regarded as having failed if
  the expected results are returned in an unexpected order.

  The default value for `expected` is an empty array, implying that by default
  validation is expected to succeed.

- Which `validators` to run. If none are specified, the `default` validator is used.
- Whether to `skip` the test. The default for this option is `false`.

To specify options for a test, create a sidecar YAML file alongside the test file.
For example, the options file for the test file `tests/xml/example.xml` would
be `tests/xml/example.yaml`. Note that the alternative `.yml` extension is not
currently supported.

If the options file does not exist, all options will take their default values.

An example options file is shown below:

``` yaml
expected:
  - status: error
    component_id: component_identifier
    message: "expected error message"
validators:
  - validator_1
  - validator_2
```

If a validator produces an `error`, `info`, or `warning` result for a given test
that is not described by that test's `expected` configuration option, the test
will fail. The actual result and expected result are equal if the String value
of their `status`, `component_id`, and `message` match exactly.

## Option overrides

Most tests have the same expected results when performed in all of the environments
represented by the configured endpoints. For situations where this is not the case,
the testbed supports *option overrides*.

To override an option in some specific situation, include an `override` option
in the tests's options file. This should be an array of objects each describing
a situation in which an override is required to the options defined at the top
level of the file.

Each override object contains keys describing the situation in which the override
should occur, and keys representing the options to be overridden. The testbed
processes these overrides in order when looking for the value for an option:
the first matching override which overrides the option will be taken; if no
overrides match or the option is not found, the option value will be taken from
the top level or from the defaults if that is not specified.

The testbed currently supports matching overrides on the basis of endpoint name
only, using the `endpoint` key. This may either be a string representing a single
endpoint name, or an array of such names.

The following example shows use of the override feature:

```yaml
expected:
  - status: error
    component_id: component_identifier
    message: "expected error message"
override:
  - endpoint: v09
    skip: true
  - endpoint: [v09x, v10x]
    expected: []
```

This example means:

- By default, expect an endpoint to return a single error status for this
  test.
- On the `v09` endpoint, skip the test entirely.
- On the `v09x` and `v10x` endpoints, expect no status metadata to be
  generated (expect the test data to be successfully validated).

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
