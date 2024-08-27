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
"""Rules for manipulation of K8s constructs."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//toolchains/kubectl:kubectl_configure.bzl", "kubectl_configure")
load(":with-defaults.bzl", _k8s_defaults = "k8s_defaults")

k8s_defaults = _k8s_defaults

_com_github_yaml_pyyaml_build_file = """\
load("@rules_python//python:defs.bzl", "py_binary", "py_library")

py_library(
    name = "yaml",
    srcs = glob(["lib/yaml/*.py"]),
    imports = [
        "lib",
    ],
    visibility = ["//visibility:public"],
)

py_library(
    name = "yaml3",
    srcs = glob(["lib3/yaml/*.py"]),
    imports = [
        "lib3",
    ],
    visibility = ["//visibility:public"],
)
"""

# buildifier: disable=unnamed-macro
def k8s_repositories():
    """Download dependencies of k8s rules."""

    # Used by utilities for roundtripping yaml.
    maybe(
        http_archive,
        name = "com_github_yaml_pyyaml",
        build_file_content = _com_github_yaml_pyyaml_build_file,
        sha256 = "3f11e50a10e70d481fc4c16880a605ee5f955e17eba2673a0bf15f4f40e3f7ef",
        strip_prefix = "pyyaml-5.4.1",
        urls = ["https://github.com/yaml/pyyaml/archive/5.4.1.zip"],
    )

    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        integrity = "sha256-M6zErg9wUC20uJPJ/B3Xqb+ZjCPn/yxFF3QdQEmpdvg=",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.48.0/rules_go-v0.48.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.48.0/rules_go-v0.48.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "bazel_gazelle",
        integrity = "sha256-12v3pg/YsFBEQJDfooN6Tq+YKeEWVhjuNdzspcvfWNU=",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.37.0/bazel-gazelle-v0.37.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.37.0/bazel-gazelle-v0.37.0.tar.gz",
        ],
    )


    # WORKSPACE target to configure the kubectl tool
    maybe(
        kubectl_configure,
        name = "k8s_config",
        build_srcs = False,
    )


    # Register the default kubectl toolchain targets for supported platforms
    # note these work with the autoconfigured toolchain
    native.register_toolchains(
        "@io_bazel_rules_k8s//toolchains/kubectl:kubectl_linux_amd64_toolchain",
        "@io_bazel_rules_k8s//toolchains/kubectl:kubectl_linux_arm64_toolchain",
        "@io_bazel_rules_k8s//toolchains/kubectl:kubectl_linux_s390x_toolchain",
        "@io_bazel_rules_k8s//toolchains/kubectl:kubectl_macos_x86_64_toolchain",
        "@io_bazel_rules_k8s//toolchains/kubectl:kubectl_macos_arm64_toolchain",
        "@io_bazel_rules_k8s//toolchains/kubectl:kubectl_windows_toolchain",
    )
