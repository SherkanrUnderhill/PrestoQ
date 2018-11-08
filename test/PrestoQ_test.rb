require "test_helper"

class PrestoQTest < Minitest::Test
  def setup
    @parser = PrestoQ::PrestoQParser.new
  end

  def test_read_file
    @parser.transform_file("sample_input.txt")

    assert_equal [
      {
        product_id: 80000001,
        product_description: 'Kimchi-flavored white rice',
        product_size: '18oz',
        regular_display_price: '$5.67 each',
        regular_calculator_price: 5.67,
        unit_of_measure: 'each'
      },
      {
        product_id: 14963801,
        product_description: 'Generic Soda 12-pack',
        product_size: '12x12oz',
        regular_display_price: '2 for $13.00',
        regular_calculator_price: 6.5,
        promotional_display_price: '$5.49 each',
        promotional_calculator_price: 5.49,
        unit_of_measure: 'each',
        tax_rate: 7.775
      },
      {
        product_id: 40123401,
        product_description: 'Marlboro Cigarettes',
        product_size: '',
        regular_display_price: '$100.00 each',
        regular_calculator_price: 100.0,
        promotional_display_price: '$5.49 each',
        promotional_calculator_price: 5.49,
        unit_of_measure: 'each'
      },
      {
        product_id: 50133333,
        product_description: 'Fuji Apples (Organic)',
        product_size: 'lb',
        regular_display_price: '$3.49 per pound',
        regular_calculator_price: 3.49,
        unit_of_measure: 'per pound'
      },
      {
        product_id: 11111111,
        product_description: 'Swedish Fish',
        product_size: '',
        regular_display_price: '3 for $1.00',
        regular_calculator_price: 0.3333,
        unit_of_measure: 'each'
      }
    ].to_json, File.read('sample_output.txt')
  end
end
