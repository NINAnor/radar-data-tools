import logging
import subprocess


def parallelize(
    cmd,
    *args,
    prefix=None,
    dry=False,
    concurrency,
    delay,
    memfree,
    load,
    joblog,
    results,
    resume,
    retries,
    progress,
    bar,
    max_replace_args,
    **kwargs,
):
    ps = None
    if prefix:
        ps = subprocess.Popen(prefix, stdout=subprocess.PIPE)  # noqa: S603

    command = list(
        filter(
            lambda x: x,
            [
                "parallel",
                f"-j{concurrency}" if concurrency else None,
                "--load" if load else None,
                load,
                "--memfree" if memfree else None,
                memfree,
                "--joblog" if joblog else None,
                joblog,
                "--retries" if retries else None,
                retries,
                "--delay" if delay else None,
                str(delay) if delay else None,
                "--retry-failed" if retries else None,
                "--dryrun" if dry else None,
                "--results" if results else None,
                results,
                "--resume" if resume else None,
                "--progress" if progress else None,
                "--bar" if bar else None,
                "-N" if max_replace_args else None,
                max_replace_args,
                *cmd,
                *args,
            ],
        )
    )

    logging.debug(command)
    stdin = ps.stdout if ps else None
    subprocess.run(command, stdin=stdin)  # noqa: S603
    if ps:
        ps.wait()
