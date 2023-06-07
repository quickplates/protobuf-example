{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      # Import local override if it exists
      imports = [
        (
          if builtins.pathExists ./local.nix
          then ./local.nix
          else {}
        )
      ];

      # Sensible defaults
      systems = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        # Override pkgs argument
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            # Allow packages with non-free licenses
            allowUnfree = true;
          };
        };

        # Set which formatter should be used
        formatter = pkgs.alejandra;

        # Define multiple development shells for different purposes
        devShells = {
          default = pkgs.mkShell {
            name = "dev";

            packages = [
              pkgs.nodejs
              pkgs.nil
              pkgs.go-task
              pkgs.trunk-io
              pkgs.copier
              pkgs.buf
              pkgs.protoc-gen-doc
            ];
          };

          template = pkgs.mkShell {
            name = "template";

            packages = [
              pkgs.go-task
              pkgs.copier
            ];
          };

          lint = pkgs.mkShell {
            name = "lint";

            packages = [
              pkgs.go-task
              pkgs.trunk-io
            ];
          };

          docs = pkgs.mkShell {
            name = "docs";

            packages = [
              pkgs.nodejs
              pkgs.go-task
              pkgs.buf
              pkgs.protoc-gen-doc
            ];
          };
        };
      };
    };
}
