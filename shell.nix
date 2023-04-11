{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "dotnix";
  buildInputs = with pkgs; [ ];
}
