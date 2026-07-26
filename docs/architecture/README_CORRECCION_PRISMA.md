# Corrección Prisma 7 + PostgreSQL 16

## Archivos corregidos

- `prisma/schema.prisma`
- `prisma/sql/0001_post_prisma_constraints_triggers_views.sql`
- `prisma/sql/0000_pre_prisma_extensions.sql` (sin cambios funcionales)

## Qué se corrigió

1. Se completaron las 12 claves candidatas `@@unique` usadas por claves foráneas compuestas.
2. Se agregó a Prisma la unicidad de `related_account_flags`.
3. Se trasladaron 11 claves foráneas compuestas desde SQL POST hacia relaciones Prisma con `map`.
4. Se eliminaron del SQL POST las restricciones que ahora genera Prisma, evitando duplicación y migraciones que intentan borrarlas.
5. `UNIQUE NULLS NOT DISTINCT` de idempotencia se reemplazó por dos índices únicos parciales equivalentes:
   - uno para `subject_user_id IS NOT NULL`;
   - otro para `subject_user_id IS NULL`.

## Sustituir en el repositorio

Desde la raíz del proyecto:

```bash
cp /RUTA_DESCARGA/schema.prisma.corregido prisma/schema.prisma
cp /RUTA_DESCARGA/0001_post_prisma_constraints_triggers_views.corregido.sql \
  prisma/sql/0001_post_prisma_constraints_triggers_views.sql
```

O extraiga el ZIP y copie directamente la carpeta `prisma/` sobre la carpeta `prisma/` del repositorio.

## Validación obligatoria

```bash
cd ~/dev/loteria-binaria
pnpm exec prisma format
pnpm exec prisma validate
pnpm exec prisma generate
```

No continúe si `prisma validate` falla. Conserve el mensaje completo del error.

## Recrear la migración inicial local

Esto elimina la base local y sus volúmenes. Úselo solo en desarrollo:

```bash
rm -rf prisma/migrations
docker compose down -v
docker compose up -d --wait

pnpm exec prisma migrate dev \
  --create-only \
  --name init_loteria_binaria
```

Después una PRE + DDL Prisma + POST dentro del `migration.sql` nuevo:

```bash
MIGRATION_FILE="$(
  find prisma/migrations -name migration.sql \
  -printf '%T@ %p\n' |
  sort -nr |
  head -1 |
  cut -d' ' -f2-
)"

cp "$MIGRATION_FILE" "${MIGRATION_FILE}.prisma-generated"

{
  echo '-- ========================================================='
  echo '-- PRE-PRISMA'
  echo '-- ========================================================='
  cat prisma/sql/0000_pre_prisma_extensions.sql

  echo
  echo '-- ========================================================='
  echo '-- DDL GENERADO POR PRISMA'
  echo '-- ========================================================='
  cat "${MIGRATION_FILE}.prisma-generated"

  echo
  echo '-- ========================================================='
  echo '-- POST-PRISMA'
  echo '-- ========================================================='
  cat prisma/sql/0001_post_prisma_constraints_triggers_views.sql
} > "$MIGRATION_FILE"

rm "${MIGRATION_FILE}.prisma-generated"

pnpm exec prisma migrate dev
pnpm exec prisma migrate status
```

Si `migrate dev` solicita inmediatamente el nombre de otra migración sin haber cambiado el esquema, cancele con `Ctrl + C` y revise el `migrate diff`.

```bash
pnpm exec prisma migrate diff \
  --from-config-datasource \
  --to-schema prisma/schema.prisma \
  --script > /tmp/prisma-drift.sql

cat /tmp/prisma-drift.sql
```
