_                   = require 'lodash'
http                = require 'http'
SubscriptionManager = require 'meshblu-core-manager-subscription'

class CreateSubscription
  constructor: ({@datastore,@uuidAliasResolver}) ->
    @subscriptionManager = new SubscriptionManager {@datastore,@uuidAliasResolver}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {subscriberUuid,emitterUuid,type} = request.metadata.options
    @subscriptionManager.create {subscriberUuid,emitterUuid,type}, (error) =>
      return @_doCallback request, error.code || 500, callback if error
      return @_doCallback request, 201, callback

module.exports = CreateSubscription
