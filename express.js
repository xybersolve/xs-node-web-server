const applyHttps = (app) => {
  const enforcer = require('./enforceHttps')

  const enforceHttps = process.env.ENFORCE_HTTPS || false

  const redirectToHttps = enforcer.shouldRedirect(enforceHttps, process.env.NODE_ENV, process.env.ENVIRONMENTS)

  if (redirectToHttps) {
    let sslify = require('express-sslify')
    enforcer.enforce(app, sslify.HTTPS, process.env.ENFORCE_HTTPS)
    console.log(`HTTP -> HTTPS enabled. Mode: ${process.env.ENFORCE_HTTPS}`)
  }
}

const createApp = () => {
  const express = require('express')
  const bodyParser = require('body-parser')
  const logger = require('morgan')
  const compression = require('compression')
  const path = require('path')
  const app = express()

  app.get('/healthCheck', function(req,res) {
    res.status(200).send('I\'m healthy papa!')
  })

  applyHttps(app)

  app.use(compression())
  app.use(bodyParser.json())
  app.use(bodyParser.urlencoded({ extended: false }))
  app.use(logger('dev'))
  app.use('/', express.static(path.join(__dirname, 'public'), { redirect: false }))
  app.get('*', (rqe, res) => res.sendFile(path.resolve(path.join(__dirname, 'public/index.html'))))
  return app
}

module.exports = {
  createApp
}
