/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

// wrapper around FileReader to work nicely in Promise chain
function readAsBinaryString(file) {
    return new Promise(function (resolve, reject) {
        var reader = new FileReader();
        reader.onload = function () {
            resolve(reader.result); // result attribute contains the raw binary data from the file.
        }
        reader.onerror = function () {
            reject(reader.error);
        }
        reader.onabort = function () {
            reject(new Error('Upload aborted.'));
        }
        reader.readAsBinaryString(file);
    });
}

export { readAsBinaryString };

function readAsDataURL(file) {
    return new Promise(function (resolve, reject) {

        console.log('readAsDataURL');

        var reader = new FileReader();

        reader.onload = function () {
            resolve(reader.result); // attribute contains the data as a data: URL representing the file's data as a base64 encoded string.
        }

        reader.onerror = function () {
            reject(reader.error);
        }

        reader.onabort = function () {
            reject(new Error('Upload aborted.'));
        }

        reader.readAsDataURL(file);

    });
}

export { readAsDataURL };

/**
 * Data URLs are composed of four parts:
 *  a prefix (data:),
 *  a MIME type indicating the type of data, a
 *  an optional base64 token if non-textual,
 *  and the data itself:
 */



// Recursive method to traverse an object's structure, trimming all of the property names
function trimProperties(thing) {
    if (Array.isArray(thing)) {
        return thing.map(trimProperties);
    } else if (typeof thing === "string") {
        return thing.trim();
    } else if (typeof thing === "object") {
        let trimmed = {};
        for (let key in thing) {
            trimmed[key.trim()] = trimProperties(thing[key]);
        }
        return trimmed;
    } else {
        return thing;
    }
}

export { trimProperties };