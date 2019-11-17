class Dog

  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
    SQL
  
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end
  
  def save
    if self.id
        self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL
    
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
     self
    end
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def self.create(dog)
    new_dog = Dog.new(name: dog[:name], breed: dog[:breed])
    new_dog.save
  end  
  
  def self.new_from_db(dog)
      new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
  end
  
  def self.find_by_id(dog_id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    find_dog_by_id = DB[:conn].execute(sql, dog_id)[0]
    self.new_from_db(find_dog_by_id)
  end
  
  def self.find_or_create_by(dog)
      sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
      db_dog = DB[:conn].execute(sql, dog[:name], dog[:breed])[0]
      if db_dog 
        self.new_from_db(db_dog)
      else
        self.create(dog)
      end
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    find_dog_by_name = DB[:conn].execute(sql, name)[0]
    self.new_from_db(find_dog_by_name)
  end
  
  
end