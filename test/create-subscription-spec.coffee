_                  = require 'lodash'
mongojs            = require 'mongojs'
Datastore          = require 'meshblu-core-datastore'
CreateSubscription = require '../'

describe 'CreateSubscription', ->
  beforeEach (done) ->
    db = mongojs 'subscription-manager-test', ['subscriptions']
    @datastore = new Datastore
      database: db
      collection: 'subscriptions'

    db.subscriptions.remove done

  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback(null, uuid)
    @sut = new CreateSubscription {@datastore, @uuidAliasResolver}

  describe '->do', ->
    context 'when given a valid request', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'its-electric'
          rawData: JSON.stringify {subscriberUuid:'superman', emitterUuid: 'spiderman', type:'broadcast'}

        @sut.do request, (error, @response) => done error

      it 'should still have one subscription', (done) ->
        @datastore.find {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal [
            {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast'}
          ]
          done()

      it 'should return a 201', ->
        expectedResponse =
          metadata:
            responseId: 'its-electric'
            code: 201
            status: 'Created'

        expect(@response).to.deep.equal expectedResponse

    context 'when given a invalid request', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'its-electric'
          rawData: JSON.stringify {emitterUuid: 'spiderman', type:'broadcast'}

        @sut.do request, (error, @response) => done error

      it 'should not have a subscription', (done) ->
        @datastore.find {subscriberUuid: 'superman', emitterUuid: 'spiderman', type: 'broadcast'}, (error, subscriptions) =>
          return done error if error?
          expect(subscriptions).to.deep.equal []
          done()

      it 'should return a 422', ->
        expectedResponse =
          metadata:
            responseId: 'its-electric'
            code: 422
            status: 'Unprocessable Entity'

        expect(@response).to.deep.equal expectedResponse
