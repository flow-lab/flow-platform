NAME=db-postgresql
TIMEOUT=600s

DB_NAME=${DB_NAME:-diatom}
DB_USER=${DB_NAME} # default to the same as DB_NAME
DB_PORT=${DB_PORT:-5432}

# create an app user secret if it doesn't exist
SECRET_EXISTS=$(kubectl get secrets | grep "^${NAME}")
if [ -z "${SECRET_EXISTS}" ]; then
  kubectl create secret generic ${NAME} \
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
  existingSecret: "${NAME}"
  secretKeys:
    userPasswordKey: "DB_PASS"
EOF

# create configmap for HOST and USERNAME
kubectl create configmap ${NAME}-config \
  --from-literal=DB_HOST="${NAME}.default.svc.cluster.local" \
  --from-literal=DB_NAME="${DB_NAME}" \
  --from-literal=DB_USER="${DB_USER}" \
  --from-literal=DB_PORT="${DB_PORT}" \
  --dry-run=client -o yaml | kubectl apply -f -

# ** Please be patient while the chart is being deployed **
  #
  #PostgreSQL can be accessed via port 5432 on the following DNS names from within your cluster:
  #
  #    postgresql.default.svc.cluster.local - Read/Write connection
  #
  #To get the password for "postgres" run:
  #
  #    export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
  #
  #To connect to your database run the following command:
  #
  #    kubectl run postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:15.3.0-debian-11-r4 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
  #      --command -- psql --host postgresql -U postgres -d postgres -p 5432
  #
  #    > NOTE: If you access the container using bash, make sure that you execute "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash" in order to avoid the error "psql: local user with ID 1001} does not exist"
  #
  #To connect to your database from outside the cluster execute the following commands:
  #
  #    kubectl port-forward --namespace default svc/postgresql 5432:5432 &
  #    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
  #
  #WARNING: The configured password will be ignored on new installation in case when previous Posgresql release was deleted through the helm command. In that case, old PVC will have an old password, and setting it through helm won't take effect. Deleting persistent volumes (PVs) will solve the issue.