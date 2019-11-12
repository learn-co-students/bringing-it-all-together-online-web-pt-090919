require 'pry'
class Dog 
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog)
    @name = dog[:name]
    @breed = dog[:breed]
    @id = dog[:id]
  end  
  
  def self.create_table 
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT);
    SQL

    DB[:conn].execute(sql)
  end 

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end 

  def save 
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?);
    SQL

    dog = DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    
    self
  end 

  def self.create(dog)
    new_dog = self.new(dog)
    new_dog.save 
  end 

  def self.new_from_db(row)
    dog_attr = {id:row[0],name:row[1],breed:row[2]}
    new_dog = self.new(dog_attr)
    new_dog 
  end 

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ? 
    SQL

    dog = DB[:conn].execute(sql, id) 
    new_dog = self.new_from_db(dog.flatten) 
    new_dog 
  end 

  def self.find_or_create_by(dog)
    this_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", dog[:name], dog[:breed]).flatten
    if !this_dog.empty? 
      this_new_dog = self.new_from_db(this_dog)
    else 
      new_dog = self.create(dog)
    end 
  end 

  def self.find_by_name(name)
    named_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    dog = self.new_from_db(named_dog)
  end 

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 

end 