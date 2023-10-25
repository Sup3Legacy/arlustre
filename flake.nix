{
  description = "ArLustre";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            zig
            zls
            avrdude
            screen

            ocaml
            ocamlPackages.alcotest
            ocamlPackages.findlib
            ocamlPackages.menhir
            ocamlPackages.menhirLib
            ocamlPackages.ocamlgraph
            ocamlPackages.camlp4
            ocamlPackages.ocamlbuild
          ];
        };
      });
}

