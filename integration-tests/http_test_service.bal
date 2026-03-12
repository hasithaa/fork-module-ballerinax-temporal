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
// HTTP TEST SERVICE
// ================================================================================
//
// A local HTTP service used by integration tests for the sendHttpRequest activity.
// Provides endpoints for testing different HTTP methods, content types,
// authentication, and error scenarios.
//
// ================================================================================

import ballerina/http;
import ballerina/lang.array;

const int TEST_HTTP_PORT = 9876;
final string testServiceUrl = "http://localhost:" + TEST_HTTP_PORT.toString();

// ================================================================================
// TEST SERVICE
// ================================================================================

service /api on new http:Listener(TEST_HTTP_PORT) {

    // --- JSON endpoints ---

    // GET /api/users - Returns a JSON array of users
    resource function get users() returns json {
        return [
            {name: "Alice", id: 1},
            {name: "Bob", id: 2}
        ];
    }

    // GET /api/users/[id] - Returns a single user by ID
    resource function get users/[int id]() returns json|http:NotFound {
        if id == 1 {
            return {name: "Alice", id: 1, email: "alice@example.com"};
        }
        if id == 2 {
            return {name: "Bob", id: 2, email: "bob@example.com"};
        }
        return http:NOT_FOUND;
    }

    // POST /api/users - Creates a new user, returns the created user with ID
    resource function post users(@http:Payload json payload) returns json|error {
        return {name: check payload.name, id: 100, status: "created"};
    }

    // PUT /api/users/[id] - Updates a user, echoes back the payload with status
    resource function put users/[int id](@http:Payload json payload) returns json {
        return {id: id, updated: true, data: payload};
    }

    // DELETE /api/users/[id] - Deletes a user, returns confirmation
    resource function delete users/[int id]() returns json {
        return {id: id, deleted: true};
    }

    // PATCH /api/users/[id] - Patches a user
    resource function patch users/[int id](@http:Payload json payload) returns json {
        return {id: id, patched: true, data: payload};
    }

    // --- XML endpoint ---

    // GET /api/data/xml - Returns XML content
    resource function get data/'xml() returns xml {
        return xml `<response><status>ok</status><value>42</value></response>`;
    }

    // --- Plain text endpoint ---

    // GET /api/data/text - Returns plain text
    resource function get data/text() returns string {
        return "Hello, plain text!";
    }

    // --- Custom headers echo ---

    // GET /api/echo/headers - Echoes back specific request headers
    resource function get echo/headers(http:Request req) returns json|error {
        string xRequestId = check req.getHeader("X-Request-Id");
        string accept = check req.getHeader("Accept");
        return {
            "X-Request-Id": xRequestId,
            "Accept": accept
        };
    }

    // --- Authentication endpoints ---

    // GET /api/auth/basic - Requires Basic auth, returns user info
    resource function get auth/basic(http:Request req) returns json|http:Unauthorized {
        string|error authHeader = req.getHeader("Authorization");
        if authHeader is error {
            return http:UNAUTHORIZED;
        }
        if !authHeader.startsWith("Basic ") {
            return http:UNAUTHORIZED;
        }
        string encoded = authHeader.substring(6);
        byte[]|error decoded = array:fromBase64(encoded);
        if decoded is error {
            return http:UNAUTHORIZED;
        }
        string credentials = checkpanic string:fromBytes(decoded);
        // Expect "testuser:testpass"
        if credentials != "testuser:testpass" {
            return http:UNAUTHORIZED;
        }
        return {authenticated: true, method: "basic", user: "testuser"};
    }

    // GET /api/auth/bearer - Requires Bearer token, returns token info
    resource function get auth/bearer(http:Request req) returns json|http:Unauthorized {
        string|error authHeader = req.getHeader("Authorization");
        if authHeader is error {
            return http:UNAUTHORIZED;
        }
        if !authHeader.startsWith("Bearer ") {
            return http:UNAUTHORIZED;
        }
        string token = authHeader.substring(7);
        if token != "test-api-token-123" {
            return http:UNAUTHORIZED;
        }
        return {authenticated: true, method: "bearer", token: token};
    }

    // --- Error endpoint ---

    // GET /api/error - Returns a 500 error
    resource function get 'error() returns http:InternalServerError {
        return http:INTERNAL_SERVER_ERROR;
    }
}
