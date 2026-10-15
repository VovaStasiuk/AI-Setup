import { test, expect } from 'claude-code/testing'

import { recentEdit } from './register'

const NOW = 1_000_000_000

test('flags another chat edit from 5 minutes ago', () => {
  const hit = recentEdit({ title: 'implementer chat', files: { '/repo/a.py': NOW - 5 * 60_000 } }, '/repo/a.py', NOW)
  expect(hit).toEqual({ minutes: 5, chat: 'implementer chat' })
})

test('ignores edits older than 30 minutes', () => {
  expect(recentEdit({ files: { '/repo/a.py': NOW - 45 * 60_000 } }, '/repo/a.py', NOW)).toBeNull()
})

test('ignores other files', () => {
  expect(recentEdit({ files: { '/repo/b.py': NOW - 60_000 } }, '/repo/a.py', NOW)).toBeNull()
})

test('edits still go through when no other chat touched the file', async ($, on) => {
  on('tool.call', () => ({ result: 'ok' }))
  const r: any = await $.tool.call({ tool: 'Edit', file_path: '/tmp/nobody-touched-this.py', old_string: 'a', new_string: 'b' } as any)
  expect(r.deny).toBeUndefined()
})
