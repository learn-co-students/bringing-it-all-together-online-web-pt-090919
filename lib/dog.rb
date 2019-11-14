class Dog
  
  attr_accessor :id, :name, :breed
  
  def initialize(hashdog)
    @name = hashdog[:name]
    @breed = hashdog[:breed]
    @id = hashdog[:id]
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
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    sql = <<-SQL
      SELECT id FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    @id = DB[:conn].execute(sql, self.name, self.breed)[0][0]
    self
  end
  
  def self.create(hashdog)
    dog = Dog.new(hashdog)
    dog.save
  end
  
  def self.new_from_db(row)
    hashdog = {
      id: row[0],
      name: row[1],
      breed: row[2]
    }
    Dog.new(hashdog)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    if row.empty?
      false
    else
      Dog.new_from_db(row)
    end
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    if row.empty?
      false
    else
      Dog.new_from_db(row)
    end
  end
  
  def self.find_or_create_by(hashdog)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql, hashdog[:name], hashdog[:breed])[0]
    if row
      Dog.new_from_db(row)
    else
      Dog.create(hashdog)
    end
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.id)
    self
  end
  
end