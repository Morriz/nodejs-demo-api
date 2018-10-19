const restify = require('restify')
const env = process.env
const server = restify.createServer()
const Prometheus = require('prom-client')
const packageVersion = require('./package.json').version

const metricsInterval = Prometheus.collectDefaultMetrics()
const httpRequestDurationMicroseconds = new Prometheus.Histogram({
  name: 'http_request_duration_ms',
  help: 'Duration of HTTP requests in ms',
  labelNames: ['method', 'route', 'code'],
  buckets: [0.1, 5, 15, 50, 100, 200, 300, 400, 500], // buckets for response time from 0.1ms to 500ms
})

const methods = {
  public: ['publicmethod'],
  private: ['privatemethod'],
}

server.use(restify.plugins.bodyParser())
server.use(restify.plugins.queryParser())

function handler(req, res, next) {
  const qry = req.query || {}
  const key = qry.key || ''
  const secret = qry.secret || ''
  const method = req.params.method
  const body = req.body

  if (!methods.public.includes(method) && !methods.private.includes(method)) {
    res.send(404, 'Method does not exist: ' + method)
    return next()
  }
  if (methods.private.includes(method) && (key === '' || secret === '')) {
    res.send(401, 'Unauthorized')
    return next()
  }

  // do some api call
  // and send result
  setTimeout(() => {
    res.send(`method[${method}]: package version: ${packageVersion}`)
    next()
  }, Math.round(Math.random() * 200))
}

// Runs before each requests
server.use((req, res, next) => {
  if (!res.locals) res.locals = {}
  res.locals.startEpoch = Date.now()
  next()
})

server.get('/bad', (req, res, next) => {
  next(new Error('My Error'))
})

server.get('/api/:method', handler)
server.post('/api/:method', handler)
// health check:
server.get('/healthz', (req, res, next) => res.send('ok') && next())
// metrics:
server.get('/metrics', (req, res) => {
  res.set('Content-Type', Prometheus.register.contentType)
  res.end(Prometheus.register.metrics())
})

// Error handler
server.use((err, req, res, next) => {
  res.send(500, 'Unknown')
  next()
})

// Runs after each requests
server.use((req, res, next) => {
  const responseTimeInMs = Date.now() - res.locals.startEpoch

  httpRequestDurationMicroseconds
    .labels(req.method, req.route.path, res.statusCode)
    .observe(responseTimeInMs)

  next()
})

server.listen(env.PORT || 3000, () => {
  console.log('%s listening at %s', server.name, server.url)
})

// Graceful shutdown
process.on('SIGTERM', () => {
  clearInterval(metricsInterval)

  server.close(err => {
    if (err) {
      console.error(err)
      process.exit(1)
    }

    process.exit(0)
  })
})
