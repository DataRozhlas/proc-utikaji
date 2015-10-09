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

class MapOverlay
  (parentElement) ->
    topo = ig.data.cover
    features = topojson.feature topo, topo.objects."data" .features
    {width, height, projection} = ig.utils.geo.getFittingProjection do
      features
      1038

    @element = d3.select parentElement .append \svg
      ..attr \width width
      ..attr \height height
    path = d3.geo.path!
      ..projection projection
    @element.selectAll \path .data features .enter!append \path
      ..attr \d path

  updateDimensions: (parentWidth, parentHeight) ->
    xScale = parentWidth / 1600
    yScale = parentHeight / 1170
    ratio = Math.max xScale, yScale
    imageWidth = 1600 * ratio
    imageHeight = 1170 * ratio
    leftCorner = (parentWidth - imageWidth) / 2
    topCorner = (parentHeight - imageHeight) / 2

    baseLeft = 284
    baseTop = 226

    translateLeft = ratio  * baseLeft + (parentWidth - imageWidth) / 2
    translateTop = ratio * baseTop + (parentHeight - imageHeight) / 2
    # console.log translateLeft, translateTop

    transform = "translate(#{translateLeft}px, #{translateTop}px)"
    transform += " scale(#ratio)"
    @element.style \transform transform
