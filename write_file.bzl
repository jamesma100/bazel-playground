'''
Create a file and writes to it
'''
def _write_file_simple_impl(ctx):
    # print("3. analyzing", ctx.label)
    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
    	output = out,
    	content = "hello world\n",
    )
    return [DefaultInfo(files = depset([out]))]

write_file_simple = rule(
    implementation = _write_file_simple_impl,
)

'''
Create a file with a shell command
'''
def _write_file_shell_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.run_shell(
        outputs = [out], 
        command = "echo 'hello world' > " + out.path,
    )
    return [DefaultInfo(files = depset([out]))]

write_file_shell = rule(
    implementation = _write_file_shell_impl,
)

'''
Create a list of files
'''
def _write_multiple_files_impl(ctx):
    outs = []
    for i in range(5):
        out = ctx.actions.declare_file(ctx.label.name + str(i+1))
        ctx.actions.write(
            output = out,
            content = str(i+1) + "/5 files!!!\n"
        ) 
        outs.append(out)
    return [DefaultInfo(files = depset(outs))]

write_multiple_files = rule(
    implementation = _write_multiple_files_impl
)

'''
Create multiple files, and stick them in one directory. Command `command` doesn't work becuase the files
do not exist yet. Command `command1` generates those files as part of an action registered to the directory -> works
'''
def _write_multiple_files_and_stick_into_one_dir_impl(ctx):
    dirname = ctx.label.name + "_dir"
    out_dir = ctx.actions.declare_directory(dirname)

    out_files = []
    for i in range(3):
        out_file = ctx.actions.declare_file(ctx.label.name + str(i+1))
        ctx.actions.write(
            output = out_file,
            content = str(i+1) + "/3 files!!!\n"
        )
        out_files.append(out_file)

    command = " ".join(["echo '{num}/3 files!!' > {out_file_path};".format(num=i+1, \
    	out_file_path=out_files[i].path) for i in range(len(out_files))])
    command += "rm -r {out_dir_path}; mkdir {out_dir_path};".format(out_dir_path=out_dir.path) + \
    " ".join(["cp {out_file_path} {out_dir_path}/;".format(out_file_path=out_file.path, out_dir_path=out_dir.path) \
    	for out_file in out_files])

    sample_file = ctx.actions.declare_file("sample_file")
    ctx.actions.write(
        output = sample_file,
        content = "sample file!!\n"
    )
    command1 = "echo 'sample file' > {out_file}; cp {out_file} {out_dir}/".format(out_file=sample_file.path, out_dir=out_dir.path)
    ctx.actions.run_shell(
        outputs = [out_dir],
        command = command
    )

    return [DefaultInfo(files = depset([out_dir]))]


write_multiple_files_and_stick_into_one_dir = rule(
    implementation = _write_multiple_files_and_stick_into_one_dir_impl
)

'''
Easier example: pass files and directories around with inputs/outputs via shell commands. Works.
'''
def _transfer_files_impl(ctx):
    # create a dir with a file inside, and return dir
    mydir = ctx.actions.declare_directory("mydir")
    ctx.actions.run_shell(
        outputs = [mydir],
        command = "rm -r {dirpath}; mkdir {dirpath}; echo 'hi earth' > myfile; cp myfile {dirpath}/".format(dirpath=mydir.path),
    )

    file_a = ctx.actions.declare_file("file_a")
    file_b = ctx.actions.declare_file("file_b")

    ctx.actions.write(
        output = file_a,
        content = "hi file a"
    )
    ctx.actions.write(
        output = file_b,
        content = "hi file b"
    )
    files = [file_a, file_b]

    mytempdir = ctx.actions.declare_directory("mytempdir")
    ctx.actions.run_shell(
        inputs = files,
        outputs = [mytempdir],
        command = "mkdir {dirpath};".format(dirpath=mytempdir.path) +
            " ".join(["cp {filepath} {dirpath}/;".format(filepath=file.path, dirpath=mytempdir.path) for file in files])
   	)

    mynewdir = ctx.actions.declare_file("mynewdir")
    ctx.actions.run_shell(
        outputs = [mynewdir],
        inputs = [mytempdir],
        command = "mkdir {mynewdirpath}; cp -R {mydirpath}/ {mynewdirpath}/;".format(mydirpath=mytempdir.path, mynewdirpath=mynewdir.path)
    )

    return [DefaultInfo(files = depset([mynewdir]))]

transfer_files = rule(
	implementation = _transfer_files_impl,
)


# print("1. bzl file evaluation")
