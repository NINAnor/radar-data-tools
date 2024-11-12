with import <nixpkgs> { 
};

let
  unstable = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/tarball/b69de56fac8c2b6f8fd27f2eca01dcda8e0a4221) {};
  pythonPackages = unstable.python312Packages;
in pkgs.mkShell rec {
  name = "impurePythonEnv";
  venvDir = "./.venv";
  buildInputs = [
    # A Python interpreter including the 'venv' module is required to bootstrap
    # the environment.
    pythonPackages.python

    # Those are dependencies that we would like to use from nixpkgs, which will
    # add them to PYTHONPATH and thus make them accessible from within the venv.
    pythonPackages.django-environ
    pythonPackages.click
    pythonPackages.duckdb
    pythonPackages.rasterio
    pythonPackages.pyarrow
    # pythonPackages.ibis-framework
    libtiff
    parallel
    # install a custom GDAL version
    unstable.gdal
    unstable.duckdb
    unstable.grass
  ];
}