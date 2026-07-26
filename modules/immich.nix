{ config, pkgs, ... }:

let
  immichDir = "/data/docker/immich";
  dbPassword = "postgres";

  composeYml = pkgs.writeText "immich-compose.yml" ''
    name: immich
    services:
      immich-server:
        container_name: immich_server
        image: ghcr.io/immich-app/immich-server:release
        volumes:
          - ${immichDir}/upload:/usr/src/app/upload
          - /etc/localtime:/etc/localtime:ro
        env_file:
          - ${immichDir}/.env
        environment:
          IMMICH_MEDIA_LOCATION: /usr/src/app/upload
        ports:
          - '2283:2283'
        depends_on:
          redis:
            condition: service_healthy
          database:
            condition: service_healthy
        restart: always

      immich-machine-learning:
        container_name: immich_machine_learning
        image: ghcr.io/immich-app/immich-machine-learning:release
        volumes:
          - ${immichDir}/model-cache:/cache
        env_file:
          - ${immichDir}/.env
        restart: always

      redis:
        container_name: immich_redis
        image: docker.io/valkey/valkey:9
        volumes:
          - ${immichDir}/redis:/data
        healthcheck:
          test: ["CMD", "redis-cli", "ping"]
          interval: 10s
          timeout: 5s
          retries: 5
        restart: always

      database:
        container_name: immich_postgres
        image: ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0
        environment:
          POSTGRES_PASSWORD: ${dbPassword}
          POSTGRES_USER: postgres
          POSTGRES_DB: immich
          POSTGRES_INITDB_ARGS: "--data-checksums"
        volumes:
          - ${immichDir}/pgdata:/var/lib/postgresql/data
        healthcheck:
          test: ["CMD-SHELL", "pg_isready -U postgres -d immich"]
          interval: 10s
          timeout: 5s
          retries: 5
        restart: always
  '';

  envFile = pkgs.writeText "immich.env" ''
    DB_HOSTNAME=immich_postgres
    DB_USERNAME=postgres
    DB_PASSWORD=${dbPassword}
    DB_DATABASE_NAME=immich
    IMMICH_MEDIA_LOCATION=/usr/src/app/upload
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
      mkdir -p ${immichDir}/{upload,pgdata,redis,model-cache}
      chown 1000:1000 ${immichDir}/upload ${immichDir}/model-cache
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
