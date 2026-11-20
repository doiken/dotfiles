import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, RenderElement, RenderInput, RenderNode, RenderSurface } from 'claude-code'

import type { Item } from '../types'

// Change the tag when Item's fields change: it declines what an earlier
// version stored, which outlives a reload.
const items = atom({ plugin: 'talk-stack', key: 'items' } as const, [], {
  shape: 'items-1',
})
const last = atom({ plugin: 'talk-stack', key: 'last' } as const, null)
const open = atom({ plugin: 'talk-stack', key: 'unfolded' } as const, [])

const storeKey = (sessionId: string) => `stack:${sessionId}`

const oneLine = (text: string) => text.replace(/\s+/g, ' ').trim()

// Wide (CJK) glyphs take two cells in the terminal
const cells = (ch: string) => ((ch.codePointAt(0) ?? 0) >= 0x2e80 ? 2 : 1)

const fit = (text: string, room: number) => {
  let used = 0
  let out = ''
  for (const ch of text) {
    if (used + cells(ch) > room - 1) return `${out}…`
    used += cells(ch)
    out += ch
  }
  return out
}

const cellsOf = (text: string) => [...text].reduce((sum, ch) => sum + cells(ch), 0)

// A pane entry shows this many rows until unfolded
const FOLD_ROWS = 5

