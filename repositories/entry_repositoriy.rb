class EntryRepository
  def initialize
    @entries = []
    @entries.length - 1
  end
  def save(entry)
    @entries.push(entry)
  end
  def fetch(id)
    @entries[id]
  end
end
