require 'net/http'
require 'rexml/document'
require 'cgi'

module Uspstracking

  class TrackingInfo
    attr_accessor :eventTime, :eventDate, :event, :eventCity, :eventState, :eventZIPCode, :eventCountry, :firmName, :name, :authorizedAgent
  end  

  class Tracking
    attr_accessor :trackingNumber, :results

    def initialize(trackingNumber)
      @trackingNumber = trackingNumber
    end

    def results?
      @results.count > 0
    end

    def getTracking
      ti = []

      doc = ""

      host = 'production.shippingapis.com'

      # MUST FILL IN USERID FROM USPS:
      userid = ""


      vars = URI.escape('<TrackFieldRequest USERID="' + userid  + '"><TrackID ID="' + @trackingNumber + '"></TrackID></TrackFieldRequest>', Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

      begin
        http = Net::HTTP.new(host, 80)
        #http.use_ssl = false
        http.start { |http|
          http_request = Net::HTTP::Get.new('/ShippingAPI.dll?API=TrackV2&XML=' + vars, {"User-Agent" => "lib/uspstracking.rb jason.carr@gmail.com 0.1"})
          xml_data = http.request(http_request).body
          doc = REXML::Document.new(xml_data).root
        }

        p doc

        begin
          doc.elements.each('TrackInfo') { |ele|
            ele.elements.each { |e|

              te = TrackingInfo.new

              if e.elements['Number'] &&  e.elements['Number'].text 
                te.eventTime = te.eventDate = te.eventCity = te.eventState = eventZipCode = te.eventCountry = te.firmName = te.name = te.authorizedAgent = "n/a"
                te.event = "Error: #{e.elements['Number'].text} #{e.elements['Description'].text}"
              else
                te.eventTime = e.elements['EventTime'].text || "n/a"
                te.eventDate = e.elements['EventDate'].text || "n/a"
                te.event = e.elements['Event'].text || "n/a"
                e.elements['EventCity'].text ? te.eventCity = e.elements['EventCity'].text.downcase.split.each{|x|x.capitalize!}.join(' ') : te.eventCity = "Unknown" || "n/a"
                e.elements['EventState'].text ? te.eventState = e.elements['EventState'].text : te.eventState = "??" || "n/a"
                te.eventZIPCode = e.elements['EventZIPCode'].text || "n/a"
                te.eventCountry = e.elements['EventCountry'].text || "n/a"
                te.firmName = e.elements['FirmName'].text || "n/a"
                te.name = e.elements['Name'].text || "n/a"
                te.authorizedAgent = e.elements['AuthorizedAgent'].text || "n/a"
              end

              ti.push(te)
            }
          }

        rescue NoMethodError
          te = TrackingInfo.new
          te.eventTime = te.eventDate = te.eventCity = te.eventState = eventZipCode = te.eventCountry = te.firmName = te.name = te.authorizedAgent = "n/a"
          te.event = "Error: unknown error occured"

          ti.push(te)
        end


        @results = ti

        return  

      rescue SocketError
        raise "Host not available?"
      rescue REXML::ParseException => e
        print "error parsing XML " + e.to_s
      end
    end

  end

end
