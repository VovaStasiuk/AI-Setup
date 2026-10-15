import { test, expect } from 'claude-code/testing'

const bottom = (on: any) => {
  on('tool.call', ($: any, e: any) => ({ result: 'ran' }))
  on('prompt.submit', ($: any, e: any) => ({ text: e.text }))
}

test('blocks git commit when the user did not ask', async ($, on) => {
  bottom(on)
  const r: any = await $.tool.call({ tool: 'Bash', command: 'git commit -m x' } as any)
  expect(String(r.text ?? r.deny)).toContain('house-rules')
})

test('always blocks --create-db', async ($, on) => {
  bottom(on)
  const r: any = await $.tool.call({ tool: 'Bash', command: 'make pytest ARGS="--create-db"' } as any)
  expect(String(r.text ?? r.deny)).toContain('test database')
})

test('lets read-only git through', async ($, on) => {
  bottom(on)
  const r: any = await $.tool.call({ tool: 'Bash', command: 'git status' } as any)
  expect(r.deny).toBeUndefined()
})

test('ignores git words inside text', async ($, on) => {
  bottom(on)
  const r: any = await $.tool.call({ tool: 'Bash', command: "echo 'Write a git commit message' > notes.txt" } as any)
  expect(r.deny).toBeUndefined()
})

test('blocks git commit after cd &&', async ($, on) => {
  bottom(on)
  const r: any = await $.tool.call({ tool: 'Bash', command: 'cd repo && git -C x commit -m y' } as any)
  expect(String(r.text ?? r.deny)).toContain('house-rules')
})

test('blocks worktree helpers', async ($, on) => {
  bottom(on)
  const r: any = await $.tool.call({ tool: 'EnterWorktree', name: 'x' } as any)
  expect(String(r.text ?? r.deny)).toContain('house-rules')
})
