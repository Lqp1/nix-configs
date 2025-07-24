{ pkgs ? import <nixpkgs> { } }:

pkgs.bundlerApp {
  pname = "lunchy";
  gemdir = ./.; # Points to your local directory with Gemfile, gemset.nix, etc.
  exes = [ "lunchy" ]; # Name of the binary as declared in the gemspec[2]
  ruby = pkgs.ruby; # Or another Ruby version if needed
  gemset = ./gemset.nix;
}

