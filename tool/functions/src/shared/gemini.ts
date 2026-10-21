import { GoogleGenAI } from '@google/genai';

/** The model every function calls. */
export const geminiModel = 'gemini-2.5-flash';

// Gemini 2.5 sets thinking with a token budget, not a thinking level.
const thinkingBudget = 1024;

/** The Agent Platform (formerly Vertex AI) location of the model. */
export const geminiLocation = 'global';

// Each attempt gets its own deadline; the whole call, retries included, has a
// longer one.
const attemptTimeoutMs = 45_000;
const callTimeoutMs = 150_000;

// Retries 408, 429 and 5xx after 5 s, 10 s and 20 s (with jitter). New
// projects share Gemini capacity and often get 429 when calls arrive together.
const retryOptions = { attempts: 4, initialDelay: 5, maxDelay: 30 };

export interface JsonRequest {
  /** Trusted instructions. Untrusted text belongs in [prompt] only. */
  systemInstruction: string;
  prompt: string;
  responseJsonSchema: object;
  maxOutputTokens: number;
}

/** Sends one prompt to Gemini and returns the JSON text of its reply. */
export type GenerateJson = (request: JsonRequest) => Promise<string>;

/**
 * Calls Gemini through the Agent Platform as the function's service account,
 * so no API key is stored. Throttled and failed calls are retried with backoff
 * within a fixed deadline.
 */
export function createGeminiGenerateJson(project: string): GenerateJson {
  const client = new GoogleGenAI({
    vertexai: true,
    project,
    location: geminiLocation,
    httpOptions: { timeout: attemptTimeoutMs, retryOptions },
  });
  return async (request) => {
    const response = await client.models.generateContent({
      model: geminiModel,
      contents: request.prompt,
      config: {
        systemInstruction: request.systemInstruction,
        temperature: 0,
        maxOutputTokens: request.maxOutputTokens,
        responseMimeType: 'application/json',
        responseJsonSchema: request.responseJsonSchema,
        thinkingConfig: { thinkingBudget },
        abortSignal: AbortSignal.timeout(callTimeoutMs),
      },
    });
    const text = response.text;
    if (!text) {
      const reason = response.candidates?.[0]?.finishReason ?? 'unknown';
      throw new Error(`Gemini returned no text (finish reason ${reason})`);
    }
    return text;
  };
}
