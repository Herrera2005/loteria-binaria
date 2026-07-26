import * as Joi from 'joi';

export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string().valid('development', 'test', 'production').required(),

  API_PORT: Joi.number().integer().min(1).max(65535).required(),

  DATABASE_URL: Joi.string()
    .uri({
      scheme: ['postgresql', 'postgres'],
    })
    .required(),

  REDIS_URL: Joi.string()
    .uri({
      scheme: ['redis', 'rediss'],
    })
    .required(),

  ACCESS_TOKEN_SECRET: Joi.string().min(32).required(),

  REFRESH_TOKEN_SECRET: Joi.string().min(32).required(),

  PASSWORD_PEPPER: Joi.string().min(32).required(),

  CORS_ALLOWED_ORIGINS: Joi.string().min(1).required(),
});
