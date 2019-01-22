class Scrapper

  def get_cities_names
    cities_array = Array.new
    page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise"))
    #The page where to scrap all the cities names.
    page.css('a[href*="./95/"]').each do |node|
      #Cities names are all in upcase and with spaces
      cities_array << node.text.downcase.tr(" ", "-")
      #Trimes the "spaces", replaced them by "-" and downcase the cities
    end
    return cities_array
  end

  def get_cities_emails(cities_names)
    emails_array = Array.new
    i = 0
    #Get to know how the scrapping is going
    for city in cities_names
      i += 1
      puts i

      page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/95/" + city))
      #Example: "https://www.annuaire-des-mairies.com/95/avernes.html"
      city_email = page.css('tbody tr:nth-child(4) td:nth-child(2)')
      #Example:
      #<td>mairie.avernes@orange.fr</td>
      #<td>Avernois, Avernoises</td>
      #<td>1148000</td>
      city_email = city_email[0]
      #[0] is use to get only: <td>mairie.avernes@orange.fr</td>
      emails_array << city_email.text
      #mairie.avernes@orange.fr
    end
    return emails_array
  end

  def perform
    hash_final = Hash[get_cities_names.zip(get_cities_emails(get_cities_names))]
    #h = Hash[ary_a.zip(ary_b)] #cré un nouvel Hash de 2 arrays
    return hash_final
  end

  def to_json
    File.write("db/email.JSON",perform.to_json)
  end

  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config("config.json")
    #google_hash = perform
    i = 0
    hash_test = perform
    #We only use perform once by created a new hash
    ws = session.spreadsheet_by_key("1FXkW8uXFQShvi1oO_nDawHPrmlUTDBx0qRYqrphN6t0").worksheets[0]
    #Using the key of our spreadsheet's URL
    hash_test.each do |key, value|
      i += 1
      ws[i, 1] = key
      #first column
      ws[i, 2] = value
      #second column
    end
    ws.save
    #without ws.save there is no change on your actual spreadsheet

  end

  def save_as_csv
    csv_hash = perform
    #We only use perform once by created a new hash
    CSV.open("db/email.csv", "w") do |csv|
      #CSV.open("data2.csv", "a") {|csv| perform.each {|elem| csv << elem} }
      csv << csv_hash.values
      #first row
      csv << csv_hash.keys
      #second row
    end
  end

  def choose_a_saving
    puts "Choose a way of saving: "
    puts "Save in Json: (1)"
    puts "Save in Google Spreadsheet: (2)"
    puts "Save in CSV: (3)"

    choice = gets.to_i

    if choice == 1
      to_json
    elsif choice == 2
      save_as_spreadsheet
    elsif choice == 3
      save_as_csv
    end


  end

  private :get_cities_names, :get_cities_emails

end