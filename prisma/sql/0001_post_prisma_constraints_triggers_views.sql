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