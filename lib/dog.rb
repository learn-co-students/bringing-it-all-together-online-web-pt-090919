class Dog
  attr_accessor :id, :name, :breed
  
  def initialize(id:nil, name:, breed:)
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def save
    # Saves an instance of  dog class to the db and then 
    # sets the given dogs `id` attribute
    if self.id 
      self.update
    else 
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    # Returns an instance of the dog class
    self
  end
  
  # Takes in a hash of attributes and uses metaprogramming to create a new dog object
  # Then it uses the #save method to save that dog to the database
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  
  # creates an instance with corresponding attribute values
  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end
  
  # Returns a new dog object by id
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    new_dog = self.new(id: result[0], name: result[1], breed: result[2])
  end
  
  # Creates an instance of a dog if it doesn't already exist
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    # Find - create object but not save to db
    if !dog.empty? 
      dog_data = dog[0] #dog =  [[id, name, breed]]
      new_dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    # Create and save new song
    else 
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end
  
  # Return an instance of dog that matches the name from the DB
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs where name = ?"
    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result)
  end
end