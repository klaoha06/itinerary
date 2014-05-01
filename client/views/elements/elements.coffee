updateElementWithEvent = (e) ->
  findAttribute = (target, attribute) ->
    if target.parentElement.parentElement.parentElement.getAttribute('data-item-type') is 'map' and target.localName isnt 'input'
      target.parentElement.parentElement.parentElement.getAttribute(attribute)
    else
      target.parentElement.parentElement.getAttribute(attribute)

  target = e.target
  if target? and target.localName is 'input' or target.getAttribute('contentEditable')?
    body = if target.localName is 'input' then target.value else target.innerText
    if !!body
      updateElement(
        findAttribute(target, 'data-element-id'),
        findAttribute(target, 'data-item-type'),
        body)
    else
      originalBody = findAttribute(target, 'data-body')
      if target.getAttribute('contentEditable')?
        target.innerText = originalBody
      else unless target.localName is 'input'
        target.value =  originalBody

Template.elements.events
  focusout: (e) -> updateElementWithEvent(e)
  keydown: (e) -> updateElementWithEvent(e) if e.which is 13 and e.target.localName is 'input'
  keyup: (e) -> if e.which is 27 and e.target.localName is 'input'
    Meteor.call('deleteElement', e.target.parentElement.parentElement.getAttribute('data-element-id'))
  'click [data-action="removeElement"]': (e) ->
    Meteor.call('deleteElement', e.target.parentElement.getAttribute('data-element-id'))
  'click [data-editable="true"]': (e) ->
    elementId = e.target.parentElement.getAttribute('data-element-id')
    Elements.update({ _id: elementId }, { $set: { editable: true } })

Template.elements.rendered = ->
  $elementList = $('#elementList')
  $elementList.sortable
    axis: 'y'
    handle: '.handle'
    items: 'div[data-sortable="true"]'
    placeholder: 'item-placeholder'
    forcePlaceholderSize: '80px'
    stop: (event, ui) ->
      _.each $(event.target).children('div'), (element, index, list) ->
        Elements.update { _id: element.getAttribute('data-element-id') },
          $set: position: index + 1

  if Session.get('selectTitleElement')
    @.$('div[data-item-type="title"] input').focus()
    Session.set('selectTitleElement', '')
