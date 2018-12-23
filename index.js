// console.log(`Versions: ${JSON.stringify(process.versions, null, '  ')}`)
// console.log(`Current Environment: ${process.env.NODE_ENV}`)

const http = require('http')
const app = require('./express').createApp()
const server = http.createServer(app)
const PORT = process.env.PORT || 3000

server.listen(PORT, () => {
  console.log(`Server listening on port: ${PORT}`)
  console.log(`To access server, use http://localhost:${PORT}`)
})
