with import <nixpkgs> { 
};

let
  unstable = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/tarball/b69de56fac8c2b6f8fd27f2eca01dcda8e0a4221) {};
in pkgs.mkShell rec {
  name = "impurePythonEnv";
  LD_LIBRARY_PATH = "${stdenv.cc.cc.lib}/lib";
  venvDir = "./.venv";
  buildInputs = [
    unstable.python312Packages.venvShellHook
    unstable.parallel
    unstable.gdal
    unstable.duckdb
    unstable.python312
    go-task
  ];

  # Run this command, only after creating the virtual environment
  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    pip install -r requirements.txt
  '';

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ''
    # allow pip to install wheels
    unset SOURCE_DATE_EPOCH
  '';
}