CARTO_SQL_API_ENDPOINT = 'http://mapc-admin.carto.com/api/v2'

class School < ActiveRecord::Base
  belongs_to :district
  has_many :surveys

  after_save :update_sheds, if: :geometry_changed?

  scope :with_active_surveys, -> () {
    self.joins(:surveys)
        .where('surveys.begin <= ? AND surveys.end >= ?', DateTime.now, DateTime.now)
  }

  def wgs84_lat
    School.select('ST_X(ST_Transform(geometry,4326)), ST_Y(ST_Transform(geometry,4326)),id').find(id).st_y
  end

  def wgs84_lng
    School.select('ST_X(ST_Transform(geometry,4326)), ST_Y(ST_Transform(geometry,4326)),id').find(id).st_x
  end

  def has_active_survey?
    surveys.where('begin <= ? AND "end" >= ?', now, now).present?
  end

  def muni_id
    if read_attribute(:muni_id).nil?
      find_intersecting_municipality
    else
      read_attribute(:muni_id)
    end
  end

  def find_intersecting_municipality
    sql = "\
    SELECT muni_id FROM ma_municipalities \
    WHERE \
    ST_Intersects(\
        ST_Transform(the_geom, 26986), \
        ST_PointFromText ('#{geometry.to_s}', 26986)\
    )"

    uri = "#{CARTO_SQL_API_ENDPOINT}/sql?q=#{sql}"
    url = URI(uri)
    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Get.new(url)
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'
    response = http.request(request)
    json = JSON.parse(response.read_body)
    
    begin
      muni_id = JSON.parse(response.read_body)['rows'][0]['muni_id']
    rescue
      muni_id = nil
    end
    
    update_columns({
      muni_id: muni_id
    })

    muni_id
  end

  private 

    def update_sheds
      # TODO: active job or sidekick or rabbit mq
      sheds = WalkshedQuery.new(id).execute

      # adds sheds to columns
      update_columns({  shed_05: sheds[0]['_05'],
                        shed_10: sheds[0]['_10'],
                        shed_15: sheds[0]['_15'],
                        shed_20: sheds[0]['_20'] })

      # converts sheds into rings
      shed_10_ring = shed_10.difference(shed_05).to_s
      shed_15_ring = shed_15.difference(shed_10).to_s
      shed_20_ring = shed_20.difference(shed_15).to_s

      # updates with new rings
      update_columns({  shed_10: shed_10_ring,
                        shed_15: shed_15_ring,
                        shed_20: shed_20_ring  })
      
    end

    def now
      DateTime.now
    end

end

