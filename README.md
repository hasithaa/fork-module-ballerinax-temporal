# Ballerina Temporal Module

[![Build](https://github.com/ballerina-platform/module-ballerinax-temporal/actions/workflows/build-timestamped-master.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-temporal/actions/workflows/build-timestamped-master.yml)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-temporal/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-temporal)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-temporal.svg)](https://github.com/ballerina-platform/module-ballerinax-temporal/commits/main)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-temporal/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-temporal/actions/workflows/build-with-bal-test-graalvm.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Built-in activity functions for the [Ballerina Workflow module](https://github.com/ballerina-platform/module-ballerina-workflow).

## Overview

This module provides pre-built, reusable activity functions that can be used within `ballerina/workflow` workflows. By decoupling activities from the core workflow engine, this module can evolve independently with a separate release cycle.

### Available Activities

- **`sendHttpRequest`** — Durable HTTP REST calls with support for all HTTP methods, custom headers, payloads, and Basic/Bearer authentication.

## Usage

```ballerina
import ballerina/workflow;
import ballerinax/temporal;

@workflow:Workflow
function myWorkflow(workflow:Context ctx, MyInput input) returns MyOutput|error {
    // Use built-in HTTP activity
    json response = check ctx->callActivity(temporal:sendHttpRequest, {
        url: "https://api.example.com/data",
        method: "POST",
        payload: {key: input.value}
    });
    return {result: response.toString()};
}
```

## Build from Source

### Prerequisites

- [Ballerina](https://ballerina.io/downloads/) Swan Lake 2201.13.0
- Java 21
- [Temporal CLI](https://docs.temporal.io/cli) (for integration tests)

### Build Commands

```bash
# Full build
./gradlew build

# Run unit tests (no Temporal server needed)
./gradlew :temporal-ballerina:test

# Run integration tests (starts Temporal CLI dev server)
./gradlew :temporal-integration-tests:test

# Build native module only
./gradlew :temporal-native:build
```

## Contributing

As an open-source project, we welcome contributions from the community.

## License

This project is licensed under Apache 2.0. See the [LICENSE](LICENSE) file for details.
