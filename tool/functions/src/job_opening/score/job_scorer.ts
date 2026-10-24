import { createHash } from 'node:crypto';

import { type GenerateJson, geminiModel } from '../../shared/gemini.js';
import type { Region } from '../match/region_filter.js';
import type {
  JobFit,
  MatchedJobOpening,
  PortfolioProfile,
} from '../job_opening.js';
import {
  jobFitInstruction,
  jobFitPrompt,
  jobFitSchema,
  parseJobFit,
} from './job_fit.js';

// Leaves room for the model's thinking tokens, which count towards the limit.
const maxOutputTokens = 4096;

// Weighing a job against the portfolio benefits from some reasoning.
const thinkingBudget = 1024;

export interface JobScorer {
  /** The fit of [opening] for a candidate who can work from [regions]. */
  score(
    opening: MatchedJobOpening,
    profile: PortfolioProfile,
    regions: ReadonlySet<Region>,
  ): Promise<JobFit>;
  /**
   * The same for two calls of [score] that send the same request, so a fit
   * from an earlier run can stand in for a new call.
   */
  fitKey(
    opening: MatchedJobOpening,
    profile: PortfolioProfile,
    regions: ReadonlySet<Region>,
  ): string;
}

/** Scores an opening by asking Gemini how well it fits the portfolio. */
export class GeminiJobScorer implements JobScorer {
  constructor(private readonly generateJson: GenerateJson) {}

  async score(
    opening: MatchedJobOpening,
    profile: PortfolioProfile,
    regions: ReadonlySet<Region>,
  ): Promise<JobFit> {
    const text = await this.generateJson({
      systemInstruction: jobFitInstruction,
      prompt: jobFitPrompt(opening, profile, regions),
      responseJsonSchema: jobFitSchema,
      maxOutputTokens,
      thinkingBudget,
    });
    return parseJobFit(text, profile.skills);
  }

  /** A hash of the model, the instruction and the prompt. */
  fitKey(
    opening: MatchedJobOpening,
    profile: PortfolioProfile,
    regions: ReadonlySet<Region>,
  ): string {
    return createHash('sha256')
      .update(
        JSON.stringify([
          geminiModel,
          jobFitInstruction,
          jobFitPrompt(opening, profile, regions),
        ]),
      )
      .digest('hex')
      .slice(0, 32);
  }
}
