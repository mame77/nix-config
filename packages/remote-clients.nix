{ pkgs }:

{
  server-desktop = pkgs.writeShellApplication {
    name = "server-desktop";
    runtimeInputs = with pkgs; [ openssh tigervnc coreutils ];
    text = ''
      remote_host="''${1:-server}"
      if [ "$#" -gt 0 ]; then shift; fi
      tunnel_dir=$(mktemp -d)
      cleanup() {
        ssh -o RemoteCommand=none -S "$tunnel_dir/control" -O exit "$remote_host" 2>/dev/null || true
        rm -rf "$tunnel_dir"
      }
      trap cleanup EXIT
      ssh -o RemoteCommand=none -o RequestTTY=no -o ExitOnForwardFailure=yes \
        -M -S "$tunnel_dir/control" -fNT \
        -L 127.0.0.1:15900:127.0.0.1:5900 "$remote_host"
      vncviewer -Shared=1 127.0.0.1::15900 "$@"
    '';
  };

  server-android = pkgs.writeShellApplication {
    name = "server-android";
    runtimeInputs = with pkgs; [ openssh scrcpy android-tools coreutils ];
    text = ''
      remote_host="''${1:-server}"
      if [ "$#" -gt 0 ]; then shift; fi
      ssh -o RemoteCommand=none -T "$remote_host" adb start-server
      tunnel_dir=$(mktemp -d)
      cleanup() {
        ssh -o RemoteCommand=none -S "$tunnel_dir/control" -O exit "$remote_host" 2>/dev/null || true
        rm -rf "$tunnel_dir"
      }
      trap cleanup EXIT
      ssh -o RemoteCommand=none -o RequestTTY=no -o ExitOnForwardFailure=yes \
        -M -S "$tunnel_dir/control" -fNT \
        -L 127.0.0.1:15038:127.0.0.1:5037 \
        -L 127.0.0.1:27183:127.0.0.1:27183 "$remote_host"
      export ADB_SERVER_SOCKET=tcp:127.0.0.1:15038
      scrcpy --force-adb-forward --port=27183 "$@"
    '';
  };
}
