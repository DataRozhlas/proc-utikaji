return unless ig.containers.population
container = d3.select ig.containers.population
countriesAssoc = {}
d3.csv.parse ig.data.population, (row) ->
  if not countriesAssoc[row.oblast]
    countriesAssoc[row.oblast] = {name: row.oblast, years: []}
  year = parseInt row.rok, 10
  population = parseFloat row.populace
  country = countriesAssoc[row.oblast]
    ..years.push {year, population}

displayedLines =
  countriesAssoc["Nigérie"]
  countriesAssoc["Evropa"]
  countriesAssoc["Afrika"]

width = 500
height = 350
margin =
  top: 0
  bottom: 20
  left: 60
  right: 40
container
  ..append \h3 .html "V Nigérii bude kolem roku 2080 žít více lidí, než v Evropě"
  ..append \h4 .html "Populace Afriky přesáhla evropskou již v 90. letech"
svg = container.append \svg
  ..attr \width width + margin.left + margin.right
  ..attr \height height + margin.top + margin.bottom
drawing = svg.append \g
  ..attr \transform "translate(#{margin.left},#{margin.top})"
yScale = d3.scale.linear!
  ..domain [0 4.39]
  ..range [height, 0]
xScale = d3.scale.linear!
  ..domain [1950 2100]
  ..range [0 width]

line = d3.svg.line!
  ..x -> xScale it.year
  ..y -> yScale it.population

drawing
  ..append \g .attr \class \lines
    ..selectAll \path .data displayedLines .enter!append \path
      ..attr \d -> line it.years
  ..append \g .attr \class \country-names
    ..selectAll \text .data displayedLines .enter!append \text
      ..text (.name)
      ..attr \y -> yScale it.years.0.population
      ..attr \dy 3
      ..attr \x -12
      ..attr \text-anchor \end

svg.append \g .attr \class "axis x"
  ..attr \transform "translate(#{margin.left}, #{margin.top + height})"
  ..append \line
    ..attr \x2 width
  ..selectAll \g.year .data [1950 to 2100 by 25] .enter!append \g
    ..attr \class \year
    ..attr \transform -> "translate(#{xScale it}, 0)"
    ..append \line
      ..attr \y2 5
    ..append \text
      ..text -> it
      ..attr \text-anchor \middle
      ..attr \y 17

drawing.append \rect
  ..attr \class \fade
  ..attr \width width
  ..attr \height 225

details = container.append \div
  ..attr \class \details
detailsYear = details.append \span .attr \class \year
detailsList = details.append \ul .selectAll \li .data displayedLines .enter!append \li
  ..append \span
    ..attr \class \name
    ..html -> "#{it.name}:"
  ..append \span
    ..attr \class \value

lineHeight = 20
highlightYear = (yearIndex, year) ->
  displayedLines.sort (a, b) -> b.years[yearIndex].population - a.years[yearIndex].population
  detailsYear.html "Rok #{year}"
  detailsList.style \top -> "#{lineHeight * displayedLines.indexOf it}px"
  detailsList.select \.value .html -> "<b>#{ig.utils.formatNumber it.years[yearIndex].population * 1e3}</b> mil."

highlightYear 5, 1975
yearWidth = (xScale 1955) - (xScale 1950)
svg.append \g .attr \class \interactivity
  ..attr \transform "translate(#{margin.left - yearWidth / 2},#{margin.top})"
  ..selectAll \rect .data [1950 to 2100 by 5] .enter!append \rect
    ..attr \x -> xScale it
    ..attr \y 225
    ..attr \width yearWidth
    ..attr \height height - 225
    ..on \mouseover (d, index) -> highlightYear index, d
    ..on \touchstart (d, index) -> highlightYear index, d
