$(document).on 'turbolinks:load', ->
  round = $("#container")
  roundID = round.attr('data-round-id')
  if $('#container').length > 0
    App.rounds = App.cable.subscriptions.create {
      channel: "RoundsChannel"
      round_id: round.attr('data-round-id')
    },
      connected: ->
        @perform("joined")

      disconnected: ->
        # Called when the subscription has been terminated by the server

      received: (data) ->
        if data.total_users?
          $("#finished-users").text("#{data.finished_count}/#{data.total_users} voted")
        else
          $("body").empty()
          $("body").append(data.body)


  $(document).on 'click', '.voteable', ->
    $that = $(this)
    restaurantId = $that.attr('data-restaurant-id')
    roundId = $that.attr('data-round-id')
    name = $that.find('p').first().text()
    $.ajax
      url: '/rounds/' + roundId + '/restaurants/' + restaurantId,
      method: 'put',
      data: {name: name}
      success: ->
        $that.removeClass('voteable').addClass('voted')

  $(document).on 'submit', '#start-form', (e) ->
    e.preventDefault()
    radius = $(this).find('select option:selected').text()
    switch radius
      when '1/2 Mile' then radius = 800
      when '2 Miles' then radius = 3200;
      when '5 Miles' then radius = 6400;
      when '10 Miles' then radius = 16000;
      else radius = 16000
    data = {lat: lat, lng: lng, radius: radius}
    $.ajax
      url: '/rounds',
      method: 'post',
      data: data
      success: ->

  $("#vote-finish").click (e) ->
    console.log("Why is this even working")
    e.preventDefault()
    $.ajax
      url: '/rounds/' + roundID + '/finish_voting'
      method: 'put'
      success: ->
        $("#vote-finish").prop('value', "Votes submitted!")
        $("#vote-finish").removeClass('hvr-grow-shadow').css('background-color', 'green')







  $("#results-link").click (e) ->
    e.preventDefault()
    roundID = $("#round-results-btn").attr('data-round-id')
    $.ajax
      url: '/rounds/' + roundID + '/results'
      method: 'get'
      success: ->

  $("#radius").change ->
    $("#step2").addClass("dim")
    $("#step3").removeClass("dim")
    $("#radius-div").addClass("dim")
    $("#create-button").removeClass("dim")


