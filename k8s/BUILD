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

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

exports_files([
    "apply.sh.tpl",
    "create.sh.tpl",
    "replace.sh.tpl",
    "resolve.sh.tpl",
    "resolve-all.sh.tpl",
    "reverse.sh.tpl",
    "delete.sh.tpl",
    "describe.sh.tpl",
    "diff.sh.tpl",
])

py_binary(
    name = "stamper",
    srcs = ["stamper.py"],
    main = "stamper.py",
    visibility = ["//visibility:public"],
)

py_binary(
    name = "reverser",
    srcs = ["reverser.py"],
    main = "reverser.py",
    visibility = ["//visibility:public"],
    deps = select({
        "@bazel_tools//tools/python:PY2": ["@com_github_yaml_pyyaml//:yaml"],
        "@bazel_tools//tools/python:PY3": ["@com_github_yaml_pyyaml//:yaml3"],
    }),
)
