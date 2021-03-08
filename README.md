This is a webscrapping tutorial I am following from youtube `https://www.youtube.com/watch?v=b3CLEUBdWwQ`
Follow the video.

So I am sharing the steps

Make Directory
`mkdir scraper`
Go to the directory
`cd scraper`
Make a gemfile
`touch Gemfile`
Make the script file for code
`touch scraper.rb`

add gems code in the gemfile

```
source "https://rubygems.org"
gem 'httparty'
gem 'nokogiri'
gem 'byebug'
```
`bunlde install`

We will now start coding in scraper.rb
we need the gemfiles in the code so we will add
```
require 'nokogiri'
require 'httparty'
require 'byebug'
```
now we will start coding by making a scraper function like this

```
def scraper
end
```

We will put the targetted url in the url varible
`url = "https://www.startech.com.bd/laptop-notebook/Gaming-Laptop"`
We made a get request to that to that url and get the raw html back from it
`unparsed_page = HTTParty.get(url)`
With the help of nokogiri we parsed that html into a format that we can extract data from it
`parsed_page = Nokogiri::HTML(unparsed_page)`


Add `byebug` and check
```
(byebug) url
"https://www.startech.com.bd/laptop-notebook/Gaming-Laptop"

```
We can check `unparsed_page` and `parsed_page` values also in the byebug panel

J will keep the parsed value
```
 j=parsed_page.css('div.product-thumb')

```
j.count will throw the products counted
```
(byebug) j.count
2

```
So if we want to extract any specific text/field we can do this like this(This will very on the css locations of the data fields)

Title
```
j_f = j.first
j_f.css('a')

(byebug) j_f.css('a').text
"Transcend TS8XDVDS-K Slim External Black DVD Writer"
```
URL
```
(byebug) j_f.css('a')[0].attributes["href"].value
"https://www.startech.com.bd/transcend-ts8xdvds-k-slim-external-dvd-writer"
```
Price
```
(byebug) j_f.css('span').first.text
"2,200৳"
```


we get the exact text format we want by this way

so we are updating the code
```
products.each  do|product|
    product ={
      title: product.css('a').text,
      price: product.css('span').first.text,
      url: "https://www.startech.com.bd/component/optical-hdd/external-optical-hdd"+product.css('a')[0].attributes["href"].value

    }
    byebug
  end
```

the output is now expected
```
(byebug) product[:title]
"Transcend TS8XDVDS-K Slim External Black DVD Writer"
(byebug) product[:price]
"2,200৳"
(byebug) product[:url]
"https://www.startech.com.bd/component/optical-hdd/external-optical-hddhttps://www.startech.com.bd/transcend-ts8xdvds-k-slim-external-dvd-writer"

```
Type this for iteration
```
(byebug) continue
```


we will put all the values in an array like this
```
require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper
  url = "https://www.startech.com.bd/component/optical-hdd/external-optical-hdd"
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)

 # byebug

 product_array = Array.new
  products = parsed_page.css('div.product-thumb')
  #products = parsed_page.css('div.row.main-content')
  products.each  do|product|
    product ={
      #title: product.css('h4.product-name').text,
      title: product.css('a').text,
      price: product.css('span').first.text,
      url: product.css('a')[0].attributes["href"].value
    }
    product_array << product
  end
  byebug
end
scraper

```
expected output is also fine
```

(byebug) product_array[1]
{:title=>"ASUS SDRW-08D2S-U LITE Eexternal Slim DVD Writer", :price=>"2,400৳", :url=>"https://www.startech.com.bd/asus-sdrw-08d2s-u-lite-eexternal-slim-dvd-writer"}
(byebug) product_array[0]
{:title=>"Transcend TS8XDVDS-K Slim External Black DVD Writer", :price=>"2,200৳", :url=>"https://www.startech.com.bd/transcend-ts8xdvds-k-slim-external-dvd-writer"}
(byebug) product_array.count
2
(byebug)

```


Now we will focus on pagination in scrapping
Page 1 will be our starting point for iteration
```
page = 1
```
we can find the total product (it is dynamic totally)
```
total_products = parsed_page.css('div.col-md-6.rs-none.text-right').text.split[-3].to_i
```

We can find the last page no via this ,this is automated
```
last_page = (total_products.to_f / per_page.to_f).round
```

This is the expected outcome
```
(byebug) total_products = parsed_page.css('div.col-md-6.rs-none.text-right').text.split[-3].to_i
475
(byebug) per_page = products.count
21
(byebug) last_page = (total_products.to_f / per_page.to_f).round
23

```

We added while loop that will iterate from page 1 to last page
Also we gave the pagination url with string interpolation of page variable and page will be incremented by 1 after each iteration.
```
while page <= last_page
    pagination_url = "https://www.startech.com.bd/laptop-notebook/laptop?page=#{page}"
    products.each  do|product|
      product ={
        #title: product.css('h4.product-name').text,
        title: product.css('a').text,
        price: product.css('span').first.text,
        url: product.css('a')[0].attributes["href"].value
      }
      product_array << product
    end
    page +=1
  end
```



So this is the final code . We have added nakigiri and httparty features thus they can extract data while pagination.
```

require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper
  #url = "https://www.startech.com.bd/component/optical-hdd/external-optical-hdd"

  url = "https://www.startech.com.bd/laptop-notebook/laptop"

  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)

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


```
