import { GoogleGenAI, ThinkingLevel } from '@google/genai';

/** The model every function calls. It matches the app's assistant. */
export const geminiModel = 'gemini-3.8-flash';

/** The Agent Platform (formerly Vertex AI) location of the model. */
export const geminiLocation = 'global';

const requestTimeoutMs = 30_000;

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
 * so no API key is stored. Each call has a fixed deadline.
 */
export function createGeminiGenerateJson(project: string): GenerateJson {
  const client = new GoogleGenAI({
    vertexai: true,
    project,
    location: geminiLocation,
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
        thinkingConfig: { thinkingLevel: ThinkingLevel.LOW },
        abortSignal: AbortSignal.timeout(requestTimeoutMs),
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
