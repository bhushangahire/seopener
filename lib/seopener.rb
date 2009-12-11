# Seopener


# Patch periodically_call_remote to set a javascript variable,
# so that we can call .stop() on it later
module ActionView::Helpers::PrototypeHelper
  def periodically_call_remote(options = {})
    variable = options[:variable] ||= 'poller'
    frequency = options[:frequency] ||= 10
    code = "#{variable} = new PeriodicalExecuter(function() {#{remote_function(options)}}, #{frequency})"
    javascript_tag(code)
  end
end

# Add to_csv to Array, so we can call it on ActiveRecord collections
class Array
  def to_csv(options = {})
    return '' if self.empty?

    if self.first.respond_to?(:to_csv)
      headers = self.first.to_csv_headers if self.first.respond_to?(:to_csv_headers)

      output = FasterCSV.generate_line(headers) if headers
      self.each do |item|
        output += item.to_csv
      end
      output

    else
      attributes = self.first.attributes.keys.collect { |c| c.to_sym }

      if options[:only]
        columns = Array(options[:only]) & attributes
      else
        columns = attributes - Array(options[:except])
      end

      columns += Array(options[:methods])

      return '' if columns.empty?

      output = FasterCSV.generate do |csv|
        csv << columns unless options[:headers] == false
        self.each do |item|
          csv << columns.collect { |column| item.send(column) }
        end
      end
      output
    end
  end
end
