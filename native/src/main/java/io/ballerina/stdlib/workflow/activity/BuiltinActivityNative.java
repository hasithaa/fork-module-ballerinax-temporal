/*
 * Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.workflow.activity;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.concurrent.StrandMetadata;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.ValueUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;

import java.util.Collections;

/**
 * Native implementation for built-in activity functions.
 * <p>
 * Provides the native body for the {@code sendHttpRequest} activity,
 * which delegates to a Ballerina helper function for the actual HTTP call
 * and then converts the result to the caller's expected type.
 *
 * @since 0.1.0
 */
public final class BuiltinActivityNative {

    private BuiltinActivityNative() {
        // Utility class, prevent instantiation
    }

    /**
     * Native implementation for the dependently-typed {@code sendHttpRequest} activity.
     * <p>
     * This method is the external body of the Ballerina {@code sendHttpRequest} function.
     * It delegates the actual HTTP call to the Ballerina helper function
     * {@code sendHttpRequestHelper} via {@link Runtime#callFunction}, then converts
     * the raw result to the caller's expected type.
     * <p>
     * The method uses {@link Environment#yieldAndRun} to yield the current Ballerina
     * strand before calling back into the Ballerina runtime, preventing potential
     * deadlocks.
     *
     * @param env        the Ballerina runtime environment (injected by the runtime)
     * @param url        the target URL
     * @param method     the HTTP method (GET, POST, etc.)
     * @param headers    optional map of HTTP headers (nullable)
     * @param payload    optional request payload (nullable)
     * @param auth       optional authentication record (nullable)
     * @param typedesc   the target type descriptor for dependent typing
     * @return the HTTP response converted to the target type, or a BError
     */
    public static Object sendHttpRequest(Environment env, BString url, BString method,
            Object headers, Object payload, Object auth, BTypedesc typedesc) {
        BString effectiveMethod = (method != null) ? method : StringUtils.fromString("GET");
        return env.yieldAndRun(() -> {
            Runtime runtime = env.getRuntime();
            Module module = env.getCurrentModule();
            Object result = runtime.callFunction(module, "sendHttpRequestHelper",
                    new StrandMetadata(true, Collections.emptyMap()),
                    url, effectiveMethod, headers, payload, auth);
            if (result instanceof BError) {
                return result;
            }
            if (typedesc != null) {
                return cloneWithType(result, typedesc.getDescribingType());
            }
            return result;
        });
    }

    /**
     * Clones a Ballerina value with a target type for dependent typing support.
     *
     * @param value the value to clone/convert
     * @param targetType the target type to convert to
     * @return the value converted to the target type, or an error if conversion fails
     */
    private static Object cloneWithType(Object value, Type targetType) {
        if (value == null) {
            return null;
        }
        if (value instanceof BError) {
            return value;
        }
        try {
            return ValueUtils.convert(value, targetType);
        } catch (BError e) {
            return e;
        } catch (Exception e) {
            return ErrorCreator.createError(
                    StringUtils.fromString("Type conversion failed: " + e.getMessage()));
        }
    }
}
