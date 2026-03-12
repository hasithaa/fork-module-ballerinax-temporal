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

# Supported HTTP methods for REST calls.
public type HttpMethod "GET"|"POST"|"PUT"|"DELETE"|"PATCH"|"HEAD"|"OPTIONS"|string;

# HTTP Basic authentication credentials.
#
# + username - The username for Basic authentication
# + password - The password for Basic authentication
public type BasicAuth record {|
    string username;
    string password;
|};

# HTTP Bearer token authentication.
#
# + token - The bearer token value
public type BearerAuth record {|
    string token;
|};

# Configuration for an HTTP REST call.
#
# + url - The target URL to send the request to
# + method - The HTTP method to use (default: `"GET"`)
# + headers - Optional map of custom HTTP headers
# + payload - Optional request payload (serialized as JSON by default)
# + auth - Optional authentication configuration (Basic or Bearer)
public type RestCallRequest record {|
    string url;
    HttpMethod method = "GET";
    map<string> headers?;
    anydata payload?;
    BasicAuth|BearerAuth auth?;
|};
