# encoding: utf-8
module Utf8Converter

	def self.geo
		['ა','ბ','გ','დ','ე','ვ','ზ','თ','ი','კ','ლ','მ','ნ','ო','პ','ჟ',
		'რ','ს','ტ','უ','ფ','ქ','ღ','ყ','შ','ჩ','ც','ძ','წ','ჭ','ხ','ჯ','ჰ']
	end

	def self.eng
		['a','b','g','d','e','v','z','T','i','k','l','m','n','o','p','zh','r',
		's','t','u','f','q','gh','y','sh','ch','c','dz','ts','ch','kh','j','h']
	end

  def self.convert_ka_to_en (text)
    geo.each_with_index do |v, i|
      text.gsub! /#{v}/, eng[i]
    end
    return text
  end

end
