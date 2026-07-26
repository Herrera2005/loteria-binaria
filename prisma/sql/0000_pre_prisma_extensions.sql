-- Lotería Binaria — PostgreSQL 16 — fase PRE-PRISMA
-- Debe colocarse al inicio de la migración inicial, antes de CREATE TYPE/CREATE TABLE.
-- Prisma ORM 7 no crea automáticamente la extensión requerida por @db.Citext.

CREATE EXTENSION IF NOT EXISTS citext;
