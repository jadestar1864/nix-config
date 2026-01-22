{
  unify.hosts.nixos.teemo.nixos = {
    networking.firewall.allowedTCPPorts = [
      3020 # prometheus
      2342 # grafana
      3030 # loki
    ];

    # Force dbus-broker implementation so prometheus systemd exporter works
    # https://discourse.nixos.org/t/systemd-exporter-couldnt-get-dbus-connection-read-unix-run-dbus-system-bus-socket-recvmsg-connection-reset-by-peer/64367
    # https://github.com/NixOS/nixpkgs/issues/408800
    services.dbus.implementation = "broker";

    services.prometheus = {
      enable = true;
      port = 3020;
      extraFlags = [
        "--web.enable-remote-write-receiver"
      ];
    };
    services.alloy = {
      enable = true;
      configPath = ./config.alloy;
      extraFlags = [
        "--disable-reporting"
      ];
    };
    services.loki = {
      enable = true;
      configuration = {
        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = 3030;
        };
        auth_enabled = false;
        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
        };
        schema_config = {
          configs = [
            {
              from = "2024-04-01";
              object_store = "filesystem";
              store = "tsdb";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };
        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/tsdb-shipper-active";
            cache_location = "/var/lib/loki/tsdb-shipper-cache";
          };
          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };
        query_scheduler.max_outstanding_requests_per_tenant = 32768;
        querier.max_concurrent = 16;
        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };
        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };
        compactor = {
          working_directory = "/var/lib/loki";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
        analytics.reporting_enabled = false;
      };
    };
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = 2342;
          domain = "grafana.jadestar.dev";
          enable_gzip = true;
        };
        analytics.reporting_enabled = false;
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:3020";
            basicAuth = false;
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:3030";
            basicAuth = false;
          }
        ];
      };
    };
  };
}
