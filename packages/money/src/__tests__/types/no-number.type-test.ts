import { addMoney, money } from '../../index.js';

money('REAL', 100n);

// @ts-expect-error El dinero nunca debe entrar como number.
money('REAL', 100);

// @ts-expect-error REAL y VIRTUAL no pueden mezclarse.
addMoney(money('REAL', 100n), money('VIRTUAL', 100n));
