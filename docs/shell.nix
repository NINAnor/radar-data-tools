with import <nixpkgs> { 
};

let in pkgs.mkShell rec {
  buildInputs = [
    mdbook
  ];
}