load(
    ":write_file.bzl", 
    "write_file_simple", 
    "write_file_shell",
    "write_multiple_files",
    "write_multiple_files_and_stick_into_one_dir",
    "transfer_files",
)

load("@rules_java//java:defs.bzl", "java_binary")

# print("2. BUILD file")
write_file_simple(name = "write_file_simple")
write_file_shell(name = "write_file_shell")
write_multiple_files(name = "write_multiple_files")
write_multiple_files_and_stick_into_one_dir(name = "write_multiple_files_and_stick_into_one_dir")
transfer_files(name = "transfer_files")

java_binary(
    name = "Greeting",
    srcs = glob(["src/main/java/com/example/*.java"])
)

java_library(
    name = "java_test_deps",
    exports = [
        "@maven//:junit_junit",
        "@maven//:org_hamcrest_hamcrest_library",
    ],
)

android_library(
    name = "android_test_deps",
    exports = [
        "@maven//:junit_junit",
        "@maven//:androidx_test_espresso_espresso_core",
    ],
)
