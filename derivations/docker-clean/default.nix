{ pkgs }:

pkgs.writeShellApplication {
  name = "docker-clean";

  runtimeInputs = with pkgs; [
    docker
    coreutils
  ];

  text = ''
    if ! docker info >/dev/null 2>&1; then
      echo "Error: Cannot connect to Docker daemon (is Docker/Colima running?)" >&2
      exit 1
    fi

    if [ "''${1:-}" != "-f" ] && [ "''${1:-}" != "--force" ]; then
      echo "Current Docker disk usage:"
      docker system df
      echo ""
      printf "Aggressively remove ALL stopped containers, unused images, volumes, and build cache? [y/N] "
      read -r response
      case "$response" in
        [yY][eE][sS]|[yY]) ;;
        *)
          echo "Aborted."
          exit 0
          ;;
      esac
      echo ""
    fi

    echo "==> Pruning containers, images, volumes, and networks..."
    docker system prune -a --volumes -f

    echo "==> Pruning build cache..."
    docker builder prune -a -f

    echo ""
    echo "Updated Docker disk usage:"
    docker system df
  '';
}
