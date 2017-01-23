class EntryRepository
  include Enumerable
  def initialize(db)
    @db = db
    @entries = []
    @entries.length - 1
  end
  def save(entry)
    columns = ['title', 'body']
    query = "INSERT INTO `entries` (#{columns.join(", ")}) VALUES (?, ?)"
    stmt = @db.prepare(query)
    stmt.execute(entry.title, entry.body)
    return @db.last_id
  end
  def fetch(id)
    query = "SELECT * FROM `entries` WHERE `id` = ?"
    stmt = @db.prepare(query)
    res = stmt.execute(id)

    data = res.first
    entry = Entry.new
    entry.title = data["title"]
    entry.body = data["body"]

    return entry
  end
  def each(&block)
    entries = []
    query = "SELECT * FROM `entries`"
    res = @db.query(query)
    res.each do |row|
      entry = Entry.new
      entry.title = row["title"]
      entry.body = row["body"]
      entries.push(entry)
    end
    return entries.each
  end
end
