import {
  Prisma,
  type PrismaClient,
} from "../../../apps/api/src/generated/prisma/client";

import { generateUuidV7 } from "../helpers/generate-uuid-v7";

interface SystemSettingDefinition {
  settingKey: string;
  valueJson: Prisma.InputJsonValue;
  valueType:
  | "integer"
  | "boolean"
  | "string"
  | "object";
  isSensitive: boolean;
  description: string;
}

const SYSTEM_SETTING_DEFINITIONS:
  readonly SystemSettingDefinition[] = [
    {
      settingKey:
        "draw.reveal_seconds_per_symbol",
      valueJson: 10,
      valueType: "integer",
      isSensitive: false,
      description:
        "Duración visual en segundos de la revelación de cada símbolo ganador.",
    },
    {
      settingKey:
        "draw.animation_skippable",
      valueJson: true,
      valueType: "boolean",
      isSensitive: false,
      description:
        "Permite omitir la animación sin alterar el resultado fijado.",
    },
    {
      settingKey:
        "conversion.platform_fallback_enabled",
      valueJson: true,
      valueType: "boolean",
      isSensitive: false,
      description:
        "Habilita la finalización de respaldo mediante la wallet general.",
    },
    {
      settingKey:
        "conversion.platform_fallback_seconds",
      valueJson: 300,
      valueType: "integer",
      isSensitive: false,
      description:
        "Tiempo máximo antes de intentar la conversión de respaldo de plataforma.",
    },
    {
      settingKey:
        "purchase.maximum_cart_items",
      valueJson: 5,
      valueType: "integer",
      isSensitive: false,
      description:
        "Cantidad máxima operativa de combinaciones reservadas en un carrito.",
    },
    {
      settingKey:
        "security.demo_users_enabled",
      valueJson: false,
      valueType: "boolean",
      isSensitive: false,
      description:
        "Indica si el entorno permite usuarios de demostración. El entorno sigue siendo la autoridad final.",
    },
    {
      settingKey:
        "notifications.email_enabled",
      valueJson: false,
      valueType: "boolean",
      isSensitive: false,
      description:
        "Indica si el canal de correo está habilitado operativamente.",
    },
    {
      settingKey:
        "storage.object_service_enabled",
      valueJson: false,
      valueType: "boolean",
      isSensitive: false,
      description:
        "Indica si el almacenamiento de objetos está habilitado.",
    },
  ];

function assertUniqueSettingKeys(): void {
  const keys = SYSTEM_SETTING_DEFINITIONS.map(
    (setting) => setting.settingKey,
  );

  if (new Set(keys).size !== keys.length) {
    throw new Error(
      "Existen setting_key duplicados en el catálogo.",
    );
  }
}

export async function seedSystemSettings(
  prisma: PrismaClient,
): Promise<void> {
  console.info(
    "[seed:system-settings] Iniciando...",
  );

  assertUniqueSettingKeys();

  for (
    const definition
    of SYSTEM_SETTING_DEFINITIONS
  ) {
    const existing =
      await prisma.systemSettings.findUnique({
        where: {
          setting_key:
            definition.settingKey,
        },
      });

    if (!existing) {
      await prisma.systemSettings.create({
        data: {
          id: generateUuidV7(),
          setting_key:
            definition.settingKey,
          value_json:
            definition.valueJson,
          value_type:
            definition.valueType,
          is_sensitive:
            definition.isSensitive,
          updated_by_user_id: null,
          description:
            definition.description,
        },
      });

      continue;
    }

    if (
      existing.value_type !==
      definition.valueType
    ) {
      throw new Error(
        `La configuración ${definition.settingKey} tiene value_type incorrecto.`,
      );
    }

    if (
      existing.is_sensitive !==
      definition.isSensitive
    ) {
      throw new Error(
        `La configuración ${definition.settingKey} tiene is_sensitive incorrecto.`,
      );
    }

  }

  console.info(
    `[seed:system-settings] ${SYSTEM_SETTING_DEFINITIONS.length} configuraciones verificadas.`,
  );
}
