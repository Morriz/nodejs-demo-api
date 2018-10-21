helm install --name team-frontend-api-flux \
--set rbac.create=true \
--set helmOperator.create=true \
--set git.url=ssh://git@github.com/morriz/nodejs-demo-api \
--namespace team-frontend \
weaveworks/flux