

#http://developer.fortnox.se/examples/code-examples/ruby/

require 'uri'
require 'net/https'
require 'json'
require 'ostruct'  #for openstruct
require 'logger'

require_relative 'school'
require_relative 'district'


class BBT

  attr_accessor :access_token


  def initialize(access_token)
  	
  	@access_token = access_token

  	#set up the logger
    @my_logger = Logger.new(STDOUT)
    @my_logger.level = Logger::DEBUG

  end
  
  

  def execute_request( endpoint, body = nil )
    
    #uri = URI.parse( BASE_URL + endpoint )
    uri = URI.parse( endpoint )
    http = Net::HTTP.new( uri.host, uri.port )
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
    request = yield( uri )
  
    request[ 'Accept' ] = 'application/json'
    
    request[ 'X-Auth-Token' ] = @access_token
    
  
    if( body )
      request[ 'Content-Type' ] = 'application/json'
      request.body = body.to_json
    end
  
    response = http.request( request )
    #JSON.parse( response.body, object_class: OpenStruct ) if response.body
    JSON.parse( response.body ) if response.body
  end


  
  def get( endpoint )
    
    #@my_logger.debug 
    execute_request( endpoint ) do |uri|
      Net::HTTP::Get.new( uri.request_uri )
    end


  end

end



# get the data from the end point
a = BBT.new('c276039b-a568-40d2-88ea-099da65acf39')

# get the school districts
result = a.get('http://challenge.brightbytes.net/api/v1/districts/self')

puts ("result is = #{result.inspect}")



district_data = result['data']['district']
puts "district_data is #{district_data}"

#district_data is {"code"=>"ZVTWOG-EF", "name"=>"Jacobs District", "schools"=>[{"code"=>"VI5K0Z-91", "name"=>"Connelly Elementary School", "type"=>"ES", "students"=>355, "score"=>1253}, {"code"=>"P9IDXX-NF", "name"=>"Zieme Elementary School", "type"=>"ES", "students"=>280, "score"=>1125}, {"code"=>"UQP34L-5W", "name"=>"Barrows Elementary School", "type"=>"ES", "students"=>259, "score"=>1279}, {"code"=>"FU57YV-I7", "name"=>"Corwin Elementary School", "type"=>"ES", "students"=>250, "score"=>872}, {"code"=>"2GFOLA-DI", "name"=>"Schroeder Middle School", "type"=>"MS", "students"=>1166, "score"=>1290}, {"code"=>"L00O1Z-VJ", "name"=>"Tillman High School", "type"=>"HS", "students"=>1125, "score"=>1241}]}

schools = []

#district.code = district_data["code"]
#district.name = district_data["name"]

#create the district
district = District.new(district_data["code"], district_data["name"])
puts "District is #{district.inspect}"

schools_data = district_data["schools"]

puts "Schools_data are #{schools_data.inspect}"

schools = schools_data.map do |i|

	
  School.new(i['code'], i['name'], i['type'], i['students'], i['score'])

end

schools.each { | i| puts "\n\nSchool is #{i.inspect}"}
puts "District is #{district.inspect}"






#get the match district data
b = BBT.new('c276039b-a568-40d2-88ea-099da65acf39')

# get the match districts
result_2 = b.get('http://challenge.brightbytes.net/api/v1/districts/selections')


puts "================================================="

puts "\n\n"
puts ("result_2 :")
puts (result_2)


matching_district_data = result_2['data']['districts']

match_dist_array = []
match_dist = {}

matching_district_data.each do |i|

	match_dist_h = Hash.new 

	d = District.new(i['code'], i['name'])

	puts "Match district is #{d.inspect}"

    # store disct into a hash
	match_dist_h['district'] = d

    school_array = Array.new
	i['schools'].each do |schl|

		a_school = School.new(schl['code'], schl['name'], schl['type'], schl['students'], schl['score'])

		school_array << a_school


	end

	match_dist_h['schools'] = school_array

    # store array of hash
	match_dist_array = match_dist_h


end


#debug print
match_dist_array.each_with_index do |m, idx|

	puts "\n\n======================"
	puts "Matching District #{idx}: #{m.inspect}"
end


puts "END"