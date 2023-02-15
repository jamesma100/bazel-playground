def _local_repo_impl(repository_ctx):
  repository_ctx.file("hello.txt", repository_ctx.attr.msg)
  repository_ctx.file("BUILD.bazel", 'exports_files(["hello.txt"])')

local_repo = repository_rule(
  implementation = _local_repo_impl,
  attrs = {
    "msg": attr.string(
      mandatory = True,
    ),
  },
)
