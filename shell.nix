with import <nixpkgs> { 
};

let
  pythonPackages = python312Packages;
  unstable = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/tarball/b69de56fac8c2b6f8fd27f2eca01dcda8e0a4221) {};
in pkgs.mkShell rec {
  name = "impurePythonEnv";
  venvDir = "./.venv";
  buildInputs = [
    # A Python interpreter including the 'venv' module is required to bootstrap
    # the environment.
    pythonPackages.python

    # This executes some shell code to initialize a venv in $venvDir before
    # dropping into the shell
    pythonPackages.venvShellHook

    # Those are dependencies that we would like to use from nixpkgs, which will
    # add them to PYTHONPATH and thus make them accessible from within the venv.
    pythonPackages.django-environ
    pythonPackages.click
    unstable.python312Packages.duckdb
    # pythonPackages.ibis-framework
    
    parallel
    # install a custom GDAL version
    unstable.gdal
    unstable.duckdb
  ];

  # Run this command, only after creating the virtual environment
  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    pip install -e .
  '';

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ''
    # allow pip to install wheels
    unset SOURCE_DATE_EPOCH
  '';

}