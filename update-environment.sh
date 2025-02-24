#! /bin/sh
#
# Copyright (c) 2024-2025 Confluent Inc.
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

cat <<EOF >~/.myvars
export CLUSTERID=$(grep -m1 CLUSTER_ID: ~/confluent-admin/docker-compose.yml | tr -d \ | cut -d: -f2)
export CONTROLLERS="9991@controller-1:19093,\ 9992@controller-2:29093,9993@controller-3:39093"
export BOOTSTRAPS="kafka-1:19092,kafka-2:29092,kafka-3:39092"
EOF

x='source ~/.myvars' ; grep -qxF "$x" ~/.bashrc || echo "$x" >>~/.bashrc
cat <<EOF
To add the variables to a terminal that is already opened (like this one), please run ". ~/.bashrc"
For terminals opened from this point onwards, the variables will be automatically added.
EOF

