module AppSpecHelper

  def create_spec_airports
    [
      create(:airport, {
        id: 1,
        iata_code: 'SZG',
        icao_code: 'LOWS',
        name: 'Salzburg Airport',
        asciiname: 'Salzburg Airport',
        coordinates: '(13.00433, 47.7933)',
        country_code: 'AT',
        country_name: 'Austria',
        continent_name: 'Europe'
      }),
      create(:airport, {
        id: 2,
        iata_code: 'VIE',
        icao_code: 'LOWW',
        name: 'Vienna International Airport',
        asciiname: 'Vienna International Airport',
        coordinates: '(16.55751, 48.1221)',
        country_code: 'AT',
        country_name: 'Austria',
        continent_name: 'Europe'
      }),
      create(:airport, {
        id: 3,
        iata_code: 'JFK',
        icao_code: 'KJFK',
        name: 'John F. Kennedy International Airport',
        asciiname: 'John F. Kennedy International Airport',
        coordinates: '(-73.77874, 40.63983)',
        country_code: 'US',
        country_name: 'United States',
        continent_name: 'North America'
      }),
      create(:airport, {
        id: 4,
        iata_code: 'BOS',
        icao_code: 'KBOS',
        name: 'Logan International Airport',
        asciiname: 'Logan International Airport',
        coordinates: '(-71.01777, 42.36514)',
        country_code: 'US',
        country_name: 'United States',
        continent_name: 'North America'
      })
    ]
  end

  def delete_spec_airports
    DB[Sequel[:public][:airports]].delete
  end
# SZG^LOWS^^Y^6299671^^Salzburg Airport^Salzburg Airport^47.7933^13.00433^S^AIRP^0.03428740722555867^^^^AT^^Austria^Europe^05^Salzburg^Salzburg^501^Salzburg Stadt^Salzburg Stadt^50101^^0^430^419^Europe/Vienna^1.0^2.0^1.0^2018-07-29^SZG^Salzburg^SZG|2766824|Salzburg|Salzburg|AT|^^^A^https://en.wikipedia.org/wiki/Salzburg_Airport^de|Flughafen Salzburg|p=en|Salzburg Airport|p=sv|Salzburg flygplats|p=en|Salzburg Airport W. A. Mozart|=fa|فرودگاه زالتسبورگ|=wuu|萨尔茨堡机场|=ru|Аэропорт Зальцбург имени В. А. Моцарта|=ja|ザルツブルク空港|=he|נמל התעופה זלצבורג|=fr|Aéroport de Salzbourg-W.-A.-Mozart|^403^Austria^EUR^ATSZG|^^^
# VIE^LOWW^^Y^2761335^^Vienna International Airport^Vienna International Airport^48.1221^16.55751^S^AIRP^0.2942276462185443^^^^AT^^Austria^Europe^03^Lower Austria^Lower Austria^307^Politischer Bezirk Bruck an der Leitha^Politischer Bezirk Bruck an der Leitha^30740^^0^182^177^Europe/Vienna^1.0^2.0^1.0^2017-06-16^VIE^Vienna^VIE|2761369|Vienna|Vienna|AT|^^^A^https://en.wikipedia.org/wiki/Vienna_International_Airport^de|Flughafen
# JFK^KJFK^JFK^Y^5122732^^John F. Kennedy International Airport^John F. Kennedy International Airport^40.63983^-73.77874^S^AIRP^0.31048316444100454^^^^US^^United States^North America^NY^New York^New York^081^Queens County^Queens County^^^0^3^8^America/New_York^-5.0^-4.0^-5.0^2016-02-14^NYC^New York City^NYC|5128581|New York City|New York City|US|NY^^NY^A^https://en.wikipedia.org/wiki/John_F._Kennedy_International_Airport^es|Aeropuert
# BOS^KBOS^BOS^Y^4937646^^Logan International Airport^Logan International Airport^42.36514^-71.01777^S^AIRP^0.2888359959668909^^^^US^^United States^North America^MA^Massachusetts^Massachusetts^025^Suffolk County^Suffolk County^07000^^0^3^9^America/New_York^-5.0^-4.0^-5.0^2019-04-03^BOS^Boston^BOS|4930956|Boston|Boston|US|MA^^MA^A^https://en.wikipedia.org/wiki/Logan_International_Airport^en|Logan International Airport|ps=yue|爱德华·劳伦斯·洛根将军国际机场|=th|ท่าอากาศยานนานาชาติโลแกน|=ru|Международный аэропорт Логан|=ja|ジェネラル・エドワード・ローレンス・ローガン国際空港|=mr|लोगन आंतरराष्ट्रीय विमानतळ|=he|נמל התעופה הבינלאומי לוגן|=hi|लोगान हवाई अड्डा|=ko|로건 국제공항|=fr|Aéroport international de Boston-Logan|=en|General Edward Lawrence Logan International Airport|=fa|فرودگاه بین‌المللی لوگان|=es|Aeropuerto Internacional Logan|=ar|مطار لوجان الدولي|=it|Aeroporto Internazionale Generale Edward Lawrence Logan|=nl|Internationale luchthaven Boston|=ca|Aeroport Internacional Logan|=eo|Internacia Flughaveno de Bostono|=fi|Loganin kansainvälinen lentoasema|=id|Bandar Udara Internasional Logan|=no|Logan internasjonale lufthavn|=tg|Фурудгоҳи Байн‌алмиллалии Логан|=vi|Sân bay quốc tế Logan|=pl|Port lotniczy Boston|=pt|Aeroporto Internacional de Boston|=ru|Логан|=zh|爱德华·劳伦斯·洛根将军国际机场|=en|Boston Logan International Airport|=|Logan Airport|=en|Boston Logan Airport|p=en|Gene
end
