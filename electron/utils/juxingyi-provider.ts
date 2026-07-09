import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { join } from 'node:path';
import { homedir } from 'node:os';
import { app } from 'electron';
import { logger } from './logger';

const OPENCLAW_CONFIG_PATH = join(homedir(), '.openclaw', 'openclaw.json');
const JUXINGYI_PROVIDER_ID = 'juxingyi';

const JUXINGYI_CONFIG = {
  id: JUXINGYI_PROVIDER_ID,
  name: '聚星逸',
  type: 'openai',
  baseUrl: 'https://fireworks-simulator-api.huo15.com/v1',
  apiKey: 'fsk-3Ycmtx_ZXCLSuKFHB-KePCChLPLRvBll',
  models: ['deepseek-v4-flash-free'],
  defaultModel: 'deepseek-v4-flash-free',
};

const JUXINGYI_MODEL_ENTRY = {
  provider: JUXINGYI_PROVIDER_ID,
  model: 'deepseek-v4-flash-free',
};

async function readJson<T = Record<string, unknown>>(filePath: string): Promise<T | null> {
  try {
    const content = await readFile(filePath, 'utf-8');
    return JSON.parse(content) as T;
  } catch {
    return null;
  }
}

async function writeJson(filePath: string, data: unknown): Promise<void> {
  const dir = filePath.substring(0, filePath.lastIndexOf('/'));
  await mkdir(dir, { recursive: true });
  await writeFile(filePath, JSON.stringify(data, null, 2), 'utf-8');
}

function hasJuxingyiProvider(config: Record<string, unknown>): boolean {
  const models = config.models as Record<string, unknown> | undefined;
  if (!models?.providers || typeof models.providers !== 'object') return false;
  const providers = models.providers as Record<string, unknown>;
  return JUXINGYI_PROVIDER_ID in providers;
}

function seedJuxingyiIntoConfig(config: Record<string, unknown>): Record<string, unknown> {
  const models = (config.models as Record<string, unknown>) ?? {};
  const providers = (models.providers as Record<string, unknown>) ?? {};

  providers[JUXINGYI_PROVIDER_ID] = JUXINGYI_CONFIG;
  models.providers = providers;
  config.models = models;

  if (!config.agents || typeof config.agents !== 'object') {
    config.agents = {};
  }
  const agents = config.agents as Record<string, unknown>;
  if (!agents.defaults || typeof agents.defaults !== 'object') {
    agents.defaults = {};
  }
  const defaults = agents.defaults as Record<string, unknown>;
  if (!defaults.model) {
    defaults.model = JUXINGYI_MODEL_ENTRY;
  }

  if (!config.auth || typeof config.auth !== 'object') {
    config.auth = {};
  }
  const auth = config.auth as Record<string, unknown>;
  if (!auth.profiles || typeof auth.profiles !== 'object') {
    auth.profiles = {};
  }
  const profiles = auth.profiles as Record<string, unknown>;
  if (!profiles[JUXINGYI_PROVIDER_ID]) {
    profiles[JUXINGYI_PROVIDER_ID] = { apiKey: JUXINGYI_CONFIG.apiKey };
  }

  return config;
}

const JUXINGYI_SEEDED_KEY = 'juxingyiProviderSeeded';

export async function ensureJuxingyiProvider(): Promise<void> {
  try {
    if (app.commandLine.hasSwitch(JUXINGYI_SEEDED_KEY)) return;

    const config = await readJson<Record<string, unknown>>(OPENCLAW_CONFIG_PATH);
    if (config && hasJuxingyiProvider(config)) {
      logger.info('[juxingyi] Provider already configured, skipping seed');
      return;
    }

    const merged = seedJuxingyiIntoConfig(config ?? {});
    await writeJson(OPENCLAW_CONFIG_PATH, merged);
    logger.info('[juxingyi] Provider seeded into openclaw.json');
  } catch (err) {
    logger.warn('[juxingyi] Failed to seed provider:', err);
  }
}
