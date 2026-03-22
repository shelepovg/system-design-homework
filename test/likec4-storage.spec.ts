import { LikeC4 } from 'likec4';
import { test } from 'vitest';

const likec4 = await LikeC4.fromWorkspace('likec4');
const projectId = likec4.projects()[0]?.id ?? 'system';
const model = await likec4.computedModel(projectId);

const storageKinds = ['database', 'queue', 'object_storage'] as const;
const storageElements = [...model.elements()].filter((e) =>
  storageKinds.includes(e.kind as (typeof storageKinds)[number]),
);

test('each database, queue and object_storage has required properties (summary, technology, icon, description)', ({
  expect,
}) => {
  expect.hasAssertions();
  for (const e of storageElements) {
    expect.soft(e.summary, `${e.kind} ${e.id} has no summary`).toBeTruthy();
    expect.soft(e.technology, `${e.kind} ${e.id} has no technology`).toBeTruthy();
    expect.soft(e.icon, `${e.kind} ${e.id} has no icon`).toBeTruthy();
    expect.soft(e.description, `${e.kind} ${e.id} has no description`).toBeTruthy();
  }
});
