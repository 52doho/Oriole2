#!/bin/sh

# Copyright 2009-2012 Urban Airship Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binaryform must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided withthe distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if [ "true" == "${ALREADYINVOKED:-false}" ]
then
echo "RECURSION: Not the root invocation, don't recurse"
else
# Prevent recursion
export ALREADYINVOKED="true"

buildConfig="$CONFIGURATION"
srcRoot="$SRCROOT"

srcPath="${srcRoot}"
destPath="${srcRoot}/build/${buildConfig}-lib"

if [ -z "$buildConfig" ]; then
	echo "Error: This script is only meant to be run within Oriole2 build phase."
	exit -1
fi

rm -rf "${destPath}"
mkdir -p "${destPath}"
echo "cp -R \"${srcPath}/Oriole2\" \"${srcRoot}/build/${buildConfig}-lib\""
cp -R "${srcPath}/Oriole2/" "${srcRoot}/build/${buildConfig}-lib"

cd "${destPath}"
cp "${srcPath}/build/${buildConfig}-universal/libOriole2 Universal.a" "${destPath}"

# Remove all non .h files from /Library and /Common
# Remove all non UA_ items & dirs from Airship/External

find Ads \! -name "*.h" -type f -delete
find Animation \! -name "*.h" -type f -delete
find Common \! -name "*.h" -type f -delete
find Controls \! -name "*.h" -type f -delete
find CrashReporter \! -name "*.h" -type f -delete
find Extend \! -name "*.h" -type f -delete
find Network \! -name "*.h" -type f -delete
find SNS \! -name "*.h" -type f -delete
find ThirdParty \! -name "*.h" -type f -delete
find Utilities \! -name "*.h" -type f -delete
find ViewControllers \! -name "*.h" -type f -delete


fi
