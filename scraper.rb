require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper
  #url = "https://www.startech.com.bd/component/optical-hdd/external-optical-hdd"

  url = "https://www.startech.com.bd/laptop-notebook/laptop"

  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)

  # byebug


  product_array = Array.new
  products = parsed_page.css('div.product-thumb')

  # we will hard code page no and total products
  page = 1
  per_page = products.count
  total_products = parsed_page.css('div.col-md-6.rs-none.text-right').text.split[-3].to_i
  # actually I have hardcoded this. First I have taken the line where our pagination occuring in the end and I saw the total number there but in paragraph form. So I extract that line and then split that and found that number from indexing in string so we will convert that to integer.

  last_page = (total_products.to_f / per_page.to_f).round
  while page <= last_page
    pagination_url = "https://www.startech.com.bd/laptop-notebook/laptop?page=#{page}"

    puts pagination_url
    puts "Page: #{page}"
    puts " "
    pagination_unparsed_page = HTTParty.get(pagination_url)
    pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
    pagination_products = pagination_parsed_page.css('div.product-thumb')
    pagination_products.each  do|product|
      product ={
        #title: product.css('h4.product-name').text,
        title: product.css('a').text,
        price: product.css('span').first.text,
        url: product.css('a')[0].attributes["href"].value
      }
      product_array << product
      puts "Added #{product[:title]}"
      puts " "
    end
    page +=1
  end
  byebug
end
scraper

