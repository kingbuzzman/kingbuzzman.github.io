$(document).ready ->

  # breakdown animation -- fixes double-click bug with slideToggle()
  toggleBreakdown = () ->
    element = $(this)
    element.children("img").slideToggle "slow", ->
      element.unbind("click").one "click", toggleBreakdown
      return
    return

  navigationLinks = $("#sidebar a")
  navigationPanels = $("#page > section")

  $('.dead-link').click (event) ->
    return false

  # initial preparation
  (() ->
    CURRENT_YEAR = (new Date()).getFullYear()
    URL_HASH = window.location.hash
    preload = navigationPanels.filter(URL_HASH)

    # update copyright year
    $("#year").html CURRENT_YEAR

    # friendlier amount time spent at each job
    $("#employment h5").hover (() ->
      box = $(this).find(".time")
      time = box.clone()
      font = 0
      message = ""
      months = 0
      years = 0

      start = box.html().split("-")[0]
      end = box.html().split("-")[1]

      # safari likes to see a day, not just month year
      start = (start.match(/(\w{3}) (\d{4})/) or []).splice(1, 2).join(" 1, ")
      end = (end.match(/(\w{3}) (\d{4})/) or []).splice(1, 2).join(" 1, ")

      start = new Date(start)
      end = new Date(end)

      # fix 'present' value
      end = (if end.toString() is "Invalid Date" then new Date() else end)

      # calculate the amount of months
      months = (end.getFullYear() - start.getFullYear()) * 12
      months -= start.getMonth() + 1
      months += end.getMonth() + 1

      # calculate the amount of years
      years = parseInt(months / 12, 10)
      months = parseInt(months % 12, 10)

      # years
      if years > 0
        message = years + " year"
        message += "s"  if years > 1

      # months
      if months > 0
        message += " and "  if years > 0
        message += months + " month"
        message += "s"  if months > 1
      else message = "Present" if years is 0

      time.css
        visibility: "hidden"
        width: box.width()
        position: "relative"
        right: -1 * box.innerWidth()
        textAlign: "center"

      time.html(message).attr "title", message
      box.after time

      font = parseInt(time.css("font-size"), 10)
      while time.height() > box.height() and font > 4
        time.css "font-size", font--

      time.css(
        visibility: ""
        height: box.height()
      ).hide()

      box.stop()
      box.animate opacity: 0

      time.fadeIn()
      return
    ), () ->
      box = $(this).find(".box")
      time = box.next()

      box.stop()
      box.animate
        opacity: 1
      , () ->
        box.removeAttr "style"
        return

      time.remove()
      return

    # hide all panels
    navigationPanels.addClass "hidden"

    # if theres a hash in the URL start with that panel open
    if preload.length is 1
      preload.removeClass "hidden"
      navigationLinks.filter("[href=" + URL_HASH + "]").addClass "bold"
    else
      navigationPanels.first().removeClass "hidden"
      navigationLinks.first().addClass "bold"

    return
  )()
  
  # image breakdown for tags
  $(".breakdown").hover(() ->
    $(this).children("img").hide()
    return
  , ->
    $(this).unbind("click").one("click", toggleBreakdown).children("img").stop().removeAttr "style"
    return
  ).one "click", toggleBreakdown
  
  # navigation handling
  navigationLinks.click ->
    navigationLink = $(this)
    element = $(navigationLink.attr("href"))
    navigationPanels.addClass "hidden"
    navigationLinks.removeClass "bold"
    navigationLink.addClass "bold"
    
    # to use animations the element needs to be hidden (not with a class)
    element.hide().removeClass("hidden").fadeIn()
    return

  return