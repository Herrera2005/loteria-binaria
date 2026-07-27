import { v7 as uuidv7 } from "uuid";

/**
 * Genera un UUID versión 7.
 *
 * UUIDv7 incorpora la marca temporal, por lo que los identificadores
 * quedan aproximadamente ordenados por fecha de creación.
 */
export function generateUuidV7(): string {
  return uuidv7();
}
