# `overlays` directory

Each sub-directory represents an overlay of files to be added to
one of the validator fleet images by means of the `Dockerfile`
`ADD` command.

A `Dockerfile` used to construct a fleet member will normally
consist of several such overlays:

- `all`
- `ukf-meta-prod`, `ukf-mda-239` or another overlay representing
the configuration used in a branch of the `ukf-meta` repository.
- `09-common` or `010-common` providing configuration specific
to the MDA version in use.
- `09`, `09x`, `010` or `010x` providing configuration specific
to an individual fleet member.
- `xalan` to supply the Xalan libraries, if required.
- `inc-mda` and `ukf-mda` are used with the MDA 0.9 fleet members
to supply those libraries; these are integrated elsewhere for
MDA 0.10 fleet members.

Notes on specific overlays:

- `all` is the base for all fleet members. It provides common
Spring Boot application configuration along with configuration
for the default validator which appears in each. Additional
validators (e.g., to test other combined rulesets) could be added
at this level.

- `ukf-meta-prod` tracks the production (currently `master`) branch
in the `ukf-meta` repository, representing the code we currently
deploy.

- `ukf-mda-239` tracks the contents of the `239-use-mda-0-10` branch
in the `ukf-meta` repository, representing the code we expect to
land in production to migrate the UK federation tooling forwards
to the 0.10 MDA.
