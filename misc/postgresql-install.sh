NAME=db-postgresql
TIMEOUT=600s

DB_NAME=${DB_NAME:-diatom}
DB_USER=${DB_NAME} # default to the same as DB_NAME
DB_PORT=${DB_PORT:-5432}

# create an app user secret if it doesn't exist
SECRET_EXISTS=$(kubectl get secrets | grep "^${NAME}-secret")
if [ -z "${SECRET_EXISTS}" ]; then
  kubectl create secret generic ${NAME}-secret \
    --from-literal=postgres-password="$(openssl rand -hex 16)" \
    --from-literal=DB_PASS="$(openssl rand -hex 16)" \
    --dry-run=client -o yaml | kubectl apply -f -
else
  echo "Secret ${NAME} already exists. Not overwriting."
fi

helm upgrade -i \
  ${NAME} postgresql \
  --atomic \
  --repo https://charts.bitnami.com/bitnami \
  --timeout ${TIMEOUT} \
  --version 12.5.4 \
  --values - <<EOF
auth:
  database: ${DB_NAME}
  username: ${DB_USER}
  existingSecret: "${NAME}-secret"
  secretKeys:
    userPasswordKey: "DB_PASS"
tls:
  enabled: ${TLS_ENABLED:-true}
  autoGenerated: ${TLS_AUTO_GENERATED:-true}
EOF

# create configmap for HOST and USERNAME
kubectl create configmap ${NAME}-config \
  --from-literal=DB_HOST="${NAME}.default.svc.cluster.local" \
  --from-literal=DB_NAME="${DB_NAME}" \
  --from-literal=DB_USER="${DB_USER}" \
  --from-literal=DB_PORT="${DB_PORT}" \
  --from-literal=DB_SSL_ROOT_CERT_NAME="ca.crt" \
  --from-literal=DB_SSL_CERT_NAME="tls.crt" \
  --from-literal=DB_SSL_KEY_NAME="tls.key" \
  --dry-run=client -o yaml | kubectl apply -f -

# ** Please be patient while the chart is being deployed **
#PostgreSQL can be accessed via port 5432 on the following DNS names from within your cluster:
#
#    db-postgresql.default.svc.cluster.local - Read/Write connection
#
#To get the password for "postgres" run:
#
#    export POSTGRES_ADMIN_PASSWORD=$(kubectl get secret --namespace default db-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
#
#To get the password for "diatom" run:
#
#    export POSTGRES_PASSWORD=$(kubectl get secret --namespace default db-postgresql -o jsonpath="{.data.DB_PASS}" | base64 -d)
#
#To connect to your database run the following command:
#
#    kubectl run db-postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:15.3.0-debian-11-r4 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
#      --command -- psql --host db-postgresql -U diatom -d diatom -p 5432
#
#    > NOTE: If you access the container using bash, make sure that you execute "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash" in order to avoid the error "psql: local user with ID 1001} does not exist"
#
#To connect to your database from outside the cluster execute the following commands:
#
#    kubectl port-forward --namespace default svc/db-postgresql 5432:5432 &
#    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U diatom -d diatom -p 5432
