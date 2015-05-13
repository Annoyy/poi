require 'coffee-react/register'

# Environments
window.ROOT = __dirname

# Shortcuts and Components
window.remote = require 'remote'
window._ = require 'underscore'
window.$ = (param) -> document.querySelector(param)
window.$$ = (param) -> document.querySelectorAll(param)
window.jQuery = require './components/jquery/dist/jquery'
window.React = require 'react'
window.ReactBootstrap = require 'react-bootstrap'

# Utils
window.resolveTime = (seconds) ->
  return '' if seconds < 0
  hours = Math.floor(seconds / 3600)
  seconds -= hours * 3600
  minutes = Math.floor(seconds / 60)
  seconds -= minutes * 60
  hours = "0#{hours}" if hours < 10
  minutes = "0#{minutes}" if minutes < 10
  seconds = "0#{seconds}" if seconds < 10
  "#{hours}:#{minutes}:#{seconds}"
window.log = (msg) ->
  event = new CustomEvent 'poi.alert',
    bubbles: true
    cancelable: true
    detail:
      message: msg
      type: 'info'
  window.dispatchEvent event
window.success = (msg) ->
  event = new CustomEvent 'poi.alert',
    bubbles: true
    cancelable: true
    detail:
      message: msg
      type: 'success'
  window.dispatchEvent event
window.warn = (msg) ->
  event = new CustomEvent 'poi.alert',
    bubbles: true
    cancelable: true
    detail:
      message: msg
      type: 'warning'
  window.dispatchEvent event
window.error = (msg) ->
  event = new CustomEvent 'poi.alert',
    bubbles: true
    cancelable: true
    detail:
      message: msg
      type: 'danger'
  window.dispatchEvent event
window.notify = (msg) ->
  new Notification 'poi',
    icon: "file://#{ROOT}/assets/icons/icon.png"
    body: msg

# Node modules
window.config = remote.require './lib/config'
window.proxy = remote.require './lib/proxy'

# User configs
window.layout = config.get 'poi.layout', 'horizonal'

# Global data resolver
proxy.addListener 'game.response', (method, path, body) ->
  switch path
    # Game datas prefixed by $
    when '/kcsapi/api_start2'
      window.$ships = []
      window.$ships[ship.api_id] = ship for ship in body.api_mst_ship
      window.$shipTypes = []
      window.$shipTypes[stype.api_id] = stype for stype in body.api_mst_stype
      window.$slotitems = []
      window.$slotitems[slotitem.api_id] = slotitem for slotitem in body.api_mst_slotitem
      window.$mapareas = []
      window.$mapareas[maparea.api_id] = maparea for maparea in body.api_mst_maparea
      window.$maps = []
      window.$maps[map.api_id] = map for map in body.api_mst_mapinfo
      window.$missions = []
      window.$missions[mission.api_id] = mission for mission in body.api_mst_mission
    # User datas prefixed by _
    when '/kcsapi/api_port/port'
      window._ships = []
      window._ships[ship.api_id] = ship for ship in body.api_ship
    when '/kcsapi/api_get_member/slot_item'
      window._slotitems = []
      window._slotitems[slotitem.api_id] = slotitem for slotitem in body
    when '/kcsapi/api_req_kousyou/getship'
      window._ships[body.api_ship.api_id] = body.api_ship
    when '/kcsapi/api_req_kousyou/createitem'
      window._slotitems[body.api_slot_item.api_id] = body.api_slot_item

views = ['layout', 'app']
for view in views
  require "./views/#{view}"
