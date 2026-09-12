{ config, lib, ... }:
let
  defaultConfig = {
    extraArgs = [ "--remote-path=borg-1.4" ];
    extraCreateArgs = [ "--stats" ];
    startAt = "*-*-* 01:00:00";
    encryption = {
      mode = "repokey";
      passCommand = "cat ${config.age.secrets.borgPass.path}";
    };
    environment.BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
    doInit = true;
    compression = "lz4";
  };
  borgUser = "u663774";
  borgHost = "falkenstein.${config.domainName}:23";
  makeRepoUrl = jobName: "ssh://${borgUser}@${borgHost}/./backups/${config.hostname}-${jobName}";
  jobsList = lib.attrsets.mapAttrsToList (name: value: "borgbackup-job-${name}") config.services.borgbackup.jobs;
in
{
  age.secrets.borgPass = {
    file = ./secrets/borgPass.age;
  };
  services.borgbackup.jobs = {
    media = defaultConfig // {
      paths = "${config.mediaDir}/./";
      repo = makeRepoUrl "media";
      compression = "none";
      exclude = [ "*/cache" "*/.cache" ];
    };
    nextcloud = defaultConfig // {
      paths = "${config.hddDir}/./nextcloud";
      repo = makeRepoUrl "nextcloud";
    };
    containers = defaultConfig // {
      paths = "/var/lib/containers/storage/./volumes";
      repo = makeRepoUrl "containers";
    };
    matrix = defaultConfig // {
      paths = "${config.hddDir}/./matrix-synapse";
      repo = makeRepoUrl "matrix";
    };
    postgres = defaultConfig // {
      paths = "${config.hddDir}/./postgres";
      repo = makeRepoUrl "postgres";
    };
  };
  # https://gist.github.com/Zaczero/59055969dc71fda0548ca7da5acb18df
  # boot.kernelPatches = [{
  #   name = "bbr";
  #   patch = null;
  #   structuredExtraConfig = with pkgs.lib.kernel; {
  #     TCP_CONG_BBR = yes; # enable BBR
  #     DEFAULT_BBR = yes; # use it by default
  #   };
  # }];
  systemd.services = (
    builtins.listToAttrs (
      map (jobName:
        {name = jobName; value = {
          serviceConfig = {
            # https://github.com/borgbackup/borg/issues/6622#issuecomment-1102701735
            RestartPreventExitStatus = 2;
            Restart = "on-failure";
            RestartSec = 30;
          };
          unitConfig = {
            StartLimitInterval = 200;
            StartLimitBurst = 5;
          };
        };}
      ) jobsList
    )
  );
}
