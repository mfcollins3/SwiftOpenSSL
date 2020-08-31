#!/usr/bin/env bash

# Copyright 2020 Michael F. Collins, III
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# build.sh
#
# This program automates building OpenSSL to be linked into an iOS application
# or to be used by other libraries that may be linked into an iOS application.
#
# Usage: bin/build.sh

SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR/.. > /dev/null
ROOT_PATH=$PWD
popd > /dev/null

CONFIGURATIONS="ios ios64 iossimulator catalyst"
for CONFIGURATION in $CONFIGURATIONS
do
    echo "Building OpenSSL for $CONFIGURATION"
    
    rm -rf /tmp/openssl
    cp -r External/openssl /tmp/

    pushd /tmp/openssl > /dev/null

    LOG="/tmp/openssl-$CONFIGURATION.log"
    rm -f $LOG

    OUTPUT_PATH=$ROOT_PATH/build/openssl/$CONFIGURATION
    rm -rf $OUTPUT_PATH
    mkdir -p $OUTPUT_PATH

    ./Configure "openssl-$CONFIGURATION" --config=$ROOT_PATH/External/openssl-config/ios-and-catalyst.conf --prefix=$OUTPUT_PATH >> $LOG 2>&1
    make >> $LOG 2>&1
    make install >> $LOG 2>&1

    popd > /dev/null
done

echo "Creating the universal library for iOS"

OUTPUT_PATH=$ROOT_PATH/build/openssl/lib
rm -rf $OUTPUT_PATH
mkdir -p $OUTPUT_PATH
lipo -create \
    $ROOT_PATH/build/openssl/ios/lib/libcrypto.a \
    $ROOT_PATH/build/openssl/ios64/lib/libcrypto.a \
    -output $OUTPUT_PATH/libcrypto.a
lipo -create \
    $ROOT_PATH/build/openssl/ios/lib/libssl.a \
    $ROOT_PATH/build/openssl/ios64/lib/libssl.a \
    -output $OUTPUT_PATH/libssl.a

echo "Creating the OpenSSL XCFrameworks"

LIB_PATH=$ROOT_PATH/lib
LIBCRYPTO_PATH=$LIB_PATH/libcrypto.xcframework
LIBSSL_PATH=$LIB_PATH/libssl.xcframework
rm -rf $LIBCRYPTO_PATH
rm -rf $LIBSSL_PATH
mkdir -p $LIB_PATH

xcodebuild -create-xcframework \
    -library $ROOT_PATH/build/openssl/lib/libcrypto.a \
    -library $ROOT_PATH/build/openssl/iossimulator/lib/libcrypto.a \
    -library $ROOT_PATH/build/openssl/catalyst/lib/libcrypto.a \
    -output $LIBCRYPTO_PATH

xcodebuild -create-xcframework \
    -library $ROOT_PATH/build/openssl/lib/libssl.a \
    -headers $ROOT_PATH/build/openssl/ios/include \
    -library $ROOT_PATH/build/openssl/iossimulator/lib/libssl.a \
    -headers $ROOT_PATH/build/openssl/iossimulator/include \
    -library $ROOT_PATH/build/openssl/catalyst/lib/libssl.a \
    -headers $ROOT_PATH/build/openssl/catalyst/include \
    -output $LIBSSL_PATH

echo "Done; cleaning up"
rm -rf /tmp/openssl