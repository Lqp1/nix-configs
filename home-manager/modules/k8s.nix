{ pkgs, ... }:

let
  gdk = pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in
{
  home.packages = with pkgs; [
    unstable.k9s
    krew
    unstable.kubectl
    unstable.kubectl-tree
    unstable.kubectl-images
    unstable.kubectl-df-pv
    unstable.kubelogin-oidc
    unstable.kubectx
    unstable.kubent
    unstable.kubie
    unstable.kubernetes-helm
    helm-ls
    gdk
  ];
}
