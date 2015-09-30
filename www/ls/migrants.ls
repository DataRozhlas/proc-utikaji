return unless ig.containers.migrants
container = d3.select ig.containers.migrants
months = <[2013-01-01 2013-02-01 2013-03-01 2013-04-01 2013-05-01 2013-06-01 2013-07-01 2013-08-01 2013-09-01 2013-10-01 2013-11-01 2013-12-01 2014-01-01 2014-02-01 2014-03-01 2014-04-01 2014-05-01 2014-06-01 2014-07-01 2014-08-01 2014-09-01 2014-10-01 2014-11-01 2014-12-01 2015-01-01 2015-02-01 2015-03-01 2015-04-01 2015-05-01 2015-06-01 2015-07-01]>
data = d3.csv.parse ig.data['odkud-utikaji'], (row) ->
  subtotal = 0
  previousValue = 0
  row.months = for month in months
    value = parseInt row[month], 10
    subtotal += previousValue
    previousValue = value
    {value, subtotal}
  row.africa = row.afrika == "TRUE"
  row.total = parseInt row.celkem, 10
  row.countryName = ig.countryCodes[row.citizen]
  row

data.length = 20

lineHeight = 36px

xScale = d3.scale.linear!
  ..domain [0 data.0.total]
  ..range [0 100]

container
  ..append \h3
    ..html "Nejvýznamnějšími zdroji afrických migrantů jsou Eritrea, Nigérie, Somálsko, Mali a Gambie"
  ..append \h4
    ..html "Od roku 2013 z nich uteklo téměř 200 000 lidí"


list = container.append \ul
for datum in data
  datum.element = list.append \li
    ..classed \africa datum.africa
    ..datum datum
    ..append \span
      ..attr \class \title
      ..html (.countryName)
    ..append \div
      ..attr \class \bar
      ..append \div
        ..attr \class \item
        ..style \width -> "#{xScale it.total}%"
      ..append \div
        ..attr \class "count service"
        ..style \left -> "#{xScale it.total}%"
        ..html -> "#{ig.utils.formatNumber it.total}"
      ..append \div
        ..attr \class \months
    ..append \div
      ..attr \class \overlay
      ..on \mouseover (datum) ->
        datum.highlightRequested = yes
        <~ setTimeout _, 200
        return unless datum.highlightRequested
        highlightItem datum
      ..on \mouseout ->
        it.highlightRequested = false
        downlightItem it

highlightItem = (datum) ->
  if datum.downlighting
    datum.highlightQueued = yes
    return
  datum.highlightQueued = no
  datum.highlighting = yes
  datum.element.classed \active yes
  subItems = datum.element.select \.months
    ..classed \active yes
    ..selectAll \div.month .data datum.months
      ..enter!append \div
        ..style \width -> "#{xScale it.value}%"
      ..style \left -> "#{xScale it.subtotal}%"
      ..attr \class \month
      ..transition!
        ..delay (d, i) -> 200 + i * 25
        ..attr \class "month rotated"
        ..style \left (d, i) -> "#{i * 11}px"
    ..selectAll \div.year .data [2013 to 2015] .enter!append \div
      ..attr \class \year
      ..html -> it
      ..style \left (d, i) -> "#{i * 12 * 11 - 6}px"
      ..transition!
        ..delay (d, i) -> i * 12 * 25
        ..style \opacity 1
  setTimeout do
    ->
      datum.highlighting = no
      if datum.downlightQueued
        downlightItem datum
    200 + datum.months.length * 25

downlightItem = (datum) ->
  if datum.highlighting
    datum.downlightQueued = yes
    return
  datum.downlightQueued = no
  datum.downlighting = yes
  datum.element.classed \active no
  months = datum.element.selectAll \div.month
  months.attr \class "month"
  years = datum.element.selectAll \div.year
    ..style \opacity 0
  <~ setTimeout _, 200
  months.style \left -> "#{xScale it.subtotal}%"
  <~ setTimeout _, 200
  months.attr \class "month tall"
  <~ setTimeout _, 200
  datum.element.select \.months .classed \active no
  months.attr \class "month tall exiting"
  <~ setTimeout _, 200
  datum.element.classed \active no
  years.remove!
  months.remove!
  datum.downlighting = no
  if datum.highlightQueued
    highlightItem datum

# <~ setTimeout _, 1000
# highlightItem data.0
# <~ setTimeout _, 2000
# downlightItem data.0
