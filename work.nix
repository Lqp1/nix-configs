{ inputs, pkgs, pkgsUnstable, ... }:
{
  environment.systemPackages = with pkgs; [
    awscli2
    bind
    cpulimit
    git-review
    gnvim
    helm-ls
    jq
    jnv
    pkgsUnstable.k9s # Use unstable version as it has the custom views feature
    krew
    kubectl
    kubectl-tree
    kubectl-images
    kubectx
    kubent
    kubie
    kubernetes-helm
    mtr
    pkgsUnstable.neovim # Use unstable version as some plugins require it
    nmap
    nodejs
    openjdk11
    pandoc
    parallel
    pssh
    uv
    whois
    xmlstarlet
    yq
  ];
}