// The head of `text` that fills FOLD_ROWS rows of `width` cells, a line
// wrapping onto ceil(cells / width) rows, and how many rows are left out.
// A code fence the cut leaves open is closed so the markdown still draws
const fold = (text: string, width: number): { text: string; hidden: number } => {
  const lines = text.split('\n')
  const rowsOf = (line: string) => Math.max(1, Math.ceil(cellsOf(line) / Math.max(1, width)))
  const total = lines.reduce((sum, line) => sum + rowsOf(line), 0)
  if (total <= FOLD_ROWS) return { text, hidden: 0 }
  const kept: string[] = []
  let rows = 0
  for (const line of lines) {
    const room = FOLD_ROWS - rows
    if (room <= 0) break
    kept.push(rowsOf(line) <= room ? line : fit(line, room * width))
    rows += Math.min(rowsOf(line), room)
  }
  const fences = kept.filter(line => line.trimStart().startsWith('```')).length
  const head = kept.join('\n')
  return { text: fences % 2 === 1 ? `${head}\n${'`'.repeat(3)}` : head, hidden: total - FOLD_ROWS }
}

const textOf =(content: unknown): string => {
  if (typeof content === 'string') return content
  if (!Array.isArray(content)) return ''
  return content
    .map(block => (block?.type === 'text' ? String(block.text) : ''))
    .join(' ')
}

// prismantis publishes $.prismantis.markdown (its types/index.d.ts); without
// prismantis loaded the call throws and the caller draws the engine's Markdown
async function prismantisMarkdown($: EngineInterface, surface: RenderSurface, text: string, columns: number) {
  try {
    return await $.prismantis.markdown({ surface, text, columns })
  } catch {
    return undefined
  }
}

async function save($: EngineInterface) {
  await $.store.set(storeKey(await $.session.id()), await read($, items))
}

// Bubble borders as prismantis draws them under its nord theme (read from
// its hooks/theme.ts, presets.ts and render.tsx; prismantis publishes no
// colors): a prompt in diffAdded, a reply in the engine's claude color, dim
const PROMPT_BORDER = '#a3be8c'
const REPLY_BORDER = 'claude'

// The pane beside the transcript that shows each stacked row in full
const PANE = 'talk-stack'

async function openPane($: EngineInterface) {
  await $.ui.open({ id: PANE, title: 'stack' })
}

async function push($: EngineInterface, item: Item) {
  await update($, items, list => [item, ...list.filter(one => one.id !== item.id)])
  await save($)
  await openPane($)
}

async function remove($: EngineInterface, id: string) {
  await update($, items, list => list.filter(one => one.id !== id))
  await save($)
  if ((await read($, items)).length === 0) await $.ui.close({ id: PANE })
}

async function jump($: EngineInterface, item: Item) {
  const moved = await $.ui.scroll({ to: { requestId: item.id }, block: 'start' })
  if ('deny' in moved && moved.deny) $.ui.toast(`stack: ${moved.deny}`)
}

// A mark over the top-left of a transcript row: "+" on hover to stack it,
// "●" while stacked, pressed again to take it off
async function mark(
  $: EngineInterface,
  e: RenderInput<'UserMessage' | 'AssistantMessage'>,
  drawn: RenderElement,
  item: Item,
  at: { left: number } | { right: number },
) {
  const { Box, Button } = $.ui.resolve(e)
  const isStacked = (await read($, items)).some(one => one.id === item.id)
  const reveal = isStacked ? {} : { display: 'none' as const, hover: { display: 'flex' as const } }

  return (
    <Box key={`row:${item.id}`}>
      {drawn}
      <Box position="absolute" top={0} {...at} {...reveal}>
        <Button
          key={`mark:${item.id}`}
          plain
          label={isStacked ? '●' : '+'}
          onPress={() => (isStacked ? remove($, item.id) : push($, item))}
        />
      </Box>
    </Box>
  )
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'stack-pane',
      description: 'Open the pane of stacked rows again',
    })
    await $.command.register({
      name: 'stack',
      description: 'Stack the last prompt to revisit later (args: a memo shown instead of the prompt)',
      argumentHint: '[memo]',
    })
    const stored = await $.store.get(storeKey(await $.session.id()))
    if (Array.isArray(stored)) await update($, items, () => stored as Item[])
    // Unasked, the pane waits for a wide enough terminal
    if (Array.isArray(stored) && stored.length > 0) void openPane($)

    return next(e)
  })

  on('session.append', { door: 'prompt' }, async ($, e, next) => {
    const kept = await next(e)
    const isTyped = e.agentId === undefined && e.message.role === 'user' && !e.message.isMeta
    const body = textOf(kept.message?.content)
    const text = oneLine(body)
    if (isTyped && kept.uuid && text !== '') {
      await update($, last, () => ({ id: kept.uuid, text, body }))
    }

    return kept
  }).catch(($, e, next) => next(e))

  on('command.run', { command: 'stack-pane' }, async $ => {
    await openPane($)

    return {}
  })

  on('command.run', { command: 'stack' }, async ($, e) => {
    const prompt = await read($, last)
    if (prompt === null) {
      $.ui.toast('stack: no prompt to stack yet')
      return {}
    }
    const item: Item = { ...prompt, text: oneLine(e.args) || prompt.text }
    await push($, item)
    $.ui.toast(`stacked: ${fit(item.text, 40)}`)

    return {}
  })

  // Placed beside prismantis's bubble labels (bubbleLabels: large):
  // "You  ⬤ " at the right edge, "⬤  Claude" atop a reply's first block
  on('ui.render', { component: 'UserMessage', props: { origin: { kind: 'composer' } } }, async ($, e, next) =>
    mark($, e, await next(e), { id: e.requestId, text: oneLine(e.props.text), body: e.props.text }, { right: 8 }),
  )

  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) =>
    mark(
      $,
      e,
      await next(e),
      { id: e.requestId, text: oneLine(e.props.text), isReply: true, body: e.props.text },
      { left: e.props.isFirstOfReply ? 10 : 0 },
    ),
  )

  // Each stacked row in full, oldest first, drawn as the transcript draws it:
  // a reply through prismantis's markdown when it is loaded, a prompt in a
  // bubble like prismantis's own. The header row moves there or drops it
  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Button, Markdown, Text } = $.ui.resolve(e)
    const list = [...(await read($, items))].reverse()
    if (list.length === 0) return <Text dimColor>Nothing stacked.</Text>
    const columns = e.props.bodyColumns
    const unfolded = await read($, open)
    const entries: RenderNode[] = []
    for (const [i, item] of list.entries()) {
      const body = item.body ?? item.text
      // A dim rule with a blank row either side tells one bookmark from the next
      if (i > 0) {
        entries.push(
          <Box key={`rule:${item.id}`} marginY={1}>
            <Text dimColor>{'─'.repeat(columns)}</Text>
          </Box>,
        )
      }
      const header = (
        <Box key={`head:${item.id}`} flexDirection="row" columnGap={1}>
          <Text bold>{i + 1}</Text>
          <Text bold color={item.isReply ? REPLY_BORDER : PROMPT_BORDER}>{item.isReply ? 'Claude' : 'You'}</Text>
          <Button key={`go:${item.id}`} label="移動" onPress={() => jump($, item)} />
          <Button key={`drop:${item.id}`} label="x" onPress={() => remove($, item.id)} />
        </Box>
      )
      // The frame and paddingX take 2 cells each side
      const inner = columns - 4
      const isOpen = unfolded.includes(item.id)
      const folded = fold(body, inner)
      const shown = isOpen ? body : folded.text
      // At the end of the text, as prismantis folds a long block
      const toggle = folded.hidden > 0 && (
        <Box key={`fold:${item.id}`}>
          <Button
            key={`fold:${item.id}`}
            label={isOpen ? 'show less' : `+${folded.hidden} more lines`}
            onPress={() => update($, open, ids => (ids.includes(item.id) ? ids.filter(id => id !== item.id) : [...ids, item.id]))}
          />
        </Box>
      )
      if (item.isReply) {
        const drawn = (await prismantisMarkdown($, e.surface, shown, inner)) ?? <Markdown text={shown} />
        entries.push(
          <Box key={`entry:${item.id}`} flexDirection="column">
            {header}
            <Box borderStyle="round" borderColor={REPLY_BORDER} borderDimColor paddingX={1} flexDirection="column">
              {drawn}
              {toggle}
            </Box>
          </Box>,
        )
      } else {
        entries.push(
          <Box key={`entry:${item.id}`} flexDirection="column" alignItems="flex-end">
            {header}
            <Box borderStyle="round" borderColor={PROMPT_BORDER} paddingX={1} flexDirection="column">
              <Text>{shown}</Text>
              {toggle}
            </Box>
          </Box>,
        )
      }
    }

    return (
      <Box flexDirection="column">
        {entries}
      </Box>
    )
  })
}
