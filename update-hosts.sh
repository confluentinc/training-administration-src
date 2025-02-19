#! /bin/bash
#
# Copyright (c) 2020-2025 Confluent Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if [ "$HOSTNAME" = tools ]; then
  echo "We don't need to update hosts in the tools container. Exiting."
  exit 1
fi

if grep -qF "CFLT" /etc/hosts ; then
  echo "Already done!"
  exit 0
fi

# Ugly hack because sudo doesn't affect redirections so a "sudo cat" wouldn't write to root-owned /etc/hosts
cat <<EOF | sudo tee -a /etc/hosts >/dev/null

# CFLT-Global Education host entries
127.0.0.1 controller-1
127.0.0.1 controller-2
127.0.0.1 controller-3
127.0.0.1 kafka-1
127.0.0.1 kafka-2
127.0.0.1 kafka-3
127.0.0.1 schema-registry
127.0.0.1 kafka-connect
127.0.0.1 control-center
127.0.0.1 tools
EOF
echo "Done!"
