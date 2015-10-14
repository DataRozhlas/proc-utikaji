return unless ig.containers.military
container = d3.select ig.containers.military

container.append \h3
  ..html "Eritrea dává na armádu pětinu svého HDP"
countries =
  * name: "Gambie"
    gdp: 0.79
  * name: "Mali"
    gdp: 1.51
  * name: "Nigérie"
    gdp: 0.58
  * name: "Somálsko"
    gdp: 0.75
  * name: "Česko"
    gdp: 1.09
  * name: "Eritrea"
    gdp: 20.87

scale = d3.scale.linear!
  ..domain [0 21]
  ..range [0 100]

container.append \div
  ..attr \class \barchart
  ..selectAll \div.country .data countries .enter!append \div
    ..attr \class \country
    ..append \div
      ..attr \class \bar
      ..style \height -> "#{scale it.gdp}%"
      ..append \span
        ..attr \class \value
        ..html -> "#{ig.utils.formatNumber it.gdp, 2} %"
      ..append \span
        ..attr \class \name
        ..html (.name)
