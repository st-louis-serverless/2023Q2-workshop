import express from 'express'

const app = express()

const sleep = (ms: number): Promise<void> => {
  return new Promise(resolve => setTimeout(resolve, ms));
}

app.get('/', async (req, res) => {
  console.log('Hello service received a request.')

  const target = process.env.TARGET || 'STLS'

  const latency = Number(process.env.DELAY) || 1000
  await sleep(latency)

  const now = new Date().toLocaleString('en-US', {
    hour: 'numeric', // numeric, 2-digit
    minute: 'numeric', // numeric, 2-digit
    second: 'numeric', // numeric, 2-digit
    hour12: false,
  })

  const index = req.query.index
  const prefix = index !== undefined ? `${index}: ${now} - ` : ''

  res.send(`${prefix}Hello ${target}\n`)
})

const port = process.env.PORT || 8080

app.listen(port, () => {
  console.log('Hello service listening on port', port)
})
