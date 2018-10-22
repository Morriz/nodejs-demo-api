helm upgrade --install team-frontend-api-flux \
--set rbac.create=true \
--set helmOperator.create=true \
--set git.url=https://github.com/Morriz/nodejs-demo-api \
--namespace team-frontend \
weaveworks/flux
