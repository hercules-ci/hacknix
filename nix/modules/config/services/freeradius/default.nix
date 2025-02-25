{ config, pkgs, lib, ... }:
let
  cfg = config.hacknix.freeradius;
  enabled = cfg.enable;
  allowedIPs = {
    v4 = lib.mapAttrsToList (_: client: client.ipv4) cfg.clients;
    v6 = lib.mapAttrsToList (_: client: client.ipv6) cfg.clients;
  };
  fwRulePerIP = port: interface: ips:
    map
      (
        ip: {
          protocol = "udp";
          inherit interface;
          dest.port = port;
          src.ip = ip;
        }
      )
      ips;
  fwRulesPerInterface = port: interfaces: ips:
    lib.flatten (map (interface: fwRulePerIP port interface ips) interfaces);
  raddb = import ./conf/raddb.nix { inherit lib pkgs config; };
in
{
  meta.maintainers = lib.maintainers.dhess;

  options.hacknix.freeradius = {
    enable = lib.mkEnableOption ''
      an opinionated FreeRADIUS server.

      The server will be configured with secure defaults, and will
      accept only modern authentication mechanisms.
    '';

    interfaces = lib.mkOption {
      type = lib.types.nonEmptyListOf pkgs.lib.types.nonEmptyStr;
      example = [ "eno2" ];
      description = ''
        A list of interface device names from which RADIUS requests
        will be permitted. The host's firewall will be configured to
        accept RADIUS requests (UDP ports 1812 and 1813) only from these
        interfaces.

        RADIUS requests from external hosts that reach the host from
        an interface not named here will be blocked by the host
        firewall.

        Note that internal RADIUS requests (i.e., requests from the
        host itself) are always accepted.
      '';
    };

    clients = lib.mkOption {
      default = { };
      type = lib.types.attrsOf pkgs.lib.types.radiusClient;
      description = ''
        RADIUS clients that are authorized to connect to this RADIUS
        server.
      '';
    };

    tls = {
      caPath = lib.mkOption {
        type = lib.types.path;
        description = ''
          The path to the directory containing the CA files for this
          RADIUS server. These CA files will be used to authenticate
          TLS clients; i.e., any CAs used to issue client certificates
          that are to be authenticated by this RADIUS server should be
          included. They should include all root CA certificates,
          intermediate CA certificates, and CRL files needed to
          authenticate clients.

          Each certificate or CRL should be stored in a separate file.
          If you use intermediate CAs, do not concatenate them with
          their parent certificates (i.e., do not chain the
          certificates).

          The certificates files should also be symlinked to their
          hashed filenames per the OpenSSL <command>c_rehash</command>
          command. The easiest way to do this is to use the
          <literal>pkgs.hashedCertDir</literal> builder function.

          Note that the certificates in this directory should not
          include the RADIUS server's own server certificate; that
          certificate, and its private key, are configured separately.

          Typically, this path will only include CAs used to generate
          certificates that are internal to your organization. Do
          <em>not</em> include CA certificates in this path that are
          not used to issue client certificates for this RADIUS
          server; i.e., do not point this path to the system
          certificate directory containing all public CAs.
        '';
      };

      serverCertificate = lib.mkOption {
        type = lib.types.path;
        description = ''
          The path to the server TLS certificate to use with (outer)
          RADIUS TLS authentication protocols, such as EAP-TLS.
        '';
      };

      serverCertificateKeyFile = lib.mkOption {
        type = pkgs.lib.types.nonStorePath;
        example = "/var/lib/freeradius/tls.key";
        description = ''
          A path to the file containing the server's TLS certificate key.
        '';
      };
    };

    users = {
      authorizedMacs = lib.mkOption {
        type = lib.types.listOf pkgs.lib.types.nonEmptyStr;
        default = [ ];
        example = [ "00:11:22:33:44:55" "aa:bb:cc:dd:ee:ff" ];
        description = ''
          A list of client MACs that are authorized to join WiFi
          networks that are authenticated against this RADIUS server.
          MACs that do not appear in this list will be blocked.

          Note: just because a MAC is present in this list doesn't
          necessarily mean it will be permitted to join a WiFi
          network. Inclusion in the list is necessary but not
          sufficient. Other authentication mechanisms will be applied
          in addition to the MAC check.
        '';
      };
    };

    postAuthConfig = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = lib.literalExpression ''
        update reply {
          Tunnel-Type := VLAN
          Tunnel-Medium-Type := IEEE-802
          Tunnel-Private-Group-ID := 100
        }
      '';
      description = ''
        A FreeRADIUS configuration block that's inserted in the
        post-auth config stanza verbatim. This is intended to be used
        to update the RADIUS reply message with additional
        configuration; e.g., dynamic VLAN configuration.
      '';
    };

    modsEnabled = lib.mkOption {
      example = [ "eap" "pap" ];
      default = [
        "always"
        "attr_filter"
        "cache_eap"
        "date"
        "detail"
        "detail.log"
        "dynamic_clients"
        "eap"
        "exec"
        "expiration"
        "expr"
        "files"
        "linelog"
        "loginitme"
        "pap"
        "preprocess"
        "radutmp"
        "realm"
        "replicate"
        "sradutmp"
        "unix"
        "unpack"
        "utf8"
      ];
      description = ''
        A list of FreeRADIUS mods that will be enabled.

        The default list includes most of the out-of-the-box
        FreeRADIUS enabled mods, except that some of the
        insecure/vulnerable/legacy authentication mechanisms have been
        removed.
      '';
    };

    configDir = lib.mkOption {
      default = "/etc/raddb";
      readOnly = true;
      description = ''
        The directory where the static FreeRADIUS configuration is
        stored.
      '';
    };

    dataDir = lib.mkOption {
      default = "/var/lib/radiusd";
      readOnly = true;
      description = ''
        The FreeRADIUS database directory, where persistent data is
        kept.
      '';
    };

    tlsCacheDir = lib.mkOption {
      default = "/var/lib/radiusd/tlscache";
      readOnly = true;
      description = ''
        The FreeRADIUS TLS cache directory.
      '';
    };

    logDir = lib.mkOption {
      default = "${cfg.dataDir}/log";
      readOnly = true;
      description = ''
        The FreeRADIUS log directory. Note that only accounting info
        will be kept here, as FreeRADIUS will otherwise be configured
        to log to <literal>syslog</literal>.
      '';
    };

    secretsDir = lib.mkOption {
      default = "${cfg.dataDir}/secrets";
      readOnly = true;
      description = ''
        The directory where FreeRADIUS secrets (client secrets, TLS
        certificate private keys, etc.) will be stored.
      '';
    };
  };

  config = lib.mkMerge [
    (
      lib.mkIf enabled {

        hacknix.assertions.moduleHashes."services/networking/freeradius.nix" =
          "92331a400ab45fb307511a0bda9986b79e58e373bc6d048a1031782c20ae5c5a";

        networking.firewall.accept =
          (fwRulesPerInterface 1812 cfg.interfaces allowedIPs.v4)
          ++ (fwRulesPerInterface 1813 cfg.interfaces allowedIPs.v4);
        networking.firewall.accept6 =
          (fwRulesPerInterface 1812 cfg.interfaces allowedIPs.v6)
          ++ (fwRulesPerInterface 1813 cfg.interfaces allowedIPs.v6);

        services.freeradius = {
          enable = true;
          configDir = cfg.configDir;
        };

        environment.systemPackages = with pkgs; [
          freeradius

          # For testing EAP functionality
          wpa_supplicant
        ];

        systemd.tmpfiles.rules = [
          "d '${cfg.dataDir}' 0750 radius wheel - -"
          "d '${cfg.logDir}' 0750 radius wheel - -"
          "d '${cfg.tlsCacheDir}' 0750 radius wheel - -"
          "d '${cfg.secretsDir}' 0750 radius wheel - -"
        ];
      }
    )
    raddb
  ];
}
