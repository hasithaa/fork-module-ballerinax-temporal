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
// HTTP ACTIVITY WORKFLOW - TESTS
// ================================================================================
// Tests for the built-in activity:sendHttpRequest activity.
// Covers: GET/POST/PUT/DELETE/PATCH methods, JSON/XML/text content types,
// custom headers, Basic auth, Bearer auth, and error handling.

import ballerina/test;
import ballerina/workflow;

// --- JSON GET tests ---

@test:Config {
    groups: ["integration"]
}
function testHttpGetJsonArray() returns error? {
    string testId = uniqueId("http-get-json-array");
    HttpActivityInput input = {id: testId, mode: "get_json_array"};
    string workflowId = check workflow:run(httpGetJsonArrayWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED", "GET JSON array workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    if execInfo.result is anydata[] {
        anydata[] users = <anydata[]>execInfo.result;
        test:assertEquals(users.length(), 2, "Should return 2 users");
        if users[0] is map<anydata> {
            map<anydata> user0 = <map<anydata>>users[0];
            test:assertEquals(user0["name"], "Alice", "First user should be Alice");
        }
    } else {
        test:assertFail("Expected array result, got: " + (execInfo.result is () ? "null" : "other"));
    }
}

@test:Config {
    groups: ["integration"]
}
function testHttpGetJsonObject() returns error? {
    string testId = uniqueId("http-get-json-object");
    HttpActivityInput input = {id: testId, mode: "get_json_object"};
    string workflowId = check workflow:run(httpGetJsonObjectWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED", "GET JSON object workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    if execInfo.result is map<anydata> {
        map<anydata> result = <map<anydata>>execInfo.result;
        test:assertEquals(result["name"], "Alice", "User name should be Alice");
        test:assertEquals(result["id"], 1, "User id should be 1");
        test:assertEquals(result["email"], "alice@example.com", "User email should match");
    } else {
        test:assertFail("Expected map<anydata> result");
    }
}

// --- POST test ---

@test:Config {
    groups: ["integration"]
}
function testHttpPost() returns error? {
    string testId = uniqueId("http-post");
    HttpActivityInput input = {id: testId, mode: "post"};
    string workflowId = check workflow:run(httpPostWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 60);
    test:assertEquals(execInfo.status, "COMPLETED", "POST workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    if execInfo.result is map<anydata> {
        map<anydata> result = <map<anydata>>execInfo.result;
        test:assertEquals(result["name"], "Charlie", "Created user name should be Charlie");
        test:assertEquals(result["status"], "created", "Status should be 'created'");
    } else {
        test:assertFail("Expected map<anydata> result");
    }
}

// --- PUT test ---

@test:Config {
    groups: ["integration"]
}
function testHttpPut() returns error? {
    string testId = uniqueId("http-put");
    HttpActivityInput input = {id: testId, mode: "put"};
    string workflowId = check workflow:run(httpPutWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED", "PUT workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    if execInfo.result is map<anydata> {
        map<anydata> result = <map<anydata>>execInfo.result;
        test:assertEquals(result["id"], 1, "Updated user id should be 1");
        test:assertEquals(result["updated"], true, "Should be marked as updated");
    } else {
        test:assertFail("Expected map<anydata> result");
    }
}

// --- DELETE test ---

@test:Config {
    groups: ["integration"]
}
function testHttpDelete() returns error? {
    string testId = uniqueId("http-delete");
    HttpActivityInput input = {id: testId, mode: "delete"};
    string workflowId = check workflow:run(httpDeleteWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED", "DELETE workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    if execInfo.result is map<anydata> {
        map<anydata> result = <map<anydata>>execInfo.result;
        test:assertEquals(result["id"], 1, "Deleted user id should be 1");
        test:assertEquals(result["deleted"], true, "Should be marked as deleted");
    } else {
        test:assertFail("Expected map<anydata> result");
    }
}

// --- PATCH test ---

@test:Config {
    groups: ["integration"]
}
function testHttpPatch() returns error? {
    string testId = uniqueId("http-patch");
    HttpActivityInput input = {id: testId, mode: "patch"};
    string workflowId = check workflow:run(httpPatchWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 60);
    test:assertEquals(execInfo.status, "COMPLETED", "PATCH workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    if execInfo.result is map<anydata> {
        map<anydata> result = <map<anydata>>execInfo.result;
        test:assertEquals(result["id"], 1, "Patched user id should be 1");
        test:assertEquals(result["patched"], true, "Should be marked as patched");
    } else {
        test:assertFail("Expected map<anydata> result");
    }
}

// --- Custom headers test ---

@test:Config {
    groups: ["integration"]
}
function testHttpCustomHeaders() returns error? {
    string testId = uniqueId("http-custom-headers");
    HttpActivityInput input = {id: testId, mode: "custom_headers"};
    string workflowId = check workflow:run(httpCustomHeadersWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED", "Custom headers workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    if execInfo.result is map<anydata> {
        map<anydata> result = <map<anydata>>execInfo.result;
        test:assertEquals(result["X-Request-Id"], "req-12345", "X-Request-Id header should be echoed");
    } else {
        test:assertFail("Expected map<anydata> result");
    }
}

// --- XML response test ---

@test:Config {
    groups: ["integration"]
}
function testHttpGetXml() returns error? {
    string testId = uniqueId("http-get-xml");
    HttpActivityInput input = {id: testId, mode: "get_xml"};
    string workflowId = check workflow:run(httpGetXmlWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED", "GET XML workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    string result = <string>execInfo.result;
    test:assertTrue(result.includes("ok"), "XML response should contain 'ok'");
    test:assertTrue(result.includes("42"), "XML response should contain '42'");
}

// --- Plain text response test ---

@test:Config {
    groups: ["integration"]
}
function testHttpGetText() returns error? {
    string testId = uniqueId("http-get-text");
    HttpActivityInput input = {id: testId, mode: "get_text"};
    string workflowId = check workflow:run(httpGetTextWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED", "GET text workflow should complete");
    test:assertEquals(execInfo.result, "Hello, plain text!", "Text response should match");
}

// --- Basic auth test ---

@test:Config {
    groups: ["integration"]
}
function testHttpBasicAuth() returns error? {
    string testId = uniqueId("http-basic-auth");
    HttpActivityInput input = {id: testId, mode: "basic_auth"};
    string workflowId = check workflow:run(httpBasicAuthWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED", "Basic auth workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    if execInfo.result is map<anydata> {
        map<anydata> result = <map<anydata>>execInfo.result;
        test:assertEquals(result["authenticated"], true, "Should be authenticated");
        test:assertEquals(result["method"], "basic", "Auth method should be 'basic'");
    } else {
        test:assertFail("Expected map<anydata> result");
    }
}

// --- Bearer auth test ---

@test:Config {
    groups: ["integration"]
}
function testHttpBearerAuth() returns error? {
    string testId = uniqueId("http-bearer-auth");
    HttpActivityInput input = {id: testId, mode: "bearer_auth"};
    string workflowId = check workflow:run(httpBearerAuthWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED", "Bearer auth workflow should complete. Error: " + (execInfo.errorMessage ?: "none"));

    if execInfo.result is map<anydata> {
        map<anydata> result = <map<anydata>>execInfo.result;
        test:assertEquals(result["authenticated"], true, "Should be authenticated");
        test:assertEquals(result["method"], "bearer", "Auth method should be 'bearer'");
    } else {
        test:assertFail("Expected map<anydata> result");
    }
}

// --- Error handling test ---

@test:Config {
    groups: ["integration"]
}
function testHttpErrorHandling() returns error? {
    string testId = uniqueId("http-error");
    HttpActivityInput input = {id: testId, mode: "error"};
    string workflowId = check workflow:run(httpErrorWorkflow, input);

    workflow:WorkflowExecutionInfo execInfo = check workflow:getWorkflowResult(workflowId, 30);
    test:assertEquals(execInfo.status, "COMPLETED",
        "Error handling workflow should complete (failOnError=false)");
    string result = <string>execInfo.result;
    test:assertTrue(result.startsWith("HTTP error caught:"),
        "Result should contain the caught error message");
}
