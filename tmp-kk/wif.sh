#!/bin/bash
# Hitscoop: GitHub Actions -> Google Play (anahtarsız, Workload Identity Federation)
set -e
P=hitscoop; N=675253797897; SA=hitscoop-play@hitscoop.iam.gserviceaccount.com
gcloud config set project $P >/dev/null
gcloud iam workload-identity-pools describe github --location=global >/dev/null 2>&1 || gcloud iam workload-identity-pools create github --location=global --display-name=GitHub
gcloud iam workload-identity-pools providers describe hitscoop-gh --location=global --workload-identity-pool=github >/dev/null 2>&1 || \
gcloud iam workload-identity-pools providers create-oidc hitscoop-gh --location=global --workload-identity-pool=github \
  --issuer-uri=https://token.actions.githubusercontent.com \
  --attribute-mapping=google.subject=assertion.sub,attribute.repository=assertion.repository \
  --attribute-condition="assertion.repository=='Melihoguzhan/hitscoop'"
gcloud iam service-accounts add-iam-policy-binding $SA --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/$N/locations/global/workloadIdentityPools/github/attribute.repository/Melihoguzhan/hitscoop" >/dev/null
# indirilen JSON anahtarını iptal et (artık gerekmiyor)
for k in $(gcloud iam service-accounts keys list --iam-account=$SA --managed-by=user --format="value(name)"); do gcloud iam service-accounts keys delete $k --iam-account=$SA -q; done
echo "WIF-TAMAM projects/$N/locations/global/workloadIdentityPools/github/providers/hitscoop-gh"
