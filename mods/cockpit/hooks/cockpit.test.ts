import { test, expect } from 'claude-code/testing'

const bottom = (on: any) => {
  on('tool.call', ($: any, e: any) => ({ result: 'ok', text: e.tool === 'TaskCreate' ? 'Task #7 created successfully' : 'ok' }))
}

test('/ship starts the checklist and briefs the model', async ($, on) => {
  const r: any = await $.command.run({ command: 'ship', args: '' } as any)
  expect(r.context[0]).toContain('done-checklist')
  expect(r.context[0]).toContain('Never commit or push')
})

test('ship_step records a step', async ($, on) => {
  await $.command.run({ command: 'ship', args: '' } as any)
  const r: any = await $.tool.call({ tool: 'mcp__cockpit__ship_step', step: 'lint', state: 'pass', note: 'clean' } as any)
  expect(r.text).toContain('lint: pass')
})

test('task tools pass through untouched', async ($, on) => {
  bottom(on)
  const created: any = await $.tool.call({ tool: 'TaskCreate', subject: 'Write tests', description: 'x' } as any)
  expect(created.deny).toBeUndefined()
  const updated: any = await $.tool.call({ tool: 'TaskUpdate', taskId: '7', status: 'completed' } as any)
  expect(updated.deny).toBeUndefined()
})

test('adds the progress-tracking instruction to the system prompt', async ($, on) => {
  on('prompt.compose', () => ({ sections: [{ id: 'intro', text: 'hi', scope: 'shared' }] }))
  const r: any = await $.prompt.compose({ model: 'claude-opus-5-5', promptModel: 'claude-opus-5-5', surfaces: ['terminal'], tools: [], outputStyle: null, traits: [] } as any)
  const mine = r.sections.find((s: any) => s.id === 'cockpit:progress')
  expect(mine.text).toContain('TaskCreate')
  expect(r.sections[0].id).toBe('intro')
})

test('/goal passes through and asks Claude to plan first', async ($, on) => {
  on('command.run', () => ({ text: 'Goal set.' }))
  const r: any = await $.command.run({ command: 'goal', args: 'Ship the export fix' } as any)
  expect(r.text).toBe('Goal set.')
  expect(r.context.join(' ')).toContain('task list')
})

test('/goal clear adds no planning brief', async ($, on) => {
  on('command.run', () => ({ text: 'Goal cleared.' }))
  const r: any = await $.command.run({ command: 'goal', args: 'clear' } as any)
  expect(r.context).toBeUndefined()
})
