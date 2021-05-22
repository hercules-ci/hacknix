{ lib
, ...
}:
{
  system = "x86_64-darwin";
  modules = lib.singleton
    ({ pkgs, ... }: {
      # For now, setting this is required.
      environment.darwinConfig = "${pkgs.lib.hacknix.path}/examples/nix-darwin/build-host.nix";

      nix.maxJobs = 16;
      hacknix-nix-darwin.build-host = {
        enable = true;
        buildMachines = {
          remote-builder = {
            hostName = "remote-builder.example.com";
            alternateHostNames = [ "192.0.2.1" "2001:db8::1" ];
            hostPublicKeyLiteral =
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBp7K+EqL+5Ry40pQrHRDd9H/jh/eaYYYV0uxH9cxa0q";
            systems = [ "x86_64-linux" "i686-linux" ];
            maxJobs = 4;
            speedFactor = 1;
            supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
            sshUserName = "remote-builder";
          };
        };
      };

      services.vault-agent = {
        enable = true;
        server.address = "http://example.com";
      };
    });
}
