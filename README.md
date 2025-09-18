# SHACL Resources Monitor


## Disclaimer

Participation by NIST in the creation of the documentation of mentioned software is not intended to imply a recommendation or endorsement by the National Institute of Standards and Technology, nor is it intended to imply that any specific software is necessarily the best available for the purpose.


## Software description


### Purpose

This repository is a monitor for synchronization between resources under development by the [W3C Data Shapes Working Group](https://www.w3.org/groups/wg/data-shapes/) (Data Shapes WG).

The motivation is that there are resources being maintained at two repositories.

* [`w3c/data-shapes`](https://github.com/w3c/data-shapes/) - the primary development space for the WG, where, e.g., the documents and primary encoding of the SHACL language are under development.
* [`w3c/shacl-resources`](https://github.com/w3c/shacl-resources/) - a development location for SHACL resources that will allow for some maintenance after the current Working Group's charter expires.

This repository operates downstream from the above resources, testing that implementation in the second location remains consistent with the "Upstream" implementation state of the primary location.

The first resource with cross-repository dependencies being monitored is the minimal OWL profile of SHACL, further described in [data-shapes Issue 246](https://github.com/w3c/data-shapes/issues/246).


#### Maturity

This repository is informational.  It is expected to inform this repository's maintainer(s) that the monitored repositories' are due for some revision.

This repository is not intended to generate automated revisions.


#### Operational period

This repository is not expected to be maintained past the duration of the Data Shapes Working Group chartered in December of 2024.  Their Charter is [here](https://www.w3.org/2024/12/data-shapes.html).


### Repository contents

This repository implements a [Make](https://en.wikipedia.org/wiki/Make_%28software%29)-based workflow to build and check artifacts for [`w3c/shacl-resources`](https://github.com/w3c/shacl-resources/) from [`w3c/data-shapes`](https://github.com/w3c/data-shapes/).  When the artifacts differ (using `diff`), an alert is raised.  The alert's mechanism is an email to the repository maintainer via a GitHub Action "Workflow failure."  Note that usage of the term "Failure" is not intended as a criticism; it's merely a mechanism to raise a maintainer's attention.


### Technical installation instructions

This software runs in POSIX environments (e.g., Linux, macOS, *BSD, Windows Subsystem for Linux (WSL)).  The Python `venv` module is required (usability can be checked with `python3 -m venv --help`), as are `git` and `make`.  (A note on Make variants: BSD Make is not tested.)

A Java tool is used to normalize syntax as part of the build process.  A Java runtime will be needed.

This software can be run with the following commands, starting from any directory the user prefers.  This will demonstrate operating in `/tmp`.

```bash
cd /tmp
git clone https://github.com/usnistgov/w3c-data-shapes-shacl-resources-monitor.git
cd w3c-data-shapes-shacl-resources-monitor
make check
```

The above workflow runs as a Continuous Integration check on a schedule.

Another workflow runs to check the "Supply chain" of this repository's dependencies.  Primarily, the supply chain is the state of the two cross-checked repositories, which are tracked as Git submodules pinned to last-reviewed states.  To run this recipe manually, follow the instruction block above, but run `make check-supply-chain` instead of `make check`.


## Contact information

[Alex Nelson](https://www.nist.gov/people/alexander-nelson), Information Technology Laboratory, Computer Security Division, Security Components and Mechanisms Group, alexander.nelson@nist.gov.

Feedback is welcome as GitHub Issues on this repository.


## Cite This Work

Please cite this repository as:

> Nelson, A.J., (2025), SHACL Resources Monitor, National Institute of Standards and Technology, [Software], https://github.com/usnistgov/w3c-data-shapes-shacl-resources-monitor (Accessed Sep 15, 2025)
