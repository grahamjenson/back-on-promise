BOP = {}

$ = require 'jquery'
_ = require 'backbone/node_modules/underscore'
Backbone = require 'backbone'
Backbone.$ = $

#####Pass these mmodules through to client

BOP.Backbone = Backbone
BOP.$ = $
BOP._ = _


class BOP.BOPModel extends Backbone.Model

  @has: (name, model, options = {}) ->
    options = _.defaults(options, 
      method: 'parse'
      model: model
      name: name
    )
    @prototype._has ||= {}
    @prototype._has[name] = options

  has_relationship: (attr, options) ->
    @get_relationship(attr, options) and true

  get_relationship: (attr, options = {}) ->
    has_rel = @_has  and @_has[attr] and true
    if options.method
      has_rel = has_rel and options.method == @_has[attr].method
    if not has_rel
      return undefined
    @_has[attr]

  get_relationship_model: (attr) ->
    @get_relationship(attr).model

  get_relationship_method: (attr) ->
    @get_relationship(attr).method

  get_relationship_reverse: (attr) ->
    @_has[attr].reverse

  has_relationship_reverse: (attr) ->
    !! @_has[attr].reverse

  get_relationships: (options ={}) ->
    if not @_has
      return []
    rels = []
    for key, val of @_has
      if  (rel = @get_relationship(key, options))
        rels.push(rel)
    rels

  set_model_values: (m, attr) ->
    m.set(@get_relationship_reverse(attr), @) if @has_relationship_reverse(attr)
    m._parent = @
    m._field_name = attr

  #Semantic change, get reutrns a promise for the data
  get: (attr, options) ->
    data = super(attr,options)
    #if it is there return it as a promise
    if data 
      return $.when(data)
    
    if @has_relationship(attr, method: 'fetch')
      #IF it is a single object, it will be a search for the item
      #TODO have fetch query called on the single item
      model_class = @get_relationship_model(attr)
      m = new model_class()
      @set_model_values(m, attr)
      @set(attr, m)
      return $.when(m.fetch(options)).then( (res) -> return m)
    $.when(undefined)

  parse: (data, options) ->
    parsed = super(data, options)

    for val in @get_relationships()
        if parsed[val.name]
          m = new val.model(parsed[val.name], parse: true)
          @set_model_values(m, val.name)
          parsed[val.name] = m

    parsed

  toJSON: (options) ->
    json = super
    #delete all relationships
    for rel in @get_relationships()
      delete json[rel.name]

    for rel in @get_relationships(method: 'parse')
      #ASSUMPTION: ALL PARSE RELATIONSHIPS WILL BE RESOLVED GET
      @get(rel.name).done( (x) ->
        json[rel.name] = x.toJSON(options) if x
      )
    json

class BOP.BOPCollection extends Backbone.Collection
  set_reverse: () ->
    console.log 'TODO'

#AMD
if (typeof define != 'undefined' && define.amd)
  define([], -> return BOP)
#Node
else if (typeof module != 'undefined' && module.exports)
    module.exports = BOP;