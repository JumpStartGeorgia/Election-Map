# encoding: utf-8
#
require 'csv' # adds a .to_csv method to Array instances
class Array
  BOM = "\xEF\xBB\xBF" #Byte Order Mark UTF-8
  alias old_to_csv to_csv #keep reference to original to_csv method
  def to_csv(options = Hash.new)
    options = options.merge(:force_quotes => true)
    # override only if first element actually has as_csv method
    return old_to_csv(options) unless self.first.respond_to? :as_csv
    # use keys from first row as header columns
    out = first.as_csv.keys.collect{|k| k.to_s.titleize }.to_csv(options)
    # collect all entries as CSV, ensure that no line break is present within values
    self.each { |r| out << r.as_csv.values.to_csv(options).gsub(/\r?\n/, ' ').strip! + "\n" }
    # Force encoding to UTF-16LE and add Byte Order Mark for Excel compatibility
    (BOM + out).force_encoding("UTF-8")
  end
  def to_tsv(options = Hash.new)
    to_csv(options.merge(:col_sep => "\t"))
  end
end
ActionController::Renderers.add :csv do |csv, options|
  csv = csv.respond_to?(:to_csv) ? csv.to_csv() : csv
  self.content_type ||= Mime::CSV
  self.response_body = csv
end
ActionController::Renderers.add :tsv do |tsv, options|
  tsv = tsv.respond_to?(:to_tsv) ? tsv.to_tsv() : tsv
  self.content_type ||= Mime::TSV
  self.response_body = tsv
end
