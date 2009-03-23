###############################################################################
#
# A test for Spreadsheet::WriteExcel.
#
# Check that the Excel DIMENSIONS record is written correctly.
#
# reverse('©'), October 2007, John McNamara, jmcnamara@cpan.org
#
# original written in Perl by John McNamara
# converted to Ruby by Hideo Nakamura, cxn03651@msj.biglobe.ne.jp
#
############################################################################
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require "test/unit"
require 'writeexcel'

class TC_dimensions < Test::Unit::TestCase

  def setup
    t = Time.now.strftime("%Y%m%d")
    path = "temp#{t}-#{$$}-#{rand(0x100000000).to_s(36)}"
    @test_file           = File.join(Dir.tmpdir, path)
    @workbook            = Spreadsheet::WriteExcel.new(@test_file)
    @worksheet           = @workbook.add_worksheet
    @format              = @workbook.add_format
    @dims                = ['row_min', 'row_max', 'col_min', 'col_max']
    @smiley              = [0x263a].pack('n')
  end

  def teardown
    @workbook.close
    File.unlink(@test_file) if FileTest.exist?(@test_file)
  end

  def test_no_worksheet_cell_data
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([0, 0, 0, 0])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_data_in_cell_0_0
    @worksheet.write(0, 0, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([0, 1, 0, 1])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_data_in_cell_0_255
    @worksheet.write(0, 255, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([0, 1, 255, 256])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_data_in_cell_65535_0
    @worksheet.write(65535, 0, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([65535, 65536, 0, 1])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_data_in_cell_65535_255
    @worksheet.write(65535, 255, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([65535, 65536, 255, 256])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_set_row_for_row_4
    @worksheet.set_row(4, 20)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([4, 5, 0, 0])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_set_row_for_row_4_to_6
    @worksheet.set_row(4, 20)
    @worksheet.set_row(5, 20)
    @worksheet.set_row(6, 20)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([4, 7, 0, 0])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_set_column_for_row_4
    @worksheet.set_column(4, 4, 20)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([0, 0, 0, 0])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_data_in_cell_0_0_and_set_row_for_row_4
    @worksheet.write(0, 0, 'Test')
    @worksheet.set_row(4, 20)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([0, 5, 0, 1])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_data_in_cell_0_0_and_set_row_for_row_4_reverse_order
    @worksheet.set_row(4, 20)
    @worksheet.write(0, 0, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([0, 5, 0, 1])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_data_in_cell_5_3_and_set_row_for_row_4
    @worksheet.write(5, 3, 'Test')
    @worksheet.set_row(4, 20)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([4, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_comment_in_cell_5_3
    @worksheet.write_comment(5, 3, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_nil_value_for_row
    error = @worksheet.write_string(nil, 1, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([0, 0, 0, 0])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
    assert_equal(-2, error)
  end

  def test_data_in_cell_5_3_and_10_1
    @worksheet.write( 5, 3, 'Test')
    @worksheet.write(10, 1, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 11, 1, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_data_in_cell_5_3_and_10_5
    @worksheet.write( 5, 3, 'Test')
    @worksheet.write(10, 5, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 11, 3, 6])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_write_string
    @worksheet.write_string(5, 3, 'Test')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_write_number
    @worksheet.write_number(5, 3, 5)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_write_url
    @worksheet.write_url(5, 3, 'http://www.ruby.com')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_write_formula
    @worksheet.write_formula(5, 3, ' 1 + 2')
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_write_blank
    @worksheet.write_string(5, 3, @format)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_write_blank_no_format
    @worksheet.write_string(5, 3)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([0, 0, 0, 0])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_write_utf16be_string
    @worksheet.write_utf16be_string(5, 3, @smiley)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_write_utf16le_string
    @worksheet.write_utf16le_string(5, 3, @smiley)
    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_repeat_formula
    formula = @worksheet.store_formula('=A1 * 3 + 50')
    @worksheet.repeat_formula(5, 3, formula, @format, 'A1', 'A2')

    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 6, 3, 4])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

  def test_merge_range
    formula = @worksheet.store_formula('=A1 * 3 + 50')
    @worksheet.merge_range('C6:E8', 'Test', @format)

    data     = @worksheet.store_dimensions

    vals     = data.unpack('x4 VVvv')
    alist    = @dims.zip(vals)
    results  = Hash[*alist.flatten]

    alist    = @dims.zip([5, 8, 2, 5])
    expected = Hash[*alist.flatten]

    assert_equal(expected, results)
  end

end
