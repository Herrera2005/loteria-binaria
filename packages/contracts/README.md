# @loteria-binaria/contracts

Reservado para contratos públicos y estables:

- DTO y respuestas públicas;
- errores públicos;
- paginación;
- tipos de eventos;
- contratos compartidos por API, web y mobile.

No debe contener entidades Prisma, servicios NestJS, secretos, objetos `Date`
sin serializar ni `bigint` directo en JSON. Los montos de transporte deberán
serializarse de forma explícita, por ejemplo como cadenas de minor units.
