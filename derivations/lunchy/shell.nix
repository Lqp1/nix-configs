with (import <nixpkgs> {});
let
  env = bundlerEnv {
    name = "lunchy-bundler-env";
    inherit ruby;
    gemfile  = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset   = ./gemset.nix;
  };
in stdenv.mkDerivation {
  name = "lunchy";
  buildInputs = [ env ];
}
