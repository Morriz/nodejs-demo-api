helm install --name team-frontend-api-flux \
--set rbac.create=true \
--set helmOperator.create=true \
--set git.url=https://github.com/Morriz/nodejs-demo-api.git \
--namespace team-frontend \
weaveworks/flux