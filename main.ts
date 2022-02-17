const isGH = !!Deno.env.get('GITHUB_ACTIONS')
import { styles } from "https://deno.land/x/ansi_styles@1.0.0/mod.ts";

function usage() {
  console.log('Usage: main <file>...')
}

if (Deno.args.length == 0) {
  usage()
  Deno.exit(1)
}
if (Deno.args[0] === "-h" || Deno.args[0] === "--help") {
  usage()
  Deno.exit()
}

type FlakeRef = {
  type: string
  lastModified?: number
  narHash?: string
  url?: string
  owner?: string
  repo?: string
  rev?: string
  ref?: string
  path?: string
}

type NodeData = {
  flake?: boolean
  inputs?: { [name: string]: string }
  locked: FlakeRef
  original: FlakeRef
}

async function checkFlakeLock(filepath: string): Promise<boolean> {
  const lock = JSON.parse(await Deno.readTextFile(filepath));
  const pathNodes =
    Object
      .entries(lock.nodes)
      .map(([name, data]) => ({ name, data } as { name: string; data: NodeData }))
  // The root node does not have locked property
      .filter(({ data }) => !!data.locked?.path && data.locked.path[0] === "/" && ! /^\/nix\/store\//.test(data.locked.path))

  for (const node of pathNodes) {
    console.error(`${styles.red.open}\
${styles.bold.open}ERROR:${styles.bold.close} \
${filepath}: \
${node.name} is locked to a path.\
${styles.red.close}`)

    if (isGH) {
      console.log(`::error file=${filepath}::${node.name} is locked to a path.`)
    }
  }

  return pathNodes.length > 0
}

const files = Deno.args
let error = false
for (const file of files) {
  error ||= await checkFlakeLock(file)
}
if (error) {
  Deno.exit(1)
}
