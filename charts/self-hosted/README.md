# Self-Hosted

A Helm chart for deploying self-hosted swanlab.

You can install the chart with the command:

```bash
helm repo add swanlab https://helm.swanlab.cn
helm install swanlab-self-hosted swanlab/self-hosted
```

## Database migrations

Schema migrations run in a dedicated Helm hook Job using the server image:

- Upgrades: `pre-upgrade`, before any business Deployment is updated.
- Fresh installs with external PostgreSQL: `pre-install`. The database, its existing
  credentials Secret, and image pull Secrets must already be available.
- Fresh installs with chart-managed PostgreSQL: `post-install`, after PostgreSQL is
  created. **Do not use `--wait` or `--atomic` for these installs**: server Pods wait
  for the schema, so waiting for readiness before running the hook would deadlock.

Set a Helm timeout longer than `service.server.migration.activeDeadlineSeconds`
(default: 14400 seconds / 4 hours for the entire Job, not each SQL file):

```bash
helm upgrade swanlab-self-hosted swanlab/self-hosted \
  -n self-hosted -f values.yaml --timeout 5h
```

Only two migration settings are exposed:

```yaml
service:
  server:
    migration:
      enabled: true
      activeDeadlineSeconds: 14400
```

The Job compares directories in the image's `prisma/migrations/` with successful
records in `_prisma_migrations` (including databases with no migration history).
It executes pending SQL files in order with `prisma db execute`, then records each
success using `prisma migrate resolve --applied`. It does not parse the CLI's
human-readable status output, change migration SQL, detect schema drift, or replay
manual changes outside the migration directory. After verifying the schema status,
`node migrate.js` performs application data migrations with the chart's `appVersion`
in `VERSION`; this step always runs when the migration Job is enabled.

Server containers only start the application. A `wait-for-schema` initContainer
always checks `prisma migrate status`, including when the Job is disabled or hooks
are skipped. It keeps waiting without a separate timeout: the Pod stays in Init
until the schema is ready, rather than restarting its initContainer during a long
migration. If a migration fails or is skipped, inspect the Job and perform the
required migrations; the server will not start on an outdated schema.
Startup, readiness, and liveness probes use `/api/health` (process health,
not database health). The schema gate does not check completion of data migrations.
If `service.server.migration.enabled=false`, run schema and data migrations externally
before updating business services; disabling the hook does not restore startup-time
migrations. GitOps controllers must preserve the hook ordering or orchestrate the
migration Job separately.

### Failure handling

Failed Jobs are retained; successful Jobs are deleted. Inspect failures with:

```bash
kubectl -n self-hosted logs job/swanlab-self-hosted-server-migrate -c migrate
```

The fixed `backoffLimit: 0` prevents automatic DDL retries. Before retrying a release:

- A Helm timeout does not necessarily stop the Job. Check its status and logs first.
  Do not rerun an upgrade while it is still migrating: `before-hook-creation` deletes
  the previous Job and can interrupt active DDL. If it finished successfully, retry
  the same target version with a longer Helm timeout; recorded migrations are skipped.
- Repair unresolved failed Prisma records manually. The Job refuses to proceed while
  any such record exists.
- If an interrupted concurrent index build left an INVALID index, inspect and drop
  that index with `DROP INDEX CONCURRENTLY` before retrying.
- If SQL succeeded but recording it failed, run `prisma migrate resolve --applied
  <migration-name>` manually **before** rerunning the Job; do not replay that SQL.
  SQL execution and migration bookkeeping are separate operations, not an atomic pair.

Do not run concurrent migration/release processes. Long-running migrations require
an uninterrupted release runner, a direct connection to the primary PostgreSQL
instance (not a transaction pooler), sufficient disk space, and compatible timeout
settings. The Job inherits the server's image pull Secrets, security context,
node selector, and tolerations. It has no separate priority or resource settings.
Upgrades run migrations while old Pods remain active, so migration SQL
must be backward-compatible with the currently running application.
