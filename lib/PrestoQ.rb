require "PrestoQ/version"
require 'json'

module PrestoQ
  class PrestoQParser
    YES_FLAG = 'Y'
    TAX_RATE = 7.775

    def transform_file(filename)
      output = []

      File.open(filename, "r") do |f|
        f.each_line do |line|
          output.append transform_product_hash(parse_line(line))
        end
      end

      File.write('sample_output.txt', output.to_json)

      output
    end

    def parse_line(line)
      {
        product_id: line[0..7].to_i,
        product_description: line[9..67].strip,
        regular_single_price: line[69..76].to_f / 100,
        promotional_singular_price: line[78..85].to_f / 100,
        regular_split_price: line[87..94].to_f / 100,
        promotional_split_price: line[96..103].to_f / 100,
        regular_for_x: line[105..112].to_i,
        promotional_for_x: line[114..121].to_i,
        flags: line[123..131].strip.split(''),
        product_size: line[132..142].strip
      }
    end

    def transform_product_hash(product_hash)
      regular_use_single = product_hash[:regular_single_price] != 0
      has_promotional_price = product_hash[:promotional_singular_price] != 0 || product_hash[:promotional_split_price] != 0
      promotional_use_single = product_hash[:promotional_singular_price] != 0 ? product_hash[:promotional_singular_price] : product_hash[:promotional_split_price]
      unit_of_measure = product_hash[:flags][2] == YES_FLAG ? 'per pound' : 'each'

      if regular_use_single
        regular_display_price = "$#{sprintf('%0.02f', product_hash[:regular_single_price])} #{unit_of_measure}"
        regular_calculator_price = product_hash[:regular_single_price]
      else
        regular_display_price =  "#{product_hash[:regular_for_x]} for $#{sprintf('%0.02f', product_hash[:regular_split_price])}"
        regular_calculator_price = product_hash[:regular_split_price] / product_hash[:regular_for_x]
      end

      if has_promotional_price
        if promotional_use_single
          promotional_display_price = "$#{sprintf('%0.02f', promotional_use_single)} #{unit_of_measure}"
          promotional_calculator_price = product_hash[:promotional_singular_price]
        else
          promotional_display_price = "#{product_hash[:promotional_for_x]} for $#{sprintf('%0.02f', product_hash[:promotional_split_price])}"
          promotional_calculator_price = product_hash[:promotional_split_price] / product_hash[:promotional_for_x]
        end
      end

      product_hash.slice(:product_id, :product_description, :product_size).merge(
        {
          regular_display_price: regular_display_price,
          regular_calculator_price: regular_calculator_price.round(4, half: :down),
          promotional_display_price: promotional_display_price,
          promotional_calculator_price: promotional_calculator_price ? promotional_calculator_price.round(4, half: :down) : nil,
          unit_of_measure: unit_of_measure,
          tax_rate: product_hash[:flags][4] == YES_FLAG ? TAX_RATE : nil
        }.compact
      )
    end
  end
end
