with import <nixpkgs> { 
};

let
  unstable = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/tarball/b69de56fac8c2b6f8fd27f2eca01dcda8e0a4221) {};
in pkgs.mkShell rec {
  buildInputs = [
    parallel
    unstable.gdal
    unstable.duckdb
    unstable.grass
  ];
}