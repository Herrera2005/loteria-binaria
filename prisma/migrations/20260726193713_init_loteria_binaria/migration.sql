-- =========================================================
-- PRE-PRISMA
-- =========================================================
-- Lotería Binaria — PostgreSQL 16 — fase PRE-PRISMA
-- Debe colocarse al inicio de la migración inicial, antes de CREATE TYPE/CREATE TABLE.
-- Prisma ORM 7 no crea automáticamente la extensión requerida por @db.Citext.

CREATE EXTENSION IF NOT EXISTS citext;

-- =========================================================
-- DDL GENERADO POR PRISMA
-- =========================================================
-- CreateEnum
CREATE TYPE "account_status" AS ENUM ('PENDIENTE_VERIFICACION', 'ACTIVO', 'SUSPENDIDO', 'BLOQUEADO', 'DESACTIVADO');

-- CreateEnum
CREATE TYPE "active_mode" AS ENUM ('CLIENTE', 'CLIENTE_FINANCIERO', 'VENDEDOR', 'ADMINISTRADOR');

-- CreateEnum
CREATE TYPE "actor_type" AS ENUM ('USER', 'ADMIN', 'WORKER', 'SYSTEM');

-- CreateEnum
CREATE TYPE "session_status" AS ENUM ('ABIERTA', 'EXPIRADA', 'REVOCADA', 'CERRADA');

-- CreateEnum
CREATE TYPE "verification_channel" AS ENUM ('EMAIL', 'PHONE');

-- CreateEnum
CREATE TYPE "verification_purpose" AS ENUM ('ACCOUNT_VERIFICATION', 'CHANGE_CONTACT', 'PASSWORD_RECOVERY');

-- CreateEnum
CREATE TYPE "currency_code" AS ENUM ('REAL', 'VIRTUAL');

-- CreateEnum
CREATE TYPE "wallet_status" AS ENUM ('ACTIVE', 'BLOCKED', 'CLOSED');

