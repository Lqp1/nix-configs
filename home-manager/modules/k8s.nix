{ pkgs, ... }:

let
  gdk = pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);

  # Expose the helm binary also under the name `helm4`.
  helm4 = pkgs.runCommand "helm4" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.unstable.kubernetes-helm}/bin/helm $out/bin/helm4
  '';
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
    helm4
    helm-ls
    gdk
  ];
}
