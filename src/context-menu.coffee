{ remote } = require 'electron'
{ Menu, MenuItem } = remote

window.addEventListener 'contextmenu', (e) ->
  e.preventDefault()
  elements = document.elementsFromPoint(e.pageX, e.pageY)
  menuItems = []
  first = true
  for element in elements
    try
      items = element.contextMenu
      if first then first = false
      else
        menuItems.push new MenuItem type: 'separator'
      menuItems.push items... if items
  menu = new Menu
  menu.append item for item in menuItems
  menu.popup remote.getCurrentWindow()
