shareUrl = window.location

ig.fit = ->
  return unless $?
  $body = $ 'body'
  $hero = $ "<div class='hero'></div>"
    ..append "<div class='overlay'></div>"
    ..append "<a href='#' class='scroll-btn'>Číst dál</a>"
    ..find 'a.scroll-btn' .bind 'click touchstart' (evt) ->
      evt.preventDefault!
      offset = $filling.offset!top + $filling.height! - 50
      d3.transition!
        .duration 800
        .tween "scroll" scrollTween offset
  $body.prepend $hero

  $ '#article h1' .html 'Proč utíkají?'
  mapOverlay = new MapOverlay $hero.0

  $filling = $ "<div class='ig filling'></div>"
  $ "p.perex" .after $filling

  $shares = $ "<div class='shares'>
    <a class='share cro' title='Zpět nahoru' href='#'><img src='https://samizdat.cz/tools/cro-logo/cro-logo-light.svg'></a>
    <a class='share fb' title='Sdílet na Facebooku' target='_blank' href='https://www.facebook.com/sharer/sharer.php?u=#shareUrl'><img src='https://samizdat.cz/tools/icons/facebook-bg-white.svg'></a>
    <a class='share tw' title='Sdílet na Twitteru' target='_blank' href='https://twitter.com/home?status=#shareUrl'><img src='https://samizdat.cz/tools/icons/twitter-bg-white.svg'></a>
  </div>"
  $body.prepend $shares

  sharesTop = $shares.offset!top
  sharesFixed = no

  onResize = ->
    $shares.removeClass \fixed if sharesFixed
    sharesTop := $shares.offset!top
    $shares.addClass \fixed if sharesFixed
    heroHeight = $hero.height!
    heroWidth = $hero.width!
    $filling.css \height heroHeight + 50
    mapOverlay.updateDimensions heroWidth, heroHeight

  onResize!
  $ window .bind \resize onResize



  $ window .bind \scroll ->
    top = (document.body.scrollTop || document.documentElement.scrollTop)
    if top > sharesTop and not sharesFixed
      sharesFixed := yes
      $shares.addClass \fixed
    else if top < sharesTop and sharesFixed
      sharesFixed := no
      $shares.removeClass \fixed
  $shares.find "a[target='_blank']" .bind \click ->
    window.open do
      @getAttribute \href
      ''
      "width=550,height=265"
  $shares.find "a.cro" .bind \click (evt) ->
    evt.preventDefault!
    d3.transition!
      .duration 800
      .tween "scroll" scrollTween 0
  <~ $
  $ '#aside' .remove!

scrollTween = (offset) ->
  ->
    interpolate = d3.interpolateNumber do
      window.pageYOffset || document.documentElement.scrollTop
      offset
    (progress) -> window.scrollTo 0, interpolate progress


barFields =
  * id : \population
    name: "Obyvatel"
    scale: null
    max: -Infinity
    format: -> "#{ig.utils.formatNumber it / 1e6, 1} mil."
  * id : \gdp
    name: "HDP"
    scale: null
    max: -Infinity
    format: -> "#{ig.utils.formatNumber it} USD / osoba"
  * id : \literacy
    name: "Gramotnost"
    scale: null
    max: -Infinity
    format: -> "#{ig.utils.formatNumber it, 1} %"
  * id : \life
    name: "Délka života"
    scale: null
    max: -Infinity
    format: -> "#{ig.utils.formatNumber it, 1} let"
  # * id : \hiv
  #   name:
  #   scale: null
  #   max: -Infinity
  # * id : \migration
  #   name:
  #   scale: null
  #   max: -Infinity

class MapOverlay
  cz: "Česká republika"

  (parentElement) ->
    @parentElement = d3.select parentElement
    @drawMap!
    @drawTooltips!

  drawMap: ->
    topo = ig.data["cover-geo"]
    features = topojson.feature topo, topo.objects."data" .features
    {width, height, projection} = ig.utils.geo.getFittingProjection do
      features
      1090

    @svg = @parentElement.append \svg
      ..attr \width width
      ..attr \height height
    path = d3.geo.path!
      ..projection projection
    @countryShapes = @svg.selectAll \path .data features .enter!append \path
      ..attr \d path
      ..on \mouseover @~highlightCountry
      ..on \mouseout @~downlightCountry
      ..on \click @~gotoCountry
    gambie = @countryShapes.filter -> it is features.1
    @svg.append \ellipse
      ..datum features.1
      ..attr \cx 20
      ..attr \cy 190
      ..attr \rx 50
      ..attr \ry 40
      ..on \mouseover ~>
        gambie.classed \active yes
        @highlightCountry it
      ..on \mouseout ~>
        gambie.classed \active no
        @downlightCountry it
      ..on \click @~gotoCountry

  drawTooltips: ->
    @tooltipContainer = @parentElement.append \div
      ..attr \class \tooltips
    dataAssoc = {}
    data = d3.tsv.parse ig.data["cover-data"], (row) ->
      row.fields = for field in barFields
        value = row[field.id] = parseFloat row[field.id]
        field.max = row[field.id] if row[field.id] > field.max
        {value, field}
      dataAssoc[row.name] = row
      row

    dataAssoc["Gambie"].x = 200
    dataAssoc["Gambie"].y = 500

    dataAssoc["Nigérie"].x = 720
    dataAssoc["Nigérie"].y = 470

    dataAssoc["Eritrea"].x = 970
    dataAssoc["Eritrea"].y = 410

    dataAssoc["Somálsko"].x = 1000
    dataAssoc["Somálsko"].y = 640

    dataAssoc["Mali"].x = 500
    dataAssoc["Mali"].y = 300

    @tooltips = @tooltipContainer.selectAll \div.tooltip .data data.slice 0, -1 .enter!append \div
      ..attr \class \tooltip
      ..append \span
        ..attr \class \title
        ..html (.name)
      ..append \div
        ..attr \class \fields
        ..selectAll \div.field .data (.fields) .enter!append \div
          ..attr \class \field
          ..html -> "#{it.field.name}: <b>#{it.field.format it.value}</b>"
        ..append \div
          ..attr \class \field
          ..html -> "Klikněte a přečtěte si o #{it.name2} víc"

  gotoCountry: (country) ->
    href = document.location.toString!split '#' .0
    document.location = href + '#' + country.properties.name_cze

  highlightCountry: (country) ->
    @tooltips.classed \active -> it.name is country.properties.name_cze

  downlightCountry: ->
    @tooltips.classed \active no

  updateDimensions: (parentWidth, parentHeight) ->
    xScale = parentWidth / 1600
    yScale = parentHeight / 1307
    ratio = Math.max xScale, yScale
    imageWidth = 1600 * ratio
    imageHeight = 1307 * ratio
    leftCorner = (parentWidth - imageWidth) / 2
    topCorner = (parentHeight - imageHeight) / 2
    baseLeft = 220
    baseTop = 290

    translateLeft = ratio  * baseLeft + (parentWidth - imageWidth) / 2
    translateTop = ratio * baseTop + (parentHeight - imageHeight) / 2

    transform = "translate(#{translateLeft}px, #{translateTop}px)"
    transform += " scale(#ratio)"
    @svg.style \transform transform
    @tooltips.style \transform ->
      "translate(#{ratio * it.x + leftCorner}px, #{ratio * it.y + topCorner}px)"
