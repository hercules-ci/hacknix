[
  ./config/providers/linode/default.nix

  ./config/providers/vultr/cloud/default.nix

  ./config/defaults/default.nix
  ./config/defaults/acme.nix
  ./config/defaults/environment.nix
  ./config/defaults/networking.nix
  ./config/defaults/nginx.nix
  ./config/defaults/nix.nix
  ./config/defaults/security.nix
  ./config/defaults/ssh.nix
  ./config/defaults/sudo.nix
  ./config/defaults/system.nix
  ./config/defaults/tmux.nix
  ./config/defaults/users.nix

  ./config/services/fail2ban
  ./config/services/freeradius

  ./config/hardware/amd/common.nix
  ./config/hardware/amd/jaguar.nix
  ./config/hardware/apu2/apu3c4.nix
  ./config/hardware/intel/broadwell-de.nix
  ./config/hardware/intel/centerton.nix
  ./config/hardware/intel/coffee-lake.nix
  ./config/hardware/intel/common.nix
  ./config/hardware/intel/haswell.nix
  ./config/hardware/intel/kaby-lake.nix
  ./config/hardware/intel/sandy-bridge.nix
  ./config/hardware/smartd/1x-non-removable.nix
  ./config/hardware/smartd/2x-non-removable.nix
  ./config/hardware/smartd/36x-hotswap.nix
  ./config/hardware/smartd/4x-hotswap.nix
  ./config/hardware/supermicro/sys-5017a-ef.nix
  ./config/hardware/supermicro/sys-5018d-fn4t.nix
  ./config/hardware/supermicro/sys-5018d-mtln4f.nix
  ./config/hardware/supermicro/mb-x10.nix
  ./config/hardware/hwutils.nix
  ./config/hardware/jetson-tk1.nix
  ./config/hardware/jetson-tx1.nix
  ./config/hardware/mbr.nix
  ./config/hardware/uefi.nix
  ./config/networking/tcp-bbr
  ./config/nix/auto-gc
  ./config/overlays.nix
  ./config/remote-builds/remote-build-host
  ./config/remote-builds/build-host
  ./core/keychain
  ./core/module-hashes.nix
  ./dns/unbound-multi-instance
  ./email/dovecot
  ./email/null-client
  ./email/opendkim
  ./email/postfix-mta
  ./email/relay-host
  ./email/service-status-email
  ./networking/accept
  ./networking/pcap-prep
  ./networking/virtual-ips
  ./networking/wireguard-dhess

  ./services/apcupsd-net
  ./services/hydra-manual-setup
  ./services/netsniff-ng
  ./services/systemd-digitalocean
  ./services/tarsnapper
  ./services/traefik-forward-auth
  ./services/tftpd-hpa
  ./services/znc
]
