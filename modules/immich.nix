{ config, pkgs, ... }:

let
  immichDir = "/data/docker/immich";

  composeYml = pkgs.writeText "immich-compose.yml" ''
    name: immich
    services:
      immich-server:
        container_name: immich_server
        image: ghcr.io/immich-app/immich-server:release
        volumes:
          - ${immichDir}/upload:/data
          - /etc/localtime:/etc/localtime:ro
        env_file:
          - ${immichDir}/.env
        ports:
          - '2283:2283'
        depends_on:
          redis:
            condition: service_started
          database:
            condition: service_started
        restart: always

      redis:
        container_name: immich_redis
        image: docker.io/valkey/valkey:9
        volumes:
          - ${immichDir}/redis:/data
        restart: always

      database:
        container_name: immich_postgres
        image: ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0
        environment:
          POSTGRES_PASSWORD: "postgres"
          POSTGRES_USER: "postgres"
          POSTGRES_DB: "immich"
          POSTGRES_INITDB_ARGS: "--data-checksums"
        volumes:
          - ${immichDir}/pgdata:/var/lib/postgresql/data
        restart: always
  '';

  envFile = pkgs.writeText "immich.env" ''
    DB_HOSTNAME=immich_postgres
    DB_USERNAME=postgres
    DB_PASSWORD=postgres
    DB_DATABASE_NAME=immich
    IMMICH_VERSION=release
  '';
in
{
  systemd.services.immich = {
    description = "Immich (Photo Management)";
    after = [ "data.mount" "docker.service" "network.target" ];
    requires = [ "data.mount" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.docker-compose ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    preStart = ''
      rm -rf ${immichDir}/{pgdata,redis}
      mkdir -p ${immichDir}/{upload,library,pgdata,redis}
      chown 1000:1000 ${immichDir}/upload ${immichDir}/library
      install -m 644 ${composeYml} ${immichDir}/docker-compose.yml
      install -m 640 ${envFile} ${immichDir}/.env
    '';
    script = ''
      docker-compose -f ${immichDir}/docker-compose.yml up -d --remove-orphans
    '';
    preStop = ''
      docker-compose -f ${immichDir}/docker-compose.yml down
    '';
  };
}
