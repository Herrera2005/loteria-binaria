export type GameEngineErrorCode =
  | 'UNKNOWN_GAME'
  | 'INVALID_SELECTION_INPUT'
  | 'INVALID_SELECTION'
  | 'INVALID_PARTIAL_SELECTION'
  | 'INVALID_COMBINATION_ARGUMENTS'
  | 'INVALID_WINDOW'
  | 'INVALID_RANDOM_INDEX';

export class GameEngineError extends Error {
  public constructor(
    public readonly code: GameEngineErrorCode,
    message: string,
    public readonly details?: Readonly<Record<string, unknown>>,
  ) {
    super(message);
    this.name = 'GameEngineError';
    Object.setPrototypeOf(this, new.target.prototype);
  }
}
