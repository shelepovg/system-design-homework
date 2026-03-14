import { LikeC4 } from 'likec4';
import { test } from 'vitest';

const likec4 = await LikeC4.fromWorkspace('likec4');
const projectId = likec4.projects()[0] ?? 'system';
const model = await likec4.computedModel(projectId);

// Собираем все связи: у каждого элемента берём исходящие (outgoing), дедуплицируем по id
const relationsById = new Map<
  string,
  { id: string; source: string; target: string; description: string | null; technology: string | null }
>();
for (const el of model.elements()) {
  for (const rel of el.outgoing()) {
    const desc = rel.description && typeof rel.description === 'object' && 'text' in rel.description
      ? (rel.description as { text: string }).text
      : (typeof rel.description === 'string' ? rel.description : null);
    relationsById.set(rel.id, {
      id: rel.id,
      source: rel.source.id,
      target: rel.target.id,
      description: desc ?? null,
      technology: rel.technology ?? null,
    });
  }
}
const relations = [...relationsById.values()];

test('each relationship has description and technology', ({ expect }) => {
  expect.hasAssertions();
  for (const r of relations) {
    const label = `relationship ${r.source} -> ${r.target} (${r.id})`;
    expect.soft(r.description, `${label} has no description`).toBeTruthy();
    expect.soft(r.technology, `${label} has no technology`).toBeTruthy();
  }
});
