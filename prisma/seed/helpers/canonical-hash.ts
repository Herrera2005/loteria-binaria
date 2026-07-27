import { createHash } from "node:crypto";

function sortValue(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(sortValue);
  }

  if (
    value !== null &&
    typeof value === "object"
  ) {
    return Object.fromEntries(
      Object.entries(
        value as Record<string, unknown>,
      )
        .sort(([left], [right]) =>
          left.localeCompare(right),
        )
        .map(([key, nestedValue]) => [
          key,
          sortValue(nestedValue),
        ]),
    );
  }

  return value;
}

export function createCanonicalHash(
  value: unknown,
): string {
  const canonicalValue = sortValue(value);
  const serialized = JSON.stringify(canonicalValue);

  return createHash("sha256")
    .update(serialized, "utf8")
    .digest("hex");
}
