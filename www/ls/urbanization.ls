return unless ig.containers.urbanization
container = d3.select ig.containers.urbanization
data = d3.csv.parse ig.data.urbanization, (row) ->
  year = parseInt row.rok, 10
  row.years = for year in [1960 to 2011]
    percentage = parseFloat row[year]
    {year, percentage}
  row.name = row.country
  row

displayedLines = data


width = 498
height = 250
margin =
  top: 20
  bottom: 20
  left: 60
  right: 70
container
  ..append \h3 .html "Obyvatelé Gambie se hromadně stěhují do měst"
svg = container.append \svg
  ..attr \width width + margin.left + margin.right
  ..attr \height height + margin.top + margin.bottom
yScale = d3.scale.linear!
  ..domain [0 58]
  ..range [height, 0]
xScale = d3.scale.linear!
  ..domain [1960 2011]
  ..range [0 width]

line = d3.svg.line!
  ..x -> xScale it.year
  ..y -> yScale it.percentage

svg.append \g .attr \class "axis x"
  ..attr \transform "translate(#{margin.left}, #{margin.top + height})"
  ..append \line
    ..attr \x2 width
  ..selectAll \g.year .data [1960 to 2010 by 10] .enter!append \g
    ..attr \class \year
    ..attr \transform -> "translate(#{xScale it}, 0)"
    ..append \line
      ..attr \y2 5
    ..append \text
      ..text -> it
      ..attr \text-anchor \middle
      ..attr \y 17

svg.append \g .attr \class "axis y"
  ..attr \transform "translate(#{margin.left}, #{margin.top})"
  ..append \line
    ..attr \y2 height
  ..selectAll \g.year .data [0 to 55 by 10] .enter!append \g
    ..attr \class \year
    ..attr \transform -> "translate(0, #{yScale it})"
    ..append \line
      ..attr \x2 -5
    ..append \text
      ..text -> "#it %"
      ..attr \text-anchor \end
      ..attr \dx -10
      ..attr \y 4
    ..filter (-> it)
      ..append \line
        ..attr \x2 width
        ..attr \class \extent

drawing = svg.append \g
  ..attr \transform "translate(#{margin.left},#{margin.top})"

drawing
  ..append \g .attr \class \lines
    ..selectAll \path .data displayedLines .enter!append \path
      ..attr \d -> line it.years
  ..append \g .attr \class \country-names
    ..selectAll \text .data displayedLines .enter!append \text
      ..text (.name)
      ..attr \y -> yScale it.years[*-1].percentage
      ..attr \dy ->
        switch it.name
        | "Somálsko" => 0
        | "Mali" => 6
        | otherwise  => 3
      ..attr \x width + 8
      ..attr \text-anchor \start

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
  displayedLines.sort (a, b) -> b.years[yearIndex].percentage - a.years[yearIndex].percentage
  detailsYear.html "Rok #{year}"
  detailsList.style \top -> "#{lineHeight * displayedLines.indexOf it}px"
  detailsList.select \.value .html -> "<b>#{ig.utils.formatNumber it.years[yearIndex].percentage, 1}</b> %."

highlightYear 51, 2011
yearWidth = (xScale 1961) - (xScale 1960)
svg.append \g .attr \class \interactivity
  ..attr \transform "translate(#{margin.left - yearWidth / 2},#{margin.top})"
  ..selectAll \rect .data [1960 to 2011] .enter!append \rect
    ..attr \x -> xScale it
    ..attr \y 0
    ..attr \width yearWidth
    ..attr \height height - 0
    ..on \mouseover (d, index) -> highlightYear index, d
    ..on \touchstart (d, index) -> highlightYear index, d
