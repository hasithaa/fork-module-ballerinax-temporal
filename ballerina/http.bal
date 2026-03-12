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

import ballerina/http;
import ballerina/jballerina.java;
import ballerina/lang.array;
import ballerina/workflow;

# Sends an HTTP request as a durable workflow activity.
#
# This is a built-in activity that performs an HTTP REST call within a workflow.
# Like all activities, the call is executed **exactly once** by the workflow engine —
# the result is persisted and reused during workflow replays, ensuring deterministic
# behavior even across program restarts.
#
# The return type is inferred from the calling context, so the response is
# automatically converted to the expected type without manual casting.
#
# Supports:
# - All standard HTTP methods (`GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD`, `OPTIONS`)
# - Custom request headers
# - Request payload (serialized as JSON by default)
# - Basic and Bearer token authentication
#
# The response is automatically deserialized based on the `Content-Type` header:
# - `application/json` → parsed as `json`
# - `application/xml` or `text/xml` → parsed as `xml`
# - All other types → returned as `string`
#
# The deserialized value is then converted to the expected return type.
#
# # Examples
#
# GET request with typed response (type inferred from LHS):
# ```ballerina
# record {string name; int age;} user = check ctx->callActivity(activity:sendHttpRequest,
#     {url: "https://api.example.com/users/1"});
# ```
#
# POST request with payload:
# ```ballerina
# json response = check ctx->callActivity(activity:sendHttpRequest, {
#     url: "https://api.example.com/orders",
#     method: "POST",
#     payload: {orderId: "ORD-123", amount: 99.99}
# });
# ```
#
# Request with Bearer token authentication:
# ```ballerina
# json response = check ctx->callActivity(activity:sendHttpRequest, {
#     url: "https://api.example.com/protected/data",
#     auth: {token: apiToken}
# });
# ```
#
# Request with Basic authentication and custom headers:
# ```ballerina
# json response = check ctx->callActivity(activity:sendHttpRequest, {
#     url: "https://api.example.com/data",
#     method: "PUT",
#     headers: {"X-Request-Id": requestId, "Accept": "application/json"},
#     payload: updatedData,
#     auth: {username: "user", password: "pass"}
# });
# ```
#
# + url - The target URL to send the request to
# + method - The HTTP method to use (default: `"GET"`)
# + headers - Optional map of custom HTTP headers to include in the request
# + payload - Optional request payload (serialized as JSON by default)
# + auth - Optional authentication configuration (`BasicAuth` or `BearerAuth`)
# + targetType - The expected return type (inferred from context or explicitly specified)
# + return - The response payload converted to the specified type, or an error if the
#            request or type conversion fails
@workflow:Activity
public isolated function sendHttpRequest(string url, HttpMethod method = "GET",
        map<string>? headers = (), anydata? payload = (),
        BasicAuth|BearerAuth? auth = (),
        typedesc<anydata> targetType = <>) returns targetType|error = @java:Method {
    'class: "io.ballerina.stdlib.workflow.activity.BuiltinActivityNative",
    name: "sendHttpRequest"
} external;

# Internal helper that performs the actual HTTP request.
# Called from the native `sendHttpRequest` implementation.
#
# + url - The target URL
# + method - The HTTP method
# + headers - Optional custom headers
# + payload - Optional request payload
# + auth - Optional authentication
# + return - The raw response payload as anydata, or an error
isolated function sendHttpRequestHelper(string url, string method,
        anydata? headers, anydata? payload,
        anydata? auth) returns anydata|error {
    http:Client restClient = check new (url);
    http:Request httpRequest = new;

    // Set custom headers.
    // Headers may arrive as map<anydata> after workflow serialization round-trip,
    // so we accept anydata and convert values to strings.
    if headers is map<anydata> {
        foreach var [key, value] in headers.entries() {
            httpRequest.setHeader(key, value.toString());
        }
    }

    // Set authentication headers.
    // Auth records lose their specific type (BasicAuth/BearerAuth) after passing
    // through the workflow engine's JSON serialization. We check for the presence
    // of distinguishing fields instead of using type guards.
    if auth is map<anydata> {
        map<anydata> authMap = auth;
        if authMap.hasKey("username") && authMap.hasKey("password") {
            string credentials = authMap.get("username").toString() + ":" + authMap.get("password").toString();
            string encodedCreds = array:toBase64(credentials.toBytes());
            httpRequest.setHeader("Authorization", "Basic " + encodedCreds);
        } else if authMap.hasKey("token") {
            httpRequest.setHeader("Authorization", "Bearer " + authMap.get("token").toString());
        }
    }

    // Set request payload
    if payload != () {
        httpRequest.setPayload(payload);
    }

    // Execute the HTTP call
    http:Response response = check restClient->execute(method, "", httpRequest);

    // Deserialize response based on Content-Type.
    // Note: XML responses are returned as strings because Ballerina's xml type
    // cannot be serialized by the workflow engine's JSON-based persistence layer.
    string contentType = response.getContentType();
    if contentType.includes("application/json") {
        return check response.getJsonPayload();
    } else if contentType.includes("application/xml") || contentType.includes("text/xml") {
        xml xmlPayload = check response.getXmlPayload();
        return xmlPayload.toString();
    } else {
        return check response.getTextPayload();
    }
}