-- CreateEnum
CREATE TYPE "idempotency_status" AS ENUM ('PROCESSING', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "ledger_transaction_status" AS ENUM ('CONTABILIZADA', 'PARCIALMENTE_REVERSADA', 'REVERSADA');

-- CreateEnum
CREATE TYPE "ledger_side" AS ENUM ('DEBIT', 'CREDIT');

-- CreateEnum
CREATE TYPE "ledger_account_type" AS ENUM ('USER_REAL_AVAILABLE', 'USER_REAL_RESERVED_CONVERSION', 'USER_REAL_IN_WITHDRAWAL', 'USER_VIRTUAL_AVAILABLE', 'PLATFORM_REAL_CASH', 'SIMULATED_TOPUP_SOURCE_REAL', 'SIMULATED_PAYOUT_CLEARING_REAL', 'PLATFORM_VIRTUAL_ISSUANCE', 'PLATFORM_VIRTUAL_REDEMPTION', 'GENERAL_CONVERSION_WALLET', 'CONVERSION_FEES_VIRTUAL', 'PLATFORM_OPERATIONS_VIRTUAL', 'ROUNDING_ADJUSTMENTS_VIRTUAL', 'DRAW_SALES_FUND', 'DRAW_PRIZE_RESERVE', 'AWARD_PAYABLE', 'DRAW_UNAWARDED_MAJOR_PRIZE', 'DRAW_ACCUMULATION_EXTRA', 'GUARANTEE_FUND_AVAILABLE', 'GUARANTEE_FUND_RESERVED_EVENT', 'FUTURE_PRIZE_FUND', 'ACCUMULATION_POOL_PRODUCT', 'USER_DRAW_ESCROW', 'USER_DRAW_COMMISSION_HELD');

-- CreateEnum
CREATE TYPE "topup_status" AS ENUM ('CREADA', 'CONFIRMADA_SIMULADA', 'FALLIDA');

-- CreateEnum
CREATE TYPE "financial_process_status" AS ENUM ('CREADA', 'PROCESANDO', 'COMPLETADA', 'RECHAZADA', 'ERROR_REINTENTABLE', 'REVISION_MANUAL');

-- CreateEnum
CREATE TYPE "withdrawal_status" AS ENUM ('SOLICITADO', 'EN_REVISION', 'APROBADO', 'COMPLETADO_SIMULADO', 'RECHAZADO', 'ERROR_REINTENTABLE', 'REVISION_MANUAL');

-- CreateEnum
CREATE TYPE "vendor_profile_status" AS ENUM ('PENDING', 'ACTIVE', 'SUSPENDED', 'CLOSED');

-- CreateEnum
CREATE TYPE "vendor_order_status" AS ENUM ('CREADA', 'PROCESANDO', 'CONFIRMADA', 'RECHAZADA', 'FALLIDA');

-- CreateEnum
CREATE TYPE "inventory_batch_status" AS ENUM ('ACTIVE', 'DEPLETED', 'REVERSED');

-- CreateEnum
CREATE TYPE "conversion_request_status" AS ENUM ('PENDIENTE', 'EN_PROCESO', 'COMPLETADA_POR_VENDEDOR', 'COMPLETADA_POR_PLATAFORMA', 'FALLIDA_POR_LIQUIDEZ');

-- CreateEnum
CREATE TYPE "conversion_assignment_status" AS ENUM ('ACTIVA', 'LIBERADA', 'CONSUMIDA', 'CERRADA_SIN_EFECTO');

-- CreateEnum
CREATE TYPE "risk_flag_status" AS ENUM ('OPEN', 'CONFIRMED', 'DISMISSED', 'RESOLVED');

-- CreateEnum
CREATE TYPE "lottery_product_code" AS ENUM ('OCTAL', 'DECIMAL', 'HEXADECIMAL');

-- CreateEnum
CREATE TYPE "version_status" AS ENUM ('DRAFT', 'PUBLISHED', 'RETIRED');

-- CreateEnum
CREATE TYPE "template_status" AS ENUM ('BORRADOR', 'ACTIVA', 'PAUSADA', 'INACTIVA');

-- CreateEnum
CREATE TYPE "draw_event_status" AS ENUM ('BORRADOR', 'PROGRAMADO', 'PUBLICADO', 'VENTAS_ABIERTAS', 'VENTAS_CERRADAS', 'CONGELADO', 'RESULTADO_FIJADO', 'PREMIOS_CALCULADOS', 'INFORME_PUBLICADO', 'FINALIZADO', 'CANCELADO');

-- CreateEnum
CREATE TYPE "combination_status" AS ENUM ('DISPONIBLE', 'RESERVADA', 'VENDIDA', 'BLOQUEADA');

-- CreateEnum
CREATE TYPE "purchase_session_status" AS ENUM ('ACTIVA', 'COMPLETADA', 'EXPIRADA', 'CERRADA_POR_EVENTO');

-- CreateEnum
CREATE TYPE "cart_status" AS ENUM ('ABIERTO', 'CONFIRMADO', 'EXPIRADO', 'CANCELADO', 'INVALIDADO_POR_EVENTO');

-- CreateEnum
CREATE TYPE "reservation_status" AS ENUM ('ACTIVA', 'CONSUMIDA', 'EXPIRADA', 'LIBERADA', 'INVALIDADA_POR_CIERRE', 'INVALIDADA_POR_CANCELACION');

-- CreateEnum
CREATE TYPE "purchase_order_status" AS ENUM ('PENDIENTE', 'PROCESANDO', 'CONFIRMADA', 'RECHAZADA', 'ERROR_REINTENTABLE', 'REVISION_MANUAL');

-- CreateEnum
CREATE TYPE "ticket_ownership_status" AS ENUM ('ACTIVO', 'REEMBOLSADO', 'ANULADO_POR_CORRECCION');

-- CreateEnum
CREATE TYPE "ticket_evaluation_status" AS ENUM ('PENDIENTE_RESULTADO', 'NO_PREMIADO', 'DEVOLUCION', 'GANADOR_MAYOR');

-- CreateEnum
CREATE TYPE "ticket_credit_status" AS ENUM ('NO_APLICA', 'PENDIENTE', 'ACREDITANDO', 'ACREDITADO', 'ERROR_REINTENTABLE', 'REVISION_MANUAL');

-- CreateEnum
CREATE TYPE "fund_reservation_status" AS ENUM ('PENDIENTE', 'RESERVADA', 'CONSUMIDA', 'LIBERADA', 'CANCELADA');

-- CreateEnum
CREATE TYPE "accumulation_transfer_status" AS ENUM ('PENDIENTE_ASIGNACION', 'ASIGNADA', 'APLICADA', 'DEVUELTA_AL_POOL', 'CANCELADA');

-- CreateEnum
CREATE TYPE "commitment_status" AS ENUM ('GENERADO_SECRETO', 'PUBLICADO', 'REVELADO', 'INVALIDADO_POR_CANCELACION');

-- CreateEnum
CREATE TYPE "snapshot_status" AS ENUM ('PENDIENTE', 'GENERADO', 'INVALIDADO_POR_CANCELACION');

-- CreateEnum
CREATE TYPE "award_category" AS ENUM ('MAIN_PRIZE', 'NEAR_MATCH_REFUND', 'EVENT_REFUND', 'ADMIN_COMPENSATION');

-- CreateEnum
CREATE TYPE "award_payment_status" AS ENUM ('CALCULADA', 'PREPARADA', 'ACREDITANDO', 'ACREDITADA', 'ERROR_REINTENTABLE', 'REVISION_MANUAL');

-- CreateEnum
CREATE TYPE "report_status" AS ENUM ('PENDIENTE', 'PREPARADO', 'PUBLICADO', 'SUPERSEDED', 'ERROR_REINTENTABLE', 'REVISION_MANUAL');

-- CreateEnum
CREATE TYPE "user_draw_visibility" AS ENUM ('PUBLICO', 'PRIVADO');

-- CreateEnum
CREATE TYPE "user_draw_status" AS ENUM ('BORRADOR', 'PUBLICADO', 'VENTAS_ABIERTAS', 'VENTAS_CERRADAS', 'CONGELADO', 'RESULTADO_FIJADO', 'ENTREGA_PENDIENTE', 'FINALIZADO', 'CANCELADO', 'CERRADO_POR_INCUMPLIMIENTO');

-- CreateEnum
CREATE TYPE "number_assignment_status" AS ENUM ('RESERVADA', 'ASIGNADA', 'LIBERADA', 'BLOQUEADA');

-- CreateEnum
CREATE TYPE "number_change_status" AS ENUM ('SOLICITADA', 'CONFIRMADA', 'RECHAZADA');

-- CreateEnum
CREATE TYPE "participation_payment_status" AS ENUM ('PENDIENTE', 'PAGADO', 'REEMBOLSANDO', 'REEMBOLSADO', 'FALLIDO');

-- CreateEnum
CREATE TYPE "participation_relation_status" AS ENUM ('ACTIVO', 'ABANDONO_REGISTRADO', 'EXPULSADO');

-- CreateEnum
CREATE TYPE "participation_eligibility_status" AS ENUM ('NO_ELEGIBLE', 'ACTIVA', 'EXCLUIDA');

-- CreateEnum
CREATE TYPE "participation_number_status" AS ENUM ('ACTIVA', 'REEMPLAZADA', 'LIBERADA');

-- CreateEnum
CREATE TYPE "code_use_status" AS ENUM ('EMITIDO', 'RECLAMADO', 'EXPIRADO');

-- CreateEnum
CREATE TYPE "code_payment_status" AS ENUM ('PENDIENTE', 'PAGADO', 'REEMBOLSADO', 'FALLIDO');

-- CreateEnum
CREATE TYPE "code_reservation_status" AS ENUM ('ACTIVA', 'CONSUMIDA', 'LIBERADA');

-- CreateEnum
CREATE TYPE "invitation_status" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED', 'REVOKED');

-- CreateEnum
CREATE TYPE "delivery_status" AS ENUM ('PENDIENTE', 'REGISTRADA_POR_ORGANIZADOR', 'CONFIRMADA_POR_GANADOR', 'EN_RECLAMO', 'INCUMPLIMIENTO_CONFIRMADO', 'CERRADA');

-- CreateEnum
CREATE TYPE "user_draw_claim_type" AS ENUM ('ACCESS', 'PAYMENT', 'NUMBER', 'REFUND', 'EXIT', 'EXPULSION', 'RESULT', 'PRIZE', 'DELIVERY');

-- CreateEnum
CREATE TYPE "claim_status" AS ENUM ('PRESENTADO', 'EN_REVISION', 'ESPERANDO_EVIDENCIA', 'RESUELTO', 'RECHAZADO', 'APELADO', 'CERRADO');

-- CreateEnum
CREATE TYPE "escrow_status" AS ENUM ('RETENIDA', 'LIBERABLE', 'EN_DISPUTA', 'LIBERANDO', 'LIBERADA', 'REEMBOLSO_ORDENADO', 'REEMBOLSANDO', 'REEMBOLSADA');

-- CreateEnum
CREATE TYPE "stored_object_status" AS ENUM ('PENDING', 'AVAILABLE', 'QUARANTINED', 'DELETED');

-- CreateEnum
CREATE TYPE "outbox_status" AS ENUM ('PENDING', 'PUBLISHED', 'FAILED', 'DEAD_LETTER');

-- CreateEnum
CREATE TYPE "inbox_status" AS ENUM ('RECEIVED', 'PROCESSED', 'FAILED');

-- CreateEnum
CREATE TYPE "job_status" AS ENUM ('PROGRAMADO', 'EJECUTANDO', 'COMPLETADO', 'ESPERANDO_REINTENTO', 'REVISION_MANUAL', 'CANCELADO', 'SIN_EFECTO_IDEMPOTENTE');

-- CreateEnum
CREATE TYPE "security_severity" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "notification_status" AS ENUM ('PENDING', 'SENT', 'FAILED', 'READ', 'CANCELLED');

-- CreateTable
CREATE TABLE "cart_items" (
    "id" UUID NOT NULL,
    "shopping_cart_id" UUID NOT NULL,
    "reservation_id" UUID NOT NULL,
    "combination_id" UUID NOT NULL,
    "unit_price_virtual_minor" BIGINT NOT NULL,
    "added_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cart_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "combination_reservations" (
    "id" UUID NOT NULL,
    "combination_id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "purchase_session_id" UUID NOT NULL,
    "status" "reservation_status" NOT NULL,
    "reserved_at" TIMESTAMPTZ(6) NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "consumed_at" TIMESTAMPTZ(6),
    "released_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "combination_reservations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_orders" (
    "id" UUID NOT NULL,
    "public_id" VARCHAR(40) NOT NULL,
    "user_id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "shopping_cart_id" UUID NOT NULL,
    "status" "purchase_order_status" NOT NULL,
    "ticket_count" INTEGER NOT NULL,
    "total_virtual_minor" BIGINT NOT NULL,
    "ledger_transaction_id" UUID,
    "idempotency_key_id" UUID NOT NULL,
    "confirmed_at" TIMESTAMPTZ(6),
    "rejection_code" VARCHAR(80),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "purchase_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_sessions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "status" "purchase_session_status" NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "purchase_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "shopping_carts" (
    "id" UUID NOT NULL,
    "purchase_session_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "status" "cart_status" NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "confirmed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "shopping_carts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ticket_numbers" (
    "id" UUID NOT NULL,
    "ticket_id" UUID NOT NULL,
    "symbol" VARCHAR(2) NOT NULL,
    "sort_order" SMALLINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ticket_numbers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ticket_status_history" (
    "id" UUID NOT NULL,
    "ticket_id" UUID NOT NULL,
    "dimension" VARCHAR(30) NOT NULL,
    "from_status" VARCHAR(50),
    "to_status" VARCHAR(50) NOT NULL,
    "transition_code" VARCHAR(80) NOT NULL,
    "actor_type" "actor_type" NOT NULL,
    "actor_user_id" UUID,
    "reason" TEXT,
    "correlation_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ticket_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tickets" (
    "id" UUID NOT NULL,
    "public_id" VARCHAR(50) NOT NULL,
    "purchase_order_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "combination_id" UUID NOT NULL,
    "rule_version_id" UUID NOT NULL,
    "normalized_key" VARCHAR(80) NOT NULL,
    "price_virtual_minor" BIGINT NOT NULL,
    "ownership_status" "ticket_ownership_status" NOT NULL,
    "evaluation_status" "ticket_evaluation_status" NOT NULL,
    "credit_status" "ticket_credit_status" NOT NULL,
    "purchase_ledger_transaction_id" UUID NOT NULL,
    "purchased_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tickets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "idempotency_keys" (
    "id" UUID NOT NULL,
    "subject_user_id" UUID,
    "scope" VARCHAR(120) NOT NULL,
    "key_value" VARCHAR(200) NOT NULL,
    "request_hash" VARCHAR(128) NOT NULL,
    "status" "idempotency_status" NOT NULL,
    "response_status" INTEGER,
    "response_body" JSONB,
    "resource_type" VARCHAR(80),
    "resource_id" UUID,
    "locked_at" TIMESTAMPTZ(6),
    "expires_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "idempotency_keys_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ledger_accounts" (
    "id" UUID NOT NULL,
    "account_code" VARCHAR(120) NOT NULL,
    "currency" "currency_code" NOT NULL,
    "account_type" "ledger_account_type" NOT NULL,
    "wallet_id" UUID,
    "user_id" UUID,
    "draw_event_id" UUID,
    "user_draw_id" UUID,
    "allows_negative" BOOLEAN NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ledger_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ledger_entries" (
    "id" UUID NOT NULL,
    "ledger_transaction_id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "reversal_of_entry_id" UUID,
    "currency" "currency_code" NOT NULL,
    "side" "ledger_side" NOT NULL,
    "amount_minor" BIGINT NOT NULL,
    "sequence" SMALLINT NOT NULL,
    "memo_code" VARCHAR(100) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ledger_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ledger_transactions" (
    "id" UUID NOT NULL,
    "transaction_type" VARCHAR(100) NOT NULL,
    "status" "ledger_transaction_status" NOT NULL,
    "correlation_id" UUID NOT NULL,
    "idempotency_key_id" UUID,
    "reversal_of_transaction_id" UUID,
    "business_reference_type" VARCHAR(80) NOT NULL,
    "business_reference_id" UUID NOT NULL,
    "rule_version_id" UUID,
    "description" TEXT,
    "calculation_snapshot" JSONB,
    "posted_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ledger_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_provider_events" (
    "id" UUID NOT NULL,
    "provider" VARCHAR(50) NOT NULL,
    "external_event_id" VARCHAR(180) NOT NULL,
    "event_type" VARCHAR(100) NOT NULL,
    "payload_hash" VARCHAR(128) NOT NULL,
    "sanitized_payload" JSONB,
    "received_at" TIMESTAMPTZ(6) NOT NULL,
    "processed_at" TIMESTAMPTZ(6),
    "processing_error" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_provider_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "real_topups" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "wallet_id" UUID NOT NULL,
    "provider_type" VARCHAR(40) NOT NULL,
    "provider_reference" VARCHAR(150),
    "amount_real_minor" BIGINT NOT NULL,
    "status" "topup_status" NOT NULL,
    "ledger_transaction_id" UUID,
    "idempotency_key_id" UUID NOT NULL,
    "confirmed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "real_topups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "virtual_to_real_conversions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "virtual_wallet_id" UUID NOT NULL,
    "real_wallet_id" UUID NOT NULL,
    "gross_virtual_minor" BIGINT NOT NULL,
    "fee_virtual_minor" BIGINT NOT NULL,
    "net_real_minor" BIGINT NOT NULL,
    "fee_rate_bps" INTEGER NOT NULL,
    "allocation_policy_code" VARCHAR(60) NOT NULL,
    "calculation_snapshot" JSONB NOT NULL,
    "status" "financial_process_status" NOT NULL,
    "ledger_transaction_id" UUID,
    "idempotency_key_id" UUID NOT NULL,
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "virtual_to_real_conversions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "virtual_transfers" (
    "id" UUID NOT NULL,
    "sender_user_id" UUID NOT NULL,
    "recipient_user_id" UUID NOT NULL,
    "amount_virtual_minor" BIGINT NOT NULL,
    "status" "financial_process_status" NOT NULL,
    "ledger_transaction_id" UUID,
    "idempotency_key_id" UUID NOT NULL,
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "virtual_transfers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wallet_balance_projections" (
    "id" UUID NOT NULL,
    "wallet_id" UUID NOT NULL,
    "available_minor" BIGINT NOT NULL,
    "reserved_minor" BIGINT NOT NULL,
    "pending_minor" BIGINT NOT NULL,
    "blocked_minor" BIGINT NOT NULL,
    "in_withdrawal_minor" BIGINT NOT NULL,
    "ledger_version" BIGINT NOT NULL,
    "calculated_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "wallet_balance_projections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wallets" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "currency" "currency_code" NOT NULL,
    "status" "wallet_status" NOT NULL,
    "closed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "wallets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "withdrawal_requests" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "real_wallet_id" UUID NOT NULL,
    "amount_real_minor" BIGINT NOT NULL,
    "status" "withdrawal_status" NOT NULL,
    "reserve_ledger_transaction_id" UUID,
    "settlement_ledger_transaction_id" UUID,
    "provider_reference" VARCHAR(150),
    "reviewed_by_user_id" UUID,
    "review_reason" TEXT,
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "withdrawal_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accumulation_pools" (
    "id" UUID NOT NULL,
    "lottery_product_id" UUID NOT NULL,
    "ledger_account_id" UUID NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "accumulation_pools_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accumulation_transfers" (
    "id" UUID NOT NULL,
    "accumulation_pool_id" UUID NOT NULL,
    "source_draw_event_id" UUID NOT NULL,
    "target_draw_event_id" UUID,
    "amount_virtual_minor" BIGINT NOT NULL,
    "status" "accumulation_transfer_status" NOT NULL,
    "assign_ledger_transaction_id" UUID,
    "return_ledger_transaction_id" UUID,
    "assigned_at" TIMESTAMPTZ(6),
    "applied_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "accumulation_transfers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fund_movements" (
    "id" UUID NOT NULL,
    "fund_type" VARCHAR(50) NOT NULL,
    "fund_reference_id" UUID NOT NULL,
    "movement_type" VARCHAR(80) NOT NULL,
    "amount_virtual_minor" BIGINT NOT NULL,
    "ledger_transaction_id" UUID NOT NULL,
    "draw_event_id" UUID,
    "actor_user_id" UUID,
    "reason" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fund_movements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "future_prize_fund" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "ledger_account_id" UUID NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "future_prize_fund_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "guarantee_fund" (
    "id" UUID NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "currency" "currency_code" NOT NULL,
    "ledger_account_id" UUID NOT NULL,
    "base_emergency_minor" BIGINT NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "guarantee_fund_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "guarantee_fund_reservations" (
    "id" UUID NOT NULL,
    "guarantee_fund_id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "reserved_ledger_account_id" UUID NOT NULL,
    "amount_virtual_minor" BIGINT NOT NULL,
    "status" "fund_reservation_status" NOT NULL,
    "reservation_ledger_transaction_id" UUID,
    "settlement_ledger_transaction_id" UUID,
    "reserved_at" TIMESTAMPTZ(6),
    "settled_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "guarantee_fund_reservations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "devices" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "device_public_id" VARCHAR(100) NOT NULL,
    "platform" VARCHAR(30) NOT NULL,
    "display_name" VARCHAR(120),
    "trusted_at" TIMESTAMPTZ(6),
    "last_seen_at" TIMESTAMPTZ(6),
    "revoked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "login_attempts" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "identifier_hash" VARCHAR(128) NOT NULL,
    "ip_hash" VARCHAR(128),
    "device_id" UUID,
    "succeeded" BOOLEAN NOT NULL,
    "failure_code" VARCHAR(80),
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "login_attempts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "password_resets" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "token_hash" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "used_at" TIMESTAMPTZ(6),
    "requested_ip_hash" VARCHAR(128),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "password_resets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" UUID NOT NULL,
    "permission_key" VARCHAR(150) NOT NULL,
    "resource_type" VARCHAR(80) NOT NULL,
    "action" VARCHAR(80) NOT NULL,
    "description" TEXT NOT NULL,
    "is_sensitive" BOOLEAN NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refresh_tokens" (
    "id" UUID NOT NULL,
    "session_id" UUID NOT NULL,
    "token_hash" VARCHAR(255) NOT NULL,
    "family_id" UUID NOT NULL,
    "rotated_from_id" UUID,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "used_at" TIMESTAMPTZ(6),
    "revoked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "id" UUID NOT NULL,
    "role_id" UUID NOT NULL,
    "permission_id" UUID NOT NULL,
    "granted_by_user_id" UUID,
    "granted_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" UUID NOT NULL,
    "code" VARCHAR(40) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "is_system" BOOLEAN NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "device_id" UUID,
    "status" "session_status" NOT NULL,
    "active_mode" "active_mode" NOT NULL,
    "ip_hash" VARCHAR(128),
    "user_agent_hash" VARCHAR(128),
    "last_seen_at" TIMESTAMPTZ(6),
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "revoked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "terms_acceptances" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "terms_version_id" UUID NOT NULL,
    "session_id" UUID,
    "accepted_at" TIMESTAMPTZ(6) NOT NULL,
    "ip_hash" VARCHAR(128),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "terms_acceptances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "terms_versions" (
    "id" UUID NOT NULL,
    "document_type" VARCHAR(40) NOT NULL,
    "version" VARCHAR(30) NOT NULL,
    "content_hash" VARCHAR(128) NOT NULL,
    "stored_object_id" UUID,
    "effective_at" TIMESTAMPTZ(6) NOT NULL,
    "retired_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "terms_versions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_permission_grants" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "permission_id" UUID NOT NULL,
    "granted_by_user_id" UUID NOT NULL,
    "valid_from" TIMESTAMPTZ(6) NOT NULL,
    "valid_until" TIMESTAMPTZ(6),
    "revoked_at" TIMESTAMPTZ(6),
    "reason" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_permission_grants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_profiles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "document_type" VARCHAR(30) NOT NULL,
    "document_number_hash" VARCHAR(128) NOT NULL,
    "document_number_encrypted" BYTEA NOT NULL,
    "birth_date" DATE NOT NULL,
    "phone_e164" VARCHAR(20),
    "address_text" TEXT,
    "country_code" CHAR(2) NOT NULL,
    "timezone" VARCHAR(64) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_roles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role_id" UUID NOT NULL,
    "assigned_by_user_id" UUID,
    "valid_from" TIMESTAMPTZ(6) NOT NULL,
    "valid_until" TIMESTAMPTZ(6),
    "revoked_at" TIMESTAMPTZ(6),
    "reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "public_id" VARCHAR(32) NOT NULL,
    "email" CITEXT NOT NULL,
    "username" CITEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "status" "account_status" NOT NULL,
    "email_verified_at" TIMESTAMPTZ(6),
    "phone_verified_at" TIMESTAMPTZ(6),
    "deactivated_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verification_tokens" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "channel" "verification_channel" NOT NULL,
    "purpose" "verification_purpose" NOT NULL,
    "target_hash" VARCHAR(255) NOT NULL,
    "token_hash" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "consumed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verification_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "combination_numbers" (
    "id" UUID NOT NULL,
    "combination_id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "symbol" VARCHAR(2) NOT NULL,
    "sort_order" SMALLINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "combination_numbers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "draw_event_status_history" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "from_status" "draw_event_status",
    "to_status" "draw_event_status" NOT NULL,
    "transition_code" VARCHAR(80) NOT NULL,
    "actor_type" "actor_type" NOT NULL,
    "actor_user_id" UUID,
    "reason" TEXT,
    "correlation_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "draw_event_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "draw_events" (
    "id" UUID NOT NULL,
    "public_id" VARCHAR(40) NOT NULL,
    "lottery_product_id" UUID NOT NULL,
    "rule_version_id" UUID NOT NULL,
    "prize_rule_version_id" UUID NOT NULL,
    "event_template_id" UUID,
    "scheduled_slot_at" TIMESTAMPTZ(6),
    "status" "draw_event_status" NOT NULL,
    "sales_open_at" TIMESTAMPTZ(6) NOT NULL,
    "sales_close_at" TIMESTAMPTZ(6) NOT NULL,
    "draw_at" TIMESTAMPTZ(6) NOT NULL,
    "limit_release_at" TIMESTAMPTZ(6) NOT NULL,
    "published_at" TIMESTAMPTZ(6),
    "cancelled_at" TIMESTAMPTZ(6),
    "cancel_reason" TEXT,
    "finalized_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "draw_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "event_combinations" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "normalized_key" VARCHAR(80) NOT NULL,
    "status" "combination_status" NOT NULL,
    "blocked_reason" TEXT,
    "blocked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "event_combinations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "event_financial_configs" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "ticket_price_virtual_minor" BIGINT NOT NULL,
    "initial_major_prize_virtual_minor" BIGINT NOT NULL,
    "major_prize_ceiling_virtual_minor" BIGINT NOT NULL,
    "minimum_capital_virtual_minor" BIGINT NOT NULL,
    "guarantee_required_virtual_minor" BIGINT NOT NULL,
    "rounding_policy_snapshot" JSONB NOT NULL,
    "frozen_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "event_financial_configs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "event_financial_projections" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "sales_virtual_minor" BIGINT NOT NULL,
    "refund_liability_virtual_minor" BIGINT NOT NULL,
    "guarantee_recovery_pending_minor" BIGINT NOT NULL,
    "growth_virtual_minor" BIGINT NOT NULL,
    "accumulation_extra_virtual_minor" BIGINT NOT NULL,
    "current_major_prize_virtual_minor" BIGINT NOT NULL,
    "ledger_version" BIGINT NOT NULL,
    "calculated_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "event_financial_projections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "event_templates" (
    "id" UUID NOT NULL,
    "lottery_product_id" UUID NOT NULL,
    "rule_version_id" UUID NOT NULL,
    "prize_rule_version_id" UUID NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "status" "template_status" NOT NULL,
    "future_generation_days" INTEGER NOT NULL,
    "publication_lead_seconds" INTEGER NOT NULL,
    "created_by_user_id" UUID NOT NULL,
    "retired_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "event_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lottery_products" (
    "id" UUID NOT NULL,
    "code" "lottery_product_code" NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lottery_products_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "prize_rule_versions" (
    "id" UUID NOT NULL,
    "rule_version_id" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "status" "version_status" NOT NULL,
    "initial_prize_multiplier_bps" INTEGER NOT NULL,
    "growth_share_bps" INTEGER NOT NULL,
    "operations_share_bps" INTEGER NOT NULL,
    "no_winner_accumulation_bps" INTEGER NOT NULL,
    "no_winner_guarantee_bps" INTEGER NOT NULL,
    "no_winner_future_prize_bps" INTEGER NOT NULL,
    "no_winner_operations_bps" INTEGER NOT NULL,
    "rounding_policy" JSONB NOT NULL,
    "allocation_policy_code" VARCHAR(60) NOT NULL,
    "content_hash" VARCHAR(128) NOT NULL,
    "published_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "prize_rule_versions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rule_versions" (
    "id" UUID NOT NULL,
    "lottery_product_id" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "status" "version_status" NOT NULL,
    "selection_count" SMALLINT NOT NULL,
    "universe_symbols" JSONB NOT NULL,
    "total_combinations" INTEGER NOT NULL,
    "order_matters" BOOLEAN NOT NULL,
    "unique_symbols_required" BOOLEAN NOT NULL,
    "purchase_limit_bps" INTEGER NOT NULL,
    "limit_release_fraction_bps" INTEGER NOT NULL,
    "reservation_seconds" INTEGER NOT NULL,
    "close_before_draw_seconds" INTEGER NOT NULL,
    "published_at" TIMESTAMPTZ(6),
    "content_hash" VARCHAR(128) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "rule_versions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "template_schedules" (
    "id" UUID NOT NULL,
    "event_template_id" UUID NOT NULL,
    "weekday" SMALLINT,
    "local_time" TIME(6),
    "interval_seconds" INTEGER,
    "effective_from" DATE NOT NULL,
    "effective_until" DATE,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "template_schedules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "award_payment_orders" (
    "id" UUID NOT NULL,
    "prize_award_id" UUID NOT NULL,
    "status" "award_payment_status" NOT NULL,
    "ledger_transaction_id" UUID,
    "idempotency_key_id" UUID NOT NULL,
    "attempt_count" INTEGER NOT NULL,
    "credited_at" TIMESTAMPTZ(6),
    "last_error" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "award_payment_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "draw_commitments" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "status" "commitment_status" NOT NULL,
    "algorithm_version" VARCHAR(50) NOT NULL,
    "commitment_hash" VARCHAR(128) NOT NULL,
    "encrypted_secret_seed" BYTEA NOT NULL,
    "encryption_key_version" VARCHAR(50) NOT NULL,
    "published_at" TIMESTAMPTZ(6),
    "revealed_seed" TEXT,
    "revealed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "draw_commitments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "draw_result_numbers" (
    "id" UUID NOT NULL,
    "draw_result_id" UUID NOT NULL,
    "symbol" VARCHAR(2) NOT NULL,
    "display_order" SMALLINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "draw_result_numbers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "draw_results" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "draw_commitment_id" UUID NOT NULL,
    "draw_snapshot_id" UUID NOT NULL,
    "algorithm_version" VARCHAR(50) NOT NULL,
    "final_seed_hash" VARCHAR(128) NOT NULL,
    "result_hash" VARCHAR(128) NOT NULL,
    "fixed_at" TIMESTAMPTZ(6) NOT NULL,
    "fixed_by_job_run_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "draw_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "draw_snapshot_tickets" (
    "id" UUID NOT NULL,
    "draw_snapshot_id" UUID NOT NULL,
    "ticket_id" UUID NOT NULL,
    "sequence" INTEGER NOT NULL,
    "ticket_hash" VARCHAR(128) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "draw_snapshot_tickets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "draw_snapshots" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "status" "snapshot_status" NOT NULL,
    "snapshot_hash" VARCHAR(128),
    "ticket_count" INTEGER NOT NULL,
    "serialization_version" VARCHAR(40) NOT NULL,
    "generated_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "draw_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "prize_awards" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "ticket_id" UUID NOT NULL,
    "ticket_evaluation_id" UUID,
    "award_category" "award_category" NOT NULL,
    "exact_virtual_minor" BIGINT NOT NULL,
    "public_virtual_minor" BIGINT NOT NULL,
    "rounding_adjustment_minor" BIGINT NOT NULL,
    "calculated_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "prize_awards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "result_reports" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "draw_result_id" UUID NOT NULL,
    "status" "report_status" NOT NULL,
    "report_version" INTEGER NOT NULL,
    "supersedes_report_id" UUID,
    "public_payload" JSONB NOT NULL,
    "report_hash" VARCHAR(128) NOT NULL,
    "json_object_id" UUID,
    "pdf_object_id" UUID,
    "image_object_id" UUID,
    "published_at" TIMESTAMPTZ(6),
    "superseded_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "result_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ticket_evaluations" (
    "id" UUID NOT NULL,
    "draw_event_id" UUID NOT NULL,
    "ticket_id" UUID NOT NULL,
    "draw_result_id" UUID NOT NULL,
    "match_count" SMALLINT NOT NULL,
    "evaluation_category" "ticket_evaluation_status" NOT NULL,
    "evaluation_hash" VARCHAR(128) NOT NULL,
    "evaluated_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ticket_evaluations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_events" (
    "id" UUID NOT NULL,
    "actor_type" "actor_type" NOT NULL,
    "actor_user_id" UUID,
    "session_id" UUID,
    "active_mode" "active_mode",
    "permission_key" VARCHAR(150),
    "action" VARCHAR(120) NOT NULL,
    "resource_type" VARCHAR(80) NOT NULL,
    "resource_id" UUID,
    "before_data" JSONB,
    "after_data" JSONB,
    "reason" TEXT,
    "correlation_id" UUID NOT NULL,
    "ip_hash" VARCHAR(128),
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inbox_events" (
    "id" UUID NOT NULL,
    "consumer_name" VARCHAR(100) NOT NULL,
    "message_id" VARCHAR(180) NOT NULL,
    "event_type" VARCHAR(120) NOT NULL,
    "payload_hash" VARCHAR(128) NOT NULL,
    "status" "inbox_status" NOT NULL,
    "received_at" TIMESTAMPTZ(6) NOT NULL,
    "processed_at" TIMESTAMPTZ(6),
    "last_error" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "inbox_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "job_runs" (
    "id" UUID NOT NULL,
    "scheduled_job_id" UUID NOT NULL,
    "attempt_number" INTEGER NOT NULL,
    "status" "job_status" NOT NULL,
    "worker_instance" VARCHAR(120),
    "started_at" TIMESTAMPTZ(6) NOT NULL,
    "finished_at" TIMESTAMPTZ(6),
    "result_payload" JSONB,
    "error_code" VARCHAR(100),
    "error_detail" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "job_runs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_preferences" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "notification_type" VARCHAR(100) NOT NULL,
    "channel" VARCHAR(30) NOT NULL,
    "is_enabled" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notification_preferences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "channel" VARCHAR(30) NOT NULL,
    "notification_type" VARCHAR(100) NOT NULL,
    "status" "notification_status" NOT NULL,
    "title" VARCHAR(180) NOT NULL,
    "body" TEXT NOT NULL,
    "resource_type" VARCHAR(80),
    "resource_id" UUID,
    "scheduled_at" TIMESTAMPTZ(6) NOT NULL,
    "sent_at" TIMESTAMPTZ(6),
    "read_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outbox_events" (
    "id" UUID NOT NULL,
    "aggregate_type" VARCHAR(80) NOT NULL,
    "aggregate_id" UUID NOT NULL,
    "event_type" VARCHAR(120) NOT NULL,
    "event_version" INTEGER NOT NULL,
    "payload" JSONB NOT NULL,
    "status" "outbox_status" NOT NULL,
    "correlation_id" UUID NOT NULL,
    "available_at" TIMESTAMPTZ(6) NOT NULL,
    "published_at" TIMESTAMPTZ(6),
    "attempt_count" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outbox_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "scheduled_jobs" (
    "id" UUID NOT NULL,
    "job_key" VARCHAR(180) NOT NULL,
    "job_type" VARCHAR(120) NOT NULL,
    "resource_type" VARCHAR(80) NOT NULL,
    "resource_id" UUID NOT NULL,
    "status" "job_status" NOT NULL,
    "run_at" TIMESTAMPTZ(6) NOT NULL,
    "payload" JSONB NOT NULL,
    "max_attempts" INTEGER NOT NULL,
    "attempt_count" INTEGER NOT NULL,
    "correlation_id" UUID NOT NULL,
    "last_error" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "scheduled_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "security_events" (
    "id" UUID NOT NULL,
    "event_type" VARCHAR(100) NOT NULL,
    "severity" "security_severity" NOT NULL,
    "user_id" UUID,
    "session_id" UUID,
    "resource_type" VARCHAR(80),
    "resource_id" UUID,
    "details" JSONB NOT NULL,
    "detected_at" TIMESTAMPTZ(6) NOT NULL,
    "resolved_at" TIMESTAMPTZ(6),
    "resolved_by_user_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "security_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stored_objects" (
    "id" UUID NOT NULL,
    "bucket" VARCHAR(100) NOT NULL,
    "object_key" VARCHAR(500) NOT NULL,
    "content_type" VARCHAR(120) NOT NULL,
    "size_bytes" BIGINT NOT NULL,
    "sha256" VARCHAR(128) NOT NULL,
    "status" "stored_object_status" NOT NULL,
    "encryption_key_version" VARCHAR(50),
    "uploaded_by_user_id" UUID,
    "available_at" TIMESTAMPTZ(6),
    "deleted_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stored_objects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "system_settings" (
    "id" UUID NOT NULL,
    "setting_key" VARCHAR(150) NOT NULL,
    "value_json" JSONB NOT NULL,
    "value_type" VARCHAR(30) NOT NULL,
    "is_sensitive" BOOLEAN NOT NULL,
    "updated_by_user_id" UUID,
    "description" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "system_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_access_code_events" (
    "id" UUID NOT NULL,
    "access_code_id" UUID NOT NULL,
    "dimension" VARCHAR(30) NOT NULL,
    "from_status" VARCHAR(40),
    "to_status" VARCHAR(40) NOT NULL,
    "actor_type" "actor_type" NOT NULL,
    "actor_user_id" UUID,
    "correlation_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_access_code_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_access_code_numbers" (
    "id" UUID NOT NULL,
    "access_code_id" UUID NOT NULL,
    "number_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_access_code_numbers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_access_codes" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "code_public_id" VARCHAR(50) NOT NULL,
    "secret_hash" VARCHAR(255) NOT NULL,
    "use_status" "code_use_status" NOT NULL,
    "payment_status" "code_payment_status" NOT NULL,
    "reservation_status" "code_reservation_status" NOT NULL,
    "price_virtual_minor" BIGINT NOT NULL,
    "funder_user_id" UUID,
    "claimed_by_user_id" UUID,
    "optional_comment" TEXT,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "claimed_at" TIMESTAMPTZ(6),
    "payment_ledger_transaction_id" UUID,
    "refund_ledger_transaction_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_access_codes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_announcements" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "author_user_id" UUID NOT NULL,
    "title" VARCHAR(160) NOT NULL,
    "body" TEXT NOT NULL,
    "published_at" TIMESTAMPTZ(6) NOT NULL,
    "removed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_announcements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_claim_events" (
    "id" UUID NOT NULL,
    "claim_id" UUID NOT NULL,
    "from_status" "claim_status",
    "to_status" "claim_status" NOT NULL,
    "actor_user_id" UUID,
    "actor_type" "actor_type" NOT NULL,
    "reason" TEXT,
    "evidence_deadline_at" TIMESTAMPTZ(6),
    "correlation_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_claim_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_claim_evidence" (
    "id" UUID NOT NULL,
    "claim_id" UUID NOT NULL,
    "submitted_by_user_id" UUID NOT NULL,
    "stored_object_id" UUID,
    "description" TEXT,
    "submitted_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_claim_evidence_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_claims" (
    "id" UUID NOT NULL,
    "public_id" VARCHAR(40) NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "claimant_user_id" UUID NOT NULL,
    "participation_id" UUID,
    "claim_type" "user_draw_claim_type" NOT NULL,
    "status" "claim_status" NOT NULL,
    "description" TEXT NOT NULL,
    "event_occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "filed_at" TIMESTAMPTZ(6) NOT NULL,
    "appeal_deadline_at" TIMESTAMPTZ(6),
    "resolved_by_user_id" UUID,
    "resolution_code" VARCHAR(80),
    "resolution_reason" TEXT,
    "compensation_ledger_transaction_id" UUID,
    "resolved_at" TIMESTAMPTZ(6),
    "closed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_claims_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_delivery_records" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "winner_user_id" UUID NOT NULL,
    "status" "delivery_status" NOT NULL,
    "delivery_method" VARCHAR(80) NOT NULL,
    "delivery_deadline_at" TIMESTAMPTZ(6) NOT NULL,
    "organizer_notes" TEXT,
    "delivery_evidence_object_id" UUID,
    "registered_at" TIMESTAMPTZ(6),
    "confirmed_at" TIMESTAMPTZ(6),
    "closed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_delivery_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_escrow_events" (
    "id" UUID NOT NULL,
    "user_draw_escrow_id" UUID NOT NULL,
    "from_status" "escrow_status",
    "to_status" "escrow_status" NOT NULL,
    "actor_type" "actor_type" NOT NULL,
    "actor_user_id" UUID,
    "reason" TEXT,
    "ledger_transaction_id" UUID,
    "correlation_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_escrow_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_escrows" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "status" "escrow_status" NOT NULL,
    "escrow_ledger_account_id" UUID NOT NULL,
    "commission_held_account_id" UUID NOT NULL,
    "gross_paid_virtual_minor" BIGINT NOT NULL,
    "commission_held_virtual_minor" BIGINT NOT NULL,
    "escrow_virtual_minor" BIGINT NOT NULL,
    "released_virtual_minor" BIGINT NOT NULL,
    "refunded_virtual_minor" BIGINT NOT NULL,
    "release_ledger_transaction_id" UUID,
    "settled_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_escrows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_invitations" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "invited_user_id" UUID,
    "target_contact_hash" VARCHAR(255),
    "token_hash" VARCHAR(255) NOT NULL,
    "status" "invitation_status" NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "accepted_by_user_id" UUID,
    "accepted_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_invitations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_number_changes" (
    "id" UUID NOT NULL,
    "participation_id" UUID NOT NULL,
    "old_participation_number_id" UUID NOT NULL,
    "new_number_id" UUID NOT NULL,
    "requested_by_user_id" UUID NOT NULL,
    "status" "number_change_status" NOT NULL,
    "reason" TEXT,
    "changed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_number_changes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_numbers" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "number_value" INTEGER NOT NULL,
    "assignment_status" "number_assignment_status" NOT NULL,
    "blocked_reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_numbers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_participation_events" (
    "id" UUID NOT NULL,
    "participation_id" UUID NOT NULL,
    "dimension" VARCHAR(30) NOT NULL,
    "from_status" VARCHAR(50),
    "to_status" VARCHAR(50) NOT NULL,
    "actor_type" "actor_type" NOT NULL,
    "actor_user_id" UUID,
    "reason" TEXT,
    "correlation_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_participation_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_participations" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "participant_user_id" UUID NOT NULL,
    "access_code_id" UUID,
    "payment_status" "participation_payment_status" NOT NULL,
    "relation_status" "participation_relation_status" NOT NULL,
    "eligibility_status" "participation_eligibility_status" NOT NULL,
    "price_virtual_minor" BIGINT NOT NULL,
    "payment_ledger_transaction_id" UUID,
    "refund_ledger_transaction_id" UUID,
    "paid_at" TIMESTAMPTZ(6),
    "abandoned_at" TIMESTAMPTZ(6),
    "expelled_at" TIMESTAMPTZ(6),
    "expulsion_reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_participations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_participation_numbers" (
    "id" UUID NOT NULL,
    "participation_id" UUID NOT NULL,
    "number_id" UUID NOT NULL,
    "status" "participation_number_status" NOT NULL,
    "assigned_at" TIMESTAMPTZ(6) NOT NULL,
    "replaced_at" TIMESTAMPTZ(6),
    "released_at" TIMESTAMPTZ(6),
    "reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_participation_numbers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_prize_evidence" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "evidence_type" VARCHAR(50) NOT NULL,
    "stored_object_id" UUID,
    "description" TEXT,
    "submitted_by_user_id" UUID NOT NULL,
    "verified_by_user_id" UUID,
    "verified_at" TIMESTAMPTZ(6),
    "is_valid" BOOLEAN,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_prize_evidence_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_results" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "user_draw_snapshot_id" UUID NOT NULL,
    "winning_snapshot_entry_id" UUID NOT NULL,
    "winning_participation_id" UUID NOT NULL,
    "winning_number_value" INTEGER NOT NULL,
    "algorithm_version" VARCHAR(50) NOT NULL,
    "verification_payload" JSONB NOT NULL,
    "result_hash" VARCHAR(128) NOT NULL,
    "fixed_at" TIMESTAMPTZ(6) NOT NULL,
    "fixed_by_job_run_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_snapshot_entries" (
    "id" UUID NOT NULL,
    "user_draw_snapshot_id" UUID NOT NULL,
    "participation_number_id" UUID NOT NULL,
    "number_value" INTEGER NOT NULL,
    "sequence" INTEGER NOT NULL,
    "entry_hash" VARCHAR(128) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_snapshot_entries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_snapshots" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "snapshot_hash" VARCHAR(128) NOT NULL,
    "entry_count" INTEGER NOT NULL,
    "serialization_version" VARCHAR(40) NOT NULL,
    "generated_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draw_status_history" (
    "id" UUID NOT NULL,
    "user_draw_id" UUID NOT NULL,
    "from_status" "user_draw_status",
    "to_status" "user_draw_status" NOT NULL,
    "transition_code" VARCHAR(80) NOT NULL,
    "actor_type" "actor_type" NOT NULL,
    "actor_user_id" UUID,
    "reason" TEXT,
    "correlation_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draw_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_draws" (
    "id" UUID NOT NULL,
    "public_id" VARCHAR(40) NOT NULL,
    "organizer_user_id" UUID NOT NULL,
    "visibility" "user_draw_visibility" NOT NULL,
    "status" "user_draw_status" NOT NULL,
    "title" VARCHAR(160) NOT NULL,
    "description" TEXT,
    "prize_description" TEXT NOT NULL,
    "price_virtual_minor" BIGINT NOT NULL,
    "platform_commission_bps" INTEGER NOT NULL,
    "allocation_policy_code" VARCHAR(60) NOT NULL,
    "range_start" INTEGER NOT NULL,
    "range_end" INTEGER NOT NULL,
    "sales_open_at" TIMESTAMPTZ(6) NOT NULL,
    "sales_close_at" TIMESTAMPTZ(6) NOT NULL,
    "first_payment_at" TIMESTAMPTZ(6),
    "published_at" TIMESTAMPTZ(6),
    "cancelled_at" TIMESTAMPTZ(6),
    "finalized_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_draws_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversion_assignments" (
    "id" UUID NOT NULL,
    "conversion_request_id" UUID NOT NULL,
    "vendor_user_id" UUID NOT NULL,
    "status" "conversion_assignment_status" NOT NULL,
    "assigned_at" TIMESTAMPTZ(6) NOT NULL,
    "released_at" TIMESTAMPTZ(6),
    "consumed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversion_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversion_request_events" (
    "id" UUID NOT NULL,
    "conversion_request_id" UUID NOT NULL,
    "from_status" "conversion_request_status",
    "to_status" "conversion_request_status" NOT NULL,
    "transition_code" VARCHAR(80) NOT NULL,
    "actor_type" "actor_type" NOT NULL,
    "actor_user_id" UUID,
    "reason_code" VARCHAR(80),
    "correlation_id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversion_request_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversion_requests" (
    "id" UUID NOT NULL,
    "client_user_id" UUID NOT NULL,
    "amount_real_minor" BIGINT NOT NULL,
    "amount_virtual_minor" BIGINT NOT NULL,
    "status" "conversion_request_status" NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "real_reservation_ledger_transaction_id" UUID NOT NULL,
    "completion_ledger_transaction_id" UUID,
    "completed_by_vendor_user_id" UUID,
    "completed_at" TIMESTAMPTZ(6),
    "idempotency_key_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversion_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "related_account_flags" (
    "id" UUID NOT NULL,
    "user_a_id" UUID NOT NULL,
    "user_b_id" UUID NOT NULL,
    "flag_type" VARCHAR(80) NOT NULL,
    "status" "risk_flag_status" NOT NULL,
    "risk_score" INTEGER,
    "evidence" JSONB,
    "detected_at" TIMESTAMPTZ(6) NOT NULL,
    "resolved_by_user_id" UUID,
    "resolved_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "related_account_flags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_inventory_batches" (
    "id" UUID NOT NULL,
    "vendor_user_id" UUID NOT NULL,
    "purchase_order_id" UUID NOT NULL,
    "virtual_acquired_minor" BIGINT NOT NULL,
    "virtual_remaining_minor" BIGINT NOT NULL,
    "real_cost_minor" BIGINT NOT NULL,
    "status" "inventory_batch_status" NOT NULL,
    "acquired_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vendor_inventory_batches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_profiles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "status" "vendor_profile_status" NOT NULL,
    "approved_by_user_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "suspended_at" TIMESTAMPTZ(6),
    "suspension_reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vendor_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_purchase_orders" (
    "id" UUID NOT NULL,
    "vendor_user_id" UUID NOT NULL,
    "requested_virtual_minor" BIGINT NOT NULL,
    "real_cost_minor" BIGINT NOT NULL,
    "unit_cost_numerator" INTEGER NOT NULL,
    "unit_cost_denominator" INTEGER NOT NULL,
    "status" "vendor_order_status" NOT NULL,
    "ledger_transaction_id" UUID,
    "idempotency_key_id" UUID NOT NULL,
    "confirmed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vendor_purchase_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_sale_batch_allocations" (
    "id" UUID NOT NULL,
    "vendor_sale_id" UUID NOT NULL,
    "inventory_batch_id" UUID NOT NULL,
    "virtual_amount_minor" BIGINT NOT NULL,
    "allocated_real_cost_minor" BIGINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vendor_sale_batch_allocations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vendor_sales" (
    "id" UUID NOT NULL,
    "conversion_request_id" UUID NOT NULL,
    "vendor_user_id" UUID NOT NULL,
    "virtual_sold_minor" BIGINT NOT NULL,
    "real_received_minor" BIGINT NOT NULL,
    "allocated_real_cost_minor" BIGINT NOT NULL,
    "realized_profit_minor" BIGINT NOT NULL,
    "ledger_transaction_id" UUID NOT NULL,
    "sold_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vendor_sales_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "cart_items_reservation_id_key" ON "cart_items"("reservation_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_cart_items_shopping_cart_id_combination_id" ON "cart_items"("shopping_cart_id", "combination_id");

-- CreateIndex
CREATE INDEX "ix_combination_reservations_user_id_draw_event_id_status" ON "combination_reservations"("user_id", "draw_event_id", "status");

-- CreateIndex
CREATE INDEX "ix_combination_reservations_expires_at" ON "combination_reservations"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_reservation_combination" ON "combination_reservations"("id", "combination_id");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_orders_public_id_key" ON "purchase_orders"("public_id");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_orders_shopping_cart_id_key" ON "purchase_orders"("shopping_cart_id");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_orders_ledger_transaction_id_key" ON "purchase_orders"("ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_purchase_order_owner_event" ON "purchase_orders"("id", "user_id", "draw_event_id");

-- CreateIndex
CREATE INDEX "ix_purchase_sessions_user_id_status" ON "purchase_sessions"("user_id", "status");

-- CreateIndex
CREATE INDEX "ix_purchase_sessions_expires_at" ON "purchase_sessions"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_purchase_session_owner_event" ON "purchase_sessions"("id", "user_id", "draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "shopping_carts_purchase_session_id_key" ON "shopping_carts"("purchase_session_id");

-- CreateIndex
CREATE INDEX "ix_shopping_carts_user_id_status" ON "shopping_carts"("user_id", "status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_shopping_cart_owner_event" ON "shopping_carts"("id", "user_id", "draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_ticket_numbers_ticket_id_symbol" ON "ticket_numbers"("ticket_id", "symbol");

-- CreateIndex
CREATE UNIQUE INDEX "uq_ticket_numbers_ticket_id_sort_order" ON "ticket_numbers"("ticket_id", "sort_order");

-- CreateIndex
CREATE INDEX "ix_ticket_status_history_ticket_id_occurred_at" ON "ticket_status_history"("ticket_id", "occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "tickets_public_id_key" ON "tickets"("public_id");

-- CreateIndex
CREATE UNIQUE INDEX "tickets_combination_id_key" ON "tickets"("combination_id");

-- CreateIndex
CREATE INDEX "ix_tickets_user_id_purchased_at" ON "tickets"("user_id", "purchased_at");

-- CreateIndex
CREATE INDEX "ix_tickets_draw_event_id_evaluation_status" ON "tickets"("draw_event_id", "evaluation_status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_tickets_draw_event_id_normalized_key" ON "tickets"("draw_event_id", "normalized_key");

-- CreateIndex
CREATE UNIQUE INDEX "uq_ticket_event" ON "tickets"("id", "draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "ledger_accounts_account_code_key" ON "ledger_accounts"("account_code");

-- CreateIndex
CREATE INDEX "ix_ledger_entries_account_id_created_at" ON "ledger_entries"("account_id", "created_at");

-- CreateIndex
CREATE INDEX "ix_ledger_entries_ledger_transaction_id" ON "ledger_entries"("ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_ledger_entries_ledger_transaction_id_sequence" ON "ledger_entries"("ledger_transaction_id", "sequence");

-- CreateIndex
CREATE INDEX "ix_ledger_transactions_business_reference_type_busin_cc7ea76683" ON "ledger_transactions"("business_reference_type", "business_reference_id");

-- CreateIndex
CREATE INDEX "ix_ledger_transactions_correlation_id" ON "ledger_transactions"("correlation_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_payment_provider_events_provider_external_event_id" ON "payment_provider_events"("provider", "external_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "real_topups_ledger_transaction_id_key" ON "real_topups"("ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_real_topups_user_id_created_at" ON "real_topups"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "ix_real_topups_status" ON "real_topups"("status");

-- CreateIndex
CREATE UNIQUE INDEX "virtual_to_real_conversions_ledger_transaction_id_key" ON "virtual_to_real_conversions"("ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_virtual_to_real_conversions_user_id_created_at" ON "virtual_to_real_conversions"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "ix_virtual_to_real_conversions_status" ON "virtual_to_real_conversions"("status");

-- CreateIndex
CREATE UNIQUE INDEX "virtual_transfers_ledger_transaction_id_key" ON "virtual_transfers"("ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_virtual_transfers_sender_user_id_created_at" ON "virtual_transfers"("sender_user_id", "created_at");

-- CreateIndex
CREATE INDEX "ix_virtual_transfers_recipient_user_id_created_at" ON "virtual_transfers"("recipient_user_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "wallet_balance_projections_wallet_id_key" ON "wallet_balance_projections"("wallet_id");

-- CreateIndex
CREATE INDEX "ix_wallet_balance_projections_calculated_at" ON "wallet_balance_projections"("calculated_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_wallets_user_id_currency" ON "wallets"("user_id", "currency");

-- CreateIndex
CREATE UNIQUE INDEX "withdrawal_requests_reserve_ledger_transaction_id_key" ON "withdrawal_requests"("reserve_ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "withdrawal_requests_settlement_ledger_transaction_id_key" ON "withdrawal_requests"("settlement_ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_withdrawal_requests_user_id_created_at" ON "withdrawal_requests"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "ix_withdrawal_requests_status" ON "withdrawal_requests"("status");

-- CreateIndex
CREATE UNIQUE INDEX "accumulation_pools_lottery_product_id_key" ON "accumulation_pools"("lottery_product_id");

-- CreateIndex
CREATE UNIQUE INDEX "accumulation_pools_ledger_account_id_key" ON "accumulation_pools"("ledger_account_id");

-- CreateIndex
CREATE UNIQUE INDEX "accumulation_transfers_assign_ledger_transaction_id_key" ON "accumulation_transfers"("assign_ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "accumulation_transfers_return_ledger_transaction_id_key" ON "accumulation_transfers"("return_ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_accumulation_transfers_accumulation_pool_id_status" ON "accumulation_transfers"("accumulation_pool_id", "status");

-- CreateIndex
CREATE INDEX "ix_accumulation_transfers_target_draw_event_id" ON "accumulation_transfers"("target_draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "fund_movements_ledger_transaction_id_key" ON "fund_movements"("ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_fund_movements_fund_type_fund_reference_id_created_at" ON "fund_movements"("fund_type", "fund_reference_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "future_prize_fund_code_key" ON "future_prize_fund"("code");

-- CreateIndex
CREATE UNIQUE INDEX "future_prize_fund_ledger_account_id_key" ON "future_prize_fund"("ledger_account_id");

-- CreateIndex
CREATE UNIQUE INDEX "guarantee_fund_code_key" ON "guarantee_fund"("code");

-- CreateIndex
CREATE UNIQUE INDEX "guarantee_fund_ledger_account_id_key" ON "guarantee_fund"("ledger_account_id");

-- CreateIndex
CREATE UNIQUE INDEX "guarantee_fund_reservations_draw_event_id_key" ON "guarantee_fund_reservations"("draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "guarantee_fund_reservations_reserved_ledger_account_id_key" ON "guarantee_fund_reservations"("reserved_ledger_account_id");

-- CreateIndex
CREATE UNIQUE INDEX "guarantee_fund_reservations_reservation_ledger_transaction__key" ON "guarantee_fund_reservations"("reservation_ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "guarantee_fund_reservations_settlement_ledger_transaction_i_key" ON "guarantee_fund_reservations"("settlement_ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_guarantee_fund_reservations_status" ON "guarantee_fund_reservations"("status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_devices_user_id_device_public_id" ON "devices"("user_id", "device_public_id");

-- CreateIndex
CREATE UNIQUE INDEX "password_resets_token_hash_key" ON "password_resets"("token_hash");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_permission_key_key" ON "permissions"("permission_key");

-- CreateIndex
CREATE UNIQUE INDEX "refresh_tokens_token_hash_key" ON "refresh_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "ix_refresh_tokens_session_id" ON "refresh_tokens"("session_id");

-- CreateIndex
CREATE INDEX "ix_refresh_tokens_family_id" ON "refresh_tokens"("family_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_role_permissions_role_id_permission_id" ON "role_permissions"("role_id", "permission_id");

-- CreateIndex
CREATE UNIQUE INDEX "roles_code_key" ON "roles"("code");

-- CreateIndex
CREATE INDEX "ix_sessions_user_id_status" ON "sessions"("user_id", "status");

-- CreateIndex
CREATE INDEX "ix_sessions_expires_at" ON "sessions"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_terms_acceptances_user_id_terms_version_id" ON "terms_acceptances"("user_id", "terms_version_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_terms_versions_document_type_version" ON "terms_versions"("document_type", "version");

-- CreateIndex
CREATE INDEX "ix_user_permission_grants_user_id_valid_from" ON "user_permission_grants"("user_id", "valid_from");

-- CreateIndex
CREATE UNIQUE INDEX "user_profiles_user_id_key" ON "user_profiles"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_profiles_document_number_hash_key" ON "user_profiles"("document_number_hash");

-- CreateIndex
CREATE UNIQUE INDEX "user_profiles_phone_e164_key" ON "user_profiles"("phone_e164");

-- CreateIndex
CREATE INDEX "ix_user_roles_user_id_valid_from" ON "user_roles"("user_id", "valid_from");

-- CreateIndex
CREATE UNIQUE INDEX "users_public_id_key" ON "users"("public_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "verification_tokens_token_hash_key" ON "verification_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "ix_combination_numbers_draw_event_id_symbol_combination_id" ON "combination_numbers"("draw_event_id", "symbol", "combination_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_combination_numbers_combination_id_symbol" ON "combination_numbers"("combination_id", "symbol");

-- CreateIndex
CREATE UNIQUE INDEX "uq_combination_numbers_combination_id_sort_order" ON "combination_numbers"("combination_id", "sort_order");

-- CreateIndex
CREATE INDEX "ix_draw_event_status_history_draw_event_id_occurred_at" ON "draw_event_status_history"("draw_event_id", "occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "draw_events_public_id_key" ON "draw_events"("public_id");

-- CreateIndex
CREATE INDEX "ix_draw_events_lottery_product_id_status_sales_open__d2c0965c29" ON "draw_events"("lottery_product_id", "status", "sales_open_at", "sales_close_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_draw_events_event_template_id_scheduled_slot_at" ON "draw_events"("event_template_id", "scheduled_slot_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_draw_event_rule" ON "draw_events"("id", "rule_version_id");

-- CreateIndex
CREATE INDEX "ix_event_combinations_draw_event_id_status_normalized_key" ON "event_combinations"("draw_event_id", "status", "normalized_key");

-- CreateIndex
CREATE UNIQUE INDEX "uq_event_combinations_draw_event_id_normalized_key" ON "event_combinations"("draw_event_id", "normalized_key");

-- CreateIndex
CREATE UNIQUE INDEX "uq_event_combination_id_event" ON "event_combinations"("id", "draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "event_financial_configs_draw_event_id_key" ON "event_financial_configs"("draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "event_financial_projections_draw_event_id_key" ON "event_financial_projections"("draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "lottery_products_code_key" ON "lottery_products"("code");

-- CreateIndex
CREATE UNIQUE INDEX "uq_prize_rule_versions_rule_version_id_version" ON "prize_rule_versions"("rule_version_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "uq_rule_versions_lottery_product_id_version" ON "rule_versions"("lottery_product_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "award_payment_orders_prize_award_id_key" ON "award_payment_orders"("prize_award_id");

-- CreateIndex
CREATE UNIQUE INDEX "award_payment_orders_ledger_transaction_id_key" ON "award_payment_orders"("ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_award_payment_orders_status_updated_at" ON "award_payment_orders"("status", "updated_at");

-- CreateIndex
CREATE UNIQUE INDEX "draw_commitments_draw_event_id_key" ON "draw_commitments"("draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "draw_commitments_commitment_hash_key" ON "draw_commitments"("commitment_hash");

-- CreateIndex
CREATE INDEX "ix_draw_commitments_status" ON "draw_commitments"("status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_draw_result_numbers_draw_result_id_symbol" ON "draw_result_numbers"("draw_result_id", "symbol");

-- CreateIndex
CREATE UNIQUE INDEX "uq_draw_result_numbers_draw_result_id_display_order" ON "draw_result_numbers"("draw_result_id", "display_order");

-- CreateIndex
CREATE UNIQUE INDEX "draw_results_draw_event_id_key" ON "draw_results"("draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "draw_results_draw_commitment_id_key" ON "draw_results"("draw_commitment_id");

-- CreateIndex
CREATE UNIQUE INDEX "draw_results_draw_snapshot_id_key" ON "draw_results"("draw_snapshot_id");

-- CreateIndex
CREATE UNIQUE INDEX "draw_results_result_hash_key" ON "draw_results"("result_hash");

-- CreateIndex
CREATE UNIQUE INDEX "uq_draw_result_event" ON "draw_results"("id", "draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_draw_snapshot_tickets_draw_snapshot_id_ticket_id" ON "draw_snapshot_tickets"("draw_snapshot_id", "ticket_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_draw_snapshot_tickets_draw_snapshot_id_sequence" ON "draw_snapshot_tickets"("draw_snapshot_id", "sequence");

-- CreateIndex
CREATE UNIQUE INDEX "draw_snapshots_draw_event_id_key" ON "draw_snapshots"("draw_event_id");

-- CreateIndex
CREATE UNIQUE INDEX "draw_snapshots_snapshot_hash_key" ON "draw_snapshots"("snapshot_hash");

-- CreateIndex
CREATE INDEX "ix_draw_snapshots_status" ON "draw_snapshots"("status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_prize_awards_draw_event_id_ticket_id_award_category" ON "prize_awards"("draw_event_id", "ticket_id", "award_category");

-- CreateIndex
CREATE UNIQUE INDEX "result_reports_report_hash_key" ON "result_reports"("report_hash");

-- CreateIndex
CREATE INDEX "ix_result_reports_status_published_at" ON "result_reports"("status", "published_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_result_reports_draw_event_id_report_version" ON "result_reports"("draw_event_id", "report_version");

-- CreateIndex
CREATE UNIQUE INDEX "ticket_evaluations_ticket_id_key" ON "ticket_evaluations"("ticket_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_ticket_evaluations_draw_event_id_ticket_id" ON "ticket_evaluations"("draw_event_id", "ticket_id");

-- CreateIndex
CREATE INDEX "ix_audit_events_actor_user_id_occurred_at" ON "audit_events"("actor_user_id", "occurred_at");

-- CreateIndex
CREATE INDEX "ix_audit_events_resource_type_resource_id" ON "audit_events"("resource_type", "resource_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_inbox_events_consumer_name_message_id" ON "inbox_events"("consumer_name", "message_id");

-- CreateIndex
CREATE INDEX "ix_job_runs_status_started_at" ON "job_runs"("status", "started_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_job_runs_scheduled_job_id_attempt_number" ON "job_runs"("scheduled_job_id", "attempt_number");

-- CreateIndex
CREATE UNIQUE INDEX "uq_notification_preferences_user_id_notification_type_channel" ON "notification_preferences"("user_id", "notification_type", "channel");

-- CreateIndex
CREATE INDEX "ix_notifications_user_id_status_created_at" ON "notifications"("user_id", "status", "created_at");

-- CreateIndex
CREATE INDEX "ix_outbox_events_status_available_at" ON "outbox_events"("status", "available_at");

-- CreateIndex
CREATE UNIQUE INDEX "scheduled_jobs_job_key_key" ON "scheduled_jobs"("job_key");

-- CreateIndex
CREATE INDEX "ix_scheduled_jobs_status_run_at" ON "scheduled_jobs"("status", "run_at");

-- CreateIndex
CREATE INDEX "ix_security_events_severity_detected_at" ON "security_events"("severity", "detected_at");

-- CreateIndex
CREATE INDEX "ix_security_events_user_id_detected_at" ON "security_events"("user_id", "detected_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_stored_objects_bucket_object_key" ON "stored_objects"("bucket", "object_key");

-- CreateIndex
CREATE UNIQUE INDEX "system_settings_setting_key_key" ON "system_settings"("setting_key");

-- CreateIndex
CREATE INDEX "ix_user_draw_access_code_events_access_code_id_occurred_at" ON "user_draw_access_code_events"("access_code_id", "occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_draw_access_code_numbers_access_code_id_number_id" ON "user_draw_access_code_numbers"("access_code_id", "number_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_access_codes_code_public_id_key" ON "user_draw_access_codes"("code_public_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_access_codes_secret_hash_key" ON "user_draw_access_codes"("secret_hash");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_access_codes_payment_ledger_transaction_id_key" ON "user_draw_access_codes"("payment_ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_access_codes_refund_ledger_transaction_id_key" ON "user_draw_access_codes"("refund_ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_user_draw_access_codes_user_draw_id_use_status_expires_at" ON "user_draw_access_codes"("user_draw_id", "use_status", "expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_draw_code_id_draw" ON "user_draw_access_codes"("id", "user_draw_id");

-- CreateIndex
CREATE INDEX "ix_user_draw_announcements_user_draw_id_published_at" ON "user_draw_announcements"("user_draw_id", "published_at");

-- CreateIndex
CREATE INDEX "ix_user_draw_claim_events_claim_id_occurred_at" ON "user_draw_claim_events"("claim_id", "occurred_at");

-- CreateIndex
CREATE INDEX "ix_user_draw_claim_evidence_claim_id_submitted_at" ON "user_draw_claim_evidence"("claim_id", "submitted_at");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_claims_public_id_key" ON "user_draw_claims"("public_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_claims_compensation_ledger_transaction_id_key" ON "user_draw_claims"("compensation_ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_user_draw_claims_user_draw_id_status" ON "user_draw_claims"("user_draw_id", "status");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_delivery_records_user_draw_id_key" ON "user_draw_delivery_records"("user_draw_id");

-- CreateIndex
CREATE INDEX "ix_user_draw_escrow_events_user_draw_escrow_id_occurred_at" ON "user_draw_escrow_events"("user_draw_escrow_id", "occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_escrows_user_draw_id_key" ON "user_draw_escrows"("user_draw_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_escrows_escrow_ledger_account_id_key" ON "user_draw_escrows"("escrow_ledger_account_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_escrows_commission_held_account_id_key" ON "user_draw_escrows"("commission_held_account_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_escrows_release_ledger_transaction_id_key" ON "user_draw_escrows"("release_ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_invitations_token_hash_key" ON "user_draw_invitations"("token_hash");

-- CreateIndex
CREATE INDEX "ix_user_draw_number_changes_participation_id_created_at" ON "user_draw_number_changes"("participation_id", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_draw_numbers_user_draw_id_number_value" ON "user_draw_numbers"("user_draw_id", "number_value");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_draw_number_id_draw" ON "user_draw_numbers"("id", "user_draw_id");

-- CreateIndex
CREATE INDEX "ix_user_draw_participation_events_participation_id_occurred_at" ON "user_draw_participation_events"("participation_id", "occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_participations_payment_ledger_transaction_id_key" ON "user_draw_participations"("payment_ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_participations_refund_ledger_transaction_id_key" ON "user_draw_participations"("refund_ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_user_draw_participations_user_draw_id_payment_sta_8f853f047b" ON "user_draw_participations"("user_draw_id", "payment_status", "eligibility_status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_draw_participation_id_draw" ON "user_draw_participations"("id", "user_draw_id");

-- CreateIndex
CREATE INDEX "ix_user_draw_participation_numbers_number_id_status" ON "user_draw_participation_numbers"("number_id", "status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_draw_participation_numbers_participation_id_number_id" ON "user_draw_participation_numbers"("participation_id", "number_id");

-- CreateIndex
CREATE INDEX "ix_user_draw_prize_evidence_user_draw_id" ON "user_draw_prize_evidence"("user_draw_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_results_user_draw_id_key" ON "user_draw_results"("user_draw_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_results_user_draw_snapshot_id_key" ON "user_draw_results"("user_draw_snapshot_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_results_winning_snapshot_entry_id_key" ON "user_draw_results"("winning_snapshot_entry_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_results_result_hash_key" ON "user_draw_results"("result_hash");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_draw_snapshot_entries_user_draw_snapshot_id__db047fa5ec" ON "user_draw_snapshot_entries"("user_draw_snapshot_id", "participation_number_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_draw_snapshot_entries_user_draw_snapshot_id_sequence" ON "user_draw_snapshot_entries"("user_draw_snapshot_id", "sequence");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_snapshots_user_draw_id_key" ON "user_draw_snapshots"("user_draw_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_draw_snapshots_snapshot_hash_key" ON "user_draw_snapshots"("snapshot_hash");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_draw_snapshot_id_draw" ON "user_draw_snapshots"("id", "user_draw_id");

-- CreateIndex
CREATE INDEX "ix_user_draw_status_history_user_draw_id_occurred_at" ON "user_draw_status_history"("user_draw_id", "occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "user_draws_public_id_key" ON "user_draws"("public_id");

-- CreateIndex
CREATE INDEX "ix_user_draws_visibility_status_sales_open_at" ON "user_draws"("visibility", "status", "sales_open_at");

-- CreateIndex
CREATE INDEX "ix_conversion_assignments_vendor_user_id_status" ON "conversion_assignments"("vendor_user_id", "status");

-- CreateIndex
CREATE INDEX "ix_conversion_request_events_conversion_request_id_occurred_at" ON "conversion_request_events"("conversion_request_id", "occurred_at");

-- CreateIndex
CREATE UNIQUE INDEX "conversion_requests_real_reservation_ledger_transaction_id_key" ON "conversion_requests"("real_reservation_ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "conversion_requests_completion_ledger_transaction_id_key" ON "conversion_requests"("completion_ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_conversion_requests_status_expires_at" ON "conversion_requests"("status", "expires_at");

-- CreateIndex
CREATE INDEX "ix_conversion_requests_client_user_id_created_at" ON "conversion_requests"("client_user_id", "created_at");

-- CreateIndex
CREATE INDEX "ix_related_account_flags_user_a_id_status" ON "related_account_flags"("user_a_id", "status");

-- CreateIndex
CREATE INDEX "ix_related_account_flags_user_b_id_status" ON "related_account_flags"("user_b_id", "status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_related_account_flags_normalized" ON "related_account_flags"("user_a_id", "user_b_id", "flag_type");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_inventory_batches_purchase_order_id_key" ON "vendor_inventory_batches"("purchase_order_id");

-- CreateIndex
CREATE INDEX "ix_vendor_inventory_batches_vendor_user_id_status_acquired_at" ON "vendor_inventory_batches"("vendor_user_id", "status", "acquired_at");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_profiles_user_id_key" ON "vendor_profiles"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_purchase_orders_ledger_transaction_id_key" ON "vendor_purchase_orders"("ledger_transaction_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_vendor_sale_batch_allocations_vendor_sale_id_inve_5795c3a96b" ON "vendor_sale_batch_allocations"("vendor_sale_id", "inventory_batch_id");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_sales_conversion_request_id_key" ON "vendor_sales"("conversion_request_id");

-- CreateIndex
CREATE UNIQUE INDEX "vendor_sales_ledger_transaction_id_key" ON "vendor_sales"("ledger_transaction_id");

-- CreateIndex
CREATE INDEX "ix_vendor_sales_vendor_user_id_sold_at" ON "vendor_sales"("vendor_user_id", "sold_at");

-- AddForeignKey
ALTER TABLE "cart_items" ADD CONSTRAINT "cart_items_shopping_cart_id_fkey" FOREIGN KEY ("shopping_cart_id") REFERENCES "shopping_carts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cart_items" ADD CONSTRAINT "cart_items_reservation_id_fkey" FOREIGN KEY ("reservation_id") REFERENCES "combination_reservations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cart_items" ADD CONSTRAINT "fk_cart_item_reservation_combination" FOREIGN KEY ("reservation_id", "combination_id") REFERENCES "combination_reservations"("id", "combination_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cart_items" ADD CONSTRAINT "cart_items_combination_id_fkey" FOREIGN KEY ("combination_id") REFERENCES "event_combinations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "combination_reservations" ADD CONSTRAINT "combination_reservations_combination_id_fkey" FOREIGN KEY ("combination_id") REFERENCES "event_combinations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "combination_reservations" ADD CONSTRAINT "combination_reservations_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "combination_reservations" ADD CONSTRAINT "combination_reservations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "combination_reservations" ADD CONSTRAINT "combination_reservations_purchase_session_id_fkey" FOREIGN KEY ("purchase_session_id") REFERENCES "purchase_sessions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "combination_reservations" ADD CONSTRAINT "fk_reservation_combination_event" FOREIGN KEY ("combination_id", "draw_event_id") REFERENCES "event_combinations"("id", "draw_event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "combination_reservations" ADD CONSTRAINT "fk_reservation_session_owner_event" FOREIGN KEY ("purchase_session_id", "user_id", "draw_event_id") REFERENCES "purchase_sessions"("id", "user_id", "draw_event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_shopping_cart_id_fkey" FOREIGN KEY ("shopping_cart_id") REFERENCES "shopping_carts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "fk_order_cart_owner_event" FOREIGN KEY ("shopping_cart_id", "user_id", "draw_event_id") REFERENCES "shopping_carts"("id", "user_id", "draw_event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_idempotency_key_id_fkey" FOREIGN KEY ("idempotency_key_id") REFERENCES "idempotency_keys"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_sessions" ADD CONSTRAINT "purchase_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_sessions" ADD CONSTRAINT "purchase_sessions_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shopping_carts" ADD CONSTRAINT "shopping_carts_purchase_session_id_fkey" FOREIGN KEY ("purchase_session_id") REFERENCES "purchase_sessions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shopping_carts" ADD CONSTRAINT "fk_cart_session_owner_event" FOREIGN KEY ("purchase_session_id", "user_id", "draw_event_id") REFERENCES "purchase_sessions"("id", "user_id", "draw_event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shopping_carts" ADD CONSTRAINT "shopping_carts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shopping_carts" ADD CONSTRAINT "shopping_carts_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_numbers" ADD CONSTRAINT "ticket_numbers_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_status_history" ADD CONSTRAINT "ticket_status_history_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_status_history" ADD CONSTRAINT "ticket_status_history_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "fk_ticket_order_owner_event" FOREIGN KEY ("purchase_order_id", "user_id", "draw_event_id") REFERENCES "purchase_orders"("id", "user_id", "draw_event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_combination_id_fkey" FOREIGN KEY ("combination_id") REFERENCES "event_combinations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "fk_ticket_combination_event" FOREIGN KEY ("combination_id", "draw_event_id") REFERENCES "event_combinations"("id", "draw_event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_rule_version_id_fkey" FOREIGN KEY ("rule_version_id") REFERENCES "rule_versions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "fk_ticket_event_rule" FOREIGN KEY ("draw_event_id", "rule_version_id") REFERENCES "draw_events"("id", "rule_version_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_purchase_ledger_transaction_id_fkey" FOREIGN KEY ("purchase_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "idempotency_keys" ADD CONSTRAINT "idempotency_keys_subject_user_id_fkey" FOREIGN KEY ("subject_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_accounts" ADD CONSTRAINT "ledger_accounts_wallet_id_fkey" FOREIGN KEY ("wallet_id") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_accounts" ADD CONSTRAINT "ledger_accounts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_accounts" ADD CONSTRAINT "ledger_accounts_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_accounts" ADD CONSTRAINT "ledger_accounts_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ledger_entries_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ledger_entries_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "ledger_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ledger_entries_reversal_of_entry_id_fkey" FOREIGN KEY ("reversal_of_entry_id") REFERENCES "ledger_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_transactions" ADD CONSTRAINT "ledger_transactions_idempotency_key_id_fkey" FOREIGN KEY ("idempotency_key_id") REFERENCES "idempotency_keys"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_transactions" ADD CONSTRAINT "ledger_transactions_reversal_of_transaction_id_fkey" FOREIGN KEY ("reversal_of_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ledger_transactions" ADD CONSTRAINT "ledger_transactions_rule_version_id_fkey" FOREIGN KEY ("rule_version_id") REFERENCES "rule_versions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "real_topups" ADD CONSTRAINT "real_topups_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "real_topups" ADD CONSTRAINT "real_topups_wallet_id_fkey" FOREIGN KEY ("wallet_id") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "real_topups" ADD CONSTRAINT "real_topups_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "real_topups" ADD CONSTRAINT "real_topups_idempotency_key_id_fkey" FOREIGN KEY ("idempotency_key_id") REFERENCES "idempotency_keys"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "virtual_to_real_conversions" ADD CONSTRAINT "virtual_to_real_conversions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "virtual_to_real_conversions" ADD CONSTRAINT "virtual_to_real_conversions_virtual_wallet_id_fkey" FOREIGN KEY ("virtual_wallet_id") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "virtual_to_real_conversions" ADD CONSTRAINT "virtual_to_real_conversions_real_wallet_id_fkey" FOREIGN KEY ("real_wallet_id") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "virtual_to_real_conversions" ADD CONSTRAINT "virtual_to_real_conversions_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "virtual_to_real_conversions" ADD CONSTRAINT "virtual_to_real_conversions_idempotency_key_id_fkey" FOREIGN KEY ("idempotency_key_id") REFERENCES "idempotency_keys"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "virtual_transfers" ADD CONSTRAINT "virtual_transfers_sender_user_id_fkey" FOREIGN KEY ("sender_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "virtual_transfers" ADD CONSTRAINT "virtual_transfers_recipient_user_id_fkey" FOREIGN KEY ("recipient_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "virtual_transfers" ADD CONSTRAINT "virtual_transfers_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "virtual_transfers" ADD CONSTRAINT "virtual_transfers_idempotency_key_id_fkey" FOREIGN KEY ("idempotency_key_id") REFERENCES "idempotency_keys"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallet_balance_projections" ADD CONSTRAINT "wallet_balance_projections_wallet_id_fkey" FOREIGN KEY ("wallet_id") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wallets" ADD CONSTRAINT "wallets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "withdrawal_requests" ADD CONSTRAINT "withdrawal_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "withdrawal_requests" ADD CONSTRAINT "withdrawal_requests_real_wallet_id_fkey" FOREIGN KEY ("real_wallet_id") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "withdrawal_requests" ADD CONSTRAINT "withdrawal_requests_reserve_ledger_transaction_id_fkey" FOREIGN KEY ("reserve_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "withdrawal_requests" ADD CONSTRAINT "withdrawal_requests_settlement_ledger_transaction_id_fkey" FOREIGN KEY ("settlement_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "withdrawal_requests" ADD CONSTRAINT "withdrawal_requests_reviewed_by_user_id_fkey" FOREIGN KEY ("reviewed_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accumulation_pools" ADD CONSTRAINT "accumulation_pools_lottery_product_id_fkey" FOREIGN KEY ("lottery_product_id") REFERENCES "lottery_products"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accumulation_pools" ADD CONSTRAINT "accumulation_pools_ledger_account_id_fkey" FOREIGN KEY ("ledger_account_id") REFERENCES "ledger_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accumulation_transfers" ADD CONSTRAINT "accumulation_transfers_accumulation_pool_id_fkey" FOREIGN KEY ("accumulation_pool_id") REFERENCES "accumulation_pools"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accumulation_transfers" ADD CONSTRAINT "accumulation_transfers_source_draw_event_id_fkey" FOREIGN KEY ("source_draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accumulation_transfers" ADD CONSTRAINT "accumulation_transfers_target_draw_event_id_fkey" FOREIGN KEY ("target_draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accumulation_transfers" ADD CONSTRAINT "accumulation_transfers_assign_ledger_transaction_id_fkey" FOREIGN KEY ("assign_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accumulation_transfers" ADD CONSTRAINT "accumulation_transfers_return_ledger_transaction_id_fkey" FOREIGN KEY ("return_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fund_movements" ADD CONSTRAINT "fund_movements_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fund_movements" ADD CONSTRAINT "fund_movements_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fund_movements" ADD CONSTRAINT "fund_movements_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "future_prize_fund" ADD CONSTRAINT "future_prize_fund_ledger_account_id_fkey" FOREIGN KEY ("ledger_account_id") REFERENCES "ledger_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "guarantee_fund" ADD CONSTRAINT "guarantee_fund_ledger_account_id_fkey" FOREIGN KEY ("ledger_account_id") REFERENCES "ledger_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "guarantee_fund_reservations" ADD CONSTRAINT "guarantee_fund_reservations_guarantee_fund_id_fkey" FOREIGN KEY ("guarantee_fund_id") REFERENCES "guarantee_fund"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "guarantee_fund_reservations" ADD CONSTRAINT "guarantee_fund_reservations_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "guarantee_fund_reservations" ADD CONSTRAINT "guarantee_fund_reservations_reserved_ledger_account_id_fkey" FOREIGN KEY ("reserved_ledger_account_id") REFERENCES "ledger_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "guarantee_fund_reservations" ADD CONSTRAINT "guarantee_fund_reservations_reservation_ledger_transaction_fkey" FOREIGN KEY ("reservation_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "guarantee_fund_reservations" ADD CONSTRAINT "guarantee_fund_reservations_settlement_ledger_transaction__fkey" FOREIGN KEY ("settlement_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "login_attempts" ADD CONSTRAINT "login_attempts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "login_attempts" ADD CONSTRAINT "login_attempts_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "devices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "password_resets" ADD CONSTRAINT "password_resets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "sessions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_rotated_from_id_fkey" FOREIGN KEY ("rotated_from_id") REFERENCES "refresh_tokens"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_granted_by_user_id_fkey" FOREIGN KEY ("granted_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "devices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "terms_acceptances" ADD CONSTRAINT "terms_acceptances_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "terms_acceptances" ADD CONSTRAINT "terms_acceptances_terms_version_id_fkey" FOREIGN KEY ("terms_version_id") REFERENCES "terms_versions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "terms_acceptances" ADD CONSTRAINT "terms_acceptances_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "sessions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "terms_versions" ADD CONSTRAINT "terms_versions_stored_object_id_fkey" FOREIGN KEY ("stored_object_id") REFERENCES "stored_objects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_permission_grants" ADD CONSTRAINT "user_permission_grants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_permission_grants" ADD CONSTRAINT "user_permission_grants_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_permission_grants" ADD CONSTRAINT "user_permission_grants_granted_by_user_id_fkey" FOREIGN KEY ("granted_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_assigned_by_user_id_fkey" FOREIGN KEY ("assigned_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verification_tokens" ADD CONSTRAINT "verification_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "combination_numbers" ADD CONSTRAINT "combination_numbers_combination_id_fkey" FOREIGN KEY ("combination_id") REFERENCES "event_combinations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "combination_numbers" ADD CONSTRAINT "combination_numbers_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "combination_numbers" ADD CONSTRAINT "fk_combination_numbers_combination_event" FOREIGN KEY ("combination_id", "draw_event_id") REFERENCES "event_combinations"("id", "draw_event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_event_status_history" ADD CONSTRAINT "draw_event_status_history_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_event_status_history" ADD CONSTRAINT "draw_event_status_history_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_events" ADD CONSTRAINT "draw_events_lottery_product_id_fkey" FOREIGN KEY ("lottery_product_id") REFERENCES "lottery_products"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_events" ADD CONSTRAINT "draw_events_rule_version_id_fkey" FOREIGN KEY ("rule_version_id") REFERENCES "rule_versions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_events" ADD CONSTRAINT "draw_events_prize_rule_version_id_fkey" FOREIGN KEY ("prize_rule_version_id") REFERENCES "prize_rule_versions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_events" ADD CONSTRAINT "draw_events_event_template_id_fkey" FOREIGN KEY ("event_template_id") REFERENCES "event_templates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_combinations" ADD CONSTRAINT "event_combinations_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_financial_configs" ADD CONSTRAINT "event_financial_configs_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_financial_projections" ADD CONSTRAINT "event_financial_projections_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_templates" ADD CONSTRAINT "event_templates_lottery_product_id_fkey" FOREIGN KEY ("lottery_product_id") REFERENCES "lottery_products"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_templates" ADD CONSTRAINT "event_templates_rule_version_id_fkey" FOREIGN KEY ("rule_version_id") REFERENCES "rule_versions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_templates" ADD CONSTRAINT "event_templates_prize_rule_version_id_fkey" FOREIGN KEY ("prize_rule_version_id") REFERENCES "prize_rule_versions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_templates" ADD CONSTRAINT "event_templates_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prize_rule_versions" ADD CONSTRAINT "prize_rule_versions_rule_version_id_fkey" FOREIGN KEY ("rule_version_id") REFERENCES "rule_versions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rule_versions" ADD CONSTRAINT "rule_versions_lottery_product_id_fkey" FOREIGN KEY ("lottery_product_id") REFERENCES "lottery_products"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "template_schedules" ADD CONSTRAINT "template_schedules_event_template_id_fkey" FOREIGN KEY ("event_template_id") REFERENCES "event_templates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "award_payment_orders" ADD CONSTRAINT "award_payment_orders_prize_award_id_fkey" FOREIGN KEY ("prize_award_id") REFERENCES "prize_awards"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "award_payment_orders" ADD CONSTRAINT "award_payment_orders_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "award_payment_orders" ADD CONSTRAINT "award_payment_orders_idempotency_key_id_fkey" FOREIGN KEY ("idempotency_key_id") REFERENCES "idempotency_keys"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_commitments" ADD CONSTRAINT "draw_commitments_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_result_numbers" ADD CONSTRAINT "draw_result_numbers_draw_result_id_fkey" FOREIGN KEY ("draw_result_id") REFERENCES "draw_results"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_results" ADD CONSTRAINT "draw_results_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_results" ADD CONSTRAINT "draw_results_draw_commitment_id_fkey" FOREIGN KEY ("draw_commitment_id") REFERENCES "draw_commitments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_results" ADD CONSTRAINT "draw_results_draw_snapshot_id_fkey" FOREIGN KEY ("draw_snapshot_id") REFERENCES "draw_snapshots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_results" ADD CONSTRAINT "draw_results_fixed_by_job_run_id_fkey" FOREIGN KEY ("fixed_by_job_run_id") REFERENCES "job_runs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_snapshot_tickets" ADD CONSTRAINT "draw_snapshot_tickets_draw_snapshot_id_fkey" FOREIGN KEY ("draw_snapshot_id") REFERENCES "draw_snapshots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_snapshot_tickets" ADD CONSTRAINT "draw_snapshot_tickets_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "draw_snapshots" ADD CONSTRAINT "draw_snapshots_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prize_awards" ADD CONSTRAINT "prize_awards_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prize_awards" ADD CONSTRAINT "prize_awards_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prize_awards" ADD CONSTRAINT "prize_awards_ticket_evaluation_id_fkey" FOREIGN KEY ("ticket_evaluation_id") REFERENCES "ticket_evaluations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "result_reports" ADD CONSTRAINT "result_reports_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "result_reports" ADD CONSTRAINT "result_reports_draw_result_id_fkey" FOREIGN KEY ("draw_result_id") REFERENCES "draw_results"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "result_reports" ADD CONSTRAINT "result_reports_supersedes_report_id_fkey" FOREIGN KEY ("supersedes_report_id") REFERENCES "result_reports"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "result_reports" ADD CONSTRAINT "result_reports_json_object_id_fkey" FOREIGN KEY ("json_object_id") REFERENCES "stored_objects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "result_reports" ADD CONSTRAINT "result_reports_pdf_object_id_fkey" FOREIGN KEY ("pdf_object_id") REFERENCES "stored_objects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "result_reports" ADD CONSTRAINT "result_reports_image_object_id_fkey" FOREIGN KEY ("image_object_id") REFERENCES "stored_objects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_evaluations" ADD CONSTRAINT "ticket_evaluations_draw_event_id_fkey" FOREIGN KEY ("draw_event_id") REFERENCES "draw_events"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_evaluations" ADD CONSTRAINT "ticket_evaluations_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_evaluations" ADD CONSTRAINT "fk_evaluation_ticket_event" FOREIGN KEY ("ticket_id", "draw_event_id") REFERENCES "tickets"("id", "draw_event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_evaluations" ADD CONSTRAINT "ticket_evaluations_draw_result_id_fkey" FOREIGN KEY ("draw_result_id") REFERENCES "draw_results"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_evaluations" ADD CONSTRAINT "fk_evaluation_result_event" FOREIGN KEY ("draw_result_id", "draw_event_id") REFERENCES "draw_results"("id", "draw_event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "sessions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "job_runs" ADD CONSTRAINT "job_runs_scheduled_job_id_fkey" FOREIGN KEY ("scheduled_job_id") REFERENCES "scheduled_jobs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_preferences" ADD CONSTRAINT "notification_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "security_events" ADD CONSTRAINT "security_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "security_events" ADD CONSTRAINT "security_events_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "sessions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "security_events" ADD CONSTRAINT "security_events_resolved_by_user_id_fkey" FOREIGN KEY ("resolved_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stored_objects" ADD CONSTRAINT "stored_objects_uploaded_by_user_id_fkey" FOREIGN KEY ("uploaded_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "system_settings" ADD CONSTRAINT "system_settings_updated_by_user_id_fkey" FOREIGN KEY ("updated_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_access_code_events" ADD CONSTRAINT "user_draw_access_code_events_access_code_id_fkey" FOREIGN KEY ("access_code_id") REFERENCES "user_draw_access_codes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_access_code_events" ADD CONSTRAINT "user_draw_access_code_events_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_access_code_numbers" ADD CONSTRAINT "user_draw_access_code_numbers_access_code_id_fkey" FOREIGN KEY ("access_code_id") REFERENCES "user_draw_access_codes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_access_code_numbers" ADD CONSTRAINT "user_draw_access_code_numbers_number_id_fkey" FOREIGN KEY ("number_id") REFERENCES "user_draw_numbers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_access_codes" ADD CONSTRAINT "user_draw_access_codes_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_access_codes" ADD CONSTRAINT "user_draw_access_codes_funder_user_id_fkey" FOREIGN KEY ("funder_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_access_codes" ADD CONSTRAINT "user_draw_access_codes_claimed_by_user_id_fkey" FOREIGN KEY ("claimed_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_access_codes" ADD CONSTRAINT "user_draw_access_codes_payment_ledger_transaction_id_fkey" FOREIGN KEY ("payment_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_access_codes" ADD CONSTRAINT "user_draw_access_codes_refund_ledger_transaction_id_fkey" FOREIGN KEY ("refund_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_announcements" ADD CONSTRAINT "user_draw_announcements_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_announcements" ADD CONSTRAINT "user_draw_announcements_author_user_id_fkey" FOREIGN KEY ("author_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claim_events" ADD CONSTRAINT "user_draw_claim_events_claim_id_fkey" FOREIGN KEY ("claim_id") REFERENCES "user_draw_claims"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claim_events" ADD CONSTRAINT "user_draw_claim_events_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claim_evidence" ADD CONSTRAINT "user_draw_claim_evidence_claim_id_fkey" FOREIGN KEY ("claim_id") REFERENCES "user_draw_claims"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claim_evidence" ADD CONSTRAINT "user_draw_claim_evidence_submitted_by_user_id_fkey" FOREIGN KEY ("submitted_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claim_evidence" ADD CONSTRAINT "user_draw_claim_evidence_stored_object_id_fkey" FOREIGN KEY ("stored_object_id") REFERENCES "stored_objects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claims" ADD CONSTRAINT "user_draw_claims_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claims" ADD CONSTRAINT "user_draw_claims_claimant_user_id_fkey" FOREIGN KEY ("claimant_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claims" ADD CONSTRAINT "user_draw_claims_participation_id_fkey" FOREIGN KEY ("participation_id") REFERENCES "user_draw_participations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claims" ADD CONSTRAINT "user_draw_claims_resolved_by_user_id_fkey" FOREIGN KEY ("resolved_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_claims" ADD CONSTRAINT "user_draw_claims_compensation_ledger_transaction_id_fkey" FOREIGN KEY ("compensation_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_delivery_records" ADD CONSTRAINT "user_draw_delivery_records_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_delivery_records" ADD CONSTRAINT "user_draw_delivery_records_winner_user_id_fkey" FOREIGN KEY ("winner_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_delivery_records" ADD CONSTRAINT "user_draw_delivery_records_delivery_evidence_object_id_fkey" FOREIGN KEY ("delivery_evidence_object_id") REFERENCES "stored_objects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_escrow_events" ADD CONSTRAINT "user_draw_escrow_events_user_draw_escrow_id_fkey" FOREIGN KEY ("user_draw_escrow_id") REFERENCES "user_draw_escrows"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_escrow_events" ADD CONSTRAINT "user_draw_escrow_events_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_escrow_events" ADD CONSTRAINT "user_draw_escrow_events_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_escrows" ADD CONSTRAINT "user_draw_escrows_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_escrows" ADD CONSTRAINT "user_draw_escrows_escrow_ledger_account_id_fkey" FOREIGN KEY ("escrow_ledger_account_id") REFERENCES "ledger_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_escrows" ADD CONSTRAINT "user_draw_escrows_commission_held_account_id_fkey" FOREIGN KEY ("commission_held_account_id") REFERENCES "ledger_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_escrows" ADD CONSTRAINT "user_draw_escrows_release_ledger_transaction_id_fkey" FOREIGN KEY ("release_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_invitations" ADD CONSTRAINT "user_draw_invitations_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_invitations" ADD CONSTRAINT "user_draw_invitations_invited_user_id_fkey" FOREIGN KEY ("invited_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_invitations" ADD CONSTRAINT "user_draw_invitations_accepted_by_user_id_fkey" FOREIGN KEY ("accepted_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_number_changes" ADD CONSTRAINT "user_draw_number_changes_participation_id_fkey" FOREIGN KEY ("participation_id") REFERENCES "user_draw_participations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_number_changes" ADD CONSTRAINT "user_draw_number_changes_old_participation_number_id_fkey" FOREIGN KEY ("old_participation_number_id") REFERENCES "user_draw_participation_numbers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_number_changes" ADD CONSTRAINT "user_draw_number_changes_new_number_id_fkey" FOREIGN KEY ("new_number_id") REFERENCES "user_draw_numbers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_number_changes" ADD CONSTRAINT "user_draw_number_changes_requested_by_user_id_fkey" FOREIGN KEY ("requested_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_numbers" ADD CONSTRAINT "user_draw_numbers_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_participation_events" ADD CONSTRAINT "user_draw_participation_events_participation_id_fkey" FOREIGN KEY ("participation_id") REFERENCES "user_draw_participations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_participation_events" ADD CONSTRAINT "user_draw_participation_events_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_participations" ADD CONSTRAINT "user_draw_participations_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_participations" ADD CONSTRAINT "user_draw_participations_participant_user_id_fkey" FOREIGN KEY ("participant_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_participations" ADD CONSTRAINT "user_draw_participations_access_code_id_fkey" FOREIGN KEY ("access_code_id") REFERENCES "user_draw_access_codes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_participations" ADD CONSTRAINT "user_draw_participations_payment_ledger_transaction_id_fkey" FOREIGN KEY ("payment_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_participations" ADD CONSTRAINT "user_draw_participations_refund_ledger_transaction_id_fkey" FOREIGN KEY ("refund_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_participation_numbers" ADD CONSTRAINT "user_draw_participation_numbers_participation_id_fkey" FOREIGN KEY ("participation_id") REFERENCES "user_draw_participations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_participation_numbers" ADD CONSTRAINT "user_draw_participation_numbers_number_id_fkey" FOREIGN KEY ("number_id") REFERENCES "user_draw_numbers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_prize_evidence" ADD CONSTRAINT "user_draw_prize_evidence_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_prize_evidence" ADD CONSTRAINT "user_draw_prize_evidence_stored_object_id_fkey" FOREIGN KEY ("stored_object_id") REFERENCES "stored_objects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_prize_evidence" ADD CONSTRAINT "user_draw_prize_evidence_submitted_by_user_id_fkey" FOREIGN KEY ("submitted_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_prize_evidence" ADD CONSTRAINT "user_draw_prize_evidence_verified_by_user_id_fkey" FOREIGN KEY ("verified_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_results" ADD CONSTRAINT "user_draw_results_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_results" ADD CONSTRAINT "user_draw_results_user_draw_snapshot_id_fkey" FOREIGN KEY ("user_draw_snapshot_id") REFERENCES "user_draw_snapshots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_results" ADD CONSTRAINT "user_draw_results_winning_snapshot_entry_id_fkey" FOREIGN KEY ("winning_snapshot_entry_id") REFERENCES "user_draw_snapshot_entries"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_results" ADD CONSTRAINT "user_draw_results_winning_participation_id_fkey" FOREIGN KEY ("winning_participation_id") REFERENCES "user_draw_participations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_results" ADD CONSTRAINT "user_draw_results_fixed_by_job_run_id_fkey" FOREIGN KEY ("fixed_by_job_run_id") REFERENCES "job_runs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_snapshot_entries" ADD CONSTRAINT "user_draw_snapshot_entries_user_draw_snapshot_id_fkey" FOREIGN KEY ("user_draw_snapshot_id") REFERENCES "user_draw_snapshots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_snapshot_entries" ADD CONSTRAINT "user_draw_snapshot_entries_participation_number_id_fkey" FOREIGN KEY ("participation_number_id") REFERENCES "user_draw_participation_numbers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_snapshots" ADD CONSTRAINT "user_draw_snapshots_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_status_history" ADD CONSTRAINT "user_draw_status_history_user_draw_id_fkey" FOREIGN KEY ("user_draw_id") REFERENCES "user_draws"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draw_status_history" ADD CONSTRAINT "user_draw_status_history_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_draws" ADD CONSTRAINT "user_draws_organizer_user_id_fkey" FOREIGN KEY ("organizer_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversion_assignments" ADD CONSTRAINT "conversion_assignments_conversion_request_id_fkey" FOREIGN KEY ("conversion_request_id") REFERENCES "conversion_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversion_assignments" ADD CONSTRAINT "conversion_assignments_vendor_user_id_fkey" FOREIGN KEY ("vendor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversion_request_events" ADD CONSTRAINT "conversion_request_events_conversion_request_id_fkey" FOREIGN KEY ("conversion_request_id") REFERENCES "conversion_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversion_request_events" ADD CONSTRAINT "conversion_request_events_actor_user_id_fkey" FOREIGN KEY ("actor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversion_requests" ADD CONSTRAINT "conversion_requests_client_user_id_fkey" FOREIGN KEY ("client_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversion_requests" ADD CONSTRAINT "conversion_requests_real_reservation_ledger_transaction_id_fkey" FOREIGN KEY ("real_reservation_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversion_requests" ADD CONSTRAINT "conversion_requests_completion_ledger_transaction_id_fkey" FOREIGN KEY ("completion_ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversion_requests" ADD CONSTRAINT "conversion_requests_completed_by_vendor_user_id_fkey" FOREIGN KEY ("completed_by_vendor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversion_requests" ADD CONSTRAINT "conversion_requests_idempotency_key_id_fkey" FOREIGN KEY ("idempotency_key_id") REFERENCES "idempotency_keys"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "related_account_flags" ADD CONSTRAINT "related_account_flags_user_a_id_fkey" FOREIGN KEY ("user_a_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "related_account_flags" ADD CONSTRAINT "related_account_flags_user_b_id_fkey" FOREIGN KEY ("user_b_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "related_account_flags" ADD CONSTRAINT "related_account_flags_resolved_by_user_id_fkey" FOREIGN KEY ("resolved_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_inventory_batches" ADD CONSTRAINT "vendor_inventory_batches_vendor_user_id_fkey" FOREIGN KEY ("vendor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_inventory_batches" ADD CONSTRAINT "vendor_inventory_batches_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "vendor_purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_profiles" ADD CONSTRAINT "vendor_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_profiles" ADD CONSTRAINT "vendor_profiles_approved_by_user_id_fkey" FOREIGN KEY ("approved_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_purchase_orders" ADD CONSTRAINT "vendor_purchase_orders_vendor_user_id_fkey" FOREIGN KEY ("vendor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_purchase_orders" ADD CONSTRAINT "vendor_purchase_orders_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_purchase_orders" ADD CONSTRAINT "vendor_purchase_orders_idempotency_key_id_fkey" FOREIGN KEY ("idempotency_key_id") REFERENCES "idempotency_keys"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_sale_batch_allocations" ADD CONSTRAINT "vendor_sale_batch_allocations_vendor_sale_id_fkey" FOREIGN KEY ("vendor_sale_id") REFERENCES "vendor_sales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_sale_batch_allocations" ADD CONSTRAINT "vendor_sale_batch_allocations_inventory_batch_id_fkey" FOREIGN KEY ("inventory_batch_id") REFERENCES "vendor_inventory_batches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_sales" ADD CONSTRAINT "vendor_sales_conversion_request_id_fkey" FOREIGN KEY ("conversion_request_id") REFERENCES "conversion_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_sales" ADD CONSTRAINT "vendor_sales_vendor_user_id_fkey" FOREIGN KEY ("vendor_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vendor_sales" ADD CONSTRAINT "vendor_sales_ledger_transaction_id_fkey" FOREIGN KEY ("ledger_transaction_id") REFERENCES "ledger_transactions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- =========================================================
-- POST-PRISMA
-- =========================================================
-- Lotería Binaria — PostgreSQL 16 — fase POST-PRISMA
-- Aplicar después del DDL generado por Prisma dentro de la MISMA migración inicial.
-- No ejecutar con db push: las funciones, triggers, vistas e índices parciales no están
-- completamente representados por Prisma Schema Language.

BEGIN;

DO $$
BEGIN
  IF current_setting('server_version_num')::integer < 160000 THEN
    RAISE EXCEPTION 'Lotería Binaria requiere PostgreSQL 16 o superior';
  END IF;
END
$$;

-- -----------------------------------------------------------------------------
-- CHECK constraints derivados del diccionario y reglas LOT-*
-- -----------------------------------------------------------------------------
ALTER TABLE "roles" ADD CONSTRAINT "ck_roles_global_code" CHECK ("code" IN ('CLIENTE', 'VENDEDOR', 'ADMINISTRADOR'));
ALTER TABLE "user_profiles" ADD CONSTRAINT "ck_user_profiles_country_code" CHECK ("country_code" = upper("country_code") AND char_length("country_code") = 2);
ALTER TABLE "user_profiles" ADD CONSTRAINT "ck_user_profiles_timezone_nonblank" CHECK (btrim("timezone") <> '');
ALTER TABLE "user_roles" ADD CONSTRAINT "ck_user_roles_validity" CHECK ("valid_until" IS NULL OR "valid_until" > "valid_from");
ALTER TABLE "user_permission_grants" ADD CONSTRAINT "ck_user_permission_grants_validity" CHECK ("valid_until" IS NULL OR "valid_until" > "valid_from");
ALTER TABLE "sessions" ADD CONSTRAINT "ck_sessions_expiry" CHECK ("expires_at" > "created_at");
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "ck_refresh_tokens_expiry" CHECK ("expires_at" > "created_at");
ALTER TABLE "password_resets" ADD CONSTRAINT "ck_password_resets_expiry" CHECK ("expires_at" > "created_at");
ALTER TABLE "verification_tokens" ADD CONSTRAINT "ck_verification_tokens_expiry" CHECK ("expires_at" > "created_at");
ALTER TABLE "terms_versions" ADD CONSTRAINT "ck_terms_versions_validity" CHECK ("retired_at" IS NULL OR "retired_at" > "effective_at");
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ck_ledger_entries_amount_positive" CHECK ("amount_minor" > 0);
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ck_ledger_entries_sequence_nonnegative" CHECK ("sequence" >= 0);
ALTER TABLE "wallet_balance_projections" ADD CONSTRAINT "ck_wallet_balance_projections_components_nonnegative" CHECK ("available_minor" >= 0 AND "reserved_minor" >= 0 AND "pending_minor" >= 0 AND "blocked_minor" >= 0 AND "in_withdrawal_minor" >= 0 AND "ledger_version" >= 0);
ALTER TABLE "real_topups" ADD CONSTRAINT "ck_real_topups_amount_positive" CHECK ("amount_real_minor" > 0);
ALTER TABLE "virtual_to_real_conversions" ADD CONSTRAINT "ck_virtual_to_real_conversions_amounts" CHECK ("gross_virtual_minor" > 0 AND "fee_virtual_minor" >= 0 AND "net_real_minor" >= 0 AND "gross_virtual_minor" = "fee_virtual_minor" + "net_real_minor" AND "fee_rate_bps" = 1000);
ALTER TABLE "withdrawal_requests" ADD CONSTRAINT "ck_withdrawal_requests_amount_positive" CHECK ("amount_real_minor" > 0);
ALTER TABLE "virtual_transfers" ADD CONSTRAINT "ck_virtual_transfers_valid_transfer" CHECK ("sender_user_id" <> "recipient_user_id" AND "amount_virtual_minor" > 0);
ALTER TABLE "vendor_purchase_orders" ADD CONSTRAINT "ck_vendor_purchase_orders_wholesale_ratio" CHECK ("requested_virtual_minor" > 0 AND "real_cost_minor" > 0 AND "unit_cost_numerator" = 90 AND "unit_cost_denominator" = 100 AND mod("requested_virtual_minor", 100) = 0 AND "real_cost_minor" * "unit_cost_denominator" = "requested_virtual_minor" * "unit_cost_numerator");
ALTER TABLE "vendor_inventory_batches" ADD CONSTRAINT "ck_vendor_inventory_batches_remaining" CHECK ("virtual_acquired_minor" > 0 AND "virtual_remaining_minor" >= 0 AND "virtual_remaining_minor" <= "virtual_acquired_minor" AND "real_cost_minor" > 0);
ALTER TABLE "conversion_requests" ADD CONSTRAINT "ck_conversion_requests_amounts_deadline" CHECK ("amount_real_minor" > 0 AND "amount_virtual_minor" = "amount_real_minor" AND "expires_at" = "created_at" + interval '5 minutes');
ALTER TABLE "conversion_requests" ADD CONSTRAINT "ck_conversion_requests_terminal_effect" CHECK (
  ("status" IN ('PENDIENTE','EN_PROCESO') AND "completion_ledger_transaction_id" IS NULL AND "completed_at" IS NULL AND "completed_by_vendor_user_id" IS NULL)
  OR
  ("status" = 'COMPLETADA_POR_VENDEDOR' AND "completion_ledger_transaction_id" IS NOT NULL AND "completed_at" IS NOT NULL AND "completed_by_vendor_user_id" IS NOT NULL)
  OR
  ("status" IN ('COMPLETADA_POR_PLATAFORMA','FALLIDA_POR_LIQUIDEZ') AND "completion_ledger_transaction_id" IS NOT NULL AND "completed_at" IS NOT NULL AND "completed_by_vendor_user_id" IS NULL)
);
ALTER TABLE "conversion_assignments" ADD CONSTRAINT "ck_conversion_assignments_timestamps" CHECK (("released_at" IS NULL OR "released_at" >= "assigned_at") AND ("consumed_at" IS NULL OR "consumed_at" >= "assigned_at"));
ALTER TABLE "vendor_sales" ADD CONSTRAINT "ck_vendor_sales_profit" CHECK ("virtual_sold_minor" > 0 AND "real_received_minor" > 0 AND "allocated_real_cost_minor" >= 0 AND "realized_profit_minor" = "real_received_minor" - "allocated_real_cost_minor");
ALTER TABLE "vendor_sale_batch_allocations" ADD CONSTRAINT "ck_vendor_sale_batch_allocations_amounts" CHECK ("virtual_amount_minor" > 0 AND "allocated_real_cost_minor" >= 0);
ALTER TABLE "related_account_flags" ADD CONSTRAINT "ck_related_account_flags_ordered_pair" CHECK ("user_a_id" < "user_b_id");
ALTER TABLE "rule_versions" ADD CONSTRAINT "ck_rule_versions_math" CHECK ("selection_count" > 0 AND "total_combinations" > 0 AND "order_matters" = false AND "unique_symbols_required" = true AND "purchase_limit_bps" = 2000 AND "limit_release_fraction_bps" = 8000 AND "reservation_seconds" = 300 AND "close_before_draw_seconds" = 600);
ALTER TABLE "rule_versions" ADD CONSTRAINT "ck_rule_versions_status_dates" CHECK (("status"='DRAFT' AND "published_at" IS NULL) OR ("status" IN ('PUBLISHED','RETIRED') AND "published_at" IS NOT NULL));
ALTER TABLE "prize_rule_versions" ADD CONSTRAINT "ck_prize_rule_versions_shares" CHECK ("initial_prize_multiplier_bps" > 0 AND "growth_share_bps" = 9000 AND "operations_share_bps" = 1000 AND "no_winner_accumulation_bps" = 5000 AND "no_winner_guarantee_bps" = 2500 AND "no_winner_future_prize_bps" = 1500 AND "no_winner_operations_bps" = 1000 AND "growth_share_bps" + "operations_share_bps" = 10000 AND "no_winner_accumulation_bps" + "no_winner_guarantee_bps" + "no_winner_future_prize_bps" + "no_winner_operations_bps" = 10000);
ALTER TABLE "prize_rule_versions" ADD CONSTRAINT "ck_prize_rule_versions_status_dates" CHECK (("status"='DRAFT' AND "published_at" IS NULL) OR ("status" IN ('PUBLISHED','RETIRED') AND "published_at" IS NOT NULL));
ALTER TABLE "event_templates" ADD CONSTRAINT "ck_event_templates_generation" CHECK ("future_generation_days" >= 0 AND "publication_lead_seconds" >= 0);
ALTER TABLE "template_schedules" ADD CONSTRAINT "ck_template_schedules_schedule" CHECK (("weekday" IS NULL OR "weekday" BETWEEN 0 AND 6) AND ("interval_seconds" IS NULL OR "interval_seconds" > 0) AND ("effective_until" IS NULL OR "effective_until" >= "effective_from") AND ("local_time" IS NOT NULL OR "interval_seconds" IS NOT NULL));
ALTER TABLE "draw_events" ADD CONSTRAINT "ck_draw_events_timeline" CHECK ("sales_open_at" < "sales_close_at" AND "sales_close_at" < "draw_at" AND "sales_close_at" = "draw_at" - interval '10 minutes' AND "limit_release_at" >= "sales_open_at" AND "limit_release_at" <= "sales_close_at");
ALTER TABLE "draw_events" ADD CONSTRAINT "ck_draw_events_cancellation_reason" CHECK ("status" <> 'CANCELADO' OR ("cancelled_at" IS NOT NULL AND btrim(coalesce("cancel_reason", '')) <> ''));
ALTER TABLE "event_financial_configs" ADD CONSTRAINT "ck_event_financial_configs_amounts" CHECK ("ticket_price_virtual_minor" > 0 AND "initial_major_prize_virtual_minor" >= 0 AND "major_prize_ceiling_virtual_minor" >= "initial_major_prize_virtual_minor" AND "minimum_capital_virtual_minor" >= 0 AND "guarantee_required_virtual_minor" >= 0);
ALTER TABLE "event_financial_projections" ADD CONSTRAINT "ck_event_financial_projections_nonnegative" CHECK ("sales_virtual_minor" >= 0 AND "refund_liability_virtual_minor" >= 0 AND "guarantee_recovery_pending_minor" >= 0 AND "growth_virtual_minor" >= 0 AND "accumulation_extra_virtual_minor" >= 0 AND "current_major_prize_virtual_minor" >= 0 AND "ledger_version" >= 0);
ALTER TABLE "event_combinations" ADD CONSTRAINT "ck_event_combinations_key_nonblank" CHECK (btrim("normalized_key") <> '');
ALTER TABLE "combination_numbers" ADD CONSTRAINT "ck_combination_numbers_sort_order" CHECK ("sort_order" >= 0);
ALTER TABLE "purchase_sessions" ADD CONSTRAINT "ck_purchase_sessions_expiry" CHECK ("expires_at" > "created_at");
ALTER TABLE "shopping_carts" ADD CONSTRAINT "ck_shopping_carts_expiry" CHECK ("expires_at" > "created_at");
ALTER TABLE "combination_reservations" ADD CONSTRAINT "ck_combination_reservations_timeline" CHECK ("expires_at" > "reserved_at" AND "expires_at" <= "reserved_at" + interval '5 minutes' AND ("consumed_at" IS NULL OR "consumed_at" >= "reserved_at") AND ("released_at" IS NULL OR "released_at" >= "reserved_at"));
ALTER TABLE "cart_items" ADD CONSTRAINT "ck_cart_items_price" CHECK ("unit_price_virtual_minor" > 0);
ALTER TABLE "purchase_orders" ADD CONSTRAINT "ck_purchase_orders_amounts" CHECK ("ticket_count" > 0 AND "total_virtual_minor" > 0);
ALTER TABLE "tickets" ADD CONSTRAINT "ck_tickets_price" CHECK ("price_virtual_minor" > 0 AND btrim("normalized_key") <> '');
ALTER TABLE "ticket_numbers" ADD CONSTRAINT "ck_ticket_numbers_sort_order" CHECK ("sort_order" >= 0);
ALTER TABLE "guarantee_fund" ADD CONSTRAINT "ck_guarantee_fund_base" CHECK ("currency" = 'VIRTUAL' AND "base_emergency_minor" >= 0);
ALTER TABLE "guarantee_fund_reservations" ADD CONSTRAINT "ck_guarantee_fund_reservations_amount" CHECK ("amount_virtual_minor" > 0);
ALTER TABLE "accumulation_transfers" ADD CONSTRAINT "ck_accumulation_transfers_amount" CHECK ("amount_virtual_minor" > 0 AND "source_draw_event_id" <> coalesce("target_draw_event_id", '00000000-0000-0000-0000-000000000000'::uuid));
ALTER TABLE "fund_movements" ADD CONSTRAINT "ck_fund_movements_amount" CHECK ("amount_virtual_minor" > 0 AND btrim("reason") <> '');
ALTER TABLE "draw_snapshots" ADD CONSTRAINT "ck_draw_snapshots_count" CHECK ("ticket_count" >= 0);
ALTER TABLE "draw_commitments" ADD CONSTRAINT "ck_draw_commitments_status_payload" CHECK (
  ("status"='GENERADO_SECRETO' AND "published_at" IS NULL AND "revealed_seed" IS NULL AND "revealed_at" IS NULL)
  OR ("status"='PUBLICADO' AND "published_at" IS NOT NULL AND "revealed_seed" IS NULL AND "revealed_at" IS NULL)
  OR ("status"='REVELADO' AND "published_at" IS NOT NULL AND "revealed_seed" IS NOT NULL AND "revealed_at" IS NOT NULL)
  OR ("status"='INVALIDADO_POR_CANCELACION')
);
ALTER TABLE "draw_snapshots" ADD CONSTRAINT "ck_draw_snapshots_status_payload" CHECK (
  ("status"='PENDIENTE' AND "snapshot_hash" IS NULL AND "generated_at" IS NULL)
  OR ("status"='GENERADO' AND "snapshot_hash" IS NOT NULL AND "generated_at" IS NOT NULL)
  OR ("status"='INVALIDADO_POR_CANCELACION')
);
ALTER TABLE "draw_result_numbers" ADD CONSTRAINT "ck_draw_result_numbers_order" CHECK ("display_order" >= 0);
ALTER TABLE "ticket_evaluations" ADD CONSTRAINT "ck_ticket_evaluations_matches" CHECK ("match_count" >= 0);
ALTER TABLE "prize_awards" ADD CONSTRAINT "ck_prize_awards_amounts" CHECK ("exact_virtual_minor" >= 0 AND "public_virtual_minor" >= 0 AND "rounding_adjustment_minor" = "public_virtual_minor" - "exact_virtual_minor");
ALTER TABLE "award_payment_orders" ADD CONSTRAINT "ck_award_payment_orders_attempts" CHECK ("attempt_count" >= 0);
ALTER TABLE "result_reports" ADD CONSTRAINT "ck_result_reports_version" CHECK ("report_version" > 0 AND "supersedes_report_id" IS DISTINCT FROM "id");
ALTER TABLE "result_reports" ADD CONSTRAINT "ck_result_reports_status_dates" CHECK (
  ("status" IN ('PENDIENTE','PREPARADO','ERROR_REINTENTABLE','REVISION_MANUAL') AND "published_at" IS NULL AND "superseded_at" IS NULL)
  OR ("status"='PUBLICADO' AND "published_at" IS NOT NULL AND "superseded_at" IS NULL)
  OR ("status"='SUPERSEDED' AND "published_at" IS NOT NULL AND "superseded_at" IS NOT NULL)
);
ALTER TABLE "stored_objects" ADD CONSTRAINT "ck_stored_objects_size" CHECK ("size_bytes" >= 0);
ALTER TABLE "outbox_events" ADD CONSTRAINT "ck_outbox_events_attempts" CHECK ("event_version" > 0 AND "attempt_count" >= 0);
ALTER TABLE "scheduled_jobs" ADD CONSTRAINT "ck_scheduled_jobs_attempts" CHECK ("max_attempts" > 0 AND "attempt_count" >= 0 AND "attempt_count" <= "max_attempts");
ALTER TABLE "job_runs" ADD CONSTRAINT "ck_job_runs_attempt" CHECK ("attempt_number" > 0 AND ("finished_at" IS NULL OR "finished_at" >= "started_at"));
ALTER TABLE "notifications" ADD CONSTRAINT "ck_notifications_schedule" CHECK ("sent_at" IS NULL OR "sent_at" >= "scheduled_at");
ALTER TABLE "user_draws" ADD CONSTRAINT "ck_user_draws_config" CHECK ("price_virtual_minor" > 0 AND "range_start" <= "range_end" AND "sales_open_at" < "sales_close_at");
ALTER TABLE "user_draw_numbers" ADD CONSTRAINT "ck_user_draw_numbers_number" CHECK ("number_value" >= 0);
ALTER TABLE "user_draw_participations" ADD CONSTRAINT "ck_user_draw_participations_price" CHECK ("price_virtual_minor" > 0);
ALTER TABLE "user_draw_participation_numbers" ADD CONSTRAINT "ck_user_draw_participation_numbers_timeline" CHECK (("replaced_at" IS NULL OR "replaced_at" >= "assigned_at") AND ("released_at" IS NULL OR "released_at" >= "assigned_at"));
ALTER TABLE "user_draw_number_changes" ADD CONSTRAINT "ck_user_draw_number_changes_distinct" CHECK ("old_participation_number_id" IS NOT NULL AND "new_number_id" IS NOT NULL);
ALTER TABLE "user_draw_access_codes" ADD CONSTRAINT "ck_user_draw_access_codes_amount_expiry" CHECK ("price_virtual_minor" > 0 AND "expires_at" > "created_at");
ALTER TABLE "user_draw_snapshots" ADD CONSTRAINT "ck_user_draw_snapshots_count" CHECK ("entry_count" >= 0);
ALTER TABLE "user_draw_snapshot_entries" ADD CONSTRAINT "ck_user_draw_snapshot_entries_sequence" CHECK ("sequence" >= 0);
ALTER TABLE "user_draw_delivery_records" ADD CONSTRAINT "ck_user_draw_delivery_records_deadline" CHECK ("delivery_deadline_at" > "created_at");
ALTER TABLE "user_draw_claims" ADD CONSTRAINT "ck_user_draw_claims_timeline" CHECK ("filed_at" >= "event_occurred_at" AND ("appeal_deadline_at" IS NULL OR "appeal_deadline_at" >= "filed_at") AND ("resolved_at" IS NULL OR "resolved_at" >= "filed_at") AND ("closed_at" IS NULL OR "closed_at" >= "filed_at"));
ALTER TABLE "user_draw_escrows" ADD CONSTRAINT "ck_user_draw_escrows_amounts" CHECK ("gross_paid_virtual_minor" >= 0 AND "commission_held_virtual_minor" >= 0 AND "escrow_virtual_minor" >= 0 AND "released_virtual_minor" >= 0 AND "refunded_virtual_minor" >= 0 AND "gross_paid_virtual_minor" = "commission_held_virtual_minor" + "escrow_virtual_minor" AND "released_virtual_minor" <= "escrow_virtual_minor" AND "refunded_virtual_minor" <= "gross_paid_virtual_minor");
ALTER TABLE "user_draw_escrows" ADD CONSTRAINT "ck_user_draw_escrows_terminal_effect" CHECK (
  ("status"='LIBERADA' AND "released_virtual_minor"="escrow_virtual_minor" AND "release_ledger_transaction_id" IS NOT NULL AND "settled_at" IS NOT NULL)
  OR ("status"='REEMBOLSADA' AND "refunded_virtual_minor"="gross_paid_virtual_minor" AND "settled_at" IS NOT NULL)
  OR ("status" NOT IN ('LIBERADA','REEMBOLSADA'))
);

-- -----------------------------------------------------------------------------
-- Unicidad parcial, NULLS NOT DISTINCT e índices de expresiones
-- -----------------------------------------------------------------------------
-- Equivalente a UNIQUE NULLS NOT DISTINCT, expresado como dos índices parciales.
-- Se conserva en SQL nativo para que Prisma no intente administrar una restricción
-- con una columna opcional que PSL no puede representar como @@unique compuesto.
CREATE UNIQUE INDEX "uq_idempotency_subject_scope_key_not_null"
  ON "idempotency_keys" ("subject_user_id", "scope", "key_value")
  WHERE "subject_user_id" IS NOT NULL;

CREATE UNIQUE INDEX "uq_idempotency_global_scope_key"
  ON "idempotency_keys" ("scope", "key_value")
  WHERE "subject_user_id" IS NULL;

CREATE UNIQUE INDEX "uq_user_roles_active"
  ON "user_roles" ("user_id", "role_id")
  WHERE "revoked_at" IS NULL;

CREATE UNIQUE INDEX "uq_user_permission_grants_active"
  ON "user_permission_grants" ("user_id", "permission_id")
  WHERE "revoked_at" IS NULL;

CREATE UNIQUE INDEX "uq_conversion_assignments_active"
  ON "conversion_assignments" ("conversion_request_id")
  WHERE "status" = 'ACTIVA';

CREATE UNIQUE INDEX "uq_combination_reservations_active"
  ON "combination_reservations" ("combination_id")
  WHERE "status" = 'ACTIVA';

CREATE UNIQUE INDEX "uq_user_draw_participation_number_active"
  ON "user_draw_participation_numbers" ("number_id")
  WHERE "status" = 'ACTIVA';

CREATE UNIQUE INDEX "uq_result_reports_published"
  ON "result_reports" ("draw_event_id")
  WHERE "status" = 'PUBLICADO';

-- Claves candidatas y claves foráneas compuestas administradas por schema.prisma.
-- No deben duplicarse en este archivo SQL POST.

-- -----------------------------------------------------------------------------
-- Funciones genéricas de protección e identidad
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lb_prevent_delete()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'DELETE prohibido en %.%; use estado lógico o compensación', TG_TABLE_SCHEMA, TG_TABLE_NAME
    USING ERRCODE = '55000';
END
$$;

CREATE OR REPLACE FUNCTION lb_prevent_update_or_delete()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% prohibido en %.%; el registro es inmutable', TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME
    USING ERRCODE = '55000';
END
$$;

CREATE OR REPLACE FUNCTION lb_validate_adult_profile()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW."birth_date" > (CURRENT_DATE - interval '18 years')::date THEN
    RAISE EXCEPTION 'El usuario debe ser mayor de edad' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END
$$;

CREATE TRIGGER "tr_user_profiles_adult"
BEFORE INSERT OR UPDATE OF "birth_date" ON "user_profiles"
FOR EACH ROW EXECUTE FUNCTION lb_validate_adult_profile();

-- -----------------------------------------------------------------------------
-- Plazos autoritativos generados por PostgreSQL
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lb_set_conversion_request_deadline()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  -- LOT-VND-006/009: ninguna asignación puede extender el fallback de cinco minutos.
  NEW."expires_at" := NEW."created_at" + interval '5 minutes';
  RETURN NEW;
END
$$;

CREATE TRIGGER "tr_conversion_requests_set_deadline"
BEFORE INSERT ON "conversion_requests"
FOR EACH ROW EXECUTE FUNCTION lb_set_conversion_request_deadline();

-- -----------------------------------------------------------------------------
-- Ledger: moneda, reversos, balance, no negatividad e inmutabilidad
-- -----------------------------------------------------------------------------
ALTER TABLE "ledger_accounts" ADD CONSTRAINT "ck_ledger_accounts_type_currency" CHECK (
  ("account_type" IN (
    'USER_REAL_AVAILABLE','USER_REAL_RESERVED_CONVERSION','USER_REAL_IN_WITHDRAWAL',
    'PLATFORM_REAL_CASH','SIMULATED_TOPUP_SOURCE_REAL','SIMULATED_PAYOUT_CLEARING_REAL'
  ) AND "currency" = 'REAL')
  OR
  ("account_type" NOT IN (
    'USER_REAL_AVAILABLE','USER_REAL_RESERVED_CONVERSION','USER_REAL_IN_WITHDRAWAL',
    'PLATFORM_REAL_CASH','SIMULATED_TOPUP_SOURCE_REAL','SIMULATED_PAYOUT_CLEARING_REAL'
  ) AND "currency" = 'VIRTUAL')
);
ALTER TABLE "ledger_accounts" ADD CONSTRAINT "ck_ledger_accounts_negative_policy" CHECK (
  "allows_negative" = ("account_type" IN ('SIMULATED_TOPUP_SOURCE_REAL','PLATFORM_VIRTUAL_ISSUANCE'))
);
ALTER TABLE "ledger_accounts" ADD CONSTRAINT "ck_ledger_accounts_scope" CHECK (
  (
    "account_type" IN ('USER_REAL_AVAILABLE','USER_REAL_RESERVED_CONVERSION','USER_REAL_IN_WITHDRAWAL','USER_VIRTUAL_AVAILABLE')
    AND "wallet_id" IS NOT NULL AND "user_id" IS NOT NULL
    AND "draw_event_id" IS NULL AND "user_draw_id" IS NULL
  )
  OR
  (
    "account_type" IN ('DRAW_SALES_FUND','DRAW_PRIZE_RESERVE','AWARD_PAYABLE','DRAW_UNAWARDED_MAJOR_PRIZE','DRAW_ACCUMULATION_EXTRA')
    AND "draw_event_id" IS NOT NULL
    AND "wallet_id" IS NULL AND "user_id" IS NULL AND "user_draw_id" IS NULL
  )
  OR
  (
    "account_type" IN ('USER_DRAW_ESCROW','USER_DRAW_COMMISSION_HELD')
    AND "user_draw_id" IS NOT NULL
    AND "wallet_id" IS NULL AND "user_id" IS NULL AND "draw_event_id" IS NULL
  )
  OR
  (
    "account_type" IN (
      'PLATFORM_REAL_CASH','SIMULATED_TOPUP_SOURCE_REAL','SIMULATED_PAYOUT_CLEARING_REAL',
      'PLATFORM_VIRTUAL_ISSUANCE','PLATFORM_VIRTUAL_REDEMPTION','GENERAL_CONVERSION_WALLET',
      'CONVERSION_FEES_VIRTUAL','PLATFORM_OPERATIONS_VIRTUAL','ROUNDING_ADJUSTMENTS_VIRTUAL',
      'GUARANTEE_FUND_AVAILABLE','GUARANTEE_FUND_RESERVED_EVENT','FUTURE_PRIZE_FUND','ACCUMULATION_POOL_PRODUCT'
    )
    AND "wallet_id" IS NULL AND "user_id" IS NULL AND "draw_event_id" IS NULL AND "user_draw_id" IS NULL
  )
);

CREATE OR REPLACE FUNCTION lb_validate_ledger_entry()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_currency currency_code;
  v_original ledger_entries%ROWTYPE;
  v_reversal_tx uuid;
  v_reversed bigint;
BEGIN
  SELECT "currency" INTO v_currency
  FROM "ledger_accounts"
  WHERE "id" = NEW."account_id"
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cuenta ledger inexistente: %', NEW."account_id" USING ERRCODE = '23503';
  END IF;
  IF v_currency <> NEW."currency" THEN
    RAISE EXCEPTION 'La moneda del asiento no coincide con la cuenta' USING ERRCODE = '23514';
  END IF;

  IF NEW."reversal_of_entry_id" IS NOT NULL THEN
    SELECT * INTO v_original
    FROM "ledger_entries"
    WHERE "id" = NEW."reversal_of_entry_id"
    FOR UPDATE;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Asiento original de reverso inexistente' USING ERRCODE = '23503';
    END IF;
    IF v_original."account_id" <> NEW."account_id"
       OR v_original."currency" <> NEW."currency"
       OR v_original."side" = NEW."side" THEN
      RAISE EXCEPTION 'Reverso debe usar misma cuenta/moneda y lado opuesto' USING ERRCODE = '23514';
    END IF;

    SELECT "reversal_of_transaction_id" INTO v_reversal_tx
    FROM "ledger_transactions" WHERE "id" = NEW."ledger_transaction_id";
    IF v_reversal_tx IS DISTINCT FROM v_original."ledger_transaction_id" THEN
      RAISE EXCEPTION 'La transacción de reverso no referencia la transacción original' USING ERRCODE = '23514';
    END IF;

    SELECT coalesce(sum("amount_minor"),0) INTO v_reversed
    FROM "ledger_entries" WHERE "reversal_of_entry_id" = v_original."id";
    IF v_reversed + NEW."amount_minor" > v_original."amount_minor" THEN
      RAISE EXCEPTION 'El reverso acumulado supera el asiento original' USING ERRCODE = '23514';
    END IF;
  END IF;
  RETURN NEW;
END
$$;

CREATE TRIGGER "tr_ledger_entry_validate"
BEFORE INSERT ON "ledger_entries"
FOR EACH ROW EXECUTE FUNCTION lb_validate_ledger_entry();

CREATE OR REPLACE FUNCTION lb_check_ledger_transaction_balanced(p_transaction_id uuid)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM "ledger_entries" WHERE "ledger_transaction_id" = p_transaction_id
  ) THEN
    RAISE EXCEPTION 'La transacción ledger % no contiene asientos', p_transaction_id
      USING ERRCODE = '23514';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "ledger_entries"
    WHERE "ledger_transaction_id" = p_transaction_id
    GROUP BY "currency"
    HAVING count(*) < 2
       OR sum(CASE WHEN "side" = 'DEBIT' THEN "amount_minor" ELSE -"amount_minor" END) <> 0
  ) THEN
    RAISE EXCEPTION 'La transacción ledger % está desbalanceada por moneda', p_transaction_id
      USING ERRCODE = '23514';
  END IF;
END
$$;

CREATE OR REPLACE FUNCTION lb_assert_ledger_entry_transaction_balanced()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM lb_check_ledger_transaction_balanced(NEW."ledger_transaction_id");
  RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION lb_assert_ledger_transaction_has_entries()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM lb_check_ledger_transaction_balanced(NEW."id");
  RETURN NULL;
END
$$;

CREATE CONSTRAINT TRIGGER "ct_ledger_entries_balanced"
AFTER INSERT ON "ledger_entries"
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION lb_assert_ledger_entry_transaction_balanced();

CREATE CONSTRAINT TRIGGER "ct_ledger_transactions_have_entries"
AFTER INSERT ON "ledger_transactions"
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION lb_assert_ledger_transaction_has_entries();

CREATE OR REPLACE FUNCTION lb_assert_ledger_account_nonnegative()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_account uuid := coalesce(NEW."account_id", OLD."account_id");
  v_allows_negative boolean;
  v_balance bigint;
BEGIN
  SELECT "allows_negative" INTO v_allows_negative FROM "ledger_accounts" WHERE "id" = v_account;
  IF NOT coalesce(v_allows_negative,false) THEN
    SELECT coalesce(sum(CASE WHEN "side" = 'CREDIT' THEN "amount_minor" ELSE -"amount_minor" END),0)
      INTO v_balance
    FROM "ledger_entries" WHERE "account_id" = v_account;
    IF v_balance < 0 THEN
      RAISE EXCEPTION 'La cuenta ledger % quedaría negativa: %', v_account, v_balance USING ERRCODE = '23514';
    END IF;
  END IF;
  RETURN NULL;
END
$$;

CREATE CONSTRAINT TRIGGER "ct_ledger_account_nonnegative"
AFTER INSERT ON "ledger_entries"
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION lb_assert_ledger_account_nonnegative();

CREATE OR REPLACE FUNCTION lb_guard_ledger_transaction_update()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_any boolean;
  v_all boolean;
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Las transacciones ledger no se eliminan' USING ERRCODE='55000';
  END IF;
  IF ROW(NEW."transaction_type",NEW."correlation_id",NEW."idempotency_key_id",NEW."reversal_of_transaction_id",NEW."business_reference_type",NEW."business_reference_id",NEW."rule_version_id",NEW."description",NEW."calculation_snapshot",NEW."posted_at",NEW."created_at")
     IS DISTINCT FROM
     ROW(OLD."transaction_type",OLD."correlation_id",OLD."idempotency_key_id",OLD."reversal_of_transaction_id",OLD."business_reference_type",OLD."business_reference_id",OLD."rule_version_id",OLD."description",OLD."calculation_snapshot",OLD."posted_at",OLD."created_at") THEN
    RAISE EXCEPTION 'Solo puede avanzar el estado de una transacción ledger' USING ERRCODE='55000';
  END IF;
  IF NEW."status" = OLD."status" THEN RETURN NEW; END IF;
  IF NOT ((OLD."status"='CONTABILIZADA' AND NEW."status" IN ('PARCIALMENTE_REVERSADA','REVERSADA'))
       OR (OLD."status"='PARCIALMENTE_REVERSADA' AND NEW."status"='REVERSADA')) THEN
    RAISE EXCEPTION 'Transición ledger no permitida: % -> %', OLD."status", NEW."status" USING ERRCODE='23514';
  END IF;

  SELECT EXISTS(SELECT 1 FROM "ledger_entries" r JOIN "ledger_entries" o ON o."id"=r."reversal_of_entry_id" WHERE o."ledger_transaction_id"=OLD."id"),
         NOT EXISTS(SELECT 1 FROM "ledger_entries" o WHERE o."ledger_transaction_id"=OLD."id" AND coalesce((SELECT sum(r."amount_minor") FROM "ledger_entries" r WHERE r."reversal_of_entry_id"=o."id"),0) < o."amount_minor")
    INTO v_any, v_all;
  IF NEW."status"='PARCIALMENTE_REVERSADA' AND (NOT v_any OR v_all) THEN
    RAISE EXCEPTION 'Estado PARCIALMENTE_REVERSADA inconsistente' USING ERRCODE='23514';
  END IF;
  IF NEW."status"='REVERSADA' AND NOT v_all THEN
    RAISE EXCEPTION 'No todos los asientos fueron revertidos completamente' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END
$$;

CREATE TRIGGER "tr_ledger_transactions_guard"
BEFORE UPDATE OR DELETE ON "ledger_transactions"
FOR EACH ROW EXECUTE FUNCTION lb_guard_ledger_transaction_update();

CREATE TRIGGER "tr_ledger_entries_immutable"
BEFORE UPDATE OR DELETE ON "ledger_entries"
FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();

-- -----------------------------------------------------------------------------
-- Solicitudes Cliente–Vendedor: transición y finalización única
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lb_guard_conversion_request_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Solicitud de conversión no eliminable' USING ERRCODE='55000'; END IF;
  IF ROW(NEW."client_user_id",NEW."amount_real_minor",NEW."amount_virtual_minor",NEW."expires_at",NEW."real_reservation_ledger_transaction_id",NEW."idempotency_key_id",NEW."created_at")
     IS DISTINCT FROM ROW(OLD."client_user_id",OLD."amount_real_minor",OLD."amount_virtual_minor",OLD."expires_at",OLD."real_reservation_ledger_transaction_id",OLD."idempotency_key_id",OLD."created_at") THEN
    RAISE EXCEPTION 'Datos base de la solicitud son inmutables' USING ERRCODE='55000';
  END IF;
  IF OLD."status" IN ('COMPLETADA_POR_VENDEDOR','COMPLETADA_POR_PLATAFORMA','FALLIDA_POR_LIQUIDEZ') THEN
    RAISE EXCEPTION 'Solicitud terminal no se modifica' USING ERRCODE='55000';
  END IF;
  IF NEW."status"<>OLD."status" AND NOT (
    (OLD."status"='PENDIENTE' AND NEW."status" IN ('EN_PROCESO','COMPLETADA_POR_PLATAFORMA','FALLIDA_POR_LIQUIDEZ')) OR
    (OLD."status"='EN_PROCESO' AND NEW."status" IN ('PENDIENTE','COMPLETADA_POR_VENDEDOR','COMPLETADA_POR_PLATAFORMA','FALLIDA_POR_LIQUIDEZ'))
  ) THEN
    RAISE EXCEPTION 'Transición de solicitud no permitida: % -> %',OLD."status",NEW."status" USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_conversion_requests_guard" BEFORE UPDATE OR DELETE ON "conversion_requests" FOR EACH ROW EXECUTE FUNCTION lb_guard_conversion_request_update();

CREATE OR REPLACE FUNCTION lb_guard_conversion_assignment_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Asignación de conversión no eliminable' USING ERRCODE='55000'; END IF;
  IF ROW(NEW."conversion_request_id",NEW."vendor_user_id",NEW."assigned_at",NEW."created_at")
     IS DISTINCT FROM ROW(OLD."conversion_request_id",OLD."vendor_user_id",OLD."assigned_at",OLD."created_at") THEN
    RAISE EXCEPTION 'Identidad de asignación inmutable' USING ERRCODE='55000';
  END IF;
  IF OLD."status"<>'ACTIVA' AND NEW."status"<>OLD."status" THEN
    RAISE EXCEPTION 'Asignación terminal no se reabre' USING ERRCODE='23514';
  END IF;
  IF NEW."status"<>OLD."status" AND NOT (OLD."status"='ACTIVA' AND NEW."status" IN ('LIBERADA','CONSUMIDA','CERRADA_SIN_EFECTO')) THEN
    RAISE EXCEPTION 'Transición de asignación no permitida' USING ERRCODE='23514';
  END IF;
  IF NEW."status"='LIBERADA' AND NEW."released_at" IS NULL THEN RAISE EXCEPTION 'Asignación liberada exige released_at' USING ERRCODE='23514'; END IF;
  IF NEW."status"='CONSUMIDA' AND NEW."consumed_at" IS NULL THEN RAISE EXCEPTION 'Asignación consumida exige consumed_at' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_conversion_assignments_guard" BEFORE UPDATE OR DELETE ON "conversion_assignments" FOR EACH ROW EXECUTE FUNCTION lb_guard_conversion_assignment_update();

-- -----------------------------------------------------------------------------
-- Evento oficial, combinación, reservas y compra
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lb_guard_draw_event_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Evento oficial no eliminable' USING ERRCODE='55000'; END IF;
  IF OLD."status" IN ('FINALIZADO','CANCELADO') THEN
    RAISE EXCEPTION 'Evento terminal no modificable' USING ERRCODE='55000';
  END IF;
  IF OLD."status" NOT IN ('BORRADOR','PROGRAMADO') AND
     ROW(NEW."lottery_product_id",NEW."rule_version_id",NEW."prize_rule_version_id",NEW."event_template_id",NEW."scheduled_slot_at",NEW."sales_open_at",NEW."sales_close_at",NEW."draw_at",NEW."limit_release_at",NEW."published_at")
     IS DISTINCT FROM
     ROW(OLD."lottery_product_id",OLD."rule_version_id",OLD."prize_rule_version_id",OLD."event_template_id",OLD."scheduled_slot_at",OLD."sales_open_at",OLD."sales_close_at",OLD."draw_at",OLD."limit_release_at",OLD."published_at") THEN
    RAISE EXCEPTION 'Evento publicado es inmutable' USING ERRCODE='55000';
  END IF;
  IF NEW."status" <> OLD."status" AND NOT (
    (OLD."status"='BORRADOR' AND NEW."status" IN ('PROGRAMADO','CANCELADO')) OR
    (OLD."status"='PROGRAMADO' AND NEW."status" IN ('PUBLICADO','CANCELADO')) OR
    (OLD."status"='PUBLICADO' AND NEW."status" IN ('VENTAS_ABIERTAS','CANCELADO')) OR
    (OLD."status"='VENTAS_ABIERTAS' AND NEW."status" IN ('VENTAS_CERRADAS','CANCELADO')) OR
    (OLD."status"='VENTAS_CERRADAS' AND NEW."status" IN ('CONGELADO','CANCELADO')) OR
    (OLD."status"='CONGELADO' AND NEW."status" IN ('RESULTADO_FIJADO','CANCELADO')) OR
    (OLD."status"='RESULTADO_FIJADO' AND NEW."status"='PREMIOS_CALCULADOS') OR
    (OLD."status"='PREMIOS_CALCULADOS' AND NEW."status"='INFORME_PUBLICADO') OR
    (OLD."status"='INFORME_PUBLICADO' AND NEW."status"='FINALIZADO')
  ) THEN RAISE EXCEPTION 'Transición de evento no permitida: % -> %',OLD."status",NEW."status" USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_draw_events_guard" BEFORE UPDATE OR DELETE ON "draw_events" FOR EACH ROW EXECUTE FUNCTION lb_guard_draw_event_update();

CREATE OR REPLACE FUNCTION lb_guard_combination_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Combinación no eliminable' USING ERRCODE='55000'; END IF;
  IF ROW(NEW."draw_event_id",NEW."normalized_key",NEW."created_at") IS DISTINCT FROM ROW(OLD."draw_event_id",OLD."normalized_key",OLD."created_at") THEN
    RAISE EXCEPTION 'Identidad de combinación inmutable' USING ERRCODE='55000';
  END IF;
  IF OLD."status"='VENDIDA' AND NEW."status"<>OLD."status" THEN RAISE EXCEPTION 'VENDIDA es terminal' USING ERRCODE='23514'; END IF;
  IF NEW."status"<>OLD."status" AND NOT (
    (OLD."status"='DISPONIBLE' AND NEW."status" IN ('RESERVADA','BLOQUEADA')) OR
    (OLD."status"='RESERVADA' AND NEW."status" IN ('VENDIDA','DISPONIBLE','BLOQUEADA')) OR
    (OLD."status"='BLOQUEADA' AND NEW."status"='DISPONIBLE')
  ) THEN RAISE EXCEPTION 'Transición de combinación no permitida' USING ERRCODE='23514'; END IF;
  IF OLD."status"='BLOQUEADA' AND NEW."status"='DISPONIBLE' AND EXISTS(SELECT 1 FROM "tickets" WHERE "combination_id"=OLD."id") THEN
    RAISE EXCEPTION 'No se desbloquea una combinación con boleto' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_event_combinations_guard" BEFORE UPDATE OR DELETE ON "event_combinations" FOR EACH ROW EXECUTE FUNCTION lb_guard_combination_update();

CREATE OR REPLACE FUNCTION lb_validate_reservation()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_close timestamptz; v_status draw_event_status;
BEGIN
  SELECT "sales_close_at","status" INTO v_close,v_status FROM "draw_events" WHERE "id"=NEW."draw_event_id";
  IF NEW."expires_at" <> least(NEW."reserved_at" + interval '5 minutes', v_close) THEN
    RAISE EXCEPTION 'Expiración de reserva inválida' USING ERRCODE='23514';
  END IF;
  IF NEW."status"='ACTIVA' AND (v_status<>'VENTAS_ABIERTAS' OR NEW."reserved_at">=v_close) THEN
    RAISE EXCEPTION 'Reserva activa fuera de ventana de ventas' USING ERRCODE='23514';
  END IF;
  IF TG_OP='UPDATE' AND NEW."status"<>OLD."status" AND NOT (OLD."status"='ACTIVA' AND NEW."status" IN ('CONSUMIDA','EXPIRADA','LIBERADA','INVALIDADA_POR_CIERRE','INVALIDADA_POR_CANCELACION')) THEN
    RAISE EXCEPTION 'Transición de reserva no permitida' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_combination_reservations_validate" BEFORE INSERT OR UPDATE ON "combination_reservations" FOR EACH ROW EXECUTE FUNCTION lb_validate_reservation();
CREATE TRIGGER "tr_combination_reservations_no_delete" BEFORE DELETE ON "combination_reservations" FOR EACH ROW EXECUTE FUNCTION lb_prevent_delete();

CREATE OR REPLACE FUNCTION lb_check_combination_consistency(p_combination_id uuid)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_status combination_status; v_active int; v_ticket int;
BEGIN
  SELECT "status" INTO v_status FROM "event_combinations" WHERE "id"=p_combination_id;
  IF NOT FOUND THEN RETURN; END IF;
  SELECT count(*) INTO v_active FROM "combination_reservations" WHERE "combination_id"=p_combination_id AND "status"='ACTIVA';
  SELECT count(*) INTO v_ticket FROM "tickets" WHERE "combination_id"=p_combination_id;
  IF v_ticket>0 AND v_status<>'VENDIDA' THEN RAISE EXCEPTION 'Boleto exige combinación VENDIDA' USING ERRCODE='23514'; END IF;
  IF v_status='VENDIDA' AND v_ticket<>1 THEN RAISE EXCEPTION 'Combinación VENDIDA exige un boleto' USING ERRCODE='23514'; END IF;
  IF v_active>0 AND v_status<>'RESERVADA' THEN RAISE EXCEPTION 'Reserva ACTIVA exige combinación RESERVADA' USING ERRCODE='23514'; END IF;
  IF v_status='RESERVADA' AND v_active<>1 THEN RAISE EXCEPTION 'Combinación RESERVADA exige una reserva ACTIVA' USING ERRCODE='23514'; END IF;
END
$$;

CREATE OR REPLACE FUNCTION lb_assert_child_combination_consistency()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM lb_check_combination_consistency(NEW."combination_id");
  RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION lb_assert_event_combination_consistency()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM lb_check_combination_consistency(NEW."id");
  RETURN NULL;
END
$$;

CREATE CONSTRAINT TRIGGER "ct_reservation_combination_consistency" AFTER INSERT OR UPDATE ON "combination_reservations" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_child_combination_consistency();
CREATE CONSTRAINT TRIGGER "ct_ticket_combination_consistency" AFTER INSERT OR UPDATE ON "tickets" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_child_combination_consistency();
CREATE CONSTRAINT TRIGGER "ct_event_combination_self_consistency" AFTER INSERT OR UPDATE ON "event_combinations" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_event_combination_consistency();

CREATE OR REPLACE FUNCTION lb_guard_ticket_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Boleto no eliminable' USING ERRCODE='55000'; END IF;
  IF ROW(NEW."public_id",NEW."purchase_order_id",NEW."user_id",NEW."draw_event_id",NEW."combination_id",NEW."rule_version_id",NEW."normalized_key",NEW."price_virtual_minor",NEW."purchase_ledger_transaction_id",NEW."purchased_at",NEW."created_at")
     IS DISTINCT FROM ROW(OLD."public_id",OLD."purchase_order_id",OLD."user_id",OLD."draw_event_id",OLD."combination_id",OLD."rule_version_id",OLD."normalized_key",OLD."price_virtual_minor",OLD."purchase_ledger_transaction_id",OLD."purchased_at",OLD."created_at") THEN
    RAISE EXCEPTION 'Datos económicos del boleto son inmutables' USING ERRCODE='55000';
  END IF;
  IF OLD."ownership_status"<>'ACTIVO' AND NEW."ownership_status"<>OLD."ownership_status" THEN RAISE EXCEPTION 'Estado de propiedad terminal' USING ERRCODE='23514'; END IF;
  IF OLD."evaluation_status"<>'PENDIENTE_RESULTADO' AND NEW."evaluation_status"<>OLD."evaluation_status" THEN RAISE EXCEPTION 'Evaluación terminal' USING ERRCODE='23514'; END IF;
  IF OLD."credit_status"='ACREDITADO' AND NEW."credit_status"<>OLD."credit_status" THEN RAISE EXCEPTION 'Acreditación terminal' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_tickets_guard" BEFORE UPDATE OR DELETE ON "tickets" FOR EACH ROW EXECUTE FUNCTION lb_guard_ticket_update();

-- -----------------------------------------------------------------------------
-- Sorteos creados por usuarios: estado, códigos, números, snapshot y escrow
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lb_guard_user_draw_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Sorteo de usuario no eliminable' USING ERRCODE='55000'; END IF;
  IF OLD."status" IN ('FINALIZADO','CANCELADO','CERRADO_POR_INCUMPLIMIENTO') THEN RAISE EXCEPTION 'Sorteo terminal no modificable' USING ERRCODE='55000'; END IF;
  IF OLD."first_payment_at" IS NOT NULL AND ROW(NEW."visibility",NEW."title",NEW."prize_description",NEW."price_virtual_minor",NEW."range_start",NEW."sales_open_at",NEW."sales_close_at") IS DISTINCT FROM ROW(OLD."visibility",OLD."title",OLD."prize_description",OLD."price_virtual_minor",OLD."range_start",OLD."sales_open_at",OLD."sales_close_at") THEN
    RAISE EXCEPTION 'Primer pago congela configuración del sorteo' USING ERRCODE='55000';
  END IF;
  IF NEW."status"<>OLD."status" AND NOT (
    (OLD."status"='BORRADOR' AND NEW."status" IN ('PUBLICADO','CANCELADO')) OR
    (OLD."status"='PUBLICADO' AND NEW."status" IN ('VENTAS_ABIERTAS','CANCELADO')) OR
    (OLD."status"='VENTAS_ABIERTAS' AND NEW."status" IN ('VENTAS_CERRADAS','CANCELADO')) OR
    (OLD."status"='VENTAS_CERRADAS' AND NEW."status" IN ('CONGELADO','CANCELADO')) OR
    (OLD."status"='CONGELADO' AND NEW."status" IN ('RESULTADO_FIJADO','CANCELADO')) OR
    (OLD."status"='RESULTADO_FIJADO' AND NEW."status"='ENTREGA_PENDIENTE') OR
    (OLD."status"='ENTREGA_PENDIENTE' AND NEW."status" IN ('FINALIZADO','CERRADO_POR_INCUMPLIMIENTO'))
  ) THEN RAISE EXCEPTION 'Transición de sorteo no permitida: % -> %',OLD."status",NEW."status" USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_user_draws_guard" BEFORE UPDATE OR DELETE ON "user_draws" FOR EACH ROW EXECUTE FUNCTION lb_guard_user_draw_update();

CREATE OR REPLACE FUNCTION lb_validate_user_draw_number()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_start int; v_end int;
BEGIN
  SELECT "range_start","range_end" INTO v_start,v_end FROM "user_draws" WHERE "id"=NEW."user_draw_id" FOR SHARE;
  IF NEW."number_value"<v_start OR NEW."number_value">v_end THEN RAISE EXCEPTION 'Número fuera del rango del sorteo' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_user_draw_numbers_range" BEFORE INSERT OR UPDATE OF "number_value","user_draw_id" ON "user_draw_numbers" FOR EACH ROW EXECUTE FUNCTION lb_validate_user_draw_number();
CREATE TRIGGER "tr_user_draw_numbers_no_delete" BEFORE DELETE ON "user_draw_numbers" FOR EACH ROW EXECUTE FUNCTION lb_prevent_delete();

CREATE OR REPLACE FUNCTION lb_validate_participation_number()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_pdraw uuid; v_ndraw uuid;
BEGIN
  SELECT "user_draw_id" INTO v_pdraw FROM "user_draw_participations" WHERE "id"=NEW."participation_id";
  SELECT "user_draw_id" INTO v_ndraw FROM "user_draw_numbers" WHERE "id"=NEW."number_id" FOR UPDATE;
  IF v_pdraw IS DISTINCT FROM v_ndraw THEN RAISE EXCEPTION 'Participación y número pertenecen a sorteos distintos' USING ERRCODE='23514'; END IF;
  IF NEW."status"='ACTIVA' AND EXISTS(
    SELECT 1 FROM "user_draw_access_code_numbers" cn JOIN "user_draw_access_codes" c ON c."id"=cn."access_code_id"
    WHERE cn."number_id"=NEW."number_id" AND c."reservation_status"='ACTIVA' AND c."use_status"='EMITIDO'
  ) THEN RAISE EXCEPTION 'Número reservado por código activo' USING ERRCODE='23514'; END IF;
  IF TG_OP='UPDATE' AND NEW."status"<>OLD."status" AND NOT (OLD."status"='ACTIVA' AND NEW."status" IN ('REEMPLAZADA','LIBERADA')) THEN RAISE EXCEPTION 'Transición de asignación no permitida' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_participation_numbers_validate" BEFORE INSERT OR UPDATE ON "user_draw_participation_numbers" FOR EACH ROW EXECUTE FUNCTION lb_validate_participation_number();
CREATE TRIGGER "tr_participation_numbers_no_delete" BEFORE DELETE ON "user_draw_participation_numbers" FOR EACH ROW EXECUTE FUNCTION lb_prevent_delete();

CREATE OR REPLACE FUNCTION lb_validate_access_code_number()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_cdraw uuid; v_ndraw uuid;
BEGIN
  SELECT "user_draw_id" INTO v_cdraw FROM "user_draw_access_codes" WHERE "id"=NEW."access_code_id" FOR SHARE;
  SELECT "user_draw_id" INTO v_ndraw FROM "user_draw_numbers" WHERE "id"=NEW."number_id" FOR UPDATE;
  IF v_cdraw IS DISTINCT FROM v_ndraw THEN RAISE EXCEPTION 'Código y número pertenecen a sorteos distintos' USING ERRCODE='23514'; END IF;
  IF EXISTS(SELECT 1 FROM "user_draw_participation_numbers" WHERE "number_id"=NEW."number_id" AND "status"='ACTIVA') THEN RAISE EXCEPTION 'Número ya asignado a una participación' USING ERRCODE='23514'; END IF;
  IF EXISTS(
    SELECT 1
    FROM "user_draw_access_code_numbers" other_cn
    JOIN "user_draw_access_codes" other_c ON other_c."id"=other_cn."access_code_id"
    WHERE other_cn."number_id"=NEW."number_id"
      AND other_cn."access_code_id"<>NEW."access_code_id"
      AND other_c."reservation_status"='ACTIVA'
      AND other_c."use_status"='EMITIDO'
  ) THEN RAISE EXCEPTION 'Número ya reservado por otro código activo' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_access_code_numbers_validate" BEFORE INSERT OR UPDATE ON "user_draw_access_code_numbers" FOR EACH ROW EXECUTE FUNCTION lb_validate_access_code_number();
CREATE TRIGGER "tr_access_code_numbers_no_delete" BEFORE DELETE ON "user_draw_access_code_numbers" FOR EACH ROW EXECUTE FUNCTION lb_prevent_delete();

CREATE OR REPLACE FUNCTION lb_validate_access_code()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_close timestamptz;
BEGIN
  SELECT "sales_close_at" INTO v_close FROM "user_draws" WHERE "id"=NEW."user_draw_id";
  IF NEW."expires_at">v_close THEN RAISE EXCEPTION 'Código no puede expirar después del cierre' USING ERRCODE='23514'; END IF;
  IF NEW."use_status"='RECLAMADO' AND (NEW."claimed_by_user_id" IS NULL OR NEW."claimed_at" IS NULL) THEN RAISE EXCEPTION 'Código reclamado exige cuenta y fecha' USING ERRCODE='23514'; END IF;
  IF TG_OP='UPDATE' AND OLD."use_status" IN ('RECLAMADO','EXPIRADO') AND NEW."use_status"<>OLD."use_status" THEN RAISE EXCEPTION 'Uso de código terminal' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_access_codes_validate" BEFORE INSERT OR UPDATE ON "user_draw_access_codes" FOR EACH ROW EXECUTE FUNCTION lb_validate_access_code();
CREATE TRIGGER "tr_access_codes_no_delete" BEFORE DELETE ON "user_draw_access_codes" FOR EACH ROW EXECUTE FUNCTION lb_prevent_delete();

CREATE OR REPLACE FUNCTION lb_check_user_draw_number_occupancy(p_number_id uuid)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_status number_assignment_status; v_participations int; v_codes int;
BEGIN
  SELECT "assignment_status" INTO v_status FROM "user_draw_numbers" WHERE "id"=p_number_id;
  IF NOT FOUND THEN RETURN; END IF;
  SELECT count(*) INTO v_participations FROM "user_draw_participation_numbers" WHERE "number_id"=p_number_id AND "status"='ACTIVA';
  SELECT count(*) INTO v_codes
  FROM "user_draw_access_code_numbers" cn
  JOIN "user_draw_access_codes" c ON c."id"=cn."access_code_id"
  WHERE cn."number_id"=p_number_id AND c."reservation_status"='ACTIVA' AND c."use_status"='EMITIDO';
  IF v_participations>1 OR v_codes>1 OR (v_participations>0 AND v_codes>0) THEN
    RAISE EXCEPTION 'Ocupación múltiple del número de sorteo %',p_number_id USING ERRCODE='23505';
  END IF;
  IF v_status='ASIGNADA' AND v_participations<>1 THEN RAISE EXCEPTION 'Número ASIGNADA exige una asignación activa' USING ERRCODE='23514'; END IF;
  IF v_status='RESERVADA' AND v_codes<>1 THEN RAISE EXCEPTION 'Número RESERVADA exige un código activo' USING ERRCODE='23514'; END IF;
  IF v_status IN ('LIBERADA','BLOQUEADA') AND (v_participations<>0 OR v_codes<>0) THEN RAISE EXCEPTION 'Número libre/bloqueado no puede estar ocupado' USING ERRCODE='23514'; END IF;
  IF v_participations=1 AND v_status<>'ASIGNADA' THEN RAISE EXCEPTION 'Asignación activa exige estado ASIGNADA' USING ERRCODE='23514'; END IF;
  IF v_codes=1 AND v_status<>'RESERVADA' THEN RAISE EXCEPTION 'Código activo exige estado RESERVADA' USING ERRCODE='23514'; END IF;
END
$$;

CREATE OR REPLACE FUNCTION lb_assert_participation_number_occupancy()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN PERFORM lb_check_user_draw_number_occupancy(NEW."number_id"); RETURN NULL; END
$$;
CREATE OR REPLACE FUNCTION lb_assert_access_code_number_occupancy()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN PERFORM lb_check_user_draw_number_occupancy(NEW."number_id"); RETURN NULL; END
$$;
CREATE OR REPLACE FUNCTION lb_assert_user_draw_number_occupancy()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN PERFORM lb_check_user_draw_number_occupancy(NEW."id"); RETURN NULL; END
$$;
CREATE OR REPLACE FUNCTION lb_assert_access_code_occupancy()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_number_id uuid;
BEGIN
  FOR v_number_id IN SELECT "number_id" FROM "user_draw_access_code_numbers" WHERE "access_code_id"=NEW."id" LOOP
    PERFORM lb_check_user_draw_number_occupancy(v_number_id);
  END LOOP;
  RETURN NULL;
END
$$;
CREATE CONSTRAINT TRIGGER "ct_participation_number_occupancy" AFTER INSERT OR UPDATE ON "user_draw_participation_numbers" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_participation_number_occupancy();
CREATE CONSTRAINT TRIGGER "ct_access_code_number_occupancy" AFTER INSERT OR UPDATE ON "user_draw_access_code_numbers" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_access_code_number_occupancy();
CREATE CONSTRAINT TRIGGER "ct_user_draw_number_occupancy" AFTER INSERT OR UPDATE ON "user_draw_numbers" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_user_draw_number_occupancy();
CREATE CONSTRAINT TRIGGER "ct_access_code_occupancy" AFTER INSERT OR UPDATE OF "use_status","reservation_status" ON "user_draw_access_codes" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_access_code_occupancy();

CREATE OR REPLACE FUNCTION lb_validate_user_draw_snapshot_entry()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_sdraw uuid; v_pdraw uuid; v_pay participation_payment_status; v_elig participation_eligibility_status; v_pn participation_number_status; v_num int;
BEGIN
  SELECT s."user_draw_id" INTO v_sdraw FROM "user_draw_snapshots" s WHERE s."id"=NEW."user_draw_snapshot_id";
  SELECT p."user_draw_id",p."payment_status",p."eligibility_status",pn."status",n."number_value"
    INTO v_pdraw,v_pay,v_elig,v_pn,v_num
  FROM "user_draw_participation_numbers" pn
  JOIN "user_draw_participations" p ON p."id"=pn."participation_id"
  JOIN "user_draw_numbers" n ON n."id"=pn."number_id"
  WHERE pn."id"=NEW."participation_number_id";
  IF v_sdraw IS DISTINCT FROM v_pdraw OR v_pay<>'PAGADO' OR v_elig<>'ACTIVA' OR v_pn<>'ACTIVA' OR NEW."number_value"<>v_num THEN
    RAISE EXCEPTION 'Entrada de snapshot de sorteo no elegible o inconsistente' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_user_draw_snapshot_entries_validate" BEFORE INSERT ON "user_draw_snapshot_entries" FOR EACH ROW EXECUTE FUNCTION lb_validate_user_draw_snapshot_entry();

CREATE OR REPLACE FUNCTION lb_validate_user_draw_result()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_sdraw uuid; v_entry_part uuid; v_entry_num int;
BEGIN
  SELECT "user_draw_id" INTO v_sdraw FROM "user_draw_snapshots" WHERE "id"=NEW."user_draw_snapshot_id";
  SELECT pn."participation_id",e."number_value" INTO v_entry_part,v_entry_num
  FROM "user_draw_snapshot_entries" e JOIN "user_draw_participation_numbers" pn ON pn."id"=e."participation_number_id"
  WHERE e."id"=NEW."winning_snapshot_entry_id" AND e."user_draw_snapshot_id"=NEW."user_draw_snapshot_id";
  IF v_sdraw IS DISTINCT FROM NEW."user_draw_id" OR v_entry_part IS DISTINCT FROM NEW."winning_participation_id" OR v_entry_num IS DISTINCT FROM NEW."winning_number_value" THEN
    RAISE EXCEPTION 'Resultado de sorteo no pertenece al snapshot' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_user_draw_results_validate" BEFORE INSERT ON "user_draw_results" FOR EACH ROW EXECUTE FUNCTION lb_validate_user_draw_result();

CREATE OR REPLACE FUNCTION lb_guard_escrow_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Escrow no eliminable' USING ERRCODE='55000'; END IF;
  IF OLD."status" IN ('LIBERADA','REEMBOLSADA') THEN RAISE EXCEPTION 'Escrow terminal no se reabre ni modifica' USING ERRCODE='55000'; END IF;
  IF NEW."status"<>OLD."status" AND NOT (
    (OLD."status"='RETENIDA' AND NEW."status" IN ('LIBERABLE','EN_DISPUTA','REEMBOLSO_ORDENADO')) OR
    (OLD."status"='EN_DISPUTA' AND NEW."status" IN ('LIBERABLE','REEMBOLSO_ORDENADO')) OR
    (OLD."status"='LIBERABLE' AND NEW."status"='LIBERANDO') OR
    (OLD."status"='LIBERANDO' AND NEW."status"='LIBERADA') OR
    (OLD."status"='REEMBOLSO_ORDENADO' AND NEW."status"='REEMBOLSANDO') OR
    (OLD."status"='REEMBOLSANDO' AND NEW."status"='REEMBOLSADA')
  ) THEN RAISE EXCEPTION 'Transición de escrow no permitida' USING ERRCODE='23514'; END IF;
  IF NEW."status"='LIBERADA' AND (NEW."released_virtual_minor"<>NEW."escrow_virtual_minor" OR NEW."release_ledger_transaction_id" IS NULL OR NEW."settled_at" IS NULL) THEN RAISE EXCEPTION 'Liquidación de escrow incompleta' USING ERRCODE='23514'; END IF;
  IF NEW."status"='REEMBOLSADA' AND (NEW."refunded_virtual_minor"<>NEW."gross_paid_virtual_minor" OR NEW."settled_at" IS NULL) THEN RAISE EXCEPTION 'Reembolso de escrow incompleto' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_user_draw_escrows_guard" BEFORE UPDATE OR DELETE ON "user_draw_escrows" FOR EACH ROW EXECUTE FUNCTION lb_guard_escrow_update();

-- -----------------------------------------------------------------------------
-- Coherencia diferida de snapshots
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lb_check_draw_snapshot_count(p_snapshot_id uuid)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_status snapshot_status; v_expected int; v_actual int;
BEGIN
  SELECT "status","ticket_count" INTO v_status,v_expected FROM "draw_snapshots" WHERE "id"=p_snapshot_id;
  IF NOT FOUND OR v_status='PENDIENTE' THEN RETURN; END IF;
  SELECT count(*) INTO v_actual FROM "draw_snapshot_tickets" WHERE "draw_snapshot_id"=p_snapshot_id;
  IF v_status='GENERADO' AND v_actual<>v_expected THEN
    RAISE EXCEPTION 'Snapshot oficial % declara % boletos y contiene %',p_snapshot_id,v_expected,v_actual USING ERRCODE='23514';
  END IF;
END
$$;
CREATE OR REPLACE FUNCTION lb_assert_draw_snapshot_entry_count()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM lb_check_draw_snapshot_count(NEW."draw_snapshot_id"); RETURN NULL;
END
$$;
CREATE OR REPLACE FUNCTION lb_assert_draw_snapshot_header_count()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM lb_check_draw_snapshot_count(NEW."id"); RETURN NULL;
END
$$;
CREATE CONSTRAINT TRIGGER "ct_draw_snapshot_ticket_count" AFTER INSERT ON "draw_snapshot_tickets" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_draw_snapshot_entry_count();
CREATE CONSTRAINT TRIGGER "ct_draw_snapshot_header_count" AFTER INSERT OR UPDATE ON "draw_snapshots" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_draw_snapshot_header_count();

CREATE OR REPLACE FUNCTION lb_check_user_draw_snapshot_count(p_snapshot_id uuid)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_expected int; v_actual int;
BEGIN
  SELECT "entry_count" INTO v_expected FROM "user_draw_snapshots" WHERE "id"=p_snapshot_id;
  IF NOT FOUND THEN RETURN; END IF;
  SELECT count(*) INTO v_actual FROM "user_draw_snapshot_entries" WHERE "user_draw_snapshot_id"=p_snapshot_id;
  IF v_actual<>v_expected THEN
    RAISE EXCEPTION 'Snapshot de sorteo % declara % entradas y contiene %',p_snapshot_id,v_expected,v_actual USING ERRCODE='23514';
  END IF;
END
$$;
CREATE OR REPLACE FUNCTION lb_assert_user_draw_snapshot_entry_count()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM lb_check_user_draw_snapshot_count(NEW."user_draw_snapshot_id"); RETURN NULL;
END
$$;
CREATE OR REPLACE FUNCTION lb_assert_user_draw_snapshot_header_count()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM lb_check_user_draw_snapshot_count(NEW."id"); RETURN NULL;
END
$$;
CREATE CONSTRAINT TRIGGER "ct_user_draw_snapshot_entry_count" AFTER INSERT ON "user_draw_snapshot_entries" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_user_draw_snapshot_entry_count();
CREATE CONSTRAINT TRIGGER "ct_user_draw_snapshot_header_count" AFTER INSERT ON "user_draw_snapshots" DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION lb_assert_user_draw_snapshot_header_count();

-- -----------------------------------------------------------------------------
-- Versiones, commitments, snapshots e informes
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION lb_guard_rule_version_update()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_is_used boolean;
BEGIN
  IF TG_OP='DELETE' THEN
    RAISE EXCEPTION 'Las versiones de reglas no se eliminan' USING ERRCODE='55000';
  END IF;
  SELECT EXISTS(
    SELECT 1 FROM "draw_events" WHERE "rule_version_id"=OLD."id"
    UNION ALL SELECT 1 FROM "tickets" WHERE "rule_version_id"=OLD."id"
    UNION ALL SELECT 1 FROM "event_templates" WHERE "rule_version_id"=OLD."id"
    UNION ALL SELECT 1 FROM "ledger_transactions" WHERE "rule_version_id"=OLD."id"
  ) INTO v_is_used;
  IF (v_is_used OR OLD."status"<>'DRAFT') AND ROW(
      NEW."lottery_product_id",NEW."version",NEW."selection_count",NEW."universe_symbols",
      NEW."total_combinations",NEW."order_matters",NEW."unique_symbols_required",
      NEW."purchase_limit_bps",NEW."limit_release_fraction_bps",NEW."reservation_seconds",
      NEW."close_before_draw_seconds",NEW."content_hash",NEW."created_at"
    ) IS DISTINCT FROM ROW(
      OLD."lottery_product_id",OLD."version",OLD."selection_count",OLD."universe_symbols",
      OLD."total_combinations",OLD."order_matters",OLD."unique_symbols_required",
      OLD."purchase_limit_bps",OLD."limit_release_fraction_bps",OLD."reservation_seconds",
      OLD."close_before_draw_seconds",OLD."content_hash",OLD."created_at"
    ) THEN
    RAISE EXCEPTION 'Una versión de reglas utilizada es inmutable' USING ERRCODE='55000';
  END IF;
  IF NEW."status"<>OLD."status" AND NOT (
    (OLD."status"='DRAFT' AND NEW."status" IN ('PUBLISHED','RETIRED')) OR
    (OLD."status"='PUBLISHED' AND NEW."status"='RETIRED')
  ) THEN
    RAISE EXCEPTION 'Transición de rule_version no permitida' USING ERRCODE='23514';
  END IF;
  IF NEW."status"='PUBLISHED' AND NEW."published_at" IS NULL THEN
    RAISE EXCEPTION 'Versión publicada exige published_at' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_rule_versions_guard" BEFORE UPDATE OR DELETE ON "rule_versions" FOR EACH ROW EXECUTE FUNCTION lb_guard_rule_version_update();

CREATE OR REPLACE FUNCTION lb_guard_prize_rule_version_update()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_is_used boolean;
BEGIN
  IF TG_OP='DELETE' THEN
    RAISE EXCEPTION 'Las versiones económicas no se eliminan' USING ERRCODE='55000';
  END IF;
  SELECT EXISTS(
    SELECT 1 FROM "draw_events" WHERE "prize_rule_version_id"=OLD."id"
    UNION ALL SELECT 1 FROM "event_templates" WHERE "prize_rule_version_id"=OLD."id"
  ) INTO v_is_used;
  IF (v_is_used OR OLD."status"<>'DRAFT') AND ROW(
      NEW."rule_version_id",NEW."version",NEW."initial_prize_multiplier_bps",
      NEW."growth_share_bps",NEW."operations_share_bps",NEW."no_winner_accumulation_bps",
      NEW."no_winner_guarantee_bps",NEW."no_winner_future_prize_bps",
      NEW."no_winner_operations_bps",NEW."rounding_policy",NEW."allocation_policy_code",
      NEW."content_hash",NEW."created_at"
    ) IS DISTINCT FROM ROW(
      OLD."rule_version_id",OLD."version",OLD."initial_prize_multiplier_bps",
      OLD."growth_share_bps",OLD."operations_share_bps",OLD."no_winner_accumulation_bps",
      OLD."no_winner_guarantee_bps",OLD."no_winner_future_prize_bps",
      OLD."no_winner_operations_bps",OLD."rounding_policy",OLD."allocation_policy_code",
      OLD."content_hash",OLD."created_at"
    ) THEN
    RAISE EXCEPTION 'Una versión económica utilizada es inmutable' USING ERRCODE='55000';
  END IF;
  IF NEW."status"<>OLD."status" AND NOT (
    (OLD."status"='DRAFT' AND NEW."status" IN ('PUBLISHED','RETIRED')) OR
    (OLD."status"='PUBLISHED' AND NEW."status"='RETIRED')
  ) THEN
    RAISE EXCEPTION 'Transición de prize_rule_version no permitida' USING ERRCODE='23514';
  END IF;
  IF NEW."status"='PUBLISHED' AND NEW."published_at" IS NULL THEN
    RAISE EXCEPTION 'Versión económica publicada exige published_at' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_prize_rule_versions_guard" BEFORE UPDATE OR DELETE ON "prize_rule_versions" FOR EACH ROW EXECUTE FUNCTION lb_guard_prize_rule_version_update();

CREATE OR REPLACE FUNCTION lb_guard_terms_version_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN
    RAISE EXCEPTION 'Las versiones de términos no se eliminan' USING ERRCODE='55000';
  END IF;
  IF EXISTS(SELECT 1 FROM "terms_acceptances" WHERE "terms_version_id"=OLD."id") AND
     ROW(NEW."document_type",NEW."version",NEW."content_hash",NEW."stored_object_id",NEW."effective_at",NEW."created_at")
     IS DISTINCT FROM
     ROW(OLD."document_type",OLD."version",OLD."content_hash",OLD."stored_object_id",OLD."effective_at",OLD."created_at") THEN
    RAISE EXCEPTION 'Una versión de términos aceptada es inmutable' USING ERRCODE='55000';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_terms_versions_guard" BEFORE UPDATE OR DELETE ON "terms_versions" FOR EACH ROW EXECUTE FUNCTION lb_guard_terms_version_update();

CREATE OR REPLACE FUNCTION lb_guard_draw_commitment_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Commitment no eliminable' USING ERRCODE='55000'; END IF;
  IF ROW(NEW."draw_event_id",NEW."algorithm_version",NEW."commitment_hash",NEW."encrypted_secret_seed",NEW."encryption_key_version",NEW."created_at")
     IS DISTINCT FROM
     ROW(OLD."draw_event_id",OLD."algorithm_version",OLD."commitment_hash",OLD."encrypted_secret_seed",OLD."encryption_key_version",OLD."created_at") THEN
    RAISE EXCEPTION 'Contenido criptográfico del commitment es inmutable' USING ERRCODE='55000';
  END IF;
  IF NEW."status"<>OLD."status" AND NOT (
    (OLD."status"='GENERADO_SECRETO' AND NEW."status" IN ('PUBLICADO','INVALIDADO_POR_CANCELACION')) OR
    (OLD."status"='PUBLICADO' AND NEW."status" IN ('REVELADO','INVALIDADO_POR_CANCELACION'))
  ) THEN RAISE EXCEPTION 'Transición de commitment no permitida' USING ERRCODE='23514'; END IF;
  IF NEW."status"='PUBLICADO' AND NEW."published_at" IS NULL THEN RAISE EXCEPTION 'Commitment publicado exige fecha' USING ERRCODE='23514'; END IF;
  IF NEW."status"='REVELADO' AND (NEW."revealed_seed" IS NULL OR NEW."revealed_at" IS NULL) THEN RAISE EXCEPTION 'Commitment revelado exige semilla y fecha' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_draw_commitments_guard" BEFORE UPDATE OR DELETE ON "draw_commitments" FOR EACH ROW EXECUTE FUNCTION lb_guard_draw_commitment_update();

CREATE OR REPLACE FUNCTION lb_guard_draw_snapshot_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Snapshot oficial no eliminable' USING ERRCODE='55000'; END IF;
  IF ROW(NEW."draw_event_id",NEW."ticket_count",NEW."serialization_version",NEW."created_at")
     IS DISTINCT FROM ROW(OLD."draw_event_id",OLD."ticket_count",OLD."serialization_version",OLD."created_at") THEN
    RAISE EXCEPTION 'Identidad y conteo del snapshot son inmutables' USING ERRCODE='55000';
  END IF;
  IF OLD."status" IN ('GENERADO','INVALIDADO_POR_CANCELACION') THEN
    RAISE EXCEPTION 'Snapshot terminal no modificable' USING ERRCODE='55000';
  END IF;
  IF NEW."status"<>OLD."status" AND NOT (OLD."status"='PENDIENTE' AND NEW."status" IN ('GENERADO','INVALIDADO_POR_CANCELACION')) THEN
    RAISE EXCEPTION 'Transición de snapshot no permitida' USING ERRCODE='23514';
  END IF;
  IF NEW."status"='GENERADO' AND (NEW."snapshot_hash" IS NULL OR NEW."generated_at" IS NULL) THEN
    RAISE EXCEPTION 'Snapshot generado exige hash y fecha' USING ERRCODE='23514';
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_draw_snapshots_guard" BEFORE UPDATE OR DELETE ON "draw_snapshots" FOR EACH ROW EXECUTE FUNCTION lb_guard_draw_snapshot_update();

CREATE TRIGGER "tr_user_draw_snapshots_immutable" BEFORE UPDATE OR DELETE ON "user_draw_snapshots" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();

CREATE OR REPLACE FUNCTION lb_validate_result_report_supersession()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_prior_draw uuid; v_prior_version int;
BEGIN
  IF NEW."supersedes_report_id" IS NOT NULL THEN
    SELECT "draw_event_id","report_version" INTO v_prior_draw,v_prior_version
    FROM "result_reports" WHERE "id"=NEW."supersedes_report_id" FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Informe reemplazado inexistente' USING ERRCODE='23503'; END IF;
    IF v_prior_draw IS DISTINCT FROM NEW."draw_event_id" OR v_prior_version>=NEW."report_version" THEN
      RAISE EXCEPTION 'La cadena de versiones del informe es inválida' USING ERRCODE='23514';
    END IF;
  END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_result_reports_supersession" BEFORE INSERT OR UPDATE OF "supersedes_report_id","draw_event_id","report_version" ON "result_reports" FOR EACH ROW EXECUTE FUNCTION lb_validate_result_report_supersession();

CREATE OR REPLACE FUNCTION lb_guard_result_report_update()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Informe de resultado no eliminable' USING ERRCODE='55000'; END IF;
  IF OLD."status" IN ('PUBLICADO','SUPERSEDED') THEN
    IF ROW(NEW."draw_event_id",NEW."draw_result_id",NEW."report_version",NEW."supersedes_report_id",NEW."public_payload",NEW."report_hash",NEW."json_object_id",NEW."pdf_object_id",NEW."image_object_id",NEW."published_at",NEW."created_at")
       IS DISTINCT FROM
       ROW(OLD."draw_event_id",OLD."draw_result_id",OLD."report_version",OLD."supersedes_report_id",OLD."public_payload",OLD."report_hash",OLD."json_object_id",OLD."pdf_object_id",OLD."image_object_id",OLD."published_at",OLD."created_at") THEN
      RAISE EXCEPTION 'Contenido de informe publicado es inmutable' USING ERRCODE='55000';
    END IF;
  END IF;
  IF NEW."status"<>OLD."status" AND NOT (
    (OLD."status"='PENDIENTE' AND NEW."status" IN ('PREPARADO','ERROR_REINTENTABLE','REVISION_MANUAL')) OR
    (OLD."status"='PREPARADO' AND NEW."status" IN ('PUBLICADO','ERROR_REINTENTABLE','REVISION_MANUAL')) OR
    (OLD."status"='ERROR_REINTENTABLE' AND NEW."status" IN ('PREPARADO','REVISION_MANUAL')) OR
    (OLD."status"='REVISION_MANUAL' AND NEW."status"='PREPARADO') OR
    (OLD."status"='PUBLICADO' AND NEW."status"='SUPERSEDED')
  ) THEN RAISE EXCEPTION 'Transición de informe no permitida' USING ERRCODE='23514'; END IF;
  IF NEW."status"='PUBLICADO' AND NEW."published_at" IS NULL THEN RAISE EXCEPTION 'Informe publicado exige published_at' USING ERRCODE='23514'; END IF;
  IF NEW."status"='SUPERSEDED' AND NEW."superseded_at" IS NULL THEN RAISE EXCEPTION 'Informe reemplazado exige superseded_at' USING ERRCODE='23514'; END IF;
  RETURN NEW;
END
$$;
CREATE TRIGGER "tr_result_reports_guard" BEFORE UPDATE OR DELETE ON "result_reports" FOR EACH ROW EXECUTE FUNCTION lb_guard_result_report_update();

-- -----------------------------------------------------------------------------
-- Tablas append-only o completamente inmutables
-- -----------------------------------------------------------------------------
CREATE TRIGGER "tr_audit_events_immutable" BEFORE UPDATE OR DELETE ON "audit_events" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_draw_results_immutable" BEFORE UPDATE OR DELETE ON "draw_results" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_draw_result_numbers_immutable" BEFORE UPDATE OR DELETE ON "draw_result_numbers" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_draw_snapshot_tickets_immutable" BEFORE UPDATE OR DELETE ON "draw_snapshot_tickets" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_ticket_evaluations_immutable" BEFORE UPDATE OR DELETE ON "ticket_evaluations" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_prize_awards_immutable" BEFORE UPDATE OR DELETE ON "prize_awards" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_user_draw_results_immutable" BEFORE UPDATE OR DELETE ON "user_draw_results" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_user_draw_snapshot_entries_immutable" BEFORE UPDATE OR DELETE ON "user_draw_snapshot_entries" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_draw_event_history_immutable" BEFORE UPDATE OR DELETE ON "draw_event_status_history" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_ticket_history_immutable" BEFORE UPDATE OR DELETE ON "ticket_status_history" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_conversion_request_history_immutable" BEFORE UPDATE OR DELETE ON "conversion_request_events" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_user_draw_history_immutable" BEFORE UPDATE OR DELETE ON "user_draw_status_history" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_participation_history_immutable" BEFORE UPDATE OR DELETE ON "user_draw_participation_events" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_code_history_immutable" BEFORE UPDATE OR DELETE ON "user_draw_access_code_events" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_claim_history_immutable" BEFORE UPDATE OR DELETE ON "user_draw_claim_events" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();
CREATE TRIGGER "tr_escrow_history_immutable" BEFORE UPDATE OR DELETE ON "user_draw_escrow_events" FOR EACH ROW EXECUTE FUNCTION lb_prevent_update_or_delete();

-- -----------------------------------------------------------------------------
-- Sellado de updated_at desde PostgreSQL
-- -----------------------------------------------------------------------------
-- Prisma @updatedAt cubre escrituras realizadas por Prisma Client. Estos triggers
-- conservan la misma garantía cuando una migración, job o intervención SQL
-- autorizada modifica una tabla directamente. La hora proviene del servidor.

CREATE OR REPLACE FUNCTION lb_touch_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW."updated_at" := clock_timestamp();
  RETURN NEW;
END
$$;

CREATE TRIGGER "tr_accumulation_pools_touch_updated_at" BEFORE UPDATE ON "accumulation_pools" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_accumulation_transfers_touch_updated_at" BEFORE UPDATE ON "accumulation_transfers" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_award_payment_orders_touch_updated_at" BEFORE UPDATE ON "award_payment_orders" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_conversion_requests_touch_updated_at" BEFORE UPDATE ON "conversion_requests" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_devices_touch_updated_at" BEFORE UPDATE ON "devices" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_draw_commitments_touch_updated_at" BEFORE UPDATE ON "draw_commitments" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_draw_events_touch_updated_at" BEFORE UPDATE ON "draw_events" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_draw_snapshots_touch_updated_at" BEFORE UPDATE ON "draw_snapshots" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_event_combinations_touch_updated_at" BEFORE UPDATE ON "event_combinations" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_event_financial_configs_touch_updated_at" BEFORE UPDATE ON "event_financial_configs" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_event_financial_projections_touch_updated_at" BEFORE UPDATE ON "event_financial_projections" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_event_templates_touch_updated_at" BEFORE UPDATE ON "event_templates" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_future_prize_fund_touch_updated_at" BEFORE UPDATE ON "future_prize_fund" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_guarantee_fund_touch_updated_at" BEFORE UPDATE ON "guarantee_fund" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_guarantee_fund_reservations_touch_updated_at" BEFORE UPDATE ON "guarantee_fund_reservations" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_idempotency_keys_touch_updated_at" BEFORE UPDATE ON "idempotency_keys" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_inbox_events_touch_updated_at" BEFORE UPDATE ON "inbox_events" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_ledger_accounts_touch_updated_at" BEFORE UPDATE ON "ledger_accounts" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_lottery_products_touch_updated_at" BEFORE UPDATE ON "lottery_products" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_notification_preferences_touch_updated_at" BEFORE UPDATE ON "notification_preferences" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_notifications_touch_updated_at" BEFORE UPDATE ON "notifications" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_outbox_events_touch_updated_at" BEFORE UPDATE ON "outbox_events" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_permissions_touch_updated_at" BEFORE UPDATE ON "permissions" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_prize_rule_versions_touch_updated_at" BEFORE UPDATE ON "prize_rule_versions" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_purchase_orders_touch_updated_at" BEFORE UPDATE ON "purchase_orders" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_purchase_sessions_touch_updated_at" BEFORE UPDATE ON "purchase_sessions" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_real_topups_touch_updated_at" BEFORE UPDATE ON "real_topups" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_related_account_flags_touch_updated_at" BEFORE UPDATE ON "related_account_flags" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_result_reports_touch_updated_at" BEFORE UPDATE ON "result_reports" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_roles_touch_updated_at" BEFORE UPDATE ON "roles" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_rule_versions_touch_updated_at" BEFORE UPDATE ON "rule_versions" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_scheduled_jobs_touch_updated_at" BEFORE UPDATE ON "scheduled_jobs" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_security_events_touch_updated_at" BEFORE UPDATE ON "security_events" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_sessions_touch_updated_at" BEFORE UPDATE ON "sessions" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_shopping_carts_touch_updated_at" BEFORE UPDATE ON "shopping_carts" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_stored_objects_touch_updated_at" BEFORE UPDATE ON "stored_objects" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_system_settings_touch_updated_at" BEFORE UPDATE ON "system_settings" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_template_schedules_touch_updated_at" BEFORE UPDATE ON "template_schedules" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_access_codes_touch_updated_at" BEFORE UPDATE ON "user_draw_access_codes" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_announcements_touch_updated_at" BEFORE UPDATE ON "user_draw_announcements" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_claims_touch_updated_at" BEFORE UPDATE ON "user_draw_claims" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_delivery_records_touch_updated_at" BEFORE UPDATE ON "user_draw_delivery_records" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_escrows_touch_updated_at" BEFORE UPDATE ON "user_draw_escrows" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_invitations_touch_updated_at" BEFORE UPDATE ON "user_draw_invitations" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_number_changes_touch_updated_at" BEFORE UPDATE ON "user_draw_number_changes" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_numbers_touch_updated_at" BEFORE UPDATE ON "user_draw_numbers" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_participation_numbers_touch_updated_at" BEFORE UPDATE ON "user_draw_participation_numbers" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_participations_touch_updated_at" BEFORE UPDATE ON "user_draw_participations" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draw_prize_evidence_touch_updated_at" BEFORE UPDATE ON "user_draw_prize_evidence" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_draws_touch_updated_at" BEFORE UPDATE ON "user_draws" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_user_profiles_touch_updated_at" BEFORE UPDATE ON "user_profiles" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_users_touch_updated_at" BEFORE UPDATE ON "users" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_vendor_inventory_batches_touch_updated_at" BEFORE UPDATE ON "vendor_inventory_batches" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_vendor_profiles_touch_updated_at" BEFORE UPDATE ON "vendor_profiles" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_vendor_purchase_orders_touch_updated_at" BEFORE UPDATE ON "vendor_purchase_orders" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_virtual_to_real_conversions_touch_updated_at" BEFORE UPDATE ON "virtual_to_real_conversions" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_virtual_transfers_touch_updated_at" BEFORE UPDATE ON "virtual_transfers" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_wallet_balance_projections_touch_updated_at" BEFORE UPDATE ON "wallet_balance_projections" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_wallets_touch_updated_at" BEFORE UPDATE ON "wallets" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();
CREATE TRIGGER "tr_withdrawal_requests_touch_updated_at" BEFORE UPDATE ON "withdrawal_requests" FOR EACH ROW EXECUTE FUNCTION lb_touch_updated_at();

-- -----------------------------------------------------------------------------
-- Vistas reconstruibles; no sustituyen al ledger ni a las tablas históricas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW "v_ledger_trial_balance" AS
SELECT e."ledger_transaction_id", e."currency",
       sum(CASE WHEN e."side"='DEBIT' THEN e."amount_minor" ELSE 0 END)::bigint AS debit_minor,
       sum(CASE WHEN e."side"='CREDIT' THEN e."amount_minor" ELSE 0 END)::bigint AS credit_minor,
       sum(CASE WHEN e."side"='DEBIT' THEN e."amount_minor" ELSE -e."amount_minor" END)::bigint AS difference_minor,
       count(*)::bigint AS entry_count
FROM "ledger_entries" e
GROUP BY e."ledger_transaction_id", e."currency";

CREATE OR REPLACE VIEW "v_wallet_balances" AS
SELECT w."id" AS wallet_id,w."user_id",w."currency",
       coalesce(sum(CASE WHEN e."side"='CREDIT' THEN e."amount_minor" ELSE -e."amount_minor" END),0)::bigint AS total_minor,
       p."available_minor",p."reserved_minor",p."pending_minor",p."blocked_minor",p."in_withdrawal_minor",p."ledger_version",p."calculated_at"
FROM "wallets" w
LEFT JOIN "ledger_accounts" a ON a."wallet_id"=w."id"
LEFT JOIN "ledger_entries" e ON e."account_id"=a."id"
LEFT JOIN "wallet_balance_projections" p ON p."wallet_id"=w."id"
GROUP BY w."id",w."user_id",w."currency",p."available_minor",p."reserved_minor",p."pending_minor",p."blocked_minor",p."in_withdrawal_minor",p."ledger_version",p."calculated_at";

CREATE OR REPLACE VIEW "v_vendor_inventory" AS
SELECT b."vendor_user_id",b."id" AS inventory_batch_id,b."purchase_order_id",b."status",b."virtual_acquired_minor",b."virtual_remaining_minor",b."real_cost_minor",b."acquired_at"
FROM "vendor_inventory_batches" b;

CREATE OR REPLACE VIEW "v_vendor_realized_profit" AS
SELECT s."vendor_user_id",sum(s."virtual_sold_minor")::bigint AS virtual_sold_minor,sum(s."real_received_minor")::bigint AS real_received_minor,sum(s."allocated_real_cost_minor")::bigint AS allocated_real_cost_minor,sum(s."realized_profit_minor")::bigint AS realized_profit_minor
FROM "vendor_sales" s GROUP BY s."vendor_user_id";

CREATE OR REPLACE VIEW "v_event_availability" AS
SELECT c."draw_event_id",
       count(*) FILTER (WHERE c."status"='DISPONIBLE')::bigint AS available_count,
       count(*) FILTER (WHERE c."status"='RESERVADA')::bigint AS reserved_count,
       count(*) FILTER (WHERE c."status"='VENDIDA')::bigint AS sold_count,
       count(*) FILTER (WHERE c."status"='BLOQUEADA')::bigint AS blocked_count,
       (count(*) FILTER (WHERE c."status"='DISPONIBLE')=0) AS is_sold_out
FROM "event_combinations" c GROUP BY c."draw_event_id";

CREATE OR REPLACE VIEW "v_client_event_limit" AS
SELECT u."user_id",u."draw_event_id",sum(u."units")::bigint AS committed_units
FROM (
  SELECT t."user_id",t."draw_event_id",count(*)::bigint AS units FROM "tickets" t GROUP BY t."user_id",t."draw_event_id"
  UNION ALL
  SELECT r."user_id",r."draw_event_id",count(*)::bigint AS units FROM "combination_reservations" r WHERE r."status"='ACTIVA' GROUP BY r."user_id",r."draw_event_id"
) u GROUP BY u."user_id",u."draw_event_id";

CREATE OR REPLACE VIEW "v_event_financial_position" AS
SELECT e."id" AS draw_event_id,e."status",c."ticket_price_virtual_minor",c."initial_major_prize_virtual_minor",c."major_prize_ceiling_virtual_minor",c."minimum_capital_virtual_minor",c."guarantee_required_virtual_minor",p."sales_virtual_minor",p."refund_liability_virtual_minor",p."guarantee_recovery_pending_minor",p."growth_virtual_minor",p."accumulation_extra_virtual_minor",p."current_major_prize_virtual_minor",p."ledger_version",p."calculated_at"
FROM "draw_events" e LEFT JOIN "event_financial_configs" c ON c."draw_event_id"=e."id" LEFT JOIN "event_financial_projections" p ON p."draw_event_id"=e."id";

CREATE OR REPLACE VIEW "v_public_result_reports" AS
SELECT r."id",r."draw_event_id",r."draw_result_id",r."report_version",r."public_payload",r."report_hash",r."published_at"
FROM "result_reports" r WHERE r."status"='PUBLICADO';

CREATE OR REPLACE VIEW "v_user_draw_participant_history" AS
SELECT p."id" AS participation_id,p."user_draw_id",p."participant_user_id",p."payment_status",p."relation_status",p."eligibility_status",p."price_virtual_minor",pn."id" AS participation_number_id,n."number_value",pn."status" AS number_status,pn."assigned_at",pn."replaced_at",pn."released_at"
FROM "user_draw_participations" p LEFT JOIN "user_draw_participation_numbers" pn ON pn."participation_id"=p."id" LEFT JOIN "user_draw_numbers" n ON n."id"=pn."number_id";

CREATE OR REPLACE VIEW "v_user_draw_escrow_position" AS
SELECT e."user_draw_id",e."status",e."gross_paid_virtual_minor",e."commission_held_virtual_minor",e."escrow_virtual_minor",e."released_virtual_minor",e."refunded_virtual_minor",e."settled_at"
FROM "user_draw_escrows" e;

COMMIT;