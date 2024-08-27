# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@bazel_gazelle//:def.bzl", "gazelle")

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

exports_files([
    "LICENSE",
    "__init__.py",
])

# gazelle:prefix github.com/bazelbuild/rules_k8s
# gazelle:repository go_repository name=com_github_docker_docker_credential_helpers importpath=github.com/docker/docker-credential-helpers/credentials
gazelle(
    name = "gazelle",
)

gazelle(
    name = "gazelle-update-repos",
    args = [
        "-from_file=go.mod",
        "-to_macro=k8s/k8s_go_deps.bzl%k8s_go_deps",
        "-prune",
    ],
    command = "update-repos",
)
