import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, RenderElement, RenderInput, RenderNode } from 'claude-code'

import type { Item } from '../types'

// Change the tag when Item's fields change: it declines what an earlier
// version stored, which outlives a reload.
const items = atom({ plugin: 'talk-stack', key: 'items' } as const, [], {
  shape: 'items-1',
})
const last = atom({ plugin: 'talk-stack', key: 'last' } as const, null)
// The first item the band shows, counted from the newest
const cursor = atom({ plugin: 'talk-stack', key: 'cursor' } as const, 0)

const storeKey = (sessionId: string) => `stack:${sessionId}`

const oneLine = (text: string) => text.replace(/\s+/g, ' ').trim()

// Wide (CJK) glyphs take two cells in the terminal
const cells = (ch: string) => ((ch.codePointAt(0) ?? 0) >= 0x2e80 ? 2 : 1)

const cellsOf = (text: string) => [...text].reduce((sum, ch) => sum + cells(ch), 0)

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

// The band shows at most this many characters of an item
const HEAD = 20

const head = (text: string) => {
  const chars = [...text]
  return chars.length > HEAD ? `${chars.slice(0, HEAD).join('')}…` : text
}

const textOf =(content: unknown): string => {
  if (typeof content === 'string') return content
  if (!Array.isArray(content)) return ''
  return content
    .map(block => (block?.type === 'text' ? String(block.text) : ''))
    .join(' ')
}

async function save($: EngineInterface) {
  await $.store.set(storeKey(await $.session.id()), await read($, items))
}

async function push($: EngineInterface, item: Item) {
  await update($, items, list => [item, ...list.filter(one => one.id !== item.id)])
  await update($, cursor, () => 0)
  await save($)
}

async function remove($: EngineInterface, id: string) {
  await update($, items, list => list.filter(one => one.id !== id))
  const count = (await read($, items)).length
  await update($, cursor, at => Math.min(at, Math.max(0, count - 1)))
  await save($)
}

async function jump($: EngineInterface, item: Item) {
  const moved = await $.ui.scroll({ to: { requestId: item.id }, block: 'start' })
  if ('deny' in moved && moved.deny) $.ui.toast(`stack: ${moved.deny}`)
}

async function step($: EngineInterface, by: number) {
  const count = (await read($, items)).length
  await update($, cursor, at => Math.min(Math.max(0, at + by), Math.max(0, count - 1)))
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
      name: 'stack',
      description: 'Stack the last prompt to revisit later (args: a memo shown instead of the prompt)',
      argumentHint: '[memo]',
    })
    const stored = await $.store.get(storeKey(await $.session.id()))
    if (Array.isArray(stored)) await update($, items, () => stored as Item[])

    return next(e)
  })

  on('session.append', { door: 'prompt' }, async ($, e, next) => {
    const kept = await next(e)
    const isTyped = e.agentId === undefined && e.message.role === 'user' && !e.message.isMeta
    const text = oneLine(textOf(kept.message?.content))
    if (isTyped && kept.uuid && text !== '') {
      await update($, last, () => ({ id: kept.uuid, text }))
    }

    return kept
  }).catch(($, e, next) => next(e))

  on('command.run', { command: 'stack' }, async ($, e) => {
    const prompt = await read($, last)
    if (prompt === null) {
      $.ui.toast('stack: no prompt to stack yet')
      return {}
    }
    const item: Item = { id: prompt.id, text: oneLine(e.args) || prompt.text }
    await push($, item)
    $.ui.toast(`stacked: ${fit(item.text, 40)}`)

    return {}
  })

  // Placed beside prismantis's bubble labels (bubbleLabels: large):
  // "You  ⬤ " at the right edge, "⬤  Claude" atop a reply's first block
  on('ui.render', { component: 'UserMessage', props: { origin: { kind: 'composer' } } }, async ($, e, next) =>
    mark($, e, await next(e), { id: e.requestId, text: oneLine(e.props.text) }, { right: 8 }),
  )

  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) =>
    mark(
      $,
      e,
      await next(e),
      { id: e.requestId, text: oneLine(e.props.text), isReply: true },
      { left: e.props.isFirstOfReply ? 10 : 0 },
    ),
  )

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const list = await read($, items)
    if (e.props.hasSurvey || list.length === 0) return next(e)

    const { Box, Button, Text } = $.ui.resolve(e)
    const first = Math.min(await read($, cursor), list.length - 1)
    const title = `stack ${list.length} `
    const hasArrows = list.length > 1
    // The round border and paddingX take 2 cells each side; "‹ " and " ›" 2 each
    const room = e.props.bodyColumns - 4 - title.length - (hasArrows ? 4 : 0)
    const chips: Array<{ item: Item; text: string }> = []
    let used = 0
    for (const [i, item] of list.slice(first).entries()) {
      const label = head(item.text)
      // "N " + "C:" + text + " ×" + the gap before the next chip
      const width = String(first + i + 1).length + 1 + (item.isReply ? 2 : 0) + cellsOf(label) + 2 + 3
      if (chips.length > 0 && used + width > room) break
      chips.push({ item, text: chips.length === 0 && width > room ? fit(label, room - 8) : label })
      used += width
    }
    const isLast = first + chips.length >= list.length
    // One flat row: a Fragment lays its children out apart
    const row: RenderNode[] = [
      <Text key="title" dimColor>{title}</Text>,
    ]
    if (hasArrows) {
      row.push(<Button key="prev" plain label={first === 0 ? ' ' : '‹'} onPress={() => step($, -1)} />, <Text> </Text>)
    }
    // A dim number opens each item, so neighbours read as separate messages
    chips.forEach(({ item, text }, i) => {
      if (i > 0) row.push(<Text>   </Text>)
      row.push(
        <Text dimColor>{first + i + 1} </Text>,
        <Button key={`go:${item.id}`} plain label={`${item.isReply ? 'C:' : ''}${text}`} onPress={() => jump($, item)} />,
        <Text> </Text>,
        <Button key={`drop:${item.id}`} plain label="×" onPress={() => remove($, item.id)} />,
      )
    })
    if (hasArrows) {
      row.push(<Text> </Text>, <Button key="next" plain label={isLast ? ' ' : '›'} onPress={() => step($, 1)} />)
    }

    // Sized to its items and kept to the right, as prismantis seats a prompt
    return (
      <Box flexDirection="row" justifyContent="flex-end" width="100%">
        <Box borderStyle="round" borderColor="subtle" borderDimColor paddingX={1} flexDirection="row" flexWrap="nowrap" flexShrink={0}>
          {row}
        </Box>
      </Box>
    )
  })
}
