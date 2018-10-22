# DIY, as opposed to setting it all up in mostack:
# they chose it, so let team-frontend install flux operator
# @todo: they need their own tiller for that
helm upgrade --install team-frontend-api-flux \
--set rbac.create=true \
--set helmOperator.create=true \
--set git.url=https://github.com/Morriz/nodejs-demo-api \
--namespace team-frontend \
weaveworks/flux

# kubeseal get pub cert from controller:
kubeseal --fetch-cert \
--controller-namespace=team-frontend \
--controller-name=sealed-secrets \
> pub-cert.pem

# secret creation:
kubectl -n dev create secret generic basic-auth \
--from-literal=user=admin \
--from-literal=password=admin \
--dry-run \
-o json > basic-auth.json

kubeseal --format=yaml --cert=pub-cert.pem < basic-auth.json > releases/dev/basic-auth.yaml

rm basic-auth.json