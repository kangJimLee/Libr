class DoubanBooksWorker

  include Sidekiq::Worker

  def perform(user_id, name)
    user = User.find_by_id user_id
    count = 40
    total = 0
    start = 0
    while (start == 0) || (total-start > count)
      result = RestClient.get "http://api.douban.com/v2/book/user/#{name}/collections?start=#{start}&count=#{count}"
      json = JSON.parse(result)
      logger.info "get books from douban user:==== #{json}"
      storeBooks(json, user)
      total = json['total']
      start += count
    end
  end


  def storeBooks(json, user)
    collections = json['collections']
    logger.error "--------------------#{collections}"
    collections.each { |collection|

      logger.warn "!!!!!!!!!!!! #{collection}\n"

      book = collection['book']
      Book.create_book_by_isbn book unless Book.find_by_isbn book['isbn13']
      user.create_book_instance book['isbn13']
    }
  end

end