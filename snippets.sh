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

# To prepare for disaster recovery you should backup the sealed-secrets controller private key with:
kubectl get secret -n team-frontend sealed-secrets-key -o yaml --export > sealed-secrets-key.yaml

# To restore from backup after a disaster, replace the newly-created secret and restart the controller:
kubectl replace secret -n team-frontend sealed-secrets-key -f sealed-secrets-key.yaml
kubectl delete pod -n team-frontend -l app=sealed-secrets