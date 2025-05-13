{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      nixpkgs-python,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        venvDir = ".venv";
        pythonVersion = "3.8";
        myPython = nixpkgs-python.packages.${system}.${pythonVersion};
      in
      {
        # `nix develop`
        devShell = pkgs.mkShell {
          buildInputs = [
            myPython
            # myPython.pkgs.pip
            # myPython.pkgs.virtualenv
            # python38
            # python38Packages.pip
            # python38Packages.virtualenv
            # pythonManylinuxPackages.manylinux2014Package
            # cmake
            # ninja
            # imagemagick
          ];
          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib:${pkgs.pythonManylinuxPackages.manylinux2014Package}/lib:$LD_LIBRARY_PATH";
            if ! [ -d "${venvDir}" ]; then
              ${myPython.interpreter} -m venv "${venvDir}"
              source "${venvDir}/bin/activate"
              [ -f requirements.txt ] && pip install -r requirements.txt
            fi
            source "${venvDir}/bin/activate"
          '';
        };
      }
    );
}
