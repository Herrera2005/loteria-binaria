export const OFFICIAL_GAMES = ['OCTAL', 'DECIMAL', 'HEXADECIMAL'] as const;
export type OfficialGame = (typeof OFFICIAL_GAMES)[number];

export interface GameDefinition {
  readonly game: OfficialGame;
  readonly selectionCount: number;
  readonly universe: readonly string[];
}

export type SelectionValidationCode =
  | 'WRONG_COUNT'
  | 'DUPLICATE_SYMBOL'
  | 'SYMBOL_OUT_OF_UNIVERSE';

export interface SelectionValidationIssue {
  readonly code: SelectionValidationCode;
  readonly message: string;
  readonly symbol?: string;
}

export type SelectionValidation =
  | {
      readonly valid: true;
      readonly symbols: readonly string[];
    }
  | {
      readonly valid: false;
      readonly symbols: readonly string[];
      readonly issues: readonly SelectionValidationIssue[];
    };

export interface ResultComparison {
  readonly exactMatch: boolean;
  readonly nearMatch: boolean;
  readonly matches: number;
  readonly distance: number;
}

export type SelectionMode =
  | 'RANDOM_COMPLETE'
  | 'PARTIAL_LIST'
  | 'PARTIAL_RANDOM_COMPLETE'
  | 'COMPLETE';

interface SelectionModeBase {
  readonly game: OfficialGame;
  readonly availableSelections: readonly (string | readonly string[])[];
}

export type ResolveSelectionModeInput =
  | (SelectionModeBase & {
      readonly mode: 'RANDOM_COMPLETE';
      readonly randomIndex: number;
    })
  | (SelectionModeBase & {
      readonly mode: 'PARTIAL_LIST';
      readonly partialSymbols: string | readonly string[];
    })
  | (SelectionModeBase & {
      readonly mode: 'PARTIAL_RANDOM_COMPLETE';
      readonly partialSymbols: string | readonly string[];
      readonly randomIndex: number;
    })
  | (SelectionModeBase & {
      readonly mode: 'COMPLETE';
      readonly requestedSelection: string | readonly string[];
    });

export interface LimitReleaseCalculation {
  readonly rawEightyPercentAt: Date;
  readonly roundedCandidateAt: Date;
  readonly releaseAt: Date;
}
