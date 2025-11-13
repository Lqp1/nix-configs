{ inputs, pkgs, pkgsUnstable, ... }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in
{
  environment.systemPackages = with pkgs; [
    awscli2
    bind
    cpulimit
    gdk
    git-review
    helm-ls
    jq
    openconnect
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
