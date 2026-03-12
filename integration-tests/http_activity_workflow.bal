// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

// ================================================================================
// HTTP ACTIVITY WORKFLOWS
// ================================================================================
//
// Workflows that exercise the built-in activity:sendHttpRequest activity.
// Each workflow covers a different HTTP method, content type, or auth scenario
// to ensure comprehensive line and method coverage of the sendHttpRequest
// helper implementation.
//
// ================================================================================

import ballerina/workflow;
import ballerina/workflow.activity;

// ================================================================================
// TYPES
// ================================================================================

# Input for HTTP activity workflows.
#
# + id - The workflow identifier
# + mode - Which HTTP scenario to test
type HttpActivityInput record {|
    string id;
    string mode;
|};

# A user record matching the test service JSON shape.
type TestUser record {|
    string name;
    int id;
|};

# A user record with email.
type TestUserDetail record {|
    string name;
    int id;
    string email;
|};

# Response from create user endpoint.
type CreateUserResponse record {|
    string name;
    int id;
    string status;
|};

# Response from update user endpoint.
type UpdateUserResponse record {
    int id;
    boolean updated;
};

# Response from delete user endpoint.
type DeleteUserResponse record {|
    int id;
    boolean deleted;
|};

# Response from patch user endpoint.
type PatchUserResponse record {
    int id;
    boolean patched;
};

# Response from header echo endpoint.
type HeaderEchoResponse record {|
    string 'X\-Request\-Id;
    string Accept;
|};

# Response from basic auth endpoint.
type BasicAuthResponse record {|
    boolean authenticated;
    string method;
    string user;
|};

# Response from bearer auth endpoint.
type BearerAuthResponse record {|
    boolean authenticated;
    string method;
    string token;
|};

// ================================================================================
// WORKFLOW DEFINITIONS — one per HTTP scenario
// ================================================================================

# GET request returning a JSON array, typed to record[].
@workflow:Workflow
function httpGetJsonArrayWorkflow(workflow:Context ctx, HttpActivityInput input) returns json|error {
    TestUser[] users = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/users"
    });
    return users.toJson();
}

# GET request returning a single JSON object, typed to record.
@workflow:Workflow
function httpGetJsonObjectWorkflow(workflow:Context ctx, HttpActivityInput input) returns json|error {
    TestUserDetail user = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/users/1"
    });
    return user.toJson();
}

# POST request with JSON payload.
@workflow:Workflow
function httpPostWorkflow(workflow:Context ctx, HttpActivityInput input) returns json|error {
    CreateUserResponse result = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/users",
        method: "POST",
        payload: {name: "Charlie"}
    });
    return result.toJson();
}

# PUT request with JSON payload.
@workflow:Workflow
function httpPutWorkflow(workflow:Context ctx, HttpActivityInput input) returns json|error {
    json result = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/users/1",
        method: "PUT",
        payload: {name: "Alice Updated"}
    });
    return result;
}

# DELETE request.
@workflow:Workflow
function httpDeleteWorkflow(workflow:Context ctx, HttpActivityInput input) returns json|error {
    DeleteUserResponse result = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/users/1",
        method: "DELETE"
    });
    return result.toJson();
}

# PATCH request with payload.
@workflow:Workflow
function httpPatchWorkflow(workflow:Context ctx, HttpActivityInput input) returns json|error {
    json result = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/users/1",
        method: "PATCH",
        payload: {email: "newemail@example.com"}
    });
    return result;
}

# GET request with custom headers.
@workflow:Workflow
function httpCustomHeadersWorkflow(workflow:Context ctx, HttpActivityInput input) returns json|error {
    HeaderEchoResponse result = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/echo/headers",
        headers: {"X-Request-Id": "req-12345", "Accept": "application/json"}
    });
    return result.toJson();
}

# GET request returning XML content (returned as string since XML cannot
# traverse the workflow engine's serialization layer).
@workflow:Workflow
function httpGetXmlWorkflow(workflow:Context ctx, HttpActivityInput input) returns string|error {
    string result = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/data/xml"
    });
    return result;
}

# GET request returning plain text content.
@workflow:Workflow
function httpGetTextWorkflow(workflow:Context ctx, HttpActivityInput input) returns string|error {
    string result = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/data/text"
    });
    return result;
}

# GET request with Basic authentication.
@workflow:Workflow
function httpBasicAuthWorkflow(workflow:Context ctx, HttpActivityInput input) returns json|error {
    BasicAuthResponse result = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/auth/basic",
        auth: <activity:BasicAuth>{username: "testuser", password: "testpass"}
    });
    return result.toJson();
}

# GET request with Bearer token authentication.
@workflow:Workflow
function httpBearerAuthWorkflow(workflow:Context ctx, HttpActivityInput input) returns json|error {
    BearerAuthResponse result = check ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/auth/bearer",
        auth: <activity:BearerAuth>{token: "test-api-token-123"}
    });
    return result.toJson();
}

# Workflow that tests HTTP error handling (server returns 500).
@workflow:Workflow
function httpErrorWorkflow(workflow:Context ctx, HttpActivityInput input) returns string|error {
    string|error result = ctx->callActivity(activity:sendHttpRequest, {
        url: testServiceUrl + "/api/error"
    }, options = {failOnError: false});
    if result is error {
        return "HTTP error caught: " + result.message();
    }
    return result;
}
