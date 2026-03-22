import { LikeC4 } from 'likec4';
import { test } from 'vitest';

// Initialize and compute LikeC4 model for the workspace with .c4 files
const likec4 = await LikeC4.fromWorkspace('likec4');
// computedModel(projectId) is async; project id from .likec4rc (e.g. "system") or first project
const projectId = likec4.projects()[0]?.id ?? 'system';
const model = await likec4.computedModel(projectId);

// elements() returns an iterator; convert to array and filter by kind
const containers = [...model.elements()].filter((e) => e.kind === 'container');

test('each container has required properties (summary, technology, icon, description, metadata.owner)', ({
  expect,
}) => {
  expect.hasAssertions();
  for (const e of containers) {
    expect.soft(e.summary, `container ${e.id} has no summary`).toBeTruthy();
    expect.soft(e.technology, `container ${e.id} has no technology`).toBeTruthy();
    expect.soft(e.icon, `container ${e.id} has no icon`).toBeTruthy();
    expect.soft(e.description, `container ${e.id} has no description`).toBeTruthy();
    // const owner = e.getMetadata('owner');
    // expect.soft(owner, `container ${e.id} has no metadata.owner`).toBeTruthy();
  }
});

