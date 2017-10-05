const restify = require('restify')
const env = process.env
const server = restify.createServer()

const methods = {
  public: ['publicmethod'],
  private: ['privatemethod'],
}

server.use(restify.plugins.bodyParser())
server.use(restify.plugins.queryParser())

function handler(req, res) {
  const qry = req.query || {}
  const key = qry.key || ''
  const secret = qry.secret || ''
  const method = req.params.method
  const body = req.body

  if (!methods.public.includes(method) && !methods.private.includes(method))
    return res.send(404, 'Method does not exist: ' + method)
  if (methods.private.includes(method) && (key === '' || secret === ''))
    return res.send(401, 'Unauthorized')

  try {
    // do some api call
    // and send result
    res.send('ok')
  } catch (e) {
    res.send(500, 'Internal server error')
  }
}

server.get('/api/:method', handler)
server.post('/api/:method', handler)
// health check:
server.get('/', (req, res) => res.send('ok'))



server.listen(env.PORT || 3000, () => {
  console.log('%s listening at %s', server.name, server.url)
})
